import 'dart:io';
import 'package:balo/variables.dart';
import 'package:path/path.dart';

class Repository {
  final String path;

  Directory get directory => Directory(join(path, repositoryFolderName));

  Repository(this.path);

  bool get isInitialized => directory.existsSync();

  Future<void> unInitializeRepository({
    Function()? onRepositoryNotInitialized,
    Function()? onSuccessfullyUninitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      //idempotent
      if (!isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }


      directory.deleteSync(recursive: true);
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

      directory.createSync(recursive: true);
      onSuccessfullyInitialized?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}
