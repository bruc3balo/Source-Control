import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/merge/merge.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/print_fn.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'branch.freezed.dart';

part 'branch.g.dart';

///Named reference to a [Commit]
///Represents a branch in memory
class Branch {
  final Repository repository;
  final String branchName;

  Branch(this.branchName, this.repository);
}

///State of a file in a [GetStatusOfCurrentBranch] command
enum BranchFileStatus { staged, untracked, unstaged }

extension BranchStatus on Branch {
  ///List stages and unstaged files in a working directory on a local [Repository]
  Map<BranchFileStatus, HashSet<String>> getBranchStatus() {
    final Map<BranchFileStatus, HashSet<String>> fileStatus = {};

    //WorkingDirFiles
    List<FileSystemEntity> workingDirFiles =
        repository.workingDirectory.listSync(recursive: true).where((e) => e.statSync().type == FileSystemEntityType.file).toList();

    //Staged files
    HashSet<String> stagedPaths = HashSet.of(staging.stagingData?.filesToBeStaged ?? []);

    //Commited files i.e. tracking
    HashSet<String> trackedFiles = HashSet.of(
      branchTreeMetaData?.latestBranchCommits?.commitedObjects.values.map((e) => e.filePathRelativeToRepository) ?? [],
    );

    //FileSystemEntity
    String directoryPath = repository.workingDirectory.path;
    for (FileSystemEntity f in workingDirFiles) {
      BranchFileStatus branchStatus = stagedPaths.contains(f.path)
          ? BranchFileStatus.staged
          : trackedFiles.contains(relativePathFromDir(directoryPath: directoryPath, path: f.path))
              ? BranchFileStatus.unstaged
              : BranchFileStatus.untracked;
      fileStatus.update(branchStatus, (l) => l..add(f.path), ifAbsent: () => HashSet()..add(f.path));
    }

    return fileStatus;
  }
}

extension BranchCreation on Branch {
  ///Create a new [Branch] on a local [Repository]
  void createBranch({
    bool Function(String name)? isValidBranchName,
    Function(String name)? onInvalidBranchName,
    Function()? onBranchAlreadyExists = onBranchAlreadyExists,
    Function()? onRepositoryNotInitialized = onRepositoryNotInitialized,
    Function(Directory)? onBranchCreated = onBranchCreated,
  }) {
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

    saveBranchTreeMetaData(BranchTreeMetaData(name: branchName, commits: HashMap()));

    onBranchCreated?.call(branchDirectory);
  }

  ///Checkout to new [Branch] on a local [Repository]
  ///If the [Branch] doesn't exist, it will create a new [Branch] and copy the [File]s from the exising branch to the current one
  void checkoutToBranch({
    String? commitSha,
    Function()? onNoCommitFound,
    Function()? onSameCommit,
    Function()? onBranchMetaDataDoesntExists,
    Function()? onStateDoesntExists,
    Function()? onRepositoryNotInitialized,
  }) {
    if (!branchTreeMetaDataExists) createBranch(isValidBranchName: isValidBranchName);

    State state = State(repository);

    StateData? stateData = state.stateInfo;
    if (stateData == null) {
      onStateDoesntExists?.call();
      return;
    }

    StateData updatedStateData = stateData;

    BranchTreeMetaData? branchData = branchTreeMetaData;
    if (branchData == null) {
      onBranchMetaDataDoesntExists?.call();
      return;
    }

    //Change branch
    updatedStateData = updatedStateData.copyWith(currentBranch: branchName);

    //Change commit
    CommitTreeMetaData? commitMetaData = commitSha != null ? branchData.commits[commitSha.trim()] : branchData.latestBranchCommits;
    if (commitSha != null && commitMetaData == null) {
      onNoCommitFound?.call();
      return;
    }

    //Update commit pointer
    updatedStateData = updatedStateData.copyWith(currentCommit: commitMetaData?.sha);
    if (updatedStateData == stateData) {
      onSameCommit?.call();
      return;
    }

    //Move files from latest commit to current working dir
    if (commitMetaData != null) {
      _writeFilesToWorkingDir(
        objects: commitMetaData.commitedObjects.values.toList(),
        workingDir: repository.workingDirectory,
      );
    }

    state.saveStateData(
      stateData: updatedStateData,
      onSuccessfullySaved: () => debugPrintToConsole(
        message: "State saved",
      ),
    );
  }

  ///Write [objects] to working directory
  void _writeFilesToWorkingDir({
    required List<RepoObjectsData> objects,
    required Directory workingDir,
  }) {
    printToConsole(message: "copying ${objects.length} files to ${workingDir.path}");
    for (RepoObjectsData o in objects) {
      RepoObjects? repoObject = o.fetchObject(repository);
      if (repoObject == null) continue;

      String fileDestinationPath = fullPathFromDir(
        relativePath: o.filePathRelativeToRepository,
        directoryPath: workingDir.path,
      );
      debugPrintToConsole(message: "File is at destination $fileDestinationPath");

      File(fileDestinationPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(
          repoObject.blob,
          mode: FileMode.write,
          flush: true,
        );

      debugPrintToConsole(message: "cp ${repoObject.objectFilePath} -> $fileDestinationPath");
    }
  }

  ///Delete a [Branch] from a local [Repository]
  ///It doesn't delete the [RepoObjects]
  void deleteBranch({
    Function()? onBranchDoesntExist,
    Function()? onBranchDeleted,
    Function()? onRepositoryNotInitialized = onRepositoryNotInitialized,
  }) {
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
  }
}

extension BranchCommons on Branch {
  ///Path of the branch with the [branchName] in a [Repository]
  String get branchDirectoryPath => join(repository.repositoryDirectory.path, branchFolderName, branchName);

  ///[Directory] of the [branchDirectoryPath]
  Directory get branchDirectory => Directory(branchDirectoryPath);

  ///[Staging] file in a [Branch]
  Staging get staging => Staging(this);

  ///[Merge] file in a [Branch]
  Merge get merge => Merge(repository, this);
}

extension BranchTreeMetaDataStorage on Branch {
  ///Path to [BranchTreeMetaData] file in a [Branch]
  String get branchTreeFilePath => join(branchDirectoryPath, branchTreeMetaDataFileName);

  ///Actual [File] of the [BranchTreeMetaData] of a [Branch]
  File get managerFile => File(branchTreeFilePath);

  /// Check if [managerFile] exists
  bool get branchTreeMetaDataExists => managerFile.existsSync();

  /// Returns a [BranchTreeMetaData] for the current [Branch]
  /// If the file is not found it returns null
  BranchTreeMetaData? get branchTreeMetaData {
    if (!branchTreeMetaDataExists) return null;

    String fileData = managerFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> json = jsonDecode(fileData);
    return BranchTreeMetaData.fromJson(json);
  }

  /// Creates a [BranchTreeMetaData] only if it doesn't exist
  ///Update a [managerFile] with the latest [metaData]
  BranchTreeMetaData saveBranchTreeMetaData(BranchTreeMetaData metaData) {
    managerFile
      ..createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode(metaData.toJson()),
        mode: FileMode.write,
        flush: true,
      );
    return metaData;
  }
}

extension BranchManager on Branch {
  ///Adds a [commit] to a [managerFile] and performs
  void addCommit({
    required Commit commit,
    Function()? onMissingManager,
    Function(CommitTreeMetaData)? onCommitCreated,
    Function()? onNoMetaData,
  }) {
    if (!branchTreeMetaDataExists) {
      onMissingManager?.call();
      return;
    }

    BranchTreeMetaData? metaData = branchTreeMetaData;
    if (metaData == null) {
      onNoMetaData?.call();
      return;
    }

    CommitTreeMetaData commitMetaData = CommitTreeMetaData(
      originalBranch: branchName,
      sha: commit.sha.hash,
      message: commit.message,
      commitedObjects: commit.objects,
      commitedAt: commit.commitedAt,
    );

    final mutableCommits = Map<String, CommitTreeMetaData>.from(metaData.commits);
    mutableCommits.putIfAbsent(commitMetaData.sha, () => commitMetaData);
    metaData = metaData.copyWith(commits: mutableCommits);

    saveBranchTreeMetaData(metaData);

    onCommitCreated?.call(commitMetaData);
  }
}

/// Entity of a [Branch] tree
@freezed
class BranchTreeMetaData with _$BranchTreeMetaData {
  factory BranchTreeMetaData({
    required String name,
    required Map<String, CommitTreeMetaData> commits,
  }) = _BranchMetaData;

  factory BranchTreeMetaData.fromJson(Map<String, Object?> json) => _$BranchTreeMetaDataFromJson(json);
}

extension BranchMetaDataX on BranchTreeMetaData {
  ///Returns a list of [CommitTreeMetaData] in descending order
  List<CommitTreeMetaData> get sortedBranchCommitsFromLatest => commits.values.toList()
    ..sort(
      (a, b) => -a.commitedAt.compareTo(b.commitedAt),
    );

  ///Returns latest [CommitTreeMetaData] in a [Branch]
  CommitTreeMetaData? get latestBranchCommits => sortedBranchCommitsFromLatest.firstOrNull;
}

/// Entity of a [Commit] tree
@freezed
class CommitTreeMetaData with _$CommitTreeMetaData {
  factory CommitTreeMetaData({
    required String originalBranch,
    required String sha,
    required String message,
    required Map<String, RepoObjectsData> commitedObjects,
    required DateTime commitedAt,
  }) = _CommitTreeMetaData;

  factory CommitTreeMetaData.fromJson(Map<String, Object?> json) => _$CommitTreeMetaDataFromJson(json);
}
