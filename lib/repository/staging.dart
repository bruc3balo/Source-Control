import 'dart:convert';
import 'dart:io';

import 'package:balo/repository/branch.dart';
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

      //Looking for this pattern
      RegExp expectedReg = RegExp(convertPatternToRegExp(pattern));

      //Ignore staging these files
      List<String> patternsToIgnore = ignore.patternsToIgnore;
      List<RegExp> regToIgnore = patternsToIgnore
          .map((p) => RegExp(convertPatternToRegExp(p)))
          .toList();

      //List files for staging
      List<FileSystemEntity> filesToBeStaged = repository
          .repositoryDirectory.parent
          .listSync(recursive: true, followLinks: false)

          //Files only
          .where((f) => f.statSync().type == FileSystemEntityType.file)

          //Pattern match
          .where((f) => expectedReg.hasMatch(basename(f.path)))

          //Ignore
          .where(
              (f) => !regToIgnore.any((reg) => reg.hasMatch(basename(f.path))))
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
  File get stagingFile => File(join(branch.branchDirectory.path, branchStage));

  Repository get repository => branch.repository;

  Ignore get ignore => repository.ignore;

  Map<String, dynamic> get stagingInfo {
    String fileData = stagingFile.readAsStringSync();
    if (fileData.isEmpty) return {};

    Map<String, dynamic> info = jsonDecode(fileData);
    return info;
  }
}
