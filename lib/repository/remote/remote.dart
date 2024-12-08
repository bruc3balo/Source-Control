import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:balo/repository/repository.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote.g.dart';

part 'remote.freezed.dart';

class Remote {
  final Repository repository;
  final String name;
  final String url;

  Remote(this.repository, this.name, this.url);

  bool get isPath => url.startsWith("/");
}

extension RemoteCommons on Remote {
  String get remoteFilePath => join(repository.repositoryDirectory.path, remoteFileName);

  File get remoteFile => File(remoteFilePath);

  bool get remoteFileExists => remoteFile.existsSync();

  RemoteData? get remote => remoteData.remotes[name];
}

extension RemoteStorage on Remote {
  void saveRemoteData(RemoteMetaData metaData) {
    remoteFile.writeAsStringSync(
      jsonEncode(metaData),
      mode: FileMode.writeOnly,
      flush: true,
    );
  }

  RemoteMetaData get remoteData {
    if (!remoteFileExists) {
      RemoteMetaData data = RemoteMetaData(remotes: HashMap());
      saveRemoteData(data);
      return data;
    }

    String data = remoteFile.readAsStringSync();
    return RemoteMetaData.fromJson(jsonDecode(data));
  }

}

extension RemoteActions on Remote {
  void addRemote({
    Function()? onRemoteAlreadyExists,
  }) {
    RemoteMetaData metaData = remoteData;
    RemoteData? rData = metaData.remotes[name];
    if (rData != null && rData.url == this.url) {
      onRemoteAlreadyExists?.call();
      return;
    }

    RemoteData updated = RemoteData(name: name, url: this.url);
    final Map<String, RemoteData> updatedMap = Map<String, RemoteData>.from(metaData.remotes)
      ..update(
        name,
        (_) => updated,
        ifAbsent: () => updated,
      );

    saveRemoteData(metaData.copyWith(remotes: updatedMap));
  }

  void removeRemote({
    Function()? onRemoteDoesntExists,
  }) {
    RemoteMetaData metaData = remoteData;
    if (!metaData.remotes.containsKey(name)) {
      onRemoteDoesntExists?.call();
      return;
    }

    final Map<String, RemoteData> updatedMap = Map<String, RemoteData>.from(metaData.remotes)
      ..remove(name);
    saveRemoteData(metaData.copyWith(remotes: updatedMap));
  }
}

@freezed
class RemoteMetaData with _$RemoteMetaData {
  factory RemoteMetaData({
    required Map<String, RemoteData> remotes,
  }) = _RemoteMetaData;

  factory RemoteMetaData.fromJson(Map<String, Object?> json) => _$RemoteMetaDataFromJson(json);
}

@freezed
class RemoteData with _$RemoteData {
  factory RemoteData({
    required String name,
    required String url,
  }) = _RemoteData;

  factory RemoteData.fromJson(Map<String, Object?> json) => _$RemoteDataFromJson(json);
}
