import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/utils/print_fn.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge.freezed.dart';

part 'merge.g.dart';

///Represents a [Commit] merge in memory
///[repository] is the current repository
///[branch] is the current branch
class Merge {
  final Repository repository;
  final Branch branch;

  Merge(this.repository, this.branch);
}

extension MergeStorage on Merge {
  ///Path to the merge file
  String get mergeFilePath => join(repository.repositoryPath, branchFolderName, branch.branchName, branchMergeFileName);

  ///[File] containing data to be merged
  File get mergeFile => File(mergeFilePath);

  ///[bool] to check if [mergeFile] exists
  ///Represents if a merge is in a pending state
  bool get hasPendingMerge => mergeFile.existsSync();

  ///Get pending merge data [MergeCommitMetaData] from [mergeFile]
  ///If the [mergeFile] doesn't exist, it will return null
  MergeCommitMetaData? get pendingMergeCommitMetaData {
    if (!hasPendingMerge) return null;

    String data = mergeFile.readAsStringSync();
    return MergeCommitMetaData.fromJson(jsonDecode(data));
  }

  ///Save [mergeData] to [mergeFile]
  MergeCommitMetaData saveCommitMergeData(MergeCommitMetaData mergeData) {
    mergeFile
      ..createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode(mergeData),
        flush: true,
        mode: FileMode.write,
      );
    return mergeData;
  }

  ///Deletes a [mergeFile]
  void deleteCommitMergeData() => mergeFile.deleteSync();
}

extension BranchMerge on Merge {

  ///Merges [otherBranch] to the current [branch]
  Future<StagingData?> mergeFromOtherBranchIntoThis({
    required Branch otherBranch,
    Function()? onSuccessfulMerge = onSuccessfulMerge,
    Function()? onPendingCommit = onPendingCommit,
    Function()? onPendingMerge = onPendingMerge,
    Function()? onSameBranchMerge = onSameBranchMerge,
    Function()? onRepositoryNotInitialized = onRepositoryNotInitialized,
    Function(Branch)? onNoOtherBranchMetaData = onNoCommitBranchMetaData,
    Function()? onNoCommit = onNoCommitsFound,
    Function(Commit)? onNoCommitBranchMetaData = onNoCommitBranchMetaData,
    Function(Commit)? onNoCommitMetaData = onNoCommitMetaData,
  }) async {
    //Ensure merging from repository
    if (!repository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return null;
    }

    Staging staging = branch.staging;
    if (staging.hasStagedFiles) {
      onPendingCommit?.call();
      return null;
    }

    //Do not create another merge
    if (hasPendingMerge) {
      onPendingMerge?.call();
      return null;
    }

    //Cannot merge from same branch
    if (otherBranch.branchName == branch.branchName) {
      onSameBranchMerge?.call();
      return null;
    }

    //Other branch data
    BranchTreeMetaData? otherBranchData = otherBranch.branchTreeMetaData;
    if (otherBranchData == null) {
      onNoOtherBranchMetaData?.call(branch);
      return null;
    }

    //Other branch commits
    List<CommitTreeMetaData> otherBranchCommits = otherBranchData.sortedBranchCommitsFromLatest;
    if (otherBranchCommits.isEmpty) {
      onNoCommit?.call();
      return null;
    }

    //This branch data
    //create new branch tree
    BranchTreeMetaData thisBranchData = branch.branchTreeMetaData ?? BranchTreeMetaData(name: branch.branchName, commits: HashMap());

    //List of commits to merge into current branch
    List<CommitTreeMetaData> commitsToMerge = [];
    CommitTreeMetaData? thisLatestBranchCommits = thisBranchData.latestBranchCommits;
    for (CommitTreeMetaData c in otherBranchCommits) {
      //Locate the common ancestor i.e.
      bool isMergeBase = c.sha == thisLatestBranchCommits?.sha;
      if (isMergeBase) {
        debugPrintToConsole(message: "Common ancestor is ${c.sha}");
        break;
      }

      //add to merge
      commitsToMerge.add(c);
    }

    //Cannot merge when there are no commits to merge
    if (commitsToMerge.isEmpty) {
      onNoCommit?.call();
      return null;
    }

    //Detect conflicts from latest commit (desired state to role model)
    commitsToMerge.sort((a, b) => -a.commitedAt.compareTo(b.commitedAt));
    CommitTreeMetaData latestCommit = commitsToMerge.first;
    List<RepoObjects> latestCommitObjects = latestCommit.commitedObjects.values
        .map((o) => o.fetchObject(repository))
        .where((o) => o != null)
        .map(
          (o) => RepoObjects(
            repository: repository,
            sha1: o!.sha1,
            relativePathToRepository: o.relativePathToRepository,
            commitedAt: o.commitedAt,
            blob: o.blob,
          ),
        )
        .toList();

    Map<String, RepoObjects> otherBranchObjectsMap = {
      for (var o in latestCommitObjects) o.relativePathToRepository: o,
    };

    //Start the actual merge
    //Generate patches (otherCommit + thisWorkingDir = merge)
    Directory workingDirectory = repository.workingDirectory;
    Directory patchesDirectory = _generatePatches(
      patternsToIgnore: repository.ignore.patternsToIgnore,
      workingDirectory: workingDirectory,
      otherBranchObjectsMap: otherBranchObjectsMap,
    );

    saveCommitMergeData(
      MergeCommitMetaData(
        fromBranchName: otherBranch.branchName,
        commitsToMerge: {for (var c in commitsToMerge) c.sha: c},
        mergedAt: DateTime.now(),
      ),
    );

    //Apply patches generated above
    List<File> mergedFiles = _applyPatches(
      patchesDirectory: patchesDirectory,
      workingDir: workingDirectory,
    );

    debugPrintToConsole(
      message: "Deleting ${patchesDirectory.path}",
    );

    patchesDirectory.deleteSync(recursive: true);

    //Stage files for commit
    debugPrintToConsole(
      message: "Staging ${mergedFiles.length} files for commit",
    );
    StagingData stagingData = staging.saveStagingData(
      StagingData(
        stagedAt: DateTime.now(),
        filesToBeStaged: mergedFiles.map((s) => relativePathFromDir(directoryPath: workingDirectory.path, path: s.path)).toList(),
      ),
    );

    return stagingData;
  }

  ///Generates temporary [Directory] with how the merge should look like
  Directory _generatePatches({
    required List<String> patternsToIgnore,
    required Directory workingDirectory,
    required Map<String, RepoObjects> otherBranchObjectsMap,
  }) {
    Directory patchDirectory = Directory.systemTemp.createTempSync();


    String repositoryParent = workingDirectory.path;
    List<File> workingBranchFiles =
        workingDirectory.listSync(recursive: true)
            .where((e) => e.statSync().type == FileSystemEntityType.file)
            .where((f) => !shouldIgnorePath(relativePathFromDir(path: f.path, directoryPath: repositoryParent), patternsToIgnore))
            .map((e) => File(e.path)).toList();

    printToConsole(
      message: "Generating ${workingBranchFiles.length} patches at Dir: ${patchDirectory.path}",
    );


    //Compare file by file
    int mergeFileCount = 0;
    for (File thisFile in workingBranchFiles) {
      mergeFileCount++;
      debugPrintToConsole(message: "File count $mergeFileCount");
      String thisFileName = basename(thisFile.path);
      bool conflict = false;
      // same -> Pick other
      // insert -> Fast Forward
      // delete -> pick mine
      // modify -> conflict [theirs] [mine]
      String thisRelativePathToRepository = relativePathFromDir(directoryPath: workingDirectory.path, path: thisFile.path);
      RepoObjects? otherFile = otherBranchObjectsMap[thisRelativePathToRepository];
      if (otherFile == null) {
        //Keep this

        String temporaryThisFilePath = fullPathFromDir(relativePath: thisRelativePathToRepository, directoryPath: patchDirectory.path);
        debugPrintToConsole(message: "Copying file from ${thisFile.path} to patch dir $temporaryThisFilePath");
        File(temporaryThisFilePath).createSync(recursive: true);
        File finalFile = thisFile.copySync(temporaryThisFilePath);

        printToConsole(
          message: "AUTO MERGING: ${basename(finalFile.path)}",
          color: CliColor.green,
        );
        continue;
      }

      //Compare line by line and write to file
      List<String> linesToWrite = [];

      String otherTempFilePath = fullPathFromDir(
        directoryPath: patchDirectory.path,
        relativePath: otherFile.relativePathToRepository,
      );

      File otherTempFile = File(otherTempFilePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(
          otherFile.blob,
          mode: FileMode.write,
          flush: true,
        );
      List<String> otherLines = otherTempFile.readAsLinesSync();
      int otherLength = otherLines.length;

      List<String> thisLines = thisFile.readAsLinesSync();
      int thisLength = thisLines.length;

      int maxLines = max(otherLength, thisLength);
      debugPrintToConsole(
        message: "Checking $maxLines lines for $thisFileName",
      );

      lineLoop:
      for (int line = 0; line < maxLines; line++) {
        if (line > otherLength - 1) {
          //out of bounds
          //keep this line
          linesToWrite.add(thisLines[line]);
        } else if (line > thisLength - 1) {
          //out of bounds
          //keep other line
          linesToWrite.add(otherLines[line]);
        } else {
          //Compare lines

          String otherLine = otherLines[line];
          String thisLine = thisLines[line];

          //int diffScore = await levenshteinDistance(otherLine, thisLine);
          bool divergence = otherLine != thisLine;


          if (!divergence) {
            //add either
            linesToWrite.add(otherLine);
            continue lineLoop;
          }

          debugPrintToConsole(
            message: "Lines $line has divergence",
          );

          //Merge conflict detected
          conflict = true;

          //include both
          linesToWrite.add("$otherLine >> @@other@@");
          linesToWrite.add("$thisLine >> @@this@@");
        }
      }

      if (!conflict) {
        printToConsole(
          message: "AUTO MERGING: $thisFileName",
          color: CliColor.cyan,
          style: CliStyle.bold,
        );

        String temporaryNewFilePath = fullPathFromDir(relativePath: thisRelativePathToRepository, directoryPath: patchDirectory.path);
        thisFile.copySync(temporaryNewFilePath);
        continue;
      }

      //Modify this file to show conflicts
      String temporaryNewFilePath = fullPathFromDir(relativePath: thisRelativePathToRepository, directoryPath: patchDirectory.path);
      File(temporaryNewFilePath)
        ..createSync(recursive: true)
        ..writeAsStringSync(
          linesToWrite.join("\n"),
          mode: FileMode.write,
          flush: true,
        );

      debugPrintToConsole(
        message: "CONFLICT: $thisFileName",
        color: CliColor.brightRed,
        style: CliStyle.bold,
      );
    }

    debugPrintToConsole(
      message: "Completed file comparison for $mergeFileCount files",
    );

    return patchDirectory;
  }

  /// Moves patch files stored in [patchesDirectory] to [workingDir]
  /// and returns all [File]s merged into working dir
  List<File> _applyPatches({
    required Directory patchesDirectory,
    required Directory workingDir,
  }) {
    printToConsole(
      message: "Applying patches from $patchesDirectory to $workingDir",
    );

    List<File> mergedFiles = [];
    patchesDirectory.listSync(recursive: true).where((e) => e.statSync().type == FileSystemEntityType.file).forEach((file) {
      String relativePath = relativePathFromDir(directoryPath: patchesDirectory.path, path: file.path);
      String newPath = fullPathFromDir(directoryPath: workingDir.path, relativePath: relativePath);
      File mergedFile = File(file.path).copySync(newPath);
      mergedFiles.add(mergedFile);
      debugPrintToConsole(message: "Copying to ${basename(file.path)} to $newPath");
    });

    printToConsole(
      message: "${mergedFiles.length} patches applied successfully to $workingDir",
    );

    return mergedFiles;
  }
}

///Entity to persist a [Merge]
@freezed
class MergeCommitMetaData with _$MergeCommitMetaData {
  factory MergeCommitMetaData({
    required String fromBranchName,
    required Map<String, CommitTreeMetaData> commitsToMerge,
    required DateTime mergedAt,
  }) = _MergeCommitMetaData;

  factory MergeCommitMetaData.fromJson(Map<String, Object?> json) => _$MergeCommitMetaDataFromJson(json);
}
