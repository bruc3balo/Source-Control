import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/merge/merge.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'staging.freezed.dart';

part 'staging.g.dart';

///Pre-[Commit] area in a [Branch] with files ready to be commited in memory
class Staging {
  final Branch branch;

  Staging(this.branch);
}

extension StagingActions on Staging {
  ///Commit staged files in [stagingFile] with a commit [message]
  ///If a [Merge] is pending, it will be included in the [Commit]
  void commitStagedFiles({
    required String message,
    Function()? onNoStagingData,
  }) {
    Repository localRepository = repository;
    Branch commitingBranch = branch;

    StagingData? data = stagingData;
    if (data == null) {
      onNoStagingData?.call();
      return;
    }

    String directoryPath = localRepository.workingDirectory.path;
    List<File> filesToBeStaged =
        data.filesToBeStaged.map((e) => File(fullPathFromDir(relativePath: e, directoryPath: directoryPath))).where((e) => e.existsSync()).toList();
    Map<String, RepoObjectsData> repoObjects = {
      for (var o in filesToBeStaged.map((e) => RepoObjects.createFromFile(localRepository, e).writeRepoObject())) o.sha: o,
    };

    //If has pending merge, add previous commits
    Merge merge = Merge(repository, branch);
    if (merge.hasPendingMerge) {
      MergeCommitMetaData mergeData = merge.pendingMergeCommitMetaData!;
      for (CommitTreeMetaData commit in mergeData.commitsToMerge.values) {
        Branch fromBranch = Branch(commit.originalBranch, repository);
        commitingBranch.addCommit(
          commit: Commit(
            Sha1(commit.sha),
            branch,
            message,
            repoObjects,
            fromBranch,
            commit.commitedAt,
          ),
        );
      }
      merge.deleteCommitMergeData();
    }

    //Save Commit
    DateTime commitedAt = DateTime.now();
    Sha1 sha1 = createCommitSha(
      branchName: branch.branchName,
      message: message,
      noOfObjects: repoObjects.length,
      commitedAt: commitedAt,
    );
    Commit commit = Commit(sha1, branch, message, repoObjects, branch, commitedAt);
    commitingBranch.addCommit(commit: commit);

    //Delete staging
    deleteStagingData();

    //Point to latest commit
    State state = State(repository);
    state.saveStateData(
      stateData: StateData(
        currentBranch: branch.branchName,
        currentCommit: commit.sha.hash,
      ),
    );
  }

  ///Stages files to be [Commit]ed into a [Branch] that match the [pattern]
  void stageFiles({
    required String pattern,
  }) {
    //Ignore staging these files
    List<String> patternsToIgnore = ignore.patternsToIgnore;
    debugPrintToConsole(
      message: "Ignoring ${patternsToIgnore.join(" ")}",
    );

    //List files for staging
    String repositoryParent = repository.workingDirectory.path;
    List<FileSystemEntity> filesToBeStaged = repository.workingDirectory
        .listSync(recursive: true, followLinks: false)

        //Files only
        .where((f) => FileSystemEntityType.file == f.statSync().type)

        //To add
        .where((f) => shouldAddPath(relativePathFromDir(path: f.path, directoryPath: repositoryParent), pattern: pattern))

        //Ignore
        .where((f) => !shouldIgnorePath(relativePathFromDir(path: f.path, directoryPath: repositoryParent), patternsToIgnore))
        .toList();

    HashMap<String, String> filesToBeStagedList = HashMap.from(
      {for (var f in filesToBeStaged) computeFileSha1Hash(File(f.path)).hash  : relativePathFromDir(directoryPath: repositoryParent, path: f.path)},
    );

    //Add RepoObjectsData from previous commit that are in working dir
    CommitTreeMetaData? commitTreeMetaData = branch.branchTreeMetaData?.latestBranchCommits;
    if (commitTreeMetaData != null) {
      Iterable<RepoObjectsData> commitObjects = commitTreeMetaData.commitedObjects.values.where(
        (f) => !shouldIgnorePath(f.filePathRelativeToRepository, patternsToIgnore),
      );
      filesToBeStagedList.addAll({for (var o in commitObjects) o.sha: o.filePathRelativeToRepository});
    }

    StagingData data = StagingData(
      stagedAt: DateTime.now(),
      filesToBeStaged: filesToBeStagedList.values.toList(),
    );

    //Write staging info
    saveStagingData(data);
  }

  ///Deletes data from [stagingFile]
  void unstageFiles({
    Function()? onStagingFileDoesntExist,
    Function(FileSystemException)? onFileSystemException,
  }) {
    if (!stagingFile.existsSync()) {
      onStagingFileDoesntExist?.call();
      return;
    }

    deleteStagingData();
  }
}

extension StagingStorage on Staging {
  ///Path of [stagingFile]
  String get stagingFilePath => join(branch.branchDirectory.path, branchStage);

  ///Checks if files have been staged for a [Commit]
  bool get hasStagedFiles => stagingFile.existsSync();

  ///Actual [File] that has [stagingData]
  File get stagingFile => File(stagingFilePath);

  ///Data containing files to be staged
  StagingData? get stagingData {
    if (!hasStagedFiles) return null;

    String fileData = stagingFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> info = jsonDecode(fileData);
    return StagingData.fromJson(info);
  }

  ///Saved [data] to [stagingFile]
  StagingData saveStagingData(StagingData data) {
    stagingFile
      ..createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode(data),
        flush: true,
        mode: FileMode.write,
      );
    return data;
  }

  ///Removes [stagingFile]
  void deleteStagingData() => stagingFile.deleteSync();
}

extension StagingCommons on Staging {
  ///Get [Repository] associated with [stagingFile]
  Repository get repository => branch.repository;

  ///Get [Ignore] associated with [repository]
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
          inputPattern: stripBeginningPathSeparatorPath(path),
        ),
      IgnorePatternRules.contains => rule.patternMatches(
          testPattern: pattern,
          inputPattern: path,
        ),
      IgnorePatternRules.exactMatch => rule.patternMatches(
          testPattern: pattern,
          inputPattern: stripBeginningPathSeparatorPath(path),
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
            inputPattern: stripBeginningPathSeparatorPath(path),
          ),
        IgnorePatternRules.contains => rule.patternMatches(
            testPattern: ignorePattern,
            inputPattern: path,
          ),
        IgnorePatternRules.exactMatch => rule.patternMatches(
            testPattern: ignorePattern,
            inputPattern: stripBeginningPathSeparatorPath(path),
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

///Entity to store [Staging] data
@freezed
class StagingData with _$StagingData {
  factory StagingData({
    required DateTime stagedAt,
    required List<String> filesToBeStaged,
  }) = _StagingData;

  factory StagingData.fromJson(Map<String, Object?> json) => _$StagingDataFromJson(json);
}
