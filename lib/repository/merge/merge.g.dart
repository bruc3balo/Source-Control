// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MergeCommitMetaDataImpl _$$MergeCommitMetaDataImplFromJson(
        Map<String, dynamic> json) =>
    _$MergeCommitMetaDataImpl(
      fromBranchName: json['fromBranchName'] as String,
      commitsToMerge: (json['commitsToMerge'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CommitTreeMetaData.fromJson(e as Map<String, dynamic>)),
      ),
      mergedAt: DateTime.parse(json['mergedAt'] as String),
    );

Map<String, dynamic> _$$MergeCommitMetaDataImplToJson(
        _$MergeCommitMetaDataImpl instance) =>
    <String, dynamic>{
      'fromBranchName': instance.fromBranchName,
      'commitsToMerge': instance.commitsToMerge,
      'mergedAt': instance.mergedAt.toIso8601String(),
    };
