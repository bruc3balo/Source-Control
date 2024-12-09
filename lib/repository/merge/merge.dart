import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge.freezed.dart';

part 'merge.g.dart';

class Merge {
  final Repository repository;
  final Branch branch;

  Merge(this.repository, this.branch);
}

extension MergeStorage on Merge {
  ///Path to the merge file
  String get mergeFilePath => join(repository.repositoryPath, branch.branchName, branchMergeFileName);

  ///[File] containing data to be merged
  File get mergeFile => File(mergeFilePath);

  ///[bool] to check if [mergeFile] exists
  ///Represents if a merge is in a pending state
  bool get hasPendingMerge => mergeFile.existsSync();

  ///Get pending merge data [MergeMetaData] from [mergeFile]
  ///If the [mergeFile] doesn't exist, it will return null
  MergeMetaData? get pendingMergeData {
    if (!hasPendingMerge) return null;

    String data = mergeFile.readAsStringSync();
    return MergeMetaData.fromJson(jsonDecode(data));
  }

  ///Save [mergeData] to [mergeFile]
  void saveMergeData(MergeMetaData mergeData) {
    String data = jsonEncode(mergeData);
    mergeFile.writeAsStringSync(
      jsonEncode(data),
      flush: true,
      mode: FileMode.writeOnly,
    );
  }
}

extension BranchMerge on Merge {
  ///Merges [otherBranch] to the current [branch]
  Future<void> mergeFromOtherBranchIntoThis({
    required Branch otherBranch,
    Function()? onPendingCommit,
    Function()? onPendingMerge,
    Function()? onSameBranchMerge,
    Function()? onRepositoryNotInitialized,
    Function()? onNoOtherBranchMetaData,
    Function()? onNoCommit,
    Function()? onNoCommitBranchMetaData,
    Function()? onNoCommitMetaData,
  }) async {
    Staging staging = branch.staging;
    if (staging.isStaged) {
      onPendingCommit?.call();
      return;
    }

    //Do not create another merge
    if (hasPendingMerge) {
      onPendingMerge?.call();
      return;
    }

    //Ensure merging from repository
    if (!repository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return;
    }

    //Cannot merge from same branch
    if (otherBranch.branchName == branch.branchName) {
      onSameBranchMerge?.call();
      return;
    }

    //Other branch data
    BranchTreeMetaData? otherBranchData = otherBranch.branchTreeMetaData;
    if (otherBranchData == null) {
      onNoOtherBranchMetaData?.call();
      return;
    }

    //Other branch commits
    List<CommitMetaData> otherBranchCommits = otherBranchData.sortedBranchCommitsFromLatest;
    if (otherBranchCommits.isEmpty) {
      onNoCommit?.call();
      return;
    }

    //This branch data
    BranchTreeMetaData? thisBranchData = branch.branchTreeMetaData;

    //List of commits to merge into current branch
    List<CommitMetaData> commitsToMerge = [];

    if (thisBranchData != null) {
      CommitMetaData? thisLatestBranchCommits = thisBranchData.latestBranchCommits;
      for (CommitMetaData c in otherBranchCommits) {
        //Stop when commits meet
        if (c.sha == thisLatestBranchCommits?.sha) break;
        commitsToMerge.add(c);
      }
    } else {
      commitsToMerge.addAll(otherBranchCommits);
      await branch.createTreeMetaDataFile();
    }

    //The this branch data should be created at this point
    assert(thisBranchData != null);

    //Cannot merge when there are no commits to merge
    if (commitsToMerge.isEmpty) {
      onNoCommit?.call();
      return;
    }

    //Start the actual merge
    MergeMetaData mergeData = MergeMetaData(
      fromBranchName: otherBranch.branchName,
      commitsToMerge: {for (var c in commitsToMerge) c.sha: c},
      mergedAt: DateTime.now(),
    );

    saveMergeData(mergeData);

    //Detect conflicts from latest commit
    commitsToMerge.sort((a, b) => -a.commitedAt.compareTo(b.commitedAt));
    CommitMetaData latestCommit = commitsToMerge.first;

    latestCommit.commitedObjects.values
        .map(
          (o) {
            return o.fetchObject(repository);
          },
        )
        .where((o) => o != null)
        .map(
          (o) => RepoObjects(
            repository: repository,
            sha1: o!.sha1,
            relativePathToRepository: o.relativePathToRepository,
            commitedAt: o.commitedAt,
            blob: o.blob,
          ),
        );

    /*Commit otherCommit = Commit(
      Sha1(commitMetaData.sha),
      otherBranch,
      commitMetaData.message,
      {},
      commitMetaData.commitedAt,
    );
    List<File> otherCommitFiles = otherCommit.getCommitFiles(
      onNoCommitMetaData: onNoCommitMetaData,
      onNoCommitBranchMetaData: onNoCommitBranchMetaData,
    ) ??
        [];

    //Get all files from this current working branch
    Directory workingBranchDir = repository.workingDirectory;
    List<File> workingBranchFiles =
    workingBranchDir.listSync(recursive: true).where((e) =>
    e
        .statSync()
        .type == FileSystemEntityType.file).map((e) => File(e.path)).toList();

    //Get other branch files map
    String otherBranchPrefix = join(
      otherBranch.branchDirectoryPath,
      branchCommitFolder,
      otherCommit.sha.hash,
    );
    Map<String, File> otherBranchFilesMap = {for (var f in otherCommitFiles) f.path.replaceAll(otherBranchPrefix, ""): f};

    //Get this branch files map
    String workingBranchPrefix = workingBranchDir.path;
    Map<String, File> workingBranchFilesMap = {for (var f in workingBranchFiles) f.path.replaceAll(workingBranchPrefix, ""): f};

    HashSet<String> filePaths = HashSet.of(otherBranchFilesMap.keys);

    List<File> mergeResult = await _doMerge(
      filePaths: filePaths,
      workingBranchFilesMap: workingBranchFilesMap,
      otherBranchFilesMap: otherBranchFilesMap,
    );

    await _addMergedFilesToWorkingDir(
      otherBranchPath: otherBranchPrefix,
      workingDirPath: workingBranchPrefix,
      mergeResult: mergeResult,
    );*/
  }

  Future<void> _addMergedFilesToWorkingDir({
    required String otherBranchPath,
    required String workingDirPath,
    required List<File> mergeResult,
  }) async {
    debugPrintToConsole(
      message: "Merging ${mergeResult.length} files to $workingDirPath",
    );

    for (File file in mergeResult) {
      String path = file.path;
      String prefixPath = path.startsWith(otherBranchPath) ? otherBranchPath : workingDirPath;
      String newPath = file.path.replaceAll(prefixPath, workingDirPath);
      file.copySync(newPath);

      debugPrintToConsole(
        message: "Copying to ${basename(newPath)} to $newPath",
      );
    }

    debugPrintToConsole(
      message: "Done merging ${mergeResult.length} files to $workingDirPath",
    );
  }

  Future<List<File>> _doMerge({
    required HashSet<String> filePaths,
    required Map<String, File> workingBranchFilesMap,
    required Map<String, File> otherBranchFilesMap,
  }) async {
    debugPrintToConsole(
      message: "Starting file comparison for ${filePaths.length} files",
    );

    List<File> mergeResult = [];

    //Compare file by file
    for (String key in filePaths) {
      bool conflict = false;
      // same -> Pick other
      // insert -> Fast Forward
      // delete -> pick mine
      // modify -> conflict [theirs] [mine]
      File? otherFile = otherBranchFilesMap[key];
      File? thisFile = workingBranchFilesMap[key];

      if (otherFile == null) {
        //Keep this
        mergeResult.add(thisFile!);
        debugPrintToConsole(
          message: "Auto merging for ${basename(thisFile.path)}",
          color: CliColor.defaultColor,
        );
        continue;
      } else if (thisFile == null) {
        //Keep other
        mergeResult.add(otherFile);
        debugPrintToConsole(
          message: "Auto merging for ${basename(otherFile.path)}",
          color: CliColor.defaultColor,
        );
        continue;
      } else {
        //Compare line by line and write to file
        List<String> linesToWrite = [];

        List<String> otherLines = otherFile.readAsLinesSync();
        int otherLength = otherLines.length;

        List<String> thisLines = thisFile.readAsLinesSync();
        int thisLength = thisLines.length;

        int maxLines = max(otherLength, thisLength);
        debugPrintToConsole(
          message: "Checking $maxLines lines for $key",
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
            int diffScore = otherLine.length.compareTo(thisLine.length);
            debugPrintToConsole(
              message: "Lines $line compares $diffScore",
            );

            if (diffScore == 0) {
              //add either
              linesToWrite.add(otherLine);
              continue lineLoop;
            }

            //Merge conflict detected
            conflict = true;

            //include both
            linesToWrite.add("$otherLine >> @@other@@");
            linesToWrite.add("$thisLine >> @@this@@");
          }
        }

        //Modify this file to show conflicts
        if (conflict) {
          thisFile.writeAsStringSync(
            linesToWrite.join("\n"),
            mode: FileMode.write,
            flush: true,
          );

          debugPrintToConsole(
            message: "CONFLICT for ${basename(thisFile.path)}",
            color: CliColor.brightRed,
            style: CliStyle.bold,
          );
        } else {
          debugPrintToConsole(
            message: "Auto merging for ${basename(otherFile.path)}",
            color: CliColor.brightRed,
            style: CliStyle.bold,
          );
        }

        mergeResult.add(thisFile);
      }
    }

    debugPrintToConsole(
      message: "Completed file comparison for ${mergeResult.length} files",
    );

    return mergeResult;
  }
}

///MergeMetaData
@freezed
class MergeMetaData with _$MergeMetaData {
  factory MergeMetaData({
    required String fromBranchName,
    required Map<String, CommitMetaData> commitsToMerge,
    required DateTime mergedAt,
  }) = _MergeMetaData;

  factory MergeMetaData.fromJson(Map<String, Object?> json) => _$MergeMetaDataFromJson(json);
}
