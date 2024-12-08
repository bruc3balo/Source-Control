import 'dart:convert';
import 'dart:io';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.g.dart';

part 'state.freezed.dart';

///Known as head in git
class State {
  final Repository repository;

  State(this.repository);
}

extension StateCommons on State {}

extension StateStorage on State {
  String get stateFilePath => join(
        repository.repositoryDirectory.path,
        stateFileName,
      );

  File get stateFile => File(stateFilePath);

  bool get exists => stateFile.existsSync();

  StateData? get stateInfo {
    if (!exists) return null;

    //Read file
    String fileData = stateFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> stateInfo = jsonDecode(fileData);
    return StateData.fromJson(stateInfo);
  }

  Future<void> saveStateData({
    required StateData stateData,
    Function()? onSuccessfullySaved,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      if (!exists) {
        stateFile.createSync(recursive: true, exclusive: true);
      }

      //Write state to file
      stateFile.writeAsStringSync(jsonEncode(stateData));
      onSuccessfullySaved?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> createStateFile({
    required Branch currentBranch,
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

      if (exists) {
        onAlreadyExists?.call();
        return;
      }

      await stateFile.create(recursive: true, exclusive: true);

      StateData data = StateData(currentBranch: currentBranch.branchName);

      //Write state to file
      stateFile.writeAsStringSync(jsonEncode(data));

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

extension StateActions on State {
  Branch? getCurrentBranch({
    Function()? onRepositoryNotInitialized,
    Function()? onNoStateFile,
  }) {
    if (!repository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return null;
    }

    if (!exists) {
      onNoStateFile?.call();
      return null;
    }

    String? branch = stateInfo?.currentBranch;
    if (branch == null) return null;

    return Branch(branch, repository);
  }
}

@freezed
class StateData with _$StateData {
  factory StateData({
    required String currentBranch,
    String? currentCommit,
  }) = _StateData;

  factory StateData.fromJson(Map<String, Object?> json) =>
      _$StateDataFromJson(json);
}