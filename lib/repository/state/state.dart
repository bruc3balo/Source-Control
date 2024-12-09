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
///The [State] object represents the current state of a [Repository] in memory
class State {
  final Repository repository;

  State(this.repository);
}

extension StateStorage on State {

  ///Path to [stateFile]
  String get stateFilePath => join(repository.repositoryDirectory.path, stateFileName);

  ///Actual state [File]
  File get stateFile => File(stateFilePath);

  ///Returns status of state file i.e. exists or not
  bool get exists => stateFile.existsSync();

  ///Returns current [StateData] if [exists]
  StateData? get stateInfo {
    if (!exists) return null;

    //Read file
    String fileData = stateFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> stateInfo = jsonDecode(fileData);
    return StateData.fromJson(stateInfo);
  }

  /// This function is idempotent
  /// Saves the [stateData] to [stateFile]
  StateData saveStateData({
    required StateData stateData,
    Function()? onSuccessfullySaved,
  }) {
    //Write state to file
    stateFile.writeAsStringSync(
      jsonEncode(stateData),
      flush: true,
      mode: FileMode.writeOnly,
    );

    onSuccessfullySaved?.call();

    return stateData;
  }

  ///Deletes the current [stateFile]
  void deleteStateFile({
    Function()? onDoesntExists,
    Function()? onSuccessfullyDeleted,
  }) {
    if (!stateFile.existsSync()) {
      onDoesntExists?.call();
      return;
    }

    stateFile.deleteSync(recursive: true);
    onSuccessfullyDeleted?.call();
  }
}

extension StateActions on State {

  ///Gets current [Branch] that [StateData] points to currently
  ///only if [exists]
  Branch? getCurrentBranch({
    Function()? onNoStateFile,
  }) {
    if (!exists) {
      onNoStateFile?.call();
      return null;
    }

    String? branch = stateInfo?.currentBranch;
    if (branch == null) return null;

    return Branch(branch, repository);
  }
}


///Entity to store [State]
@freezed
class StateData with _$StateData {
  factory StateData({
    required String currentBranch,
    String? currentCommit,
  }) = _StateData;

  factory StateData.fromJson(Map<String, Object?> json) => _$StateDataFromJson(json);
}
