// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewAuthor _$ReviewAuthorFromJson(Map<String, dynamic> json) {
  return _ReviewAuthor.fromJson(json);
}

/// @nodoc
mixin _$ReviewAuthor {
  String get name => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_path')
  String? get avatarPath => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReviewAuthorCopyWith<ReviewAuthor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewAuthorCopyWith<$Res> {
  factory $ReviewAuthorCopyWith(
    ReviewAuthor value,
    $Res Function(ReviewAuthor) then,
  ) = _$ReviewAuthorCopyWithImpl<$Res, ReviewAuthor>;
  @useResult
  $Res call({
    String name,
    String username,
    @JsonKey(name: 'avatar_path') String? avatarPath,
    double? rating,
  });
}

/// @nodoc
class _$ReviewAuthorCopyWithImpl<$Res, $Val extends ReviewAuthor>
    implements $ReviewAuthorCopyWith<$Res> {
  _$ReviewAuthorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? username = null,
    Object? avatarPath = freezed,
    Object? rating = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarPath: freezed == avatarPath
                ? _value.avatarPath
                : avatarPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewAuthorImplCopyWith<$Res>
    implements $ReviewAuthorCopyWith<$Res> {
  factory _$$ReviewAuthorImplCopyWith(
    _$ReviewAuthorImpl value,
    $Res Function(_$ReviewAuthorImpl) then,
  ) = __$$ReviewAuthorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String username,
    @JsonKey(name: 'avatar_path') String? avatarPath,
    double? rating,
  });
}

/// @nodoc
class __$$ReviewAuthorImplCopyWithImpl<$Res>
    extends _$ReviewAuthorCopyWithImpl<$Res, _$ReviewAuthorImpl>
    implements _$$ReviewAuthorImplCopyWith<$Res> {
  __$$ReviewAuthorImplCopyWithImpl(
    _$ReviewAuthorImpl _value,
    $Res Function(_$ReviewAuthorImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? username = null,
    Object? avatarPath = freezed,
    Object? rating = freezed,
  }) {
    return _then(
      _$ReviewAuthorImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarPath: freezed == avatarPath
            ? _value.avatarPath
            : avatarPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewAuthorImpl implements _ReviewAuthor {
  const _$ReviewAuthorImpl({
    required this.name,
    required this.username,
    @JsonKey(name: 'avatar_path') this.avatarPath,
    this.rating,
  });

  factory _$ReviewAuthorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewAuthorImplFromJson(json);

  @override
  final String name;
  @override
  final String username;
  @override
  @JsonKey(name: 'avatar_path')
  final String? avatarPath;
  @override
  final double? rating;

  @override
  String toString() {
    return 'ReviewAuthor(name: $name, username: $username, avatarPath: $avatarPath, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewAuthorImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarPath, avatarPath) ||
                other.avatarPath == avatarPath) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, username, avatarPath, rating);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewAuthorImplCopyWith<_$ReviewAuthorImpl> get copyWith =>
      __$$ReviewAuthorImplCopyWithImpl<_$ReviewAuthorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewAuthorImplToJson(this);
  }
}

abstract class _ReviewAuthor implements ReviewAuthor {
  const factory _ReviewAuthor({
    required final String name,
    required final String username,
    @JsonKey(name: 'avatar_path') final String? avatarPath,
    final double? rating,
  }) = _$ReviewAuthorImpl;

  factory _ReviewAuthor.fromJson(Map<String, dynamic> json) =
      _$ReviewAuthorImpl.fromJson;

  @override
  String get name;
  @override
  String get username;
  @override
  @JsonKey(name: 'avatar_path')
  String? get avatarPath;
  @override
  double? get rating;
  @override
  @JsonKey(ignore: true)
  _$$ReviewAuthorImplCopyWith<_$ReviewAuthorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return _Review.fromJson(json);
}

/// @nodoc
mixin _$Review {
  String get id => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_details')
  ReviewAuthor get authorDetails => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReviewCopyWith<Review> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewCopyWith<$Res> {
  factory $ReviewCopyWith(Review value, $Res Function(Review) then) =
      _$ReviewCopyWithImpl<$Res, Review>;
  @useResult
  $Res call({
    String id,
    String author,
    @JsonKey(name: 'author_details') ReviewAuthor authorDetails,
    String content,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? url,
  });

  $ReviewAuthorCopyWith<$Res> get authorDetails;
}

/// @nodoc
class _$ReviewCopyWithImpl<$Res, $Val extends Review>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? author = null,
    Object? authorDetails = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? url = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            authorDetails: null == authorDetails
                ? _value.authorDetails
                : authorDetails // ignore: cast_nullable_to_non_nullable
                      as ReviewAuthor,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $ReviewAuthorCopyWith<$Res> get authorDetails {
    return $ReviewAuthorCopyWith<$Res>(_value.authorDetails, (value) {
      return _then(_value.copyWith(authorDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReviewImplCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$$ReviewImplCopyWith(
    _$ReviewImpl value,
    $Res Function(_$ReviewImpl) then,
  ) = __$$ReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String author,
    @JsonKey(name: 'author_details') ReviewAuthor authorDetails,
    String content,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? url,
  });

  @override
  $ReviewAuthorCopyWith<$Res> get authorDetails;
}

/// @nodoc
class __$$ReviewImplCopyWithImpl<$Res>
    extends _$ReviewCopyWithImpl<$Res, _$ReviewImpl>
    implements _$$ReviewImplCopyWith<$Res> {
  __$$ReviewImplCopyWithImpl(
    _$ReviewImpl _value,
    $Res Function(_$ReviewImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? author = null,
    Object? authorDetails = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? url = freezed,
  }) {
    return _then(
      _$ReviewImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        authorDetails: null == authorDetails
            ? _value.authorDetails
            : authorDetails // ignore: cast_nullable_to_non_nullable
                  as ReviewAuthor,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewImpl implements _Review {
  const _$ReviewImpl({
    required this.id,
    required this.author,
    @JsonKey(name: 'author_details') required this.authorDetails,
    required this.content,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.url,
  });

  factory _$ReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewImplFromJson(json);

  @override
  final String id;
  @override
  final String author;
  @override
  @JsonKey(name: 'author_details')
  final ReviewAuthor authorDetails;
  @override
  final String content;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  final String? url;

  @override
  String toString() {
    return 'Review(id: $id, author: $author, authorDetails: $authorDetails, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.authorDetails, authorDetails) ||
                other.authorDetails == authorDetails) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    author,
    authorDetails,
    content,
    createdAt,
    updatedAt,
    url,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      __$$ReviewImplCopyWithImpl<_$ReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewImplToJson(this);
  }
}

abstract class _Review implements Review {
  const factory _Review({
    required final String id,
    required final String author,
    @JsonKey(name: 'author_details') required final ReviewAuthor authorDetails,
    required final String content,
    @JsonKey(name: 'created_at') required final String createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
    final String? url,
  }) = _$ReviewImpl;

  factory _Review.fromJson(Map<String, dynamic> json) = _$ReviewImpl.fromJson;

  @override
  String get id;
  @override
  String get author;
  @override
  @JsonKey(name: 'author_details')
  ReviewAuthor get authorDetails;
  @override
  String get content;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  String? get url;
  @override
  @JsonKey(ignore: true)
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
