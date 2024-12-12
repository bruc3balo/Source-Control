// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repo_objects.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RepoObjectsData _$RepoObjectsDataFromJson(Map<String, dynamic> json) {
  return _RepoObjectsData.fromJson(json);
}

/// @nodoc
mixin _$RepoObjectsData {
  String get sha => throw _privateConstructorUsedError;
  String get filePathRelativeToRepository => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  DateTime get commitedAt => throw _privateConstructorUsedError;

  /// Serializes this RepoObjectsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RepoObjectsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RepoObjectsDataCopyWith<RepoObjectsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepoObjectsDataCopyWith<$Res> {
  factory $RepoObjectsDataCopyWith(
          RepoObjectsData value, $Res Function(RepoObjectsData) then) =
      _$RepoObjectsDataCopyWithImpl<$Res, RepoObjectsData>;
  @useResult
  $Res call(
      {String sha,
      String filePathRelativeToRepository,
      String fileName,
      DateTime commitedAt});
}

/// @nodoc
class _$RepoObjectsDataCopyWithImpl<$Res, $Val extends RepoObjectsData>
    implements $RepoObjectsDataCopyWith<$Res> {
  _$RepoObjectsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RepoObjectsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sha = null,
    Object? filePathRelativeToRepository = null,
    Object? fileName = null,
    Object? commitedAt = null,
  }) {
    return _then(_value.copyWith(
      sha: null == sha
          ? _value.sha
          : sha // ignore: cast_nullable_to_non_nullable
              as String,
      filePathRelativeToRepository: null == filePathRelativeToRepository
          ? _value.filePathRelativeToRepository
          : filePathRelativeToRepository // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      commitedAt: null == commitedAt
          ? _value.commitedAt
          : commitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RepoObjectsDataImplCopyWith<$Res>
    implements $RepoObjectsDataCopyWith<$Res> {
  factory _$$RepoObjectsDataImplCopyWith(_$RepoObjectsDataImpl value,
          $Res Function(_$RepoObjectsDataImpl) then) =
      __$$RepoObjectsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sha,
      String filePathRelativeToRepository,
      String fileName,
      DateTime commitedAt});
}

/// @nodoc
class __$$RepoObjectsDataImplCopyWithImpl<$Res>
    extends _$RepoObjectsDataCopyWithImpl<$Res, _$RepoObjectsDataImpl>
    implements _$$RepoObjectsDataImplCopyWith<$Res> {
  __$$RepoObjectsDataImplCopyWithImpl(
      _$RepoObjectsDataImpl _value, $Res Function(_$RepoObjectsDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of RepoObjectsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sha = null,
    Object? filePathRelativeToRepository = null,
    Object? fileName = null,
    Object? commitedAt = null,
  }) {
    return _then(_$RepoObjectsDataImpl(
      sha: null == sha
          ? _value.sha
          : sha // ignore: cast_nullable_to_non_nullable
              as String,
      filePathRelativeToRepository: null == filePathRelativeToRepository
          ? _value.filePathRelativeToRepository
          : filePathRelativeToRepository // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
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
class _$RepoObjectsDataImpl implements _RepoObjectsData {
  _$RepoObjectsDataImpl(
      {required this.sha,
      required this.filePathRelativeToRepository,
      required this.fileName,
      required this.commitedAt});

  factory _$RepoObjectsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RepoObjectsDataImplFromJson(json);

  @override
  final String sha;
  @override
  final String filePathRelativeToRepository;
  @override
  final String fileName;
  @override
  final DateTime commitedAt;

  @override
  String toString() {
    return 'RepoObjectsData(sha: $sha, filePathRelativeToRepository: $filePathRelativeToRepository, fileName: $fileName, commitedAt: $commitedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepoObjectsDataImpl &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.filePathRelativeToRepository,
                    filePathRelativeToRepository) ||
                other.filePathRelativeToRepository ==
                    filePathRelativeToRepository) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.commitedAt, commitedAt) ||
                other.commitedAt == commitedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, sha, filePathRelativeToRepository, fileName, commitedAt);

  /// Create a copy of RepoObjectsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RepoObjectsDataImplCopyWith<_$RepoObjectsDataImpl> get copyWith =>
      __$$RepoObjectsDataImplCopyWithImpl<_$RepoObjectsDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RepoObjectsDataImplToJson(
      this,
    );
  }
}

abstract class _RepoObjectsData implements RepoObjectsData {
  factory _RepoObjectsData(
      {required final String sha,
      required final String filePathRelativeToRepository,
      required final String fileName,
      required final DateTime commitedAt}) = _$RepoObjectsDataImpl;

  factory _RepoObjectsData.fromJson(Map<String, dynamic> json) =
      _$RepoObjectsDataImpl.fromJson;

  @override
  String get sha;
  @override
  String get filePathRelativeToRepository;
  @override
  String get fileName;
  @override
  DateTime get commitedAt;

  /// Create a copy of RepoObjectsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RepoObjectsDataImplCopyWith<_$RepoObjectsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
