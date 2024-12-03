import 'dart:io';

import 'package:balo/repository/branch.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/variables.dart';
import 'package:path/path.dart';

class State {
  final Repository repository;
  String currentBranch;

  File get file => File(
        joinAll([
          repository.directory.path,
          stateFileName,
        ]),
      );

  State(this.repository, this.currentBranch);

  Future<void> createStateFile({
    Function()? onAlreadyExists,
    Function()? onSuccessfullyCreated,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      if (file.existsSync()) {
        onAlreadyExists?.call();
        return;
      }

      await file.create(recursive: true, exclusive: true);
      onSuccessfullyCreated?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> deleteStateFile({
    Function()? onDoesntExists,
    Function()? onSuccessfullyDeleted,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      if (!file.existsSync()) {
        onDoesntExists?.call();
        return;
      }

      await file.delete(recursive: true);
      onSuccessfullyDeleted?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}
