import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/diff/diff.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:dart_levenshtein/dart_levenshtein.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'branch.freezed.dart';

part 'branch.g.dart';

class Branch {
  final Repository repository;
  final String branchName;

  Branch(this.branchName, this.repository);
}

extension BranchCreation on Branch {
  Future<void> createBranch({
    bool Function(String name)? isValidBranchName,
    Function(String name)? onInvalidBranchName,
    Function()? onBranchAlreadyExists,
    Function()? onRepositoryNotInitialized,
    Function(Directory)? onBranchCreated,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      bool valid = isValidBranchName?.call(branchName) ?? true;
      if (!valid) {
        onInvalidBranchName?.call(branchName);
        return;
      }

      bool branchExists = branchDirectory.existsSync();
      if (branchExists) {
        onBranchAlreadyExists?.call();
        return;
      }

      branchDirectory.createSync(
        recursive: true,
      );

      createMetaDataFile();

      onBranchCreated?.call(branchDirectory);
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> checkoutToBranch({
    Function()? onSameBranch,
    Function()? onBranchMetaDataDoesntExists,
    Function()? onStateDoesntExists,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!branchMetaDataExists) {
        await createBranch(
          onFileSystemException: (e) => debugPrintToConsole(
            message: e.message,
            color: CliColor.red,
          ),
          onRepositoryNotInitialized: () => debugPrintToConsole(
            message: "Repository not initialized",
          ),
          onBranchAlreadyExists: () => debugPrintToConsole(
            message: "Branch exists",
          ),
          onInvalidBranchName: (s) => printToConsole(
            message: "Invalid branch name $s",
          ),
          onBranchCreated: (d) => debugPrintToConsole(
            message: "Branch has been created on ${d.path}",
          ),
        );
      }

      State state = State(repository);
      StateData? stateData = state.stateInfo;

      if (stateData == null) {
        onStateDoesntExists?.call();
        return;
      }

      if (branchName == stateData.currentBranch) {
        onSameBranch?.call();
        return;
      }

      stateData = stateData.copyWith(currentBranch: branchName);

      BranchMetaData? branchData = branchMetaData;
      if (branchData == null) {
        onBranchMetaDataDoesntExists?.call();
        return;
      }

      if (branchData.commits.isNotEmpty) {
        List<CommitMetaData> allBranchCommits = branchData.sortedBranchCommits;
        CommitMetaData commitMetaData = allBranchCommits.first;
        String latestCommitDirPath =
            join(branchDirectoryPath, branchCommitFolder, commitMetaData.sha);
        Directory latestCommitDir = Directory(latestCommitDirPath);

        List<File> files = latestCommitDir
            .listSync(recursive: true)
            .where((e) => e.statSync().type == FileSystemEntityType.file)
            .map((e) => File(e.path))
            .toList();

        moveFiles(
          files: files,
          destinationDir: repository.repositoryDirectory.parent,
          sourceDir: latestCommitDir,
        );
      }

      state.saveStateData(
        stateData: stateData,
        onFileSystemException: (e) => debugPrintToConsole(
          message: e.message,
          color: CliColor.red,
        ),
        onRepositoryNotInitialized: () => debugPrintToConsole(
          message: "Repository not initialized",
        ),
        onSuccessfullySaved: () => debugPrintToConsole(
          message: "State saved",
        ),
      );
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> deleteBranch({
    Function()? onBranchDoesntExist,
    Function()? onBranchDeleted,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      if (!branchDirectory.existsSync()) {
        onBranchDoesntExist?.call();
        return;
      }

      branchDirectory.deleteSync(recursive: true);
      onBranchDeleted?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}

extension BranchCommons on Branch {
  String get branchDirectoryPath => joinAll(
        [
          repository.repositoryDirectory.path,
          branchFolderName,
          branchName,
        ],
      );

  Directory get branchDirectory => Directory(branchDirectoryPath);

  Staging get staging => Staging(this);
}

extension BranchMetaDataStorage on Branch {
  String get managerPath => join(branchDirectoryPath, branchMetaDataFileName);

  File get managerFile => File(managerPath);

  bool get branchMetaDataExists => managerFile.existsSync();

  BranchMetaData? get branchMetaData {
    if (!branchMetaDataExists) return null;

    String fileData = managerFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> json = jsonDecode(fileData);
    return BranchMetaData.fromJson(json);
  }

  Future<void> createMetaDataFile({
    Function()? onDuplicateFile,
    Function()? onCreateFile,
  }) async {
    if (branchMetaDataExists) {
      onDuplicateFile?.call();
      return;
    }

    managerFile.createSync(recursive: true);
    managerFile.writeAsStringSync(
        jsonEncode(BranchMetaData(name: branchName, commits: HashMap())));

    onCreateFile?.call();
  }

  void saveBranchMetaData(BranchMetaData metaData) {
    if (!branchMetaDataExists) createMetaDataFile();

    managerFile.writeAsStringSync(
      jsonEncode(metaData.toJson()),
      flush: true,
    );
  }
}

extension BranchManager on Branch {
  Future<void> addCommit({
    required Commit commit,
    Function()? onMissingManager,
    Function(CommitMetaData)? onCommitCreated,
    Function()? onNoMetaData,
  }) async {
    if (!branchMetaDataExists) {
      onMissingManager?.call();
      return;
    }

    BranchMetaData? metaData = branchMetaData;
    if (metaData == null) {
      onNoMetaData?.call();
      return;
    }

    CommitMetaData commitMetaData = CommitMetaData(
      sha: commit.sha,
      message: commit.message,
      commitedAt: commit.commitedAt,
    );

    final mutableCommits = Map<String, CommitMetaData>.from(metaData.commits);
    mutableCommits.putIfAbsent(commitMetaData.sha, () => commitMetaData);
    metaData = metaData.copyWith(commits: mutableCommits);

    saveBranchMetaData(metaData);

    onCommitCreated?.call(commitMetaData);
  }
}

extension BranchMerge on Branch {
  Future<void> mergeFromOtherBranchIntoThis({
    required Branch otherBranch,
    Function()? onSameBranchMerge,
    Function()? onRepositoryNotInitialized,
    Function()? onNoOtherBranchMetaData,
    Function()? onNoCommit,
  }) async {
    //Ensure merging from repository
    if (!repository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return;
    }

    if(otherBranch == this) {
      onSameBranchMerge?.call();
      return;
    }

    //Get all files from otherBranch latest commit
    BranchMetaData? otherBranchData = otherBranch.branchMetaData;
    if (otherBranchData == null) {
      onNoOtherBranchMetaData?.call();
      return;
    }

    CommitMetaData? commitMetaData =
        otherBranchData.sortedBranchCommits.firstOrNull;

    if (commitMetaData == null) {
      onNoCommit?.call();
      return;
    }
    Commit otherCommit = Commit(
      commitMetaData.sha,
      otherBranch,
      commitMetaData.message,
      commitMetaData.commitedAt,
    );
    List<File> otherCommitFiles = otherCommit.getCommitFiles() ?? [];

    //Get all files from this current working branch
    Directory workingBranchDir = repository.repositoryDirectory.parent;
    List<File> workingBranchFiles = workingBranchDir
        .listSync(recursive: true)
        .where((e) => e.statSync().type == FileSystemEntityType.file)
        .map((e) => File(e.path))
        .toList();

    //Get other branch files map
    String otherBranchPrefix = join(
      otherBranch.branchDirectoryPath,
      branchCommitFolder,
      otherCommit.sha,
    );
    Map<String, File> otherBranchFilesMap = {
      for (var f in otherCommitFiles)
        f.path.replaceAll(otherBranchPrefix, ""): f
    };

    //Get this branch files map
    String workingBranchPrefix = workingBranchDir.path;
    Map<String, File> workingBranchFilesMap = {
      for (var f in workingBranchFiles)
        f.path.replaceAll(workingBranchPrefix, ""): f
    };

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
    );
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
      String prefixPath =
          path.startsWith(otherBranchPath) ? otherBranchPath : workingDirPath;
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

@freezed
class BranchMetaData with _$BranchMetaData {
  factory BranchMetaData({
    required String name,
    required Map<String, CommitMetaData> commits,
  }) = _BranchMetaData;

  factory BranchMetaData.fromJson(Map<String, Object?> json) =>
      _$BranchMetaDataFromJson(json);
}

extension BranchMetaDataX on BranchMetaData {
  List<CommitMetaData> get sortedBranchCommits => commits.values.toList()
    ..sort(
      (a, b) => -a.commitedAt.compareTo(b.commitedAt),
    );
}

@freezed
class CommitMetaData with _$CommitMetaData {
  factory CommitMetaData({
    required String sha,
    required String message,
    required DateTime commitedAt,
  }) = _CommitMetaData;

  factory CommitMetaData.fromJson(Map<String, Object?> json) =>
      _$CommitMetaDataFromJson(json);
}
