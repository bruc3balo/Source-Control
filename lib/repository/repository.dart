import 'dart:io';
import 'package:balo/variables.dart';
import 'package:path/path.dart' as path;

class Repository {
  final Directory directory;

  Repository(this.directory);

  bool get isInitialized => directory
      .listSync(recursive: false)
      .any((f) => path.basename(f.path) == repositoryFolderName);

  Future<void> unInitializeRepository({
    Function()? onNotInitialized,
    Function()? onSuccessfullyUninitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      //idempotent
      if (!isInitialized) {
        onNotInitialized?.call();
        return;
      }

      //Delete directory
      String repositoryFolderPath = path.join(
        directory.path,
        repositoryFolderName,
      );

      await Directory(repositoryFolderPath).delete(recursive: true);

      onSuccessfullyUninitialized?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> initializeRepository({
    Function()? onAlreadyInitialized,
    Function()? onSuccessfullyInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      //idempotent
      if (isInitialized) {
        onAlreadyInitialized?.call();
        return;
      }

      //Create directory
      String repositoryFolderPath = path.join(
        directory.path,
        repositoryFolderName,
      );

      await Directory(repositoryFolderPath).create();

      onSuccessfullyInitialized?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}




