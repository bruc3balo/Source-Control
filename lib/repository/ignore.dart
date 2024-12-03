import 'dart:io';

import 'package:balo/repository/repository.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

class Ignore {
  final Repository repository;

  Ignore(this.repository);
}

extension IgnoreActions on Ignore {
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

      if (ignoreFile.existsSync()) {
        onAlreadyExists?.call();
        return;
      }

      await ignoreFile.create(recursive: true, exclusive: true);
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

      if (!ignoreFile.existsSync()) {
        onDoesntExists?.call();
        return;
      }

      await ignoreFile.delete(recursive: true);
      onSuccessfullyDeleted?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> addIgnore({
    required String pattern,
    Function()? onAlreadyPresent,
    Function()? onAdded,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      List<String> ignores = ignoreFile.readAsLinesSync();
      if (ignores.contains(pattern)) {
        onAlreadyPresent?.call();
        return;
      }

      ignores.add(pattern);

      ignoreFile.writeAsStringSync(
        ignores.join(Platform.lineTerminator),
        flush: true,
      );

      onAdded?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> removeIgnore({
    required String pattern,
    Function()? onNotFoundPresent,
    Function()? onRemoved,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      List<String> ignores = ignoreFile.readAsLinesSync();
      if (!ignores.contains(pattern)) {
        onNotFoundPresent?.call();
        return;
      }

      ignores.remove(pattern);

      ignoreFile.writeAsStringSync(
        ignores.join(Platform.lineTerminator),
        flush: true,
      );

      onRemoved?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}

extension IgnoreCommons on Ignore {
  File get ignoreFile => File(
        join(
          repository.repositoryDirectory.path,
          repositoryIgnoreFileName,
        ),
      );

  List<String> get patternsToIgnore => ignoreFile.existsSync()
      ? ignoreFile
          .readAsLinesSync()
          .where((p) => p.isNotEmpty && !p.startsWith("#"))
          .map((p) => convertPatternToRegExp(p))
          .toList()
      : [];
}
