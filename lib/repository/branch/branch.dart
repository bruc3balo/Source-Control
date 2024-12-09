import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:balo/repository/commit.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'branch.freezed.dart';

part 'branch.g.dart';

///Named reference to a [Commit]
class Branch {
  final Repository repository;
  final String branchName;

  Branch(this.branchName, this.repository);
}

///State of a file status
enum BranchFileStatus { staged, unstaged }

extension BranchStatus on Branch {
  ///List stages and unstaged files in a working directory on a local [Repository]
  Map<BranchFileStatus, HashSet<String>> getBranchStatus() {
    final Map<BranchFileStatus, HashSet<String>> fileStatus = {};

    //WorkingDirFiles
    List<FileSystemEntity> workingDirFiles =
        repository.workingDirectory.listSync(recursive: true).where((e) => e.statSync().type == FileSystemEntityType.file).toList();

    //Staged files
    HashSet<String> stagedPaths = HashSet.of(staging.stagingData?.filesToBeStaged ?? []);

    //FileSystemEntity
    for (FileSystemEntity f in workingDirFiles) {
      BranchFileStatus branchStatus = stagedPaths.contains(f.path) ? BranchFileStatus.staged : BranchFileStatus.unstaged;
      fileStatus.update(branchStatus, (l) => l..add(f.path), ifAbsent: () => HashSet()..add(f.path));
    }

    return fileStatus;
  }
}

extension BranchCreation on Branch {

  ///Create a new [Branch] on a local [Repository]
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

      createTreeMetaDataFile();

      onBranchCreated?.call(branchDirectory);
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  ///Checkout to new [Branch] on a local [Repository]
  ///If the [Branch] doesn't exist, it will create a new [Branch] and copy the [File]s from the exising branch to the current one
  Future<void> checkoutToBranch({
    String? commitSha,
    Function()? onNoCommitFound,
    Function()? onSameCommit,
    Function()? onBranchMetaDataDoesntExists,
    Function()? onStateDoesntExists,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!branchTreeMetaDataExists) {
        await createBranch(
          isValidBranchName: isValidBranchName,
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

      StateData updatedStateData = stateData;

      BranchTreeMetaData? branchData = branchTreeMetaData;
      if (branchData == null) {
        onBranchMetaDataDoesntExists?.call();
        return;
      }

      //Change branch
      updatedStateData = updatedStateData.copyWith(currentBranch: branchName);

      //Change commit
      CommitMetaData? commitMetaData = commitSha != null ? branchData.commits[commitSha.trim()] : branchData.latestBranchCommits;
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
        _copyFilesToWorkingDir(
          objects: commitMetaData.commitedObjects.values.toList(),
          workingDir: repository.workingDirectory,
        );
      }

      await state.saveStateData(
        stateData: updatedStateData,
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
      debugPrintToConsole(message: trace.toString(), color: CliColor.red);
      onFileSystemException?.call(e);
    }
  }

  
  
  void _copyFilesToWorkingDir({
    required List<RepoObjectsData> objects,
    required Directory workingDir,
  }) {
    printToConsole(message: "copying ${objects.length} files to ${workingDir.path}");
    for (RepoObjectsData o in objects) {
      RepoObjects? repoObject = o.fetchObject(repository);
      if (repoObject == null) continue;

      String fileDestinationPath = join(workingDir.path, o.filePathRelativeToRepository.replaceFirst(Platform.pathSeparator, ""));
      debugPrintToConsole(message: "File is at destination ${fileDestinationPath}");

      File(fileDestinationPath).writeAsBytesSync(
        repoObject.blob,
        mode: FileMode.writeOnly,
        flush: true,
      );

      debugPrintToConsole(message: "cp ${repoObject.objectFilePath} -> $fileDestinationPath");
    }
  }

  ///Delete a [Branch] from a local [Repository] 
  ///It doesn't delete the [RepoObjects]
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
  
  ///Path of the branch with the [branchName] in a [Repository]
  String get branchDirectoryPath => join(repository.repositoryDirectory.path, branchFolderName, branchName);

  ///[Directory] of the [branchDirectoryPath]
  Directory get branchDirectory => Directory(branchDirectoryPath);

  ///[Staging] file in a [Branch]
  Staging get staging => Staging(this);
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
  /// If it exists it will call [onDuplicateFile] and when created 
  Future<void> createTreeMetaDataFile({
    Function()? onDuplicateFile,
    Function()? onCreateFile,
  }) async {
    if (branchTreeMetaDataExists) {
      onDuplicateFile?.call();
      return;
    }

    managerFile.createSync(recursive: true);

    managerFile.writeAsStringSync(
      jsonEncode(BranchTreeMetaData(name: branchName, commits: HashMap())),
      mode: FileMode.writeOnly,
      flush: true,
    );

    onCreateFile?.call();
  }

  ///Update a [managerFile] with the latest [metaData]
  void saveBranchTreeMetaData(BranchTreeMetaData metaData) {
    if (!branchTreeMetaDataExists) createTreeMetaDataFile();

    managerFile.writeAsStringSync(
      jsonEncode(metaData.toJson()),
      flush: true,
    );
  }
}

extension BranchManager on Branch {
  
  ///Adds a [commit] to a [managerFile] and performs
  Future<void> addCommit({
    required Commit commit,
    Function()? onMissingManager,
    Function(CommitMetaData)? onCommitCreated,
    Function()? onNoMetaData,
  }) async {
    if (!branchTreeMetaDataExists) {
      onMissingManager?.call();
      return;
    }

    BranchTreeMetaData? metaData = branchTreeMetaData;
    if (metaData == null) {
      onNoMetaData?.call();
      return;
    }

    CommitMetaData commitMetaData = CommitMetaData(
      sha: commit.sha.hash,
      message: commit.message,
      commitedObjects: commit.objects,
      commitedAt: commit.commitedAt,
    );

    final mutableCommits = Map<String, CommitMetaData>.from(metaData.commits);
    mutableCommits.putIfAbsent(commitMetaData.sha, () => commitMetaData);
    metaData = metaData.copyWith(commits: mutableCommits);

    saveBranchTreeMetaData(metaData);

    onCommitCreated?.call(commitMetaData);
  }
}



///BranchTreeMetaData
@freezed
class BranchTreeMetaData with _$BranchTreeMetaData {
  factory BranchTreeMetaData({
    required String name,
    required Map<String, CommitMetaData> commits,
  }) = _BranchMetaData;

  factory BranchTreeMetaData.fromJson(Map<String, Object?> json) => _$BranchTreeMetaDataFromJson(json);
}

extension BranchMetaDataX on BranchTreeMetaData {
  List<CommitMetaData> get sortedBranchCommitsFromLatest => commits.values.toList()
    ..sort(
      (a, b) => -a.commitedAt.compareTo(b.commitedAt),
    );

  CommitMetaData? get latestBranchCommits => sortedBranchCommitsFromLatest.firstOrNull;
}

///CommitMetaData
@freezed
class CommitMetaData with _$CommitMetaData {
  factory CommitMetaData({
    required String sha,
    required String message,
    required Map<String, RepoObjectsData> commitedObjects,
    required DateTime commitedAt,
  }) = _CommitMetaData;

  factory CommitMetaData.fromJson(Map<String, Object?> json) => _$CommitMetaDataFromJson(json);
}
