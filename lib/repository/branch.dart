import 'dart:io';

import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/variables.dart';
import 'package:path/path.dart';

class Branch {
  final Repository repository;

  Directory get directory => Directory(
        joinAll(
          [
            repository.directory.path,
            branchFolderName,
            name,
          ],
        ),
      );
  final String name;

  Branch(this.name, this.repository);

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

      printToConsole(message: "Branch : ${repository.path}");

      bool branchExists = directory.existsSync();
      if (branchExists) {
        onBranchAlreadyExists?.call();
        return;
      }

      await directory.create(
        recursive: true,
      );

      onBranchCreated?.call(directory);
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

      if (!directory.existsSync()) {
        onBranchDoesntExist?.call();
        return;
      }

      directory.deleteSync(recursive: true);
      onBranchDeleted?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}
