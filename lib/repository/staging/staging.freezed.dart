// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staging.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StagingData _$StagingDataFromJson(Map<String, dynamic> json) {
  return _StagingData.fromJson(json);
}

/// @nodoc
mixin _$StagingData {
  DateTime get stagedAt => throw _privateConstructorUsedError;
  List<String> get filesToBeStaged => throw _privateConstructorUsedError;

  /// Serializes this StagingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StagingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StagingDataCopyWith<StagingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StagingDataCopyWith<$Res> {
  factory $StagingDataCopyWith(
          StagingData value, $Res Function(StagingData) then) =
      _$StagingDataCopyWithImpl<$Res, StagingData>;
  @useResult
  $Res call({DateTime stagedAt, List<String> filesToBeStaged});
}

/// @nodoc
class _$StagingDataCopyWithImpl<$Res, $Val extends StagingData>
    implements $StagingDataCopyWith<$Res> {
  _$StagingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StagingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stagedAt = null,
    Object? filesToBeStaged = null,
  }) {
    return _then(_value.copyWith(
      stagedAt: null == stagedAt
          ? _value.stagedAt
          : stagedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      filesToBeStaged: null == filesToBeStaged
          ? _value.filesToBeStaged
          : filesToBeStaged // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StagingDataImplCopyWith<$Res>
    implements $StagingDataCopyWith<$Res> {
  factory _$$StagingDataImplCopyWith(
          _$StagingDataImpl value, $Res Function(_$StagingDataImpl) then) =
      __$$StagingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime stagedAt, List<String> filesToBeStaged});
}

/// @nodoc
class __$$StagingDataImplCopyWithImpl<$Res>
    extends _$StagingDataCopyWithImpl<$Res, _$StagingDataImpl>
    implements _$$StagingDataImplCopyWith<$Res> {
  __$$StagingDataImplCopyWithImpl(
      _$StagingDataImpl _value, $Res Function(_$StagingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of StagingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stagedAt = null,
    Object? filesToBeStaged = null,
  }) {
    return _then(_$StagingDataImpl(
      stagedAt: null == stagedAt
          ? _value.stagedAt
          : stagedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      filesToBeStaged: null == filesToBeStaged
          ? _value._filesToBeStaged
          : filesToBeStaged // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StagingDataImpl implements _StagingData {
  _$StagingDataImpl(
      {required this.stagedAt, required final List<String> filesToBeStaged})
      : _filesToBeStaged = filesToBeStaged;

  factory _$StagingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StagingDataImplFromJson(json);

  @override
  final DateTime stagedAt;
  final List<String> _filesToBeStaged;
  @override
  List<String> get filesToBeStaged {
    if (_filesToBeStaged is EqualUnmodifiableListView) return _filesToBeStaged;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filesToBeStaged);
  }

  @override
  String toString() {
    return 'StagingData(stagedAt: $stagedAt, filesToBeStaged: $filesToBeStaged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StagingDataImpl &&
            (identical(other.stagedAt, stagedAt) ||
                other.stagedAt == stagedAt) &&
            const DeepCollectionEquality()
                .equals(other._filesToBeStaged, _filesToBeStaged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stagedAt,
      const DeepCollectionEquality().hash(_filesToBeStaged));

  /// Create a copy of StagingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StagingDataImplCopyWith<_$StagingDataImpl> get copyWith =>
      __$$StagingDataImplCopyWithImpl<_$StagingDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StagingDataImplToJson(
      this,
    );
  }
}

abstract class _StagingData implements StagingData {
  factory _StagingData(
      {required final DateTime stagedAt,
      required final List<String> filesToBeStaged}) = _$StagingDataImpl;

  factory _StagingData.fromJson(Map<String, dynamic> json) =
      _$StagingDataImpl.fromJson;

  @override
  DateTime get stagedAt;
  @override
  List<String> get filesToBeStaged;

  /// Create a copy of StagingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StagingDataImplCopyWith<_$StagingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
