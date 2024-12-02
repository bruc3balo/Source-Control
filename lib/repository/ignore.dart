import 'dart:io';

import 'package:balo/repository/repository.dart';

class Ignore {
  final Repository repository;
  final File file;

  Ignore(this.repository, this.file);

  Future<void> createIgnoreFile({
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

  Future<void> deleteIgnoreFile({
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
