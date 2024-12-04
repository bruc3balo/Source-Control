import 'dart:io';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

class Repository {
  final String path;

  Repository(this.path);
}

extension RepositoryActions on Repository {
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

      repositoryDirectory.deleteSync(recursive: true);
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

      repositoryDirectory.createSync(recursive: true);
      onSuccessfullyInitialized?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}

extension RepositoryCommons on Repository {
  String get repositoryPath => join(path, repositoryFolderName);
  Directory get repositoryDirectory => Directory(repositoryPath);
  bool get isInitialized => repositoryDirectory.existsSync();
}

extension RepositoryEnvironment on Repository {

  List<Branch> get allBranches =>
      Directory(join(repositoryPath, branchFolderName))
          .listSync(recursive: false, followLinks: false)
          .where((f) => f.statSync().type == FileSystemEntityType.directory)
          .map((f) => Branch(basename(f.path), this))
          .toList();

  Ignore get ignore => Ignore(this);
  State get state => State(this);
}
