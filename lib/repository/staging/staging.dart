import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'staging.freezed.dart';

part 'staging.g.dart';

///Pre-[Commit] area on a [Branch] with files ready to be commited
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

    List<File> filesToBeStaged = data.filesToBeStaged.map((e) => File(e)).toList();

    //Move files to be staged
    copyFiles(
      files: filesToBeStaged,
      sourceDir: r.repositoryDirectory.parent,
      destinationDir: commitDir,
    );

    //Save Commit
    Commit commit = Commit(sha, branch, message, DateTime.now());
    b.addCommit(commit: commit);

    //Delete staging
    deleteStagingData();

    //Point to latest commit
    State state = State(repository);
    StateData? stateData = state.stateInfo;
    if (stateData == null) {
      stateData = StateData(currentBranch: branch.branchName, currentCommit: commit.sha);
    } else {
      stateData = stateData.copyWith(currentCommit: commit.sha);
    }

    await state.saveStateData(stateData: stateData);
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
      Ignore i = ignore;
      List<String> patternsToIgnore = ignore.patternsToIgnore;
      debugPrintToConsole(
        message: "Ignoring ${patternsToIgnore.join(" ")}",
      );

      //List files for staging
      String repositoryParent = repository.repositoryDirectory.parent.path;
      List<FileSystemEntity> filesToBeStaged = repository.repositoryDirectory.parent
          .listSync(recursive: true, followLinks: false)

          //Files only
          .where((f) => FileSystemEntityType.file == f.statSync().type)

          //To add
          .where((f) => shouldAddPath(f.path.replaceAll(repositoryParent, ""), pattern: pattern))

          //Ignore
          .where((f) => !shouldIgnorePath(f.path.replaceAll(repositoryParent, ""), patternsToIgnore))
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
    if (!isStaged) return null;

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

extension StagingIgnore on Staging {

  ///[path] starts with [Platform.pathSeparator] as a relative path from the [Repository]parent dir
  bool shouldAddPath(String path, {String pattern = star}) {
    debugPrintToConsole(message: "Checking if should add Path: $path", newLine: true);
    debugPrintToConsole(message: "Pattern: $pattern");

    if (pattern == dot || pattern == star || pattern.isEmpty) return true;

    final IgnorePatternRules rule = IgnorePatternRules.detectRule(pattern);
    final bool matched = switch (rule) {
      IgnorePatternRules.pathFromRoot => rule.patternMatches(
        testPattern: pattern,
        inputPattern: path,
      ),
      IgnorePatternRules.suffix => rule.patternMatches(
        testPattern: pattern,
        inputPattern: path,
      ),
      IgnorePatternRules.single => rule.patternMatches(
        testPattern: pattern,
        inputPattern: path.replaceFirst(Platform.pathSeparator, ""),
      ),
      IgnorePatternRules.contains => rule.patternMatches(
        testPattern: pattern,
        inputPattern: path,
      ),
      IgnorePatternRules.exactMatch => rule.patternMatches(
        testPattern: pattern,
        inputPattern: path.replaceFirst(Platform.pathSeparator, ""),
      ),
    };

    debugPrintToConsole(message: "Result: $matched");
    debugPrintToConsole(message: "Description: Pattern matched $matched against $rule");

    return matched;
  }

  ///[path] starts with [Platform.pathSeparator] as a relative path from the [Repository] parent dir
  bool shouldIgnorePath(String path, List<String> ignoredPatterns) {
    debugPrintToConsole(message: "Checking if should ignore $path", newLine: true);

    for (String ignorePattern in ignoredPatterns) {
      IgnorePatternRules rule = IgnorePatternRules.detectRule(ignorePattern);

      final bool matched = switch (rule) {
        IgnorePatternRules.pathFromRoot => rule.patternMatches(
          testPattern: ignorePattern,
          inputPattern: path,
        ),
        IgnorePatternRules.suffix => rule.patternMatches(
          testPattern: ignorePattern,
          inputPattern: path,
        ),
        IgnorePatternRules.single => rule.patternMatches(
          testPattern: ignorePattern,
          inputPattern: path.replaceFirst(Platform.pathSeparator, ""),
        ),
        IgnorePatternRules.contains => rule.patternMatches(
          testPattern: ignorePattern,
          inputPattern: path,
        ),
        IgnorePatternRules.exactMatch => rule.patternMatches(
          testPattern: ignorePattern,
          inputPattern: path.replaceFirst(Platform.pathSeparator, ""),
        ),
      };

      if (matched) {
        debugPrintToConsole(message: "$path will be ignored due to match by $rule on $ignorePattern");
        return true;
      }
    }

    debugPrintToConsole(message: "$path will not be ignored");
    return false;
  }
}

@freezed
class StagingData with _$StagingData {
  factory StagingData({
    required DateTime stagedAt,
    required List<String> filesToBeStaged,
  }) = _StagingData;

  factory StagingData.fromJson(Map<String, Object?> json) => _$StagingDataFromJson(json);
}
