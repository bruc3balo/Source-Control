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
            MapEntry(k, CommitMetaData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$BranchMetaDataImplToJson(
        _$BranchMetaDataImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'commits': instance.commits,
    };

_$CommitMetaDataImpl _$$CommitMetaDataImplFromJson(Map<String, dynamic> json) =>
    _$CommitMetaDataImpl(
      sha: json['sha'] as String,
      message: json['message'] as String,
      commitedAt: DateTime.parse(json['commitedAt'] as String),
    );

Map<String, dynamic> _$$CommitMetaDataImplToJson(
        _$CommitMetaDataImpl instance) =>
    <String, dynamic>{
      'sha': instance.sha,
      'message': instance.message,
      'commitedAt': instance.commitedAt.toIso8601String(),
    };
