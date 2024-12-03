import 'dart:io';

import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

class Branch {
  final Repository repository;
  final String name;

  Branch(this.name, this.repository);
}

extension BranchActions on Branch {
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

      bool valid = isValidBranchName?.call(name) ?? true;
      if (!valid) {
        onInvalidBranchName?.call(name);
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
          name,
        ],
      );

  Directory get branchDirectory => Directory(branchDirectoryPath);

  Staging get staging => Staging(this);
}
