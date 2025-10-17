import 'package:flutter/foundation.dart';

@immutable
class AccountAvatar {
  const AccountAvatar({this.gravatarHash, this.tmdbAvatarPath});

  factory AccountAvatar.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AccountAvatar();
    }

    final gravatar = json['gravatar'];
    final tmdb = json['tmdb'];

    return AccountAvatar(
      gravatarHash: gravatar is Map<String, dynamic> ? gravatar['hash'] as String? : null,
      tmdbAvatarPath: tmdb is Map<String, dynamic> ? tmdb['avatar_path'] as String? : null,
    );
  }

  final String? gravatarHash;
  final String? tmdbAvatarPath;
}

@immutable
class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.username,
    this.name,
    this.includeAdult,
    this.avatar = const AccountAvatar(),
  });

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    return AccountProfile(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      username: (json['username'] as String?) ?? '',
      name: json['name'] as String?,
      includeAdult: json['include_adult'] as bool?,
      avatar: AccountAvatar.fromJson(json['avatar'] as Map<String, dynamic>?),
    );
  }

  final int id;
  final String username;
  final String? name;
  final bool? includeAdult;
  final AccountAvatar avatar;
}

@immutable
class AccountListSummary {
  const AccountListSummary({
    required this.id,
    required this.name,
    this.description,
    this.posterPath,
    this.listType,
    this.language,
    this.itemCount = 0,
    this.favoriteCount = 0,
  });

  factory AccountListSummary.fromJson(Map<String, dynamic> json) {
    return AccountListSummary(
      id: json['id'] is int
          ? (json['id'] as int).toString()
          : json['id']?.toString() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim(),
      posterPath: json['poster_path'] as String?,
      listType: json['list_type'] as String?,
      language: json['iso_639_1'] as String?,
      itemCount: json['item_count'] is int
          ? json['item_count'] as int
          : int.tryParse('${json['item_count']}') ?? 0,
      favoriteCount: json['favorite_count'] is int
          ? json['favorite_count'] as int
          : int.tryParse('${json['favorite_count']}') ?? 0,
    );
  }

  final String id;
  final String name;
  final String? description;
  final String? posterPath;
  final String? listType;
  final String? language;
  final int itemCount;
  final int favoriteCount;
}
