// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nino_create_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NinoCreateState {

 String? get nfcUid; bool get isLoading;
/// Create a copy of NinoCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NinoCreateStateCopyWith<NinoCreateState> get copyWith => _$NinoCreateStateCopyWithImpl<NinoCreateState>(this as NinoCreateState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NinoCreateState&&(identical(other.nfcUid, nfcUid) || other.nfcUid == nfcUid)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,nfcUid,isLoading);

@override
String toString() {
  return 'NinoCreateState(nfcUid: $nfcUid, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $NinoCreateStateCopyWith<$Res>  {
  factory $NinoCreateStateCopyWith(NinoCreateState value, $Res Function(NinoCreateState) _then) = _$NinoCreateStateCopyWithImpl;
@useResult
$Res call({
 String? nfcUid, bool isLoading
});




}
/// @nodoc
class _$NinoCreateStateCopyWithImpl<$Res>
    implements $NinoCreateStateCopyWith<$Res> {
  _$NinoCreateStateCopyWithImpl(this._self, this._then);

  final NinoCreateState _self;
  final $Res Function(NinoCreateState) _then;

/// Create a copy of NinoCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nfcUid = freezed,Object? isLoading = null,}) {
  return _then(_self.copyWith(
nfcUid: freezed == nfcUid ? _self.nfcUid : nfcUid // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NinoCreateState].
extension NinoCreateStatePatterns on NinoCreateState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NinoCreateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NinoCreateState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NinoCreateState value)  $default,){
final _that = this;
switch (_that) {
case _NinoCreateState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NinoCreateState value)?  $default,){
final _that = this;
switch (_that) {
case _NinoCreateState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? nfcUid,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NinoCreateState() when $default != null:
return $default(_that.nfcUid,_that.isLoading);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? nfcUid,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _NinoCreateState():
return $default(_that.nfcUid,_that.isLoading);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? nfcUid,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _NinoCreateState() when $default != null:
return $default(_that.nfcUid,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _NinoCreateState extends NinoCreateState {
  const _NinoCreateState({this.nfcUid = null, this.isLoading = false}): super._();
  

@override@JsonKey() final  String? nfcUid;
@override@JsonKey() final  bool isLoading;

/// Create a copy of NinoCreateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NinoCreateStateCopyWith<_NinoCreateState> get copyWith => __$NinoCreateStateCopyWithImpl<_NinoCreateState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NinoCreateState&&(identical(other.nfcUid, nfcUid) || other.nfcUid == nfcUid)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,nfcUid,isLoading);

@override
String toString() {
  return 'NinoCreateState(nfcUid: $nfcUid, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$NinoCreateStateCopyWith<$Res> implements $NinoCreateStateCopyWith<$Res> {
  factory _$NinoCreateStateCopyWith(_NinoCreateState value, $Res Function(_NinoCreateState) _then) = __$NinoCreateStateCopyWithImpl;
@override @useResult
$Res call({
 String? nfcUid, bool isLoading
});




}
/// @nodoc
class __$NinoCreateStateCopyWithImpl<$Res>
    implements _$NinoCreateStateCopyWith<$Res> {
  __$NinoCreateStateCopyWithImpl(this._self, this._then);

  final _NinoCreateState _self;
  final $Res Function(_NinoCreateState) _then;

/// Create a copy of NinoCreateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nfcUid = freezed,Object? isLoading = null,}) {
  return _then(_NinoCreateState(
nfcUid: freezed == nfcUid ? _self.nfcUid : nfcUid // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
