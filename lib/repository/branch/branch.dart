import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:balo/repository/commit.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'branch.freezed.dart';

part 'branch.g.dart';

///Named reference to a commit
class Branch {
  final Repository repository;
  final String branchName;

  Branch(this.branchName, this.repository);
}

enum BranchFileStatus { staged, unstaged }

extension BranchStatus on Branch {
  Map<BranchFileStatus, HashSet<String>> getBranchStatus() {
    final Map<BranchFileStatus, HashSet<String>> fileStatus = {};

    //WorkingDirFiles
    List<FileSystemEntity> workingDirFiles =
        repository.workingDirectory.listSync(recursive: true).where((e) => e.statSync().type == FileSystemEntityType.file).toList();

    //Staged files
    HashSet<String> stagedPaths = HashSet.of(staging.stagingData?.filesToBeStaged ?? []);

    //FileSystemEntity
    for (FileSystemEntity f in workingDirFiles) {
      BranchFileStatus branchStatus = stagedPaths.contains(f.path) ? BranchFileStatus.staged : BranchFileStatus.unstaged;
      fileStatus.update(branchStatus, (l) => l..add(f.path), ifAbsent: () => HashSet()..add(f.path));
    }

    return fileStatus;
  }
}

extension BranchCreation on Branch {
  Future<void> createBranch({
    bool Function(String name)? isValidBranchName,
    Function(String name)? onInvalidBranchName,
    Function()? onBranchAlreadyExists,
    Function()? onRepositoryNotInitialized,
    Function(Directory)? onBranchCreated,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      bool valid = isValidBranchName?.call(branchName) ?? true;
      if (!valid) {
        onInvalidBranchName?.call(branchName);
        return;
      }

      bool branchExists = branchDirectory.existsSync();
      if (branchExists) {
        onBranchAlreadyExists?.call();
        return;
      }

      branchDirectory.createSync(
        recursive: true,
      );

      createTreeMetaDataFile();

      onBranchCreated?.call(branchDirectory);
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> checkoutToBranch({
    String? commitSha,
    Function()? onNoCommitFound,
    Function()? onSameCommit,
    Function()? onBranchMetaDataDoesntExists,
    Function()? onStateDoesntExists,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!branchTreeMetaDataExists) {
        await createBranch(
          isValidBranchName: isValidBranchName,
          onFileSystemException: (e) => debugPrintToConsole(
            message: e.message,
            color: CliColor.red,
          ),
          onRepositoryNotInitialized: () => debugPrintToConsole(
            message: "Repository not initialized",
          ),
          onBranchAlreadyExists: () => debugPrintToConsole(
            message: "Branch exists",
          ),
          onInvalidBranchName: (s) => printToConsole(
            message: "Invalid branch name $s",
          ),
          onBranchCreated: (d) => debugPrintToConsole(
            message: "Branch has been created on ${d.path}",
          ),
        );
      }

      State state = State(repository);

      StateData? stateData = state.stateInfo;
      if (stateData == null) {
        onStateDoesntExists?.call();
        return;
      }

      StateData updatedStateData = stateData;

      BranchTreeMetaData? branchData = branchTreeMetaData;
      if (branchData == null) {
        onBranchMetaDataDoesntExists?.call();
        return;
      }

      //Change branch
      updatedStateData = updatedStateData.copyWith(currentBranch: branchName);

      //Change commit
      CommitMetaData? commitMetaData = commitSha != null ? branchData.commits[commitSha.trim()] : branchData.latestBranchCommits;
      if (commitSha != null && commitMetaData == null) {
        onNoCommitFound?.call();
        return;
      }

      //Update commit pointer
      updatedStateData = updatedStateData.copyWith(currentCommit: commitMetaData?.sha);
      if (updatedStateData == stateData) {
        onSameCommit?.call();
        return;
      }

      //Move files from latest commit to current working dir
      if (commitMetaData != null) {
        copyFilesToWorkingDir(
          objects: commitMetaData.commitedObjects.values.toList(),
          workingDir: repository.workingDirectory,
        );
      }

      await state.saveStateData(
        stateData: updatedStateData,
        onFileSystemException: (e) => debugPrintToConsole(
          message: e.message,
          color: CliColor.red,
        ),
        onRepositoryNotInitialized: () => debugPrintToConsole(
          message: "Repository not initialized",
        ),
        onSuccessfullySaved: () => debugPrintToConsole(
          message: "State saved",
        ),
      );
    } on FileSystemException catch (e, trace) {
      debugPrintToConsole(message: trace.toString(), color: CliColor.red);
      onFileSystemException?.call(e);
    }
  }

  void copyFilesToWorkingDir({
    required List<RepoObjectsData> objects,
    required Directory workingDir,
  }) {
    printToConsole(message: "copying ${objects.length} files to ${workingDir.path}");
    for (RepoObjectsData o in objects) {
      RepoObjects? repoObject = o.fetchObject(repository);
      if (repoObject == null) continue;

      String fileDestinationPath = join(workingDir.path, o.filePathRelativeToRepository.replaceFirst(Platform.pathSeparator, ""));
      debugPrintToConsole(message: "File is at destination ${fileDestinationPath}");

      File(fileDestinationPath)
        .writeAsBytesSync(
          repoObject.blob,
          mode: FileMode.writeOnly,
          flush: true,
        );

      debugPrintToConsole(message: "cp ${repoObject.objectFilePath} -> $fileDestinationPath");
    }
  }

  Future<void> deleteBranch({
    Function()? onBranchDoesntExist,
    Function()? onBranchDeleted,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      if (!branchDirectory.existsSync()) {
        onBranchDoesntExist?.call();
        return;
      }

      branchDirectory.deleteSync(recursive: true);
      onBranchDeleted?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}

extension BranchCommons on Branch {
  String get branchDirectoryPath => join(repository.repositoryDirectory.path, branchFolderName, branchName);

  Directory get branchDirectory => Directory(branchDirectoryPath);

  Staging get staging => Staging(this);
}

extension BranchTreeMetaDataStorage on Branch {
  String get managerPath => join(branchDirectoryPath, branchTreeMetaDataFileName);

  File get managerFile => File(managerPath);

  bool get branchTreeMetaDataExists => managerFile.existsSync();

  BranchTreeMetaData? get branchTreeMetaData {
    if (!branchTreeMetaDataExists) return null;

    String fileData = managerFile.readAsStringSync();
    if (fileData.isEmpty) return null;

    Map<String, dynamic> json = jsonDecode(fileData);
    return BranchTreeMetaData.fromJson(json);
  }

  Future<void> createTreeMetaDataFile({
    Function()? onDuplicateFile,
    Function()? onCreateFile,
  }) async {
    if (branchTreeMetaDataExists) {
      onDuplicateFile?.call();
      return;
    }

    managerFile.createSync(recursive: true);
    managerFile.writeAsStringSync(jsonEncode(BranchTreeMetaData(name: branchName, commits: HashMap())));

    onCreateFile?.call();
  }

  void saveBranchTreeMetaData(BranchTreeMetaData metaData) {
    if (!branchTreeMetaDataExists) createTreeMetaDataFile();

    managerFile.writeAsStringSync(
      jsonEncode(metaData.toJson()),
      flush: true,
    );
  }
}

extension BranchManager on Branch {
  Future<void> addCommit({
    required Commit commit,
    Function()? onMissingManager,
    Function(CommitMetaData)? onCommitCreated,
    Function()? onNoMetaData,
  }) async {
    if (!branchTreeMetaDataExists) {
      onMissingManager?.call();
      return;
    }

    BranchTreeMetaData? metaData = branchTreeMetaData;
    if (metaData == null) {
      onNoMetaData?.call();
      return;
    }

    CommitMetaData commitMetaData = CommitMetaData(
      sha: commit.sha.hash,
      message: commit.message,
      commitedObjects: commit.objects,
      commitedAt: commit.commitedAt,
    );

    final mutableCommits = Map<String, CommitMetaData>.from(metaData.commits);
    mutableCommits.putIfAbsent(commitMetaData.sha, () => commitMetaData);
    metaData = metaData.copyWith(commits: mutableCommits);

    saveBranchTreeMetaData(metaData);

    onCommitCreated?.call(commitMetaData);
  }
}

extension BranchMerge on Branch {
  Future<void> mergeFromOtherBranchIntoThis({
    required Branch otherBranch,
    Function()? onSameBranchMerge,
    Function()? onRepositoryNotInitialized,
    Function()? onNoOtherBranchMetaData,
    Function()? onNoCommit,
    Function()? onNoCommitBranchMetaData,
    Function()? onNoCommitMetaData,
  }) async {
    //Ensure merging from repository
    if (!repository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return;
    }

    if (otherBranch == this) {
      onSameBranchMerge?.call();
      return;
    }

    //Get all files from otherBranch latest commit
    BranchTreeMetaData? otherBranchData = otherBranch.branchTreeMetaData;
    if (otherBranchData == null) {
      onNoOtherBranchMetaData?.call();
      return;
    }

    CommitMetaData? commitMetaData = otherBranchData.sortedBranchCommits.firstOrNull;

    if (commitMetaData == null) {
      onNoCommit?.call();
      return;
    }
    Commit otherCommit = Commit(
      Sha1(commitMetaData.sha),
      otherBranch,
      commitMetaData.message,
      {},
      commitMetaData.commitedAt,
    );
    List<File> otherCommitFiles = otherCommit.getCommitFiles(
          onNoCommitMetaData: onNoCommitMetaData,
          onNoCommitBranchMetaData: onNoCommitBranchMetaData,
        ) ??
        [];

    //Get all files from this current working branch
    Directory workingBranchDir = repository.workingDirectory;
    List<File> workingBranchFiles =
        workingBranchDir.listSync(recursive: true).where((e) => e.statSync().type == FileSystemEntityType.file).map((e) => File(e.path)).toList();

    //Get other branch files map
    String otherBranchPrefix = join(
      otherBranch.branchDirectoryPath,
      branchCommitFolder,
      otherCommit.sha.hash,
    );
    Map<String, File> otherBranchFilesMap = {for (var f in otherCommitFiles) f.path.replaceAll(otherBranchPrefix, ""): f};

    //Get this branch files map
    String workingBranchPrefix = workingBranchDir.path;
    Map<String, File> workingBranchFilesMap = {for (var f in workingBranchFiles) f.path.replaceAll(workingBranchPrefix, ""): f};

    HashSet<String> filePaths = HashSet.of(otherBranchFilesMap.keys);

    List<File> mergeResult = await _doMerge(
      filePaths: filePaths,
      workingBranchFilesMap: workingBranchFilesMap,
      otherBranchFilesMap: otherBranchFilesMap,
    );

    await _addMergedFilesToWorkingDir(
      otherBranchPath: otherBranchPrefix,
      workingDirPath: workingBranchPrefix,
      mergeResult: mergeResult,
    );
  }

  Future<void> _addMergedFilesToWorkingDir({
    required String otherBranchPath,
    required String workingDirPath,
    required List<File> mergeResult,
  }) async {
    debugPrintToConsole(
      message: "Merging ${mergeResult.length} files to $workingDirPath",
    );

    for (File file in mergeResult) {
      String path = file.path;
      String prefixPath = path.startsWith(otherBranchPath) ? otherBranchPath : workingDirPath;
      String newPath = file.path.replaceAll(prefixPath, workingDirPath);
      file.copySync(newPath);

      debugPrintToConsole(
        message: "Copying to ${basename(newPath)} to $newPath",
      );
    }

    debugPrintToConsole(
      message: "Done merging ${mergeResult.length} files to $workingDirPath",
    );
  }

  Future<List<File>> _doMerge({
    required HashSet<String> filePaths,
    required Map<String, File> workingBranchFilesMap,
    required Map<String, File> otherBranchFilesMap,
  }) async {
    debugPrintToConsole(
      message: "Starting file comparison for ${filePaths.length} files",
    );

    List<File> mergeResult = [];

    //Compare file by file
    for (String key in filePaths) {
      bool conflict = false;
      // same -> Pick other
      // insert -> Fast Forward
      // delete -> pick mine
      // modify -> conflict [theirs] [mine]
      File? otherFile = otherBranchFilesMap[key];
      File? thisFile = workingBranchFilesMap[key];

      if (otherFile == null) {
        //Keep this
        mergeResult.add(thisFile!);
        debugPrintToConsole(
          message: "Auto merging for ${basename(thisFile.path)}",
          color: CliColor.defaultColor,
        );
        continue;
      } else if (thisFile == null) {
        //Keep other
        mergeResult.add(otherFile);
        debugPrintToConsole(
          message: "Auto merging for ${basename(otherFile.path)}",
          color: CliColor.defaultColor,
        );
        continue;
      } else {
        //Compare line by line and write to file
        List<String> linesToWrite = [];

        List<String> otherLines = otherFile.readAsLinesSync();
        int otherLength = otherLines.length;

        List<String> thisLines = thisFile.readAsLinesSync();
        int thisLength = thisLines.length;

        int maxLines = max(otherLength, thisLength);
        debugPrintToConsole(
          message: "Checking $maxLines lines for $key",
        );

        lineLoop:
        for (int line = 0; line < maxLines; line++) {
          if (line > otherLength - 1) {
            //out of bounds
            //keep this line
            linesToWrite.add(thisLines[line]);
          } else if (line > thisLength - 1) {
            //out of bounds
            //keep other line
            linesToWrite.add(otherLines[line]);
          } else {
            //Compare lines

            String otherLine = otherLines[line];
            String thisLine = thisLines[line];

            //int diffScore = await levenshteinDistance(otherLine, thisLine);
            int diffScore = otherLine.length.compareTo(thisLine.length);
            debugPrintToConsole(
              message: "Lines $line compares $diffScore",
            );

            if (diffScore == 0) {
              //add either
              linesToWrite.add(otherLine);
              continue lineLoop;
            }

            //Merge conflict detected
            conflict = true;

            //include both
            linesToWrite.add("$otherLine >> @@other@@");
            linesToWrite.add("$thisLine >> @@this@@");
          }
        }

        //Modify this file to show conflicts
        if (conflict) {
          thisFile.writeAsStringSync(
            linesToWrite.join("\n"),
            mode: FileMode.write,
            flush: true,
          );

          debugPrintToConsole(
            message: "CONFLICT for ${basename(thisFile.path)}",
            color: CliColor.brightRed,
            style: CliStyle.bold,
          );
        } else {
          debugPrintToConsole(
            message: "Auto merging for ${basename(otherFile.path)}",
            color: CliColor.brightRed,
            style: CliStyle.bold,
          );
        }

        mergeResult.add(thisFile);
      }
    }

    debugPrintToConsole(
      message: "Completed file comparison for ${mergeResult.length} files",
    );

    return mergeResult;
  }
}

///BranchTreeMetaData
@freezed
class BranchTreeMetaData with _$BranchTreeMetaData {
  factory BranchTreeMetaData({
    required String name,
    required Map<String, CommitMetaData> commits,
  }) = _BranchMetaData;

  factory BranchTreeMetaData.fromJson(Map<String, Object?> json) => _$BranchTreeMetaDataFromJson(json);
}

extension BranchMetaDataX on BranchTreeMetaData {
  List<CommitMetaData> get sortedBranchCommits => commits.values.toList()
    ..sort(
      (a, b) => -a.commitedAt.compareTo(b.commitedAt),
    );

  CommitMetaData? get latestBranchCommits => sortedBranchCommits.firstOrNull;
}

///CommitMetaData
@freezed
class CommitMetaData with _$CommitMetaData {
  factory CommitMetaData({
    required String sha,
    required String message,
    required Map<String, RepoObjectsData> commitedObjects,
    required DateTime commitedAt,
  }) = _CommitMetaData;

  factory CommitMetaData.fromJson(Map<String, Object?> json) => _$CommitMetaDataFromJson(json);
}
