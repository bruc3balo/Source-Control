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

MergeMetaData _$MergeMetaDataFromJson(Map<String, dynamic> json) {
  return _MergeMetaData.fromJson(json);
}

/// @nodoc
mixin _$MergeMetaData {
  String get message => throw _privateConstructorUsedError;
  Map<String, CommitMetaData> get commitsToMerge =>
      throw _privateConstructorUsedError;
  DateTime get mergedAt => throw _privateConstructorUsedError;

  /// Serializes this MergeMetaData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MergeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MergeMetaDataCopyWith<MergeMetaData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MergeMetaDataCopyWith<$Res> {
  factory $MergeMetaDataCopyWith(
          MergeMetaData value, $Res Function(MergeMetaData) then) =
      _$MergeMetaDataCopyWithImpl<$Res, MergeMetaData>;
  @useResult
  $Res call(
      {String message,
      Map<String, CommitMetaData> commitsToMerge,
      DateTime mergedAt});
}

/// @nodoc
class _$MergeMetaDataCopyWithImpl<$Res, $Val extends MergeMetaData>
    implements $MergeMetaDataCopyWith<$Res> {
  _$MergeMetaDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MergeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? commitsToMerge = null,
    Object? mergedAt = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      commitsToMerge: null == commitsToMerge
          ? _value.commitsToMerge
          : commitsToMerge // ignore: cast_nullable_to_non_nullable
              as Map<String, CommitMetaData>,
      mergedAt: null == mergedAt
          ? _value.mergedAt
          : mergedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MergeMetaDataImplCopyWith<$Res>
    implements $MergeMetaDataCopyWith<$Res> {
  factory _$$MergeMetaDataImplCopyWith(
          _$MergeMetaDataImpl value, $Res Function(_$MergeMetaDataImpl) then) =
      __$$MergeMetaDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      Map<String, CommitMetaData> commitsToMerge,
      DateTime mergedAt});
}

/// @nodoc
class __$$MergeMetaDataImplCopyWithImpl<$Res>
    extends _$MergeMetaDataCopyWithImpl<$Res, _$MergeMetaDataImpl>
    implements _$$MergeMetaDataImplCopyWith<$Res> {
  __$$MergeMetaDataImplCopyWithImpl(
      _$MergeMetaDataImpl _value, $Res Function(_$MergeMetaDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MergeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? commitsToMerge = null,
    Object? mergedAt = null,
  }) {
    return _then(_$MergeMetaDataImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      commitsToMerge: null == commitsToMerge
          ? _value._commitsToMerge
          : commitsToMerge // ignore: cast_nullable_to_non_nullable
              as Map<String, CommitMetaData>,
      mergedAt: null == mergedAt
          ? _value.mergedAt
          : mergedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MergeMetaDataImpl implements _MergeMetaData {
  _$MergeMetaDataImpl(
      {required this.message,
      required final Map<String, CommitMetaData> commitsToMerge,
      required this.mergedAt})
      : _commitsToMerge = commitsToMerge;

  factory _$MergeMetaDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MergeMetaDataImplFromJson(json);

  @override
  final String message;
  final Map<String, CommitMetaData> _commitsToMerge;
  @override
  Map<String, CommitMetaData> get commitsToMerge {
    if (_commitsToMerge is EqualUnmodifiableMapView) return _commitsToMerge;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_commitsToMerge);
  }

  @override
  final DateTime mergedAt;

  @override
  String toString() {
    return 'MergeMetaData(message: $message, commitsToMerge: $commitsToMerge, mergedAt: $mergedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MergeMetaDataImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._commitsToMerge, _commitsToMerge) &&
            (identical(other.mergedAt, mergedAt) ||
                other.mergedAt == mergedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message,
      const DeepCollectionEquality().hash(_commitsToMerge), mergedAt);

  /// Create a copy of MergeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MergeMetaDataImplCopyWith<_$MergeMetaDataImpl> get copyWith =>
      __$$MergeMetaDataImplCopyWithImpl<_$MergeMetaDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MergeMetaDataImplToJson(
      this,
    );
  }
}

abstract class _MergeMetaData implements MergeMetaData {
  factory _MergeMetaData(
      {required final String message,
      required final Map<String, CommitMetaData> commitsToMerge,
      required final DateTime mergedAt}) = _$MergeMetaDataImpl;

  factory _MergeMetaData.fromJson(Map<String, dynamic> json) =
      _$MergeMetaDataImpl.fromJson;

  @override
  String get message;
  @override
  Map<String, CommitMetaData> get commitsToMerge;
  @override
  DateTime get mergedAt;

  /// Create a copy of MergeMetaData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MergeMetaDataImplCopyWith<_$MergeMetaDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
