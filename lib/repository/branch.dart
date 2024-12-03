import 'dart:convert';
import 'dart:io';

import 'package:balo/repository/commit.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

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

      await branchDirectory.create(
        recursive: true,
      );

      onBranchCreated?.call(branchDirectory);
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

extension BranchManager on Branch {
  String get managerPath => join(branchDirectoryPath, branchMetaData);

  File get managerFile => File(managerPath);

  bool get exists => managerFile.existsSync();

  BranchMetaData? get branchMetaDataFromManagerFile {
    if (!exists) return null;

    String fileData = managerFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> json = jsonDecode(fileData);
    return BranchMetaData.fromJson(json);
  }

  void saveBranchMetaData(BranchMetaData metaData) {
    if (!exists) createManagerFile();

    managerFile.writeAsStringSync(
      jsonEncode(metaData.toJson()),
      flush: true,
    );
  }


  Future<void> createManagerFile({
    Function()? onDuplicateFile,
    Function()? onCreateFile,
  }) async {
    if (exists) {
      onDuplicateFile?.call();
      return;
    }

    managerFile.createSync(recursive: true);
    managerFile.writeAsStringSync(jsonEncode(BranchMetaData(branchName, {}).toJson()));

    onCreateFile?.call();
  }

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

    BranchMetaData? metaData = branchMetaDataFromManagerFile;
    if (metaData == null) {
      onNoMetaData?.call();
      return;
    }

    CommitMetaData commitMetaData = CommitMetaData(
      commit.sha,
      commit.message,
      commit.commitedAt,
    );
    metaData.commits.putIfAbsent(commitMetaData.sha, () => commitMetaData);

    saveBranchMetaData(metaData);

    onCommitCreated?.call(commitMetaData);
  }
}


///Stored in file
class BranchMetaData {
  final String name;
  final Map<String, CommitMetaData> commits;

  BranchMetaData(this.name, this.commits);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'commits': commits,
    };
  }

  static BranchMetaData fromJson(Map<String, dynamic> json) {
    return BranchMetaData(
      json['name'],
      {
        for (var e in (json['commits'] as List<dynamic>)
            .map((e) => CommitMetaData.fromJson(e)))
          e.sha: e
      },
    );
  }
}

class CommitMetaData {
  final String sha;
  final String message;
  final DateTime commitedAt;

  CommitMetaData(this.sha, this.message, this.commitedAt);

  static CommitMetaData fromJson(Map<String, dynamic> json) {
    return CommitMetaData(
        json['sha'], json['message'], DateTime.parse(json['commited_at']));
  }

  Map<String, dynamic> toJson() {
    return {
      'sha': sha,
      'message': message,
      'commited_at': commitedAt,
    };
  }
}
