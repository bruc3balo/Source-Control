import 'dart:convert';
import 'dart:io';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/remote/remote.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/print_fn.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';

/// A [Directory] containing source control working data
class Repository {
  final String path;

  Repository(this.path);
}

extension RepositoryActions on Repository {
  /// Delete all [Repository] data
  void unInitializeRepository({
    void Function()? onRepositoryNotInitialized = onRepositoryNotInitialized,
    void Function()? onSuccessfullyUninitialized = onRepositorySuccessfullyUninitialized,
  }) {
    if (!isInitialized) {
      onRepositoryNotInitialized?.call();
      return;
    }

    repositoryDirectory.deleteSync(recursive: true);
    onSuccessfullyUninitialized?.call();
  }

  /// Create a [Repository] in [path]
  void initializeRepository({
    Function()? onAlreadyInitialized = onRepositoryAlreadyInitialized,
    Function()? onSuccessfullyInitialized = onRepositorySuccessfullyUninitialized,
  }) {
    if (isInitialized) {
      printToConsole(
        message: "Repository is already initialized",
        color: CliColor.red,
      );
      onAlreadyInitialized?.call();
      return;
    }

    repositoryDirectory.createSync(recursive: true);
    onSuccessfullyInitialized?.call();
    printToConsole(
      message: "Repository initialized",
    );
  }
}

extension RepositoryCommons on Repository {
  /// Path to a [repositoryDirectory]
  String get repositoryPath => join(path, repositoryWorkingDirName);

  /// Directory of a [Repository]
  Directory get repositoryDirectory => Directory(repositoryPath);

  /// Directory where a [Repository] and project lives in
  Directory get workingDirectory => Directory(repositoryDirectory.parent.path);

  /// Checks if a [repositoryWorkingDirName] exists
  bool get isInitialized => repositoryDirectory.existsSync();
}

extension RepositoryEnvironment on Repository {
  /// Get all [Branch]es in a [Repository]
  List<Branch> get allBranches => Directory(join(repositoryPath, branchFolderName))
      .listSync(recursive: false, followLinks: false)
      .where((f) => f.statSync().type == FileSystemEntityType.directory)
      .map((f) => Branch(basename(f.path), this))
      .toList();

  /// [Ignore] file in a [Repository]
  Ignore get ignore => Ignore(this);

  /// [State] file in a [Repository]
  State get state => State(this);

  /// [Remote] file in a [Repository]
  RemoteMetaData? get remoteMetaData {
    String remotePath = join(repositoryDirectory.path, remoteFileName);
    File remoteFile = File(remotePath);

    if (!remoteFile.existsSync()) {
      return null;
    }

    String data = remoteFile.readAsStringSync();
    return RemoteMetaData.fromJson(jsonDecode(data));
  }
}
