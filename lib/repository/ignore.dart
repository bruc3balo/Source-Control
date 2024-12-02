import 'dart:io';

class Ignore {
  final File file;

  Ignore(this.file);

  Future<void> createIgnoreFile({
    Function()? onAlreadyExists,
    Function()? onSuccessfullyCreated,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
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
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
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
