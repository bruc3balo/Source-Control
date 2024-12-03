import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

class Staging {
  final Branch branch;

  Staging(this.branch);
}

extension StagingActions on Staging {
  Future<void> commitStagedFiles({
    required String message,
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

    List<File> filesToBeStaged = (stagingInfo[filePathsKey] as List<dynamic>)
        .map((e) => File(e))
        .toList();

    for (File f in filesToBeStaged) {
      String newPath = f.path.replaceAll(r.path, commitDir.path);
      File(newPath).createSync(recursive: true);
      f.copySync(newPath);
      printToConsole(message: "${f.path} -> $newPath");
    }


    Commit commit = Commit(sha, branch);

    //Delete staging
    stagingFile.deleteSync();
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

      //List files for staging
      List<FileSystemEntity> filesToBeStaged =
          await repository.repositoryDirectory.parent
              .list(recursive: true, followLinks: false)

              //Files only
              .where((f) => f.statSync().type == FileSystemEntityType.file)

              //Pattern match
              .where((f) => shouldAddPath(f.path, pattern))

              //Ignore
              .where(
                (f) => !shouldIgnorePath(f.path, patternsToIgnore),
              )
              .toList();

      //Clear previous staging
      if (stagingFile.existsSync()) {
        stagingFile.deleteSync(recursive: true);
        stagingFile.createSync(recursive: true);
      }

      //Fresh file
      Map<String, dynamic> info = {
        stagedAtKey: DateTime.now().toString(),
        filePathsKey: filesToBeStaged.map((f) => f.path).toList(),
      };

      //Write staging info
      stagingFile.writeAsStringSync(jsonEncode(info), flush: true);
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

      stagingFile.deleteSync(recursive: true);
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}

extension StagingCommons on Staging {
  bool get isStaged => stagingFile.existsSync();
  File get stagingFile => File(stagingFilePath);

  String get stagingFilePath => join(branch.branchDirectory.path, branchStage);

  Repository get repository => branch.repository;

  Ignore get ignore => repository.ignore;

  Map<String, dynamic> get stagingInfo {
    String fileData = stagingFile.readAsStringSync();
    if (fileData.isEmpty) return {};

    Map<String, dynamic> info = jsonDecode(fileData);
    return info;
  }
}
