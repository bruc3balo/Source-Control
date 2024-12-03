import 'dart:io';

import 'package:balo/repository/repository.dart';
import 'package:balo/variables.dart';
import 'package:path/path.dart';

class Ignore {
  final Repository repository;

  File get file => File(
        join(
          repository.directory.parent.path,
          repositoryIgnoreFileName,
        ),
      );

  Ignore(this.repository);

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
