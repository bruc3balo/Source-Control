import 'dart:convert';
import 'dart:io';

import 'package:balo/repository/branch.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

class State {
  final Repository repository;

  State(this.repository);
}

extension StateCommons on State {

  File get stateFile => File(
        joinAll([
          repository.repositoryDirectory.path,
          stateFileName,
        ]),
      );

  Map<String, dynamic> get stateInfo {
    //Read file
    String fileData = stateFile.readAsStringSync();
    if (fileData.isEmpty) return {};

    Map<String, dynamic> stateInfo = jsonDecode(fileData);
    return stateInfo;
  }

  Branch get currentBranch {
    String currentBranchName = stateInfo[currentBranchKey];
    return Branch(currentBranchName, repository);
  }

}

extension StateActions on State {

  Future<Branch?> getCurrentBranch({
    Function()? onRepositoryNotInitialized,
  }) async {
    if (!repository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return null;
    }

    String branch = stateInfo[currentBranchKey];
    return Branch(branch, repository);
  }

  Future<void> createStateFile({
    required String currentBranch,
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

      if (stateFile.existsSync()) {
        onAlreadyExists?.call();
        return;
      }

      await stateFile.create(recursive: true, exclusive: true);

      Map<String, dynamic> info = {currentBranchKey: currentBranch};

      //Write state to file
      stateFile.writeAsStringSync(jsonEncode(info));

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

      if (!stateFile.existsSync()) {
        onDoesntExists?.call();
        return;
      }

      await stateFile.delete(recursive: true);
      onSuccessfullyDeleted?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}
