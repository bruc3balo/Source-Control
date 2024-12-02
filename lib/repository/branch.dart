import 'dart:io';

import 'package:balo/repository/repository.dart';
import 'package:balo/variables.dart';
import 'package:path/path.dart';

class Branch {
  final Repository repository;
  final String name;

  Branch(this.name, this.repository);

  Future<void> createBranch({
    bool Function(String name)? isValidBranchName,
    Function(String name)? onInvalidBranchName,
    Function()? onBranchAlreadyExists,
    Function()? onRepositoryInitialized,
    Function()? onBranchCreated,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryInitialized?.call();
        return;
      }

      String repositoryPath = repository.directory.path;
      String branchesPath = join(repositoryPath, branchFolderName);

      Directory branches = Directory(branchesPath);
      if (!branches.existsSync()) {
        branches = await branches.create(recursive: true);
      }
      assert(branches.existsSync());

      bool valid = isValidBranchName?.call(name) ?? true;
      if (!valid) {
        onInvalidBranchName?.call(name);
        return;
      }

      bool branchExists = branches
          .listSync(recursive: false)
          .any((b) => basename(b.path) == name);

      if (branchExists) {
        onBranchAlreadyExists?.call();
        return;
      }

      Directory newBranch = await Directory(join(branchesPath, name)).create(
        recursive: true,
      );

      onBranchCreated?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> deleteBranch({
    Function()? onBranchDoesntExist,
    Function()? onBranchDeleted,
    Function()? onRepositoryInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryInitialized?.call();
        return;
      }

      String repositoryPath = repository.directory.path;
      String branchPath = joinAll([repositoryPath, branchFolderName, name]);

      Directory branches = Directory(branchPath);
      if (!branches.existsSync()) {
        onBranchDoesntExist?.call();
        return;
      }

      branches.deleteSync();
      onBranchDeleted?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}
