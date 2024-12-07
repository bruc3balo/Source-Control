// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StateDataImpl _$$StateDataImplFromJson(Map<String, dynamic> json) =>
    _$StateDataImpl(
      currentBranch: json['currentBranch'] as String,
      currentCommit: json['currentCommit'] as String?,
    );

Map<String, dynamic> _$$StateDataImplToJson(_$StateDataImpl instance) =>
    <String, dynamic>{
      'currentBranch': instance.currentBranch,
      'currentCommit': instance.currentCommit,
    };
