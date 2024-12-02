import 'dart:io';

import 'package:balo/repository/repository.dart';

class State {
  final Repository repository;
  final File file;

  State(this.repository, this.file);

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
