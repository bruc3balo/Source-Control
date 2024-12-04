import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
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
      if (!exists) {
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

      CommitMetaData? commitMetaData = branchData.commits.values.firstOrNull;
      if (commitMetaData != null) {
        String latestCommitDirPath =
            join(branchDirectoryPath, commitMetaData.sha);
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
        onFileSystemException: (e) =>
            debugPrintToConsole(message: e.message, color: CliColor.red),
        onRepositoryNotInitialized: () =>
            debugPrintToConsole(message: "Repository not initialized"),
        onSuccessfullySaved: () => debugPrintToConsole(message: "State saved"),
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

  bool get exists => managerFile.existsSync();

  BranchMetaData? get branchMetaData {
    if (!exists) return null;

    String fileData = managerFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> json = jsonDecode(fileData);
    return BranchMetaData.fromJson(json);
  }

  Future<void> createMetaDataFile({
    Function()? onDuplicateFile,
    Function()? onCreateFile,
  }) async {
    if (exists) {
      onDuplicateFile?.call();
      return;
    }

    managerFile.createSync(recursive: true);
    managerFile.writeAsStringSync(
        jsonEncode(BranchMetaData(name: branchName, commits: HashMap())));

    onCreateFile?.call();
  }

  void saveBranchMetaData(BranchMetaData metaData) {
    if (!exists) createMetaDataFile();

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
    if (!exists) {
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

@freezed
class BranchMetaData with _$BranchMetaData {
  factory BranchMetaData({
    required String name,
    required Map<String, CommitMetaData> commits,
  }) = _BranchMetaData;

  factory BranchMetaData.fromJson(Map<String, Object?> json) =>
      _$BranchMetaDataFromJson(json);
}

@freezed
class CommitMetaData with _$CommitMetaData {
  factory CommitMetaData(
      {required String sha,
      required String message,
      required DateTime commitedAt}) = _CommitMetaData;

  factory CommitMetaData.fromJson(Map<String, Object?> json) =>
      _$CommitMetaDataFromJson(json);
}
