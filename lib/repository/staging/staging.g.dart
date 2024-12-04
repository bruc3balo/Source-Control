// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StagingDataImpl _$$StagingDataImplFromJson(Map<String, dynamic> json) =>
    _$StagingDataImpl(
      stagedAt: DateTime.parse(json['stagedAt'] as String),
      filesToBeStaged: (json['filesToBeStaged'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$StagingDataImplToJson(_$StagingDataImpl instance) =>
    <String, dynamic>{
      'stagedAt': instance.stagedAt.toIso8601String(),
      'filesToBeStaged': instance.filesToBeStaged,
    };
