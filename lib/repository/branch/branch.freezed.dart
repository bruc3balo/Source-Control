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

BranchTreeMetaData _$BranchTreeMetaDataFromJson(Map<String, dynamic> json) {
  return _BranchMetaData.fromJson(json);
}

/// @nodoc
mixin _$BranchTreeMetaData {
  String get name => throw _privateConstructorUsedError;
  Map<String, CommitTreeMetaData> get commits =>
      throw _privateConstructorUsedError;

  /// Serializes this BranchTreeMetaData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BranchTreeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BranchTreeMetaDataCopyWith<BranchTreeMetaData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BranchTreeMetaDataCopyWith<$Res> {
  factory $BranchTreeMetaDataCopyWith(
          BranchTreeMetaData value, $Res Function(BranchTreeMetaData) then) =
      _$BranchTreeMetaDataCopyWithImpl<$Res, BranchTreeMetaData>;
  @useResult
  $Res call({String name, Map<String, CommitTreeMetaData> commits});
}

/// @nodoc
class _$BranchTreeMetaDataCopyWithImpl<$Res, $Val extends BranchTreeMetaData>
    implements $BranchTreeMetaDataCopyWith<$Res> {
  _$BranchTreeMetaDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BranchTreeMetaData
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
              as Map<String, CommitTreeMetaData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BranchMetaDataImplCopyWith<$Res>
    implements $BranchTreeMetaDataCopyWith<$Res> {
  factory _$$BranchMetaDataImplCopyWith(_$BranchMetaDataImpl value,
          $Res Function(_$BranchMetaDataImpl) then) =
      __$$BranchMetaDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, Map<String, CommitTreeMetaData> commits});
}

/// @nodoc
class __$$BranchMetaDataImplCopyWithImpl<$Res>
    extends _$BranchTreeMetaDataCopyWithImpl<$Res, _$BranchMetaDataImpl>
    implements _$$BranchMetaDataImplCopyWith<$Res> {
  __$$BranchMetaDataImplCopyWithImpl(
      _$BranchMetaDataImpl _value, $Res Function(_$BranchMetaDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of BranchTreeMetaData
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
              as Map<String, CommitTreeMetaData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BranchMetaDataImpl implements _BranchMetaData {
  _$BranchMetaDataImpl(
      {required this.name,
      required final Map<String, CommitTreeMetaData> commits})
      : _commits = commits;

  factory _$BranchMetaDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BranchMetaDataImplFromJson(json);

  @override
  final String name;
  final Map<String, CommitTreeMetaData> _commits;
  @override
  Map<String, CommitTreeMetaData> get commits {
    if (_commits is EqualUnmodifiableMapView) return _commits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_commits);
  }

  @override
  String toString() {
    return 'BranchTreeMetaData(name: $name, commits: $commits)';
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

  /// Create a copy of BranchTreeMetaData
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

abstract class _BranchMetaData implements BranchTreeMetaData {
  factory _BranchMetaData(
          {required final String name,
          required final Map<String, CommitTreeMetaData> commits}) =
      _$BranchMetaDataImpl;

  factory _BranchMetaData.fromJson(Map<String, dynamic> json) =
      _$BranchMetaDataImpl.fromJson;

  @override
  String get name;
  @override
  Map<String, CommitTreeMetaData> get commits;

  /// Create a copy of BranchTreeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BranchMetaDataImplCopyWith<_$BranchMetaDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommitTreeMetaData _$CommitTreeMetaDataFromJson(Map<String, dynamic> json) {
  return _CommitTreeMetaData.fromJson(json);
}

/// @nodoc
mixin _$CommitTreeMetaData {
  String get originalBranch => throw _privateConstructorUsedError;
  String get sha => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  Map<String, RepoObjectsData> get commitedObjects =>
      throw _privateConstructorUsedError;
  DateTime get commitedAt => throw _privateConstructorUsedError;

  /// Serializes this CommitTreeMetaData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommitTreeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommitTreeMetaDataCopyWith<CommitTreeMetaData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommitTreeMetaDataCopyWith<$Res> {
  factory $CommitTreeMetaDataCopyWith(
          CommitTreeMetaData value, $Res Function(CommitTreeMetaData) then) =
      _$CommitTreeMetaDataCopyWithImpl<$Res, CommitTreeMetaData>;
  @useResult
  $Res call(
      {String originalBranch,
      String sha,
      String message,
      Map<String, RepoObjectsData> commitedObjects,
      DateTime commitedAt});
}

/// @nodoc
class _$CommitTreeMetaDataCopyWithImpl<$Res, $Val extends CommitTreeMetaData>
    implements $CommitTreeMetaDataCopyWith<$Res> {
  _$CommitTreeMetaDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommitTreeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalBranch = null,
    Object? sha = null,
    Object? message = null,
    Object? commitedObjects = null,
    Object? commitedAt = null,
  }) {
    return _then(_value.copyWith(
      originalBranch: null == originalBranch
          ? _value.originalBranch
          : originalBranch // ignore: cast_nullable_to_non_nullable
              as String,
      sha: null == sha
          ? _value.sha
          : sha // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      commitedObjects: null == commitedObjects
          ? _value.commitedObjects
          : commitedObjects // ignore: cast_nullable_to_non_nullable
              as Map<String, RepoObjectsData>,
      commitedAt: null == commitedAt
          ? _value.commitedAt
          : commitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommitTreeMetaDataImplCopyWith<$Res>
    implements $CommitTreeMetaDataCopyWith<$Res> {
  factory _$$CommitTreeMetaDataImplCopyWith(_$CommitTreeMetaDataImpl value,
          $Res Function(_$CommitTreeMetaDataImpl) then) =
      __$$CommitTreeMetaDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String originalBranch,
      String sha,
      String message,
      Map<String, RepoObjectsData> commitedObjects,
      DateTime commitedAt});
}

/// @nodoc
class __$$CommitTreeMetaDataImplCopyWithImpl<$Res>
    extends _$CommitTreeMetaDataCopyWithImpl<$Res, _$CommitTreeMetaDataImpl>
    implements _$$CommitTreeMetaDataImplCopyWith<$Res> {
  __$$CommitTreeMetaDataImplCopyWithImpl(_$CommitTreeMetaDataImpl _value,
      $Res Function(_$CommitTreeMetaDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommitTreeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalBranch = null,
    Object? sha = null,
    Object? message = null,
    Object? commitedObjects = null,
    Object? commitedAt = null,
  }) {
    return _then(_$CommitTreeMetaDataImpl(
      originalBranch: null == originalBranch
          ? _value.originalBranch
          : originalBranch // ignore: cast_nullable_to_non_nullable
              as String,
      sha: null == sha
          ? _value.sha
          : sha // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      commitedObjects: null == commitedObjects
          ? _value._commitedObjects
          : commitedObjects // ignore: cast_nullable_to_non_nullable
              as Map<String, RepoObjectsData>,
      commitedAt: null == commitedAt
          ? _value.commitedAt
          : commitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommitTreeMetaDataImpl implements _CommitTreeMetaData {
  _$CommitTreeMetaDataImpl(
      {required this.originalBranch,
      required this.sha,
      required this.message,
      required final Map<String, RepoObjectsData> commitedObjects,
      required this.commitedAt})
      : _commitedObjects = commitedObjects;

  factory _$CommitTreeMetaDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommitTreeMetaDataImplFromJson(json);

  @override
  final String originalBranch;
  @override
  final String sha;
  @override
  final String message;
  final Map<String, RepoObjectsData> _commitedObjects;
  @override
  Map<String, RepoObjectsData> get commitedObjects {
    if (_commitedObjects is EqualUnmodifiableMapView) return _commitedObjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_commitedObjects);
  }

  @override
  final DateTime commitedAt;

  @override
  String toString() {
    return 'CommitTreeMetaData(originalBranch: $originalBranch, sha: $sha, message: $message, commitedObjects: $commitedObjects, commitedAt: $commitedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommitTreeMetaDataImpl &&
            (identical(other.originalBranch, originalBranch) ||
                other.originalBranch == originalBranch) &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._commitedObjects, _commitedObjects) &&
            (identical(other.commitedAt, commitedAt) ||
                other.commitedAt == commitedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, originalBranch, sha, message,
      const DeepCollectionEquality().hash(_commitedObjects), commitedAt);

  /// Create a copy of CommitTreeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommitTreeMetaDataImplCopyWith<_$CommitTreeMetaDataImpl> get copyWith =>
      __$$CommitTreeMetaDataImplCopyWithImpl<_$CommitTreeMetaDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommitTreeMetaDataImplToJson(
      this,
    );
  }
}

abstract class _CommitTreeMetaData implements CommitTreeMetaData {
  factory _CommitTreeMetaData(
      {required final String originalBranch,
      required final String sha,
      required final String message,
      required final Map<String, RepoObjectsData> commitedObjects,
      required final DateTime commitedAt}) = _$CommitTreeMetaDataImpl;

  factory _CommitTreeMetaData.fromJson(Map<String, dynamic> json) =
      _$CommitTreeMetaDataImpl.fromJson;

  @override
  String get originalBranch;
  @override
  String get sha;
  @override
  String get message;
  @override
  Map<String, RepoObjectsData> get commitedObjects;
  @override
  DateTime get commitedAt;

  /// Create a copy of CommitTreeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommitTreeMetaDataImplCopyWith<_$CommitTreeMetaDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
