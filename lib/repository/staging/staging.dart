import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'staging.freezed.dart';

part 'staging.g.dart';

class Staging {
  final Branch branch;

  Staging(this.branch);
}

extension StagingActions on Staging {
  Future<void> commitStagedFiles({
    required String message,
    Function()? onNoStagingData,
  }) async {
    Repository r = repository;
    Branch b = branch;
    String sha = Random().nextInt(1000000).toString();

    //Create dir
    Directory commitDir = Directory(
      join(
        b.branchDirectoryPath,
        branchCommitFolder,
        sha,
      ),
    );
    commitDir.createSync(recursive: true);

    StagingData? data = stagingData;
    if (data == null) {
      onNoStagingData?.call();
      return;
    }

    List<File> filesToBeStaged =
        data.filesToBeStaged.map((e) => File(e)).toList();

    moveFiles(
      files: filesToBeStaged,
      sourceDir: r.repositoryDirectory.parent,
      destinationDir: commitDir,
    );

    //Save Commit
    Commit commit = Commit(sha, branch, message, DateTime.now());
    b.addCommit(commit: commit);

    //Delete staging
    deleteStagingData();
  }

  Future<void> stageFiles({
    required String pattern,
    Function()? onUninitializedRepository,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onUninitializedRepository?.call();
        return;
      }

      //Ignore staging these files
      List<String> patternsToIgnore = ignore.patternsToIgnore;
      debugPrintToConsole(
        message: "Ignoring ${patternsToIgnore.join(" ")}",
      );

      //List files for staging
      List<FileSystemEntity> filesToBeStaged =
          repository.repositoryDirectory.parent
              .listSync(recursive: true, followLinks: false)

              //Files only
              .where((f) => f.statSync().type == FileSystemEntityType.file)

              //Pattern match
              .where((f) => shouldAddPath(f.path, pattern))

              //Ignore
              .where((f) => !shouldIgnorePath(f.path, patternsToIgnore))
              .toList();

      //Clear previous staging
      if (stagingFile.existsSync()) {
        stagingFile.deleteSync(recursive: true);
        stagingFile.createSync(recursive: true);
      }

      //Fresh file
      StagingData data = StagingData(
        stagedAt: DateTime.now(),
        filesToBeStaged: filesToBeStaged.map((f) => f.path).toList(),
      );

      //Write staging info
      stagingFile.writeAsStringSync(jsonEncode(data), flush: true);
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> unstageFiles({
    Function()? onUninitializedRepository,
    Function()? onStagingFileDoesntExist,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onUninitializedRepository?.call();
        return;
      }

      if (!stagingFile.existsSync()) {
        onStagingFileDoesntExist?.call();
        return;
      }

      deleteStagingData();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}

extension StagingStorage on Staging {
  String get stagingFilePath => join(branch.branchDirectory.path, branchStage);

  bool get isStaged => stagingFile.existsSync();

  File get stagingFile => File(stagingFilePath);

  StagingData? get stagingData {
    String fileData = stagingFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> info = jsonDecode(fileData);
    return StagingData.fromJson(info);
  }

  void saveStagingData(StagingData data) {
    stagingFile.writeAsStringSync(jsonEncode(data), flush: true);
  }

  void deleteStagingData() {
    stagingFile.deleteSync();
  }
}

extension StagingCommons on Staging {
  Repository get repository => branch.repository;

  Ignore get ignore => repository.ignore;
}

@freezed
class StagingData with _$StagingData {
  factory StagingData({
    required DateTime stagedAt,
    required List<String> filesToBeStaged,
  }) = _StagingData;

  factory StagingData.fromJson(Map<String, Object?> json) =>
      _$StagingDataFromJson(json);
}
