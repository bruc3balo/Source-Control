// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RemoteMetaDataImpl _$$RemoteMetaDataImplFromJson(Map<String, dynamic> json) =>
    _$RemoteMetaDataImpl(
      remotes: (json['remotes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, RemoteData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$RemoteMetaDataImplToJson(
        _$RemoteMetaDataImpl instance) =>
    <String, dynamic>{
      'remotes': instance.remotes,
    };

_$RemoteDataImpl _$$RemoteDataImplFromJson(Map<String, dynamic> json) =>
    _$RemoteDataImpl(
      name: json['name'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$$RemoteDataImplToJson(_$RemoteDataImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
    };
