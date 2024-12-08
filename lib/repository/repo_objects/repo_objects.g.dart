// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_objects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RepoObjectsDataImpl _$$RepoObjectsDataImplFromJson(
        Map<String, dynamic> json) =>
    _$RepoObjectsDataImpl(
      sha: json['sha'] as String,
      filePathRelativeToRepository:
          json['filePathRelativeToRepository'] as String,
      commitedAt: DateTime.parse(json['commitedAt'] as String),
    );

Map<String, dynamic> _$$RepoObjectsDataImplToJson(
        _$RepoObjectsDataImpl instance) =>
    <String, dynamic>{
      'sha': instance.sha,
      'filePathRelativeToRepository': instance.filePathRelativeToRepository,
      'commitedAt': instance.commitedAt.toIso8601String(),
    };
