// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChangeValue _$ChangeValueFromJson(Map<String, dynamic> json) {
  return _ChangeValue.fromJson(json);
}

/// @nodoc
mixin _$ChangeValue {
  dynamic get value => throw _privateConstructorUsedError;

  /// Serializes this ChangeValue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChangeValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChangeValueCopyWith<ChangeValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangeValueCopyWith<$Res> {
  factory $ChangeValueCopyWith(
    ChangeValue value,
    $Res Function(ChangeValue) then,
  ) = _$ChangeValueCopyWithImpl<$Res, ChangeValue>;
  @useResult
  $Res call({dynamic value});
}

/// @nodoc
class _$ChangeValueCopyWithImpl<$Res, $Val extends ChangeValue>
    implements $ChangeValueCopyWith<$Res> {
  _$ChangeValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChangeValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = freezed}) {
    return _then(
      _value.copyWith(
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChangeValueImplCopyWith<$Res>
    implements $ChangeValueCopyWith<$Res> {
  factory _$$ChangeValueImplCopyWith(
    _$ChangeValueImpl value,
    $Res Function(_$ChangeValueImpl) then,
  ) = __$$ChangeValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic value});
}

/// @nodoc
class __$$ChangeValueImplCopyWithImpl<$Res>
    extends _$ChangeValueCopyWithImpl<$Res, _$ChangeValueImpl>
    implements _$$ChangeValueImplCopyWith<$Res> {
  __$$ChangeValueImplCopyWithImpl(
    _$ChangeValueImpl _value,
    $Res Function(_$ChangeValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChangeValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = freezed}) {
    return _then(
      _$ChangeValueImpl(
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChangeValueImpl implements _ChangeValue {
  const _$ChangeValueImpl({this.value});

  factory _$ChangeValueImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChangeValueImplFromJson(json);

  @override
  final dynamic value;

  @override
  String toString() {
    return 'ChangeValue(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangeValueImpl &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));

  /// Create a copy of ChangeValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangeValueImplCopyWith<_$ChangeValueImpl> get copyWith =>
      __$$ChangeValueImplCopyWithImpl<_$ChangeValueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChangeValueImplToJson(this);
  }
}

abstract class _ChangeValue implements ChangeValue {
  const factory _ChangeValue({final dynamic value}) = _$ChangeValueImpl;

  factory _ChangeValue.fromJson(Map<String, dynamic> json) =
      _$ChangeValueImpl.fromJson;

  @override
  dynamic get value;

  /// Create a copy of ChangeValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangeValueImplCopyWith<_$ChangeValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChangeItem _$ChangeItemFromJson(Map<String, dynamic> json) {
  return _ChangeItem.fromJson(json);
}

/// @nodoc
mixin _$ChangeItem {
  String get id => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  @JsonKey(name: 'iso_639_1')
  String? get language => throw _privateConstructorUsedError;
  @JsonKey(name: 'iso_3166_1')
  String? get country => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_value')
  dynamic get originalValue => throw _privateConstructorUsedError;

  /// Serializes this ChangeItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChangeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChangeItemCopyWith<ChangeItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangeItemCopyWith<$Res> {
  factory $ChangeItemCopyWith(
    ChangeItem value,
    $Res Function(ChangeItem) then,
  ) = _$ChangeItemCopyWithImpl<$Res, ChangeItem>;
  @useResult
  $Res call({
    String id,
    String action,
    String time,
    @JsonKey(name: 'iso_639_1') String? language,
    @JsonKey(name: 'iso_3166_1') String? country,
    dynamic value,
    @JsonKey(name: 'original_value') dynamic originalValue,
  });
}

/// @nodoc
class _$ChangeItemCopyWithImpl<$Res, $Val extends ChangeItem>
    implements $ChangeItemCopyWith<$Res> {
  _$ChangeItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChangeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? time = null,
    Object? language = freezed,
    Object? country = freezed,
    Object? value = freezed,
    Object? originalValue = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            originalValue: freezed == originalValue
                ? _value.originalValue
                : originalValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChangeItemImplCopyWith<$Res>
    implements $ChangeItemCopyWith<$Res> {
  factory _$$ChangeItemImplCopyWith(
    _$ChangeItemImpl value,
    $Res Function(_$ChangeItemImpl) then,
  ) = __$$ChangeItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String action,
    String time,
    @JsonKey(name: 'iso_639_1') String? language,
    @JsonKey(name: 'iso_3166_1') String? country,
    dynamic value,
    @JsonKey(name: 'original_value') dynamic originalValue,
  });
}

/// @nodoc
class __$$ChangeItemImplCopyWithImpl<$Res>
    extends _$ChangeItemCopyWithImpl<$Res, _$ChangeItemImpl>
    implements _$$ChangeItemImplCopyWith<$Res> {
  __$$ChangeItemImplCopyWithImpl(
    _$ChangeItemImpl _value,
    $Res Function(_$ChangeItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChangeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? time = null,
    Object? language = freezed,
    Object? country = freezed,
    Object? value = freezed,
    Object? originalValue = freezed,
  }) {
    return _then(
      _$ChangeItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        originalValue: freezed == originalValue
            ? _value.originalValue
            : originalValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChangeItemImpl implements _ChangeItem {
  const _$ChangeItemImpl({
    required this.id,
    required this.action,
    required this.time,
    @JsonKey(name: 'iso_639_1') this.language,
    @JsonKey(name: 'iso_3166_1') this.country,
    this.value,
    @JsonKey(name: 'original_value') this.originalValue,
  });

  factory _$ChangeItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChangeItemImplFromJson(json);

  @override
  final String id;
  @override
  final String action;
  @override
  final String time;
  @override
  @JsonKey(name: 'iso_639_1')
  final String? language;
  @override
  @JsonKey(name: 'iso_3166_1')
  final String? country;
  @override
  final dynamic value;
  @override
  @JsonKey(name: 'original_value')
  final dynamic originalValue;

  @override
  String toString() {
    return 'ChangeItem(id: $id, action: $action, time: $time, language: $language, country: $country, value: $value, originalValue: $originalValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangeItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.country, country) || other.country == country) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            const DeepCollectionEquality().equals(
              other.originalValue,
              originalValue,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    action,
    time,
    language,
    country,
    const DeepCollectionEquality().hash(value),
    const DeepCollectionEquality().hash(originalValue),
  );

  /// Create a copy of ChangeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangeItemImplCopyWith<_$ChangeItemImpl> get copyWith =>
      __$$ChangeItemImplCopyWithImpl<_$ChangeItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChangeItemImplToJson(this);
  }
}

abstract class _ChangeItem implements ChangeItem {
  const factory _ChangeItem({
    required final String id,
    required final String action,
    required final String time,
    @JsonKey(name: 'iso_639_1') final String? language,
    @JsonKey(name: 'iso_3166_1') final String? country,
    final dynamic value,
    @JsonKey(name: 'original_value') final dynamic originalValue,
  }) = _$ChangeItemImpl;

  factory _ChangeItem.fromJson(Map<String, dynamic> json) =
      _$ChangeItemImpl.fromJson;

  @override
  String get id;
  @override
  String get action;
  @override
  String get time;
  @override
  @JsonKey(name: 'iso_639_1')
  String? get language;
  @override
  @JsonKey(name: 'iso_3166_1')
  String? get country;
  @override
  dynamic get value;
  @override
  @JsonKey(name: 'original_value')
  dynamic get originalValue;

  /// Create a copy of ChangeItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangeItemImplCopyWith<_$ChangeItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Change _$ChangeFromJson(Map<String, dynamic> json) {
  return _Change.fromJson(json);
}

/// @nodoc
mixin _$Change {
  String get key => throw _privateConstructorUsedError;
  List<ChangeItem> get items => throw _privateConstructorUsedError;

  /// Serializes this Change to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Change
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChangeCopyWith<Change> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangeCopyWith<$Res> {
  factory $ChangeCopyWith(Change value, $Res Function(Change) then) =
      _$ChangeCopyWithImpl<$Res, Change>;
  @useResult
  $Res call({String key, List<ChangeItem> items});
}

/// @nodoc
class _$ChangeCopyWithImpl<$Res, $Val extends Change>
    implements $ChangeCopyWith<$Res> {
  _$ChangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Change
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? items = null}) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ChangeItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChangeImplCopyWith<$Res> implements $ChangeCopyWith<$Res> {
  factory _$$ChangeImplCopyWith(
    _$ChangeImpl value,
    $Res Function(_$ChangeImpl) then,
  ) = __$$ChangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, List<ChangeItem> items});
}

/// @nodoc
class __$$ChangeImplCopyWithImpl<$Res>
    extends _$ChangeCopyWithImpl<$Res, _$ChangeImpl>
    implements _$$ChangeImplCopyWith<$Res> {
  __$$ChangeImplCopyWithImpl(
    _$ChangeImpl _value,
    $Res Function(_$ChangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Change
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? items = null}) {
    return _then(
      _$ChangeImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ChangeItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChangeImpl implements _Change {
  const _$ChangeImpl({
    required this.key,
    final List<ChangeItem> items = const [],
  }) : _items = items;

  factory _$ChangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChangeImplFromJson(json);

  @override
  final String key;
  final List<ChangeItem> _items;
  @override
  @JsonKey()
  List<ChangeItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'Change(key: $key, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangeImpl &&
            (identical(other.key, key) || other.key == key) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    key,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of Change
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangeImplCopyWith<_$ChangeImpl> get copyWith =>
      __$$ChangeImplCopyWithImpl<_$ChangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChangeImplToJson(this);
  }
}

abstract class _Change implements Change {
  const factory _Change({
    required final String key,
    final List<ChangeItem> items,
  }) = _$ChangeImpl;

  factory _Change.fromJson(Map<String, dynamic> json) = _$ChangeImpl.fromJson;

  @override
  String get key;
  @override
  List<ChangeItem> get items;

  /// Create a copy of Change
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangeImplCopyWith<_$ChangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChangesResponse _$ChangesResponseFromJson(Map<String, dynamic> json) {
  return _ChangesResponse.fromJson(json);
}

/// @nodoc
mixin _$ChangesResponse {
  List<Change> get changes => throw _privateConstructorUsedError;

  /// Serializes this ChangesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChangesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChangesResponseCopyWith<ChangesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangesResponseCopyWith<$Res> {
  factory $ChangesResponseCopyWith(
    ChangesResponse value,
    $Res Function(ChangesResponse) then,
  ) = _$ChangesResponseCopyWithImpl<$Res, ChangesResponse>;
  @useResult
  $Res call({List<Change> changes});
}

/// @nodoc
class _$ChangesResponseCopyWithImpl<$Res, $Val extends ChangesResponse>
    implements $ChangesResponseCopyWith<$Res> {
  _$ChangesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChangesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? changes = null}) {
    return _then(
      _value.copyWith(
            changes: null == changes
                ? _value.changes
                : changes // ignore: cast_nullable_to_non_nullable
                      as List<Change>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChangesResponseImplCopyWith<$Res>
    implements $ChangesResponseCopyWith<$Res> {
  factory _$$ChangesResponseImplCopyWith(
    _$ChangesResponseImpl value,
    $Res Function(_$ChangesResponseImpl) then,
  ) = __$$ChangesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Change> changes});
}

/// @nodoc
class __$$ChangesResponseImplCopyWithImpl<$Res>
    extends _$ChangesResponseCopyWithImpl<$Res, _$ChangesResponseImpl>
    implements _$$ChangesResponseImplCopyWith<$Res> {
  __$$ChangesResponseImplCopyWithImpl(
    _$ChangesResponseImpl _value,
    $Res Function(_$ChangesResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChangesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? changes = null}) {
    return _then(
      _$ChangesResponseImpl(
        changes: null == changes
            ? _value._changes
            : changes // ignore: cast_nullable_to_non_nullable
                  as List<Change>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChangesResponseImpl implements _ChangesResponse {
  const _$ChangesResponseImpl({final List<Change> changes = const []})
    : _changes = changes;

  factory _$ChangesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChangesResponseImplFromJson(json);

  final List<Change> _changes;
  @override
  @JsonKey()
  List<Change> get changes {
    if (_changes is EqualUnmodifiableListView) return _changes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_changes);
  }

  @override
  String toString() {
    return 'ChangesResponse(changes: $changes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangesResponseImpl &&
            const DeepCollectionEquality().equals(other._changes, _changes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_changes));

  /// Create a copy of ChangesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangesResponseImplCopyWith<_$ChangesResponseImpl> get copyWith =>
      __$$ChangesResponseImplCopyWithImpl<_$ChangesResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChangesResponseImplToJson(this);
  }
}

abstract class _ChangesResponse implements ChangesResponse {
  const factory _ChangesResponse({final List<Change> changes}) =
      _$ChangesResponseImpl;

  factory _ChangesResponse.fromJson(Map<String, dynamic> json) =
      _$ChangesResponseImpl.fromJson;

  @override
  List<Change> get changes;

  /// Create a copy of ChangesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangesResponseImplCopyWith<_$ChangesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
