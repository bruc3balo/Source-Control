import 'dart:io';
import 'dart:typed_data';

import 'package:balo/repository/commit.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:path/path.dart' as path;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo_objects.g.dart';

part 'repo_objects.freezed.dart';


///Represents an object's [Uint8List] data with meta data in memory
class RepoObjects {
  final Repository repository;
  final Sha1 sha1;
  final String relativePathToRepository;
  final DateTime commitedAt;
  final Uint8List blob;

  RepoObjects({
    required this.repository,
    required this.sha1,
    required this.relativePathToRepository,
    required this.commitedAt,
    required this.blob,
  });

  static RepoObjects createFromFile(Repository repository, File file) {
    Uint8List blob = file.readAsBytesSync();
    Sha1 sha = computeSha1Hash(blob);
    String relativePathToRepository = file.path.replaceAll(repository.workingDirectory.path, "");
    return RepoObjects(
      repository: repository,
      sha1: sha,
      relativePathToRepository: relativePathToRepository,
      commitedAt: DateTime.now(),
      blob: blob,
    );
  }
}

extension RepoObjectStorage on RepoObjects {

  ///Path to [objectFile]
  String get objectFilePath => path.join(repository.repositoryPath, objectsStore, sha1.sub, sha1.hash);

  ///Actual [RepoObjects] file in a [repository]
  File get objectFile => File(objectFilePath);

  ///Convert a [RepoObjects] to a [RepoObjectsData] for storage
  RepoObjectsData get toRepoObjectsData => RepoObjectsData(
        sha: sha1.hash,
        filePathRelativeToRepository: relativePathToRepository,
        commitedAt: commitedAt,
      );

  ///Writes [blob] into a [objectFile] in a [repository] at [objectsStore]
  RepoObjectsData writeRepoObject() {
    //If it exists, return
    if (objectFile.existsSync()) {
      debugPrintToConsole(message: "Objects ${objectFile.path} already exists");
      return toRepoObjectsData;
    }

    //Write blob
    objectFile.writeAsBytesSync(
      blob,
      mode: FileMode.writeOnly,
      flush: true,
    );

    return toRepoObjectsData;
  }
}

///Entity to store [RepoObjects] in [Commit]s
@freezed
class RepoObjectsData with _$RepoObjectsData {
  factory RepoObjectsData({
    required String sha,
    required String filePathRelativeToRepository,
    required DateTime commitedAt,
  }) = _RepoObjectsData;

  factory RepoObjectsData.fromJson(Map<String, Object?> json) => _$RepoObjectsDataFromJson(json);
}

extension RepoObjectsDataX on RepoObjectsData {
  ///[Sha1] for a specific [RepoObjectsData]
  Sha1 get sha1 => Sha1(sha);

  ///Returns a [RepoObjects] from a [repository] if it exists
  RepoObjects? fetchObject(Repository repository) {
    String objectFilePath = path.join(repository.repositoryPath, objectsStore, sha1.sub, sha1.hash);
    File objectFile = File(objectFilePath);

    if (!objectFile.existsSync()) {
      debugPrintToConsole(message: "Objects $sha not found on path ${objectFile.path}");
      return null;
    }

    return RepoObjects(
      repository: repository,
      sha1: sha1,
      relativePathToRepository: filePathRelativeToRepository,
      commitedAt: commitedAt,
      blob: objectFile.readAsBytesSync(),
    );
  }
}
