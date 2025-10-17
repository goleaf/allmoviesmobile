import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'movie.dart';

enum SavedMediaType {
  movie,
  tv,
}

extension SavedMediaTypeX on SavedMediaType {
  String get storageKey {
    switch (this) {
      case SavedMediaType.movie:
        return 'movie';
      case SavedMediaType.tv:
        return 'tv';
    }
  }

  String get displayLabel {
    switch (this) {
      case SavedMediaType.movie:
        return 'Movie';
      case SavedMediaType.tv:
        return 'TV Show';
    }
  }

  static SavedMediaType fromStorage(String? value) {
    switch (value) {
      case 'tv':
        return SavedMediaType.tv;
      case 'movie':
      default:
        return SavedMediaType.movie;
    }
  }
}

@immutable
class SavedMediaItem {
  SavedMediaItem({
    required this.id,
    required this.type,
    required this.title,
    this.originalTitle,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.runtimeMinutes,
    this.episodeRuntimeMinutes,
    this.episodeCount,
    this.seasonCount,
    this.genreIds = const <int>[],
    DateTime? addedAt,
    DateTime? updatedAt,
    this.watched = false,
    this.watchedAt,
  })  : addedAt = addedAt ?? DateTime.now(),
        updatedAt = updatedAt ?? addedAt ?? DateTime.now();

  factory SavedMediaItem.fromMovie(
    Movie movie, {
    SavedMediaType? fallbackType,
    bool watched = false,
  }) {
    final type = _resolveType(movie.mediaType, fallbackType);
    return SavedMediaItem(
      id: movie.id,
      type: type,
      title: movie.title,
      originalTitle: movie.originalTitle,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      overview: movie.overview,
      releaseDate: movie.releaseDate,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      runtimeMinutes: movie.runtime,
      genreIds: movie.genreIds ?? const <int>[],
      watched: watched,
    );
  }

  factory SavedMediaItem.fromJson(Map<String, dynamic> json) {
    return SavedMediaItem(
      id: json['id'] as int,
      type: SavedMediaTypeX.fromStorage(json['type'] as String?),
      title: json['title'] as String,
      originalTitle: json['originalTitle'] as String?,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      overview: json['overview'] as String?,
      releaseDate: json['releaseDate'] as String?,
      voteAverage: (json['voteAverage'] as num?)?.toDouble(),
      voteCount: json['voteCount'] as int?,
      runtimeMinutes: json['runtimeMinutes'] as int?,
      episodeRuntimeMinutes: json['episodeRuntimeMinutes'] as int?,
      episodeCount: json['episodeCount'] as int?,
      seasonCount: json['seasonCount'] as int?,
      genreIds: (json['genreIds'] as List<dynamic>?)
              ?.whereType<int>()
              .toList(growable: false) ??
          const <int>[],
      addedAt: _parseDateTime(json['addedAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      watched: json['watched'] as bool? ?? false,
      watchedAt: _parseDateTime(json['watchedAt']),
    );
  }

  final int id;
  final SavedMediaType type;
  final String title;
  final String? originalTitle;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final int? runtimeMinutes;
  final int? episodeRuntimeMinutes;
  final int? episodeCount;
  final int? seasonCount;
  final List<int> genreIds;
  final DateTime addedAt;
  final DateTime updatedAt;
  final bool watched;
  final DateTime? watchedAt;

  SavedMediaItem copyWith({
    String? title,
    String? originalTitle,
    String? posterPath,
    String? backdropPath,
    String? overview,
    String? releaseDate,
    double? voteAverage,
    int? voteCount,
    int? runtimeMinutes,
    int? episodeRuntimeMinutes,
    int? episodeCount,
    int? seasonCount,
    List<int>? genreIds,
    DateTime? addedAt,
    DateTime? updatedAt,
    bool? watched,
    Object? watchedAt = _sentinelDateTime,
  }) {
    return SavedMediaItem(
      id: id,
      type: type,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      episodeRuntimeMinutes:
          episodeRuntimeMinutes ?? this.episodeRuntimeMinutes,
      episodeCount: episodeCount ?? this.episodeCount,
      seasonCount: seasonCount ?? this.seasonCount,
      genreIds: genreIds ?? this.genreIds,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? DateTime.now(),
      watched: watched ?? this.watched,
      watchedAt: identical(watchedAt, _sentinelDateTime)
          ? this.watchedAt
          : watchedAt as DateTime?, // explicit null allowed
    );
  }

  String get storageId => '${type.storageKey}_$id';

  String? get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) {
      return null;
    }
    return releaseDate!.split('-').first;
  }

  double? get voteAverageRounded {
    if (voteAverage == null) return null;
    return double.parse(voteAverage!.toStringAsFixed(1));
  }

  int? get totalRuntimeEstimate {
    if (type == SavedMediaType.movie) {
      return runtimeMinutes;
    }

    if (episodeCount != null && episodeRuntimeMinutes != null) {
      return episodeCount! * episodeRuntimeMinutes!;
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.storageKey,
      'title': title,
      'originalTitle': originalTitle,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'overview': overview,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
      'runtimeMinutes': runtimeMinutes,
      'episodeRuntimeMinutes': episodeRuntimeMinutes,
      'episodeCount': episodeCount,
      'seasonCount': seasonCount,
      'genreIds': genreIds,
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'watched': watched,
      'watchedAt': watchedAt?.toIso8601String(),
    };
  }

  static List<SavedMediaItem> decodeList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return const <SavedMediaItem>[];
    }

    try {
      final decoded = json.decode(jsonString);
      if (decoded is List) {
        if (decoded.isEmpty) {
          return const <SavedMediaItem>[];
        }

        if (decoded.first is int) {
          // Legacy format: list of movie IDs
          return decoded
              .whereType<int>()
              .map(
                (id) => SavedMediaItem(
                  id: id,
                  type: SavedMediaType.movie,
                  title: 'Movie #$id',
                ),
              )
              .toList(growable: false);
        }

        return decoded
            .whereType<Map<String, dynamic>>()
            .map(SavedMediaItem.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      // Fall through to return empty list
    }

    return const <SavedMediaItem>[];
  }

  static String encodeList(Iterable<SavedMediaItem> items) {
    final encoded =
        items.map((item) => item.toJson()).toList(growable: false);
    return json.encode(encoded);
  }

  static SavedMediaType _resolveType(
    String? mediaType,
    SavedMediaType? fallback,
  ) {
    if (mediaType != null) {
      switch (mediaType) {
        case 'tv':
          return SavedMediaType.tv;
        case 'movie':
          return SavedMediaType.movie;
      }
    }
    return fallback ?? SavedMediaType.movie;
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

const _sentinelDateTime = Object();
