// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MergeCommitMetaData _$MergeCommitMetaDataFromJson(Map<String, dynamic> json) {
  return _MergeCommitMetaData.fromJson(json);
}

/// @nodoc
mixin _$MergeCommitMetaData {
  String get fromBranchName => throw _privateConstructorUsedError;
  Map<String, CommitTreeMetaData> get commitsToMerge =>
      throw _privateConstructorUsedError;
  DateTime get mergedAt => throw _privateConstructorUsedError;

  /// Serializes this MergeCommitMetaData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MergeCommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MergeCommitMetaDataCopyWith<MergeCommitMetaData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MergeCommitMetaDataCopyWith<$Res> {
  factory $MergeCommitMetaDataCopyWith(
          MergeCommitMetaData value, $Res Function(MergeCommitMetaData) then) =
      _$MergeCommitMetaDataCopyWithImpl<$Res, MergeCommitMetaData>;
  @useResult
  $Res call(
      {String fromBranchName,
      Map<String, CommitTreeMetaData> commitsToMerge,
      DateTime mergedAt});
}

/// @nodoc
class _$MergeCommitMetaDataCopyWithImpl<$Res, $Val extends MergeCommitMetaData>
    implements $MergeCommitMetaDataCopyWith<$Res> {
  _$MergeCommitMetaDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MergeCommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromBranchName = null,
    Object? commitsToMerge = null,
    Object? mergedAt = null,
  }) {
    return _then(_value.copyWith(
      fromBranchName: null == fromBranchName
          ? _value.fromBranchName
          : fromBranchName // ignore: cast_nullable_to_non_nullable
              as String,
      commitsToMerge: null == commitsToMerge
          ? _value.commitsToMerge
          : commitsToMerge // ignore: cast_nullable_to_non_nullable
              as Map<String, CommitTreeMetaData>,
      mergedAt: null == mergedAt
          ? _value.mergedAt
          : mergedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MergeCommitMetaDataImplCopyWith<$Res>
    implements $MergeCommitMetaDataCopyWith<$Res> {
  factory _$$MergeCommitMetaDataImplCopyWith(_$MergeCommitMetaDataImpl value,
          $Res Function(_$MergeCommitMetaDataImpl) then) =
      __$$MergeCommitMetaDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fromBranchName,
      Map<String, CommitTreeMetaData> commitsToMerge,
      DateTime mergedAt});
}

/// @nodoc
class __$$MergeCommitMetaDataImplCopyWithImpl<$Res>
    extends _$MergeCommitMetaDataCopyWithImpl<$Res, _$MergeCommitMetaDataImpl>
    implements _$$MergeCommitMetaDataImplCopyWith<$Res> {
  __$$MergeCommitMetaDataImplCopyWithImpl(_$MergeCommitMetaDataImpl _value,
      $Res Function(_$MergeCommitMetaDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MergeCommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromBranchName = null,
    Object? commitsToMerge = null,
    Object? mergedAt = null,
  }) {
    return _then(_$MergeCommitMetaDataImpl(
      fromBranchName: null == fromBranchName
          ? _value.fromBranchName
          : fromBranchName // ignore: cast_nullable_to_non_nullable
              as String,
      commitsToMerge: null == commitsToMerge
          ? _value._commitsToMerge
          : commitsToMerge // ignore: cast_nullable_to_non_nullable
              as Map<String, CommitTreeMetaData>,
      mergedAt: null == mergedAt
          ? _value.mergedAt
          : mergedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MergeCommitMetaDataImpl implements _MergeCommitMetaData {
  _$MergeCommitMetaDataImpl(
      {required this.fromBranchName,
      required final Map<String, CommitTreeMetaData> commitsToMerge,
      required this.mergedAt})
      : _commitsToMerge = commitsToMerge;

  factory _$MergeCommitMetaDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MergeCommitMetaDataImplFromJson(json);

  @override
  final String fromBranchName;
  final Map<String, CommitTreeMetaData> _commitsToMerge;
  @override
  Map<String, CommitTreeMetaData> get commitsToMerge {
    if (_commitsToMerge is EqualUnmodifiableMapView) return _commitsToMerge;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_commitsToMerge);
  }

  @override
  final DateTime mergedAt;

  @override
  String toString() {
    return 'MergeCommitMetaData(fromBranchName: $fromBranchName, commitsToMerge: $commitsToMerge, mergedAt: $mergedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MergeCommitMetaDataImpl &&
            (identical(other.fromBranchName, fromBranchName) ||
                other.fromBranchName == fromBranchName) &&
            const DeepCollectionEquality()
                .equals(other._commitsToMerge, _commitsToMerge) &&
            (identical(other.mergedAt, mergedAt) ||
                other.mergedAt == mergedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fromBranchName,
      const DeepCollectionEquality().hash(_commitsToMerge), mergedAt);

  /// Create a copy of MergeCommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MergeCommitMetaDataImplCopyWith<_$MergeCommitMetaDataImpl> get copyWith =>
      __$$MergeCommitMetaDataImplCopyWithImpl<_$MergeCommitMetaDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MergeCommitMetaDataImplToJson(
      this,
    );
  }
}

abstract class _MergeCommitMetaData implements MergeCommitMetaData {
  factory _MergeCommitMetaData(
      {required final String fromBranchName,
      required final Map<String, CommitTreeMetaData> commitsToMerge,
      required final DateTime mergedAt}) = _$MergeCommitMetaDataImpl;

  factory _MergeCommitMetaData.fromJson(Map<String, dynamic> json) =
      _$MergeCommitMetaDataImpl.fromJson;

  @override
  String get fromBranchName;
  @override
  Map<String, CommitTreeMetaData> get commitsToMerge;
  @override
  DateTime get mergedAt;

  /// Create a copy of MergeCommitMetaData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MergeCommitMetaDataImplCopyWith<_$MergeCommitMetaDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
