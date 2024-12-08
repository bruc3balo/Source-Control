// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RemoteMetaData _$RemoteMetaDataFromJson(Map<String, dynamic> json) {
  return _RemoteMetaData.fromJson(json);
}

/// @nodoc
mixin _$RemoteMetaData {
  Map<String, RemoteData> get remotes => throw _privateConstructorUsedError;

  /// Serializes this RemoteMetaData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RemoteMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RemoteMetaDataCopyWith<RemoteMetaData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoteMetaDataCopyWith<$Res> {
  factory $RemoteMetaDataCopyWith(
          RemoteMetaData value, $Res Function(RemoteMetaData) then) =
      _$RemoteMetaDataCopyWithImpl<$Res, RemoteMetaData>;
  @useResult
  $Res call({Map<String, RemoteData> remotes});
}

/// @nodoc
class _$RemoteMetaDataCopyWithImpl<$Res, $Val extends RemoteMetaData>
    implements $RemoteMetaDataCopyWith<$Res> {
  _$RemoteMetaDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RemoteMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remotes = null,
  }) {
    return _then(_value.copyWith(
      remotes: null == remotes
          ? _value.remotes
          : remotes // ignore: cast_nullable_to_non_nullable
              as Map<String, RemoteData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RemoteMetaDataImplCopyWith<$Res>
    implements $RemoteMetaDataCopyWith<$Res> {
  factory _$$RemoteMetaDataImplCopyWith(_$RemoteMetaDataImpl value,
          $Res Function(_$RemoteMetaDataImpl) then) =
      __$$RemoteMetaDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, RemoteData> remotes});
}

/// @nodoc
class __$$RemoteMetaDataImplCopyWithImpl<$Res>
    extends _$RemoteMetaDataCopyWithImpl<$Res, _$RemoteMetaDataImpl>
    implements _$$RemoteMetaDataImplCopyWith<$Res> {
  __$$RemoteMetaDataImplCopyWithImpl(
      _$RemoteMetaDataImpl _value, $Res Function(_$RemoteMetaDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of RemoteMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remotes = null,
  }) {
    return _then(_$RemoteMetaDataImpl(
      remotes: null == remotes
          ? _value._remotes
          : remotes // ignore: cast_nullable_to_non_nullable
              as Map<String, RemoteData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RemoteMetaDataImpl implements _RemoteMetaData {
  _$RemoteMetaDataImpl({required final Map<String, RemoteData> remotes})
      : _remotes = remotes;

  factory _$RemoteMetaDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RemoteMetaDataImplFromJson(json);

  final Map<String, RemoteData> _remotes;
  @override
  Map<String, RemoteData> get remotes {
    if (_remotes is EqualUnmodifiableMapView) return _remotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_remotes);
  }

  @override
  String toString() {
    return 'RemoteMetaData(remotes: $remotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteMetaDataImpl &&
            const DeepCollectionEquality().equals(other._remotes, _remotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_remotes));

  /// Create a copy of RemoteMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoteMetaDataImplCopyWith<_$RemoteMetaDataImpl> get copyWith =>
      __$$RemoteMetaDataImplCopyWithImpl<_$RemoteMetaDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RemoteMetaDataImplToJson(
      this,
    );
  }
}

abstract class _RemoteMetaData implements RemoteMetaData {
  factory _RemoteMetaData({required final Map<String, RemoteData> remotes}) =
      _$RemoteMetaDataImpl;

  factory _RemoteMetaData.fromJson(Map<String, dynamic> json) =
      _$RemoteMetaDataImpl.fromJson;

  @override
  Map<String, RemoteData> get remotes;

  /// Create a copy of RemoteMetaData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RemoteMetaDataImplCopyWith<_$RemoteMetaDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RemoteData _$RemoteDataFromJson(Map<String, dynamic> json) {
  return _RemoteData.fromJson(json);
}

/// @nodoc
mixin _$RemoteData {
  String get name => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;

  /// Serializes this RemoteData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RemoteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RemoteDataCopyWith<RemoteData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoteDataCopyWith<$Res> {
  factory $RemoteDataCopyWith(
          RemoteData value, $Res Function(RemoteData) then) =
      _$RemoteDataCopyWithImpl<$Res, RemoteData>;
  @useResult
  $Res call({String name, String url});
}

/// @nodoc
class _$RemoteDataCopyWithImpl<$Res, $Val extends RemoteData>
    implements $RemoteDataCopyWith<$Res> {
  _$RemoteDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RemoteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? url = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RemoteDataImplCopyWith<$Res>
    implements $RemoteDataCopyWith<$Res> {
  factory _$$RemoteDataImplCopyWith(
          _$RemoteDataImpl value, $Res Function(_$RemoteDataImpl) then) =
      __$$RemoteDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String url});
}

/// @nodoc
class __$$RemoteDataImplCopyWithImpl<$Res>
    extends _$RemoteDataCopyWithImpl<$Res, _$RemoteDataImpl>
    implements _$$RemoteDataImplCopyWith<$Res> {
  __$$RemoteDataImplCopyWithImpl(
      _$RemoteDataImpl _value, $Res Function(_$RemoteDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of RemoteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? url = null,
  }) {
    return _then(_$RemoteDataImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RemoteDataImpl implements _RemoteData {
  _$RemoteDataImpl({required this.name, required this.url});

  factory _$RemoteDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RemoteDataImplFromJson(json);

  @override
  final String name;
  @override
  final String url;

  @override
  String toString() {
    return 'RemoteData(name: $name, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteDataImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, url);

  /// Create a copy of RemoteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoteDataImplCopyWith<_$RemoteDataImpl> get copyWith =>
      __$$RemoteDataImplCopyWithImpl<_$RemoteDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RemoteDataImplToJson(
      this,
    );
  }
}

abstract class _RemoteData implements RemoteData {
  factory _RemoteData({required final String name, required final String url}) =
      _$RemoteDataImpl;

  factory _RemoteData.fromJson(Map<String, dynamic> json) =
      _$RemoteDataImpl.fromJson;

  @override
  String get name;
  @override
  String get url;

  /// Create a copy of RemoteData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RemoteDataImplCopyWith<_$RemoteDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
