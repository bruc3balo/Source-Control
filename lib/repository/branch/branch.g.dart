// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BranchMetaDataImpl _$$BranchMetaDataImplFromJson(Map<String, dynamic> json) =>
    _$BranchMetaDataImpl(
      name: json['name'] as String,
      commits: (json['commits'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CommitTreeMetaData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$BranchMetaDataImplToJson(
        _$BranchMetaDataImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'commits': instance.commits,
    };

_$CommitTreeMetaDataImpl _$$CommitTreeMetaDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CommitTreeMetaDataImpl(
      originalBranch: json['originalBranch'] as String,
      sha: json['sha'] as String,
      message: json['message'] as String,
      commitedObjects: (json['commitedObjects'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, RepoObjectsData.fromJson(e as Map<String, dynamic>)),
      ),
      commitedAt: DateTime.parse(json['commitedAt'] as String),
    );

Map<String, dynamic> _$$CommitTreeMetaDataImplToJson(
        _$CommitTreeMetaDataImpl instance) =>
    <String, dynamic>{
      'originalBranch': instance.originalBranch,
      'sha': instance.sha,
      'message': instance.message,
      'commitedObjects': instance.commitedObjects,
      'commitedAt': instance.commitedAt.toIso8601String(),
    };
