import 'package:flutter/foundation.dart';
import 'custom_list.dart';
import 'saved_media_item.dart';

@immutable
class ListCollaborator {
  const ListCollaborator({
    required this.userId,
    required this.displayName,
    required this.addedAt,
  });

  factory ListCollaborator.fromJson(Map<String, dynamic> json) {
    return ListCollaborator(
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      displayName:
          (json['display_name'] ?? json['displayName'] ?? '') as String,
      addedAt: _parseDateTime(json['added_at'] ?? json['addedAt']),
    );
  }

  final String userId;
  final String displayName;
  final DateTime addedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user_id': userId,
    'display_name': displayName,
    'added_at': addedAt.toIso8601String(),
  };
}

enum ListSortMode { manual, recentlyAdded, alphabetical, releaseDate }

extension ListSortModeLabel on ListSortMode {
  String get label {
    switch (this) {
      case ListSortMode.manual:
        return 'Custom order';
      case ListSortMode.recentlyAdded:
        return 'Recently added';
      case ListSortMode.alphabetical:
        return 'Alphabetical';
      case ListSortMode.releaseDate:
        return 'Release date';
    }
  }
}

ListSortMode parseListSortMode(String? value) {
  if (value == null || value.isEmpty) {
    return ListSortMode.manual;
  }
  return ListSortMode.values.firstWhere(
    (mode) => mode.name == value,
    orElse: () => ListSortMode.manual,
  );
}

enum ListEntryType { movie, tv }

ListEntryType parseListEntryType(String? name) {
  if (name == null || name.isEmpty) {
    return ListEntryType.movie;
  }
  return ListEntryType.values.firstWhere(
    (type) => type.name == name,
    orElse: () => ListEntryType.movie,
  );
}

@immutable
class ListEntry {
  const ListEntry({
    required this.mediaId,
    this.mediaType = ListEntryType.movie,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.addedBy,
    required this.addedAt,
    required this.position,
    this.voteAverage,
  });

  factory ListEntry.fromJson(Map<String, dynamic> json) {
    return ListEntry(
      mediaId: json['media_id'] is int
          ? json['media_id'] as int
          : int.tryParse('${json['media_id'] ?? json['mediaId']}') ?? 0,
      mediaType: parseListEntryType(
        (json['media_type'] ?? json['mediaType']) as String?,
      ),
      title: (json['title'] ?? json['name'] ?? '') as String,
      overview: json['overview'] as String?,
      posterPath:
          json['poster_path'] as String? ?? json['posterPath'] as String?,
      backdropPath:
          json['backdrop_path'] as String? ?? json['backdropPath'] as String?,
      releaseDate: _parseOptionalDate(
        json['release_date'] ?? json['releaseDate'],
      ),
      addedBy: (json['added_by'] ?? json['addedBy'] ?? '') as String,
      addedAt: _parseDateTime(json['added_at'] ?? json['addedAt']),
      position: json['position'] is int
          ? json['position'] as int
          : int.tryParse('${json['position']}') ?? 0,
      voteAverage: json['vote_average'] is num
          ? (json['vote_average'] as num).toDouble()
          : json['voteAverage'] is num
          ? (json['voteAverage'] as num).toDouble()
          : null,
    );
  }

  final int mediaId;
  final ListEntryType mediaType;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;
  final String addedBy;
  final DateTime addedAt;
  final int position;
  final double? voteAverage;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'media_id': mediaId,
    'media_type': mediaType.name,
    'title': title,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'release_date': releaseDate?.toIso8601String(),
    'added_by': addedBy,
    'added_at': addedAt.toIso8601String(),
    'position': position,
    'vote_average': voteAverage,
  };

  ListEntry copyWith({
    int? mediaId,
    ListEntryType? mediaType,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    DateTime? releaseDate,
    String? addedBy,
    DateTime? addedAt,
    int? position,
    double? voteAverage,
  }) {
    return ListEntry(
      mediaId: mediaId ?? this.mediaId,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      addedBy: addedBy ?? this.addedBy,
      addedAt: addedAt ?? this.addedAt,
      position: position ?? this.position,
      voteAverage: voteAverage ?? this.voteAverage,
    );
  }
}

@immutable
class ListComment {
  const ListComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });

  factory ListComment.fromJson(Map<String, dynamic> json) {
    return ListComment(
      id: (json['id'] ?? '') as String,
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      userName: (json['user_name'] ?? json['userName'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'user_id': userId,
    'user_name': userName,
    'message': message,
    'created_at': createdAt.toIso8601String(),
  };
}

@immutable
class UserList {
  const UserList({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    this.description,
    this.posterPath,
    this.isPublic = true,
    this.isCollaborative = false,
    this.createdAt,
    this.updatedAt,
    this.items = const <ListEntry>[],
    this.collaborators = const <ListCollaborator>[],
    this.followerIds = const <String>{},
    this.comments = const <ListComment>[],
    this.sortMode = ListSortMode.manual,
  });

  factory UserList.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(ListEntry.fromJson)
        .toList();

    final collaborators =
        (json['collaborators'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(ListCollaborator.fromJson)
            .toList();

    final comments =
        (json['comments'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(ListComment.fromJson)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final followers =
        (json['followers'] as List<dynamic>? ??
                json['follower_ids'] as List<dynamic>? ??
                const <dynamic>[])
            .whereType<String>()
            .toSet();

    return UserList(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? json['title'] ?? '') as String,
      ownerId: (json['owner_id'] ?? json['ownerId'] ?? '') as String,
      ownerName: (json['owner_name'] ?? json['ownerName'] ?? '') as String,
      description: json['description'] as String?,
      posterPath:
          json['poster_path'] as String? ?? json['posterPath'] as String?,
      isPublic: json['is_public'] is bool
          ? json['is_public'] as bool
          : json['public'] is bool
          ? json['public'] as bool
          : (json['is_public'] ?? json['public'] ?? true) == true,
      isCollaborative: json['is_collaborative'] is bool
          ? json['is_collaborative'] as bool
          : ((json['is_collaborative'] ?? json['collaborative']) == true),
      createdAt: _parseOptionalDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseOptionalDate(json['updated_at'] ?? json['updatedAt']),
      items: items,
      collaborators: collaborators,
      followerIds: followers,
      comments: comments,
      sortMode: parseListSortMode(
        (json['sort_mode'] ?? json['sortMode']) as String?,
      ),
    );
  }

  final String id;
  final String name;
  final String ownerId;
  final String ownerName;
  final String? description;
  final String? posterPath;
  final bool isPublic;
  final bool isCollaborative;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ListEntry> items;
  final List<ListCollaborator> collaborators;
  final Set<String> followerIds;
  final List<ListComment> comments;
  final ListSortMode sortMode;

  int get itemCount => items.length;

  bool allowsEditsBy(String userId) =>
      ownerId == userId ||
      (isCollaborative &&
          collaborators.any((collab) => collab.userId == userId));

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'owner_id': ownerId,
    'owner_name': ownerName,
    'description': description,
    'poster_path': posterPath,
    'is_public': isPublic,
    'is_collaborative': isCollaborative,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'sort_mode': sortMode.name,
    'items': items.map((item) => item.toJson()).toList(),
    'collaborators': collaborators.map((item) => item.toJson()).toList(),
    'followers': followerIds.toList(),
    'comments': comments.map((item) => item.toJson()).toList(),
  };

  UserList copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? ownerName,
    String? description,
    String? posterPath,
    bool? isPublic,
    bool? isCollaborative,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ListEntry>? items,
    List<ListCollaborator>? collaborators,
    Set<String>? followerIds,
    List<ListComment>? comments,
    ListSortMode? sortMode,
  }) {
    return UserList(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      description: description ?? this.description,
      posterPath: posterPath ?? this.posterPath,
      isPublic: isPublic ?? this.isPublic,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      collaborators: collaborators ?? this.collaborators,
      followerIds: followerIds ?? this.followerIds,
      comments: comments ?? this.comments,
      sortMode: sortMode ?? this.sortMode,
    );
  }
}

extension UserListPersistenceX on UserList {
  CustomList toCustomList() {
    return CustomList(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPublic: isPublic,
      items: items
          .map(
            (e) => SavedMediaItem(
              id: e.mediaId,
              type: e.mediaType == ListEntryType.tv
                  ? SavedMediaType.tv
                  : SavedMediaType.movie,
              title: e.title,
              posterPath: e.posterPath,
              backdropPath: e.backdropPath,
              overview: e.overview,
              releaseDate: e.releaseDate != null
                  ? e.releaseDate!.toIso8601String()
                  : null,
              voteAverage: e.voteAverage,
            ),
          )
          .toList(growable: false),
    );
  }

  static UserList fromCustom(CustomList list) {
    return UserList(
      id: list.id,
      name: list.name,
      ownerId: 'local-user',
      ownerName: 'You',
      description: list.description,
      posterPath: null,
      isPublic: list.isPublic,
      isCollaborative: false,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
      items: [
        for (var index = 0; index < list.items.length; index++)
          ListEntry(
            mediaId: list.items[index].id,
            mediaType: list.items[index].type == SavedMediaType.tv
                ? ListEntryType.tv
                : ListEntryType.movie,
            title: list.items[index].title ?? '',
            posterPath: list.items[index].posterPath,
            backdropPath: list.items[index].backdropPath,
            releaseDate: list.items[index].releaseDate != null
                ? DateTime.tryParse(list.items[index].releaseDate!)
                : null,
            addedBy: '',
            addedAt: list.updatedAt ?? DateTime.now(),
            position: index,
            voteAverage: list.items[index].voteAverage,
          ),
      ],
      collaborators: const <ListCollaborator>[],
      followerIds: const <String>{},
      comments: const <ListComment>[],
      sortMode: ListSortMode.manual,
    );
  }
}

DateTime _parseDateTime(Object? raw) {
  if (raw is DateTime) {
    return raw;
  }
  if (raw is String && raw.isNotEmpty) {
    return DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
  }
  if (raw is int) {
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }
  return DateTime.now();
}

DateTime? _parseOptionalDate(Object? raw) {
  if (raw == null) {
    return null;
  }
  if (raw is DateTime) {
    return raw;
  }
  if (raw is String && raw.isNotEmpty) {
    return DateTime.tryParse(raw)?.toLocal();
  }
  if (raw is int) {
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }
  return null;
}
