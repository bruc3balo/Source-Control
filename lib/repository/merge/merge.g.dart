// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MergeMetaDataImpl _$$MergeMetaDataImplFromJson(Map<String, dynamic> json) =>
    _$MergeMetaDataImpl(
      message: json['message'] as String,
      commitsToMerge: (json['commitsToMerge'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CommitMetaData.fromJson(e as Map<String, dynamic>)),
      ),
      mergedAt: DateTime.parse(json['mergedAt'] as String),
    );

Map<String, dynamic> _$$MergeMetaDataImplToJson(_$MergeMetaDataImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'commitsToMerge': instance.commitsToMerge,
      'mergedAt': instance.mergedAt.toIso8601String(),
    };
