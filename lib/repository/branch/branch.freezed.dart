// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BranchMetaData _$BranchMetaDataFromJson(Map<String, dynamic> json) {
  return _BranchMetaData.fromJson(json);
}

/// @nodoc
mixin _$BranchMetaData {
  String get name => throw _privateConstructorUsedError;
  Map<String, CommitMetaData> get commits => throw _privateConstructorUsedError;

  /// Serializes this BranchMetaData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BranchMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BranchMetaDataCopyWith<BranchMetaData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BranchMetaDataCopyWith<$Res> {
  factory $BranchMetaDataCopyWith(
          BranchMetaData value, $Res Function(BranchMetaData) then) =
      _$BranchMetaDataCopyWithImpl<$Res, BranchMetaData>;
  @useResult
  $Res call({String name, Map<String, CommitMetaData> commits});
}

/// @nodoc
class _$BranchMetaDataCopyWithImpl<$Res, $Val extends BranchMetaData>
    implements $BranchMetaDataCopyWith<$Res> {
  _$BranchMetaDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BranchMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? commits = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      commits: null == commits
          ? _value.commits
          : commits // ignore: cast_nullable_to_non_nullable
              as Map<String, CommitMetaData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BranchMetaDataImplCopyWith<$Res>
    implements $BranchMetaDataCopyWith<$Res> {
  factory _$$BranchMetaDataImplCopyWith(_$BranchMetaDataImpl value,
          $Res Function(_$BranchMetaDataImpl) then) =
      __$$BranchMetaDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, Map<String, CommitMetaData> commits});
}

/// @nodoc
class __$$BranchMetaDataImplCopyWithImpl<$Res>
    extends _$BranchMetaDataCopyWithImpl<$Res, _$BranchMetaDataImpl>
    implements _$$BranchMetaDataImplCopyWith<$Res> {
  __$$BranchMetaDataImplCopyWithImpl(
      _$BranchMetaDataImpl _value, $Res Function(_$BranchMetaDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of BranchMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? commits = null,
  }) {
    return _then(_$BranchMetaDataImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      commits: null == commits
          ? _value._commits
          : commits // ignore: cast_nullable_to_non_nullable
              as Map<String, CommitMetaData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BranchMetaDataImpl implements _BranchMetaData {
  _$BranchMetaDataImpl(
      {required this.name, required final Map<String, CommitMetaData> commits})
      : _commits = commits;

  factory _$BranchMetaDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BranchMetaDataImplFromJson(json);

  @override
  final String name;
  final Map<String, CommitMetaData> _commits;
  @override
  Map<String, CommitMetaData> get commits {
    if (_commits is EqualUnmodifiableMapView) return _commits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_commits);
  }

  @override
  String toString() {
    return 'BranchMetaData(name: $name, commits: $commits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BranchMetaDataImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._commits, _commits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(_commits));

  /// Create a copy of BranchMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BranchMetaDataImplCopyWith<_$BranchMetaDataImpl> get copyWith =>
      __$$BranchMetaDataImplCopyWithImpl<_$BranchMetaDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BranchMetaDataImplToJson(
      this,
    );
  }
}

abstract class _BranchMetaData implements BranchMetaData {
  factory _BranchMetaData(
          {required final String name,
          required final Map<String, CommitMetaData> commits}) =
      _$BranchMetaDataImpl;

  factory _BranchMetaData.fromJson(Map<String, dynamic> json) =
      _$BranchMetaDataImpl.fromJson;

  @override
  String get name;
  @override
  Map<String, CommitMetaData> get commits;

  /// Create a copy of BranchMetaData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BranchMetaDataImplCopyWith<_$BranchMetaDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommitMetaData _$CommitMetaDataFromJson(Map<String, dynamic> json) {
  return _CommitMetaData.fromJson(json);
}

/// @nodoc
mixin _$CommitMetaData {
  String get sha => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get commitedAt => throw _privateConstructorUsedError;

  /// Serializes this CommitMetaData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommitMetaDataCopyWith<CommitMetaData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommitMetaDataCopyWith<$Res> {
  factory $CommitMetaDataCopyWith(
          CommitMetaData value, $Res Function(CommitMetaData) then) =
      _$CommitMetaDataCopyWithImpl<$Res, CommitMetaData>;
  @useResult
  $Res call({String sha, String message, DateTime commitedAt});
}

/// @nodoc
class _$CommitMetaDataCopyWithImpl<$Res, $Val extends CommitMetaData>
    implements $CommitMetaDataCopyWith<$Res> {
  _$CommitMetaDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sha = null,
    Object? message = null,
    Object? commitedAt = null,
  }) {
    return _then(_value.copyWith(
      sha: null == sha
          ? _value.sha
          : sha // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      commitedAt: null == commitedAt
          ? _value.commitedAt
          : commitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommitMetaDataImplCopyWith<$Res>
    implements $CommitMetaDataCopyWith<$Res> {
  factory _$$CommitMetaDataImplCopyWith(_$CommitMetaDataImpl value,
          $Res Function(_$CommitMetaDataImpl) then) =
      __$$CommitMetaDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sha, String message, DateTime commitedAt});
}

/// @nodoc
class __$$CommitMetaDataImplCopyWithImpl<$Res>
    extends _$CommitMetaDataCopyWithImpl<$Res, _$CommitMetaDataImpl>
    implements _$$CommitMetaDataImplCopyWith<$Res> {
  __$$CommitMetaDataImplCopyWithImpl(
      _$CommitMetaDataImpl _value, $Res Function(_$CommitMetaDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sha = null,
    Object? message = null,
    Object? commitedAt = null,
  }) {
    return _then(_$CommitMetaDataImpl(
      sha: null == sha
          ? _value.sha
          : sha // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      commitedAt: null == commitedAt
          ? _value.commitedAt
          : commitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommitMetaDataImpl implements _CommitMetaData {
  _$CommitMetaDataImpl(
      {required this.sha, required this.message, required this.commitedAt});

  factory _$CommitMetaDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommitMetaDataImplFromJson(json);

  @override
  final String sha;
  @override
  final String message;
  @override
  final DateTime commitedAt;

  @override
  String toString() {
    return 'CommitMetaData(sha: $sha, message: $message, commitedAt: $commitedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommitMetaDataImpl &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.commitedAt, commitedAt) ||
                other.commitedAt == commitedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sha, message, commitedAt);

  /// Create a copy of CommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommitMetaDataImplCopyWith<_$CommitMetaDataImpl> get copyWith =>
      __$$CommitMetaDataImplCopyWithImpl<_$CommitMetaDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommitMetaDataImplToJson(
      this,
    );
  }
}

abstract class _CommitMetaData implements CommitMetaData {
  factory _CommitMetaData(
      {required final String sha,
      required final String message,
      required final DateTime commitedAt}) = _$CommitMetaDataImpl;

  factory _CommitMetaData.fromJson(Map<String, dynamic> json) =
      _$CommitMetaDataImpl.fromJson;

  @override
  String get sha;
  @override
  String get message;
  @override
  DateTime get commitedAt;

  /// Create a copy of CommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommitMetaDataImplCopyWith<_$CommitMetaDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
