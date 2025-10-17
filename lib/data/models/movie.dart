import 'package:flutter/foundation.dart';

import '../../core/utils/media_image_helper.dart';

import '../utils/genre_catalog.dart';

@immutable
class Movie {
  const Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.mediaType,
    this.releaseDate,
    this.runtime,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.originalLanguage,
    this.originalTitle,
    this.adult = false,
    this.genreIds,
    this.status,
  });

  factory Movie.fromJson(
    Map<String, dynamic> json, {
    String? mediaType,
  }) {
    final resolvedMediaType = mediaType ?? json['media_type'] as String?;
    final title = ((json['title'] ?? json['name']) as String?)?.trim() ?? '';
    final overviewRaw = (json['overview'] as String?)?.trim();
    final overview = (overviewRaw == null || overviewRaw.isEmpty) ? null : overviewRaw;
    
    final genreIdsList = json['genre_ids'] as List?;
    final genreIds = genreIdsList?.whereType<int>().toList();

    return Movie(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: title,
      overview: overview,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      mediaType: resolvedMediaType,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      originalLanguage: json['original_language'] as String?,
      originalTitle: (json['original_title'] ?? json['original_name']) as String?,
      adult: json['adult'] as bool? ?? false,
      genreIds: genreIds,
      status: (json['status'] as String?)?.trim(),
    );
  }

  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? mediaType;
  final String? releaseDate;
  final int? runtime;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;
  final String? originalLanguage;
  final String? originalTitle;
  final bool adult;
  final List<int>? genreIds;
  final String? status;

  List<String> get alternativeTitles {
    final normalizedPrimary = title.trim().toLowerCase();
    final titles = <String>{};

    final candidate = originalTitle?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      if (candidate.toLowerCase() != normalizedPrimary) {
        titles.add(candidate);
      }
    }

    return List.unmodifiable(titles);
  }

  String? get posterUrl => MediaImageHelper.buildUrl(
        posterPath,
        type: MediaImageType.poster,
        size: MediaImageSize.w500,
      );

  String? get backdropUrl => MediaImageHelper.buildUrl(
        backdropPath,
        type: MediaImageType.backdrop,
        size: MediaImageSize.w780,
      );

  String? posterUrlFor(MediaImageSize size) => MediaImageHelper.buildUrl(
        posterPath,
        type: MediaImageType.poster,
        size: size,
      );

  String? backdropUrlFor(MediaImageSize size) => MediaImageHelper.buildUrl(
        backdropPath,
        type: MediaImageType.backdrop,
        size: size,
      );

  String? get releaseYear => releaseDate != null && releaseDate!.isNotEmpty
      ? releaseDate!.split('-').first
      : null;

  String get mediaLabel {
    if ((mediaType ?? '').isEmpty) {
      return 'Movie';
    }

    switch (mediaType) {
      case 'tv':
        return 'TV';
      case 'person':
        return 'Person';
      default:
        return mediaType![0].toUpperCase() + mediaType!.substring(1);
    }
  }

  String get formattedRating {
    if (voteAverage == null || voteAverage! <= 0) {
      return 'N/A';
    }
    return '${voteAverage!.toStringAsFixed(1)} ★';
  }

  String get formattedVoteCount {
    if (voteCount == null || voteCount! <= 0) {
      return '';
    }
    if (voteCount! >= 1000) {
      return '${(voteCount! / 1000).toStringAsFixed(1)}K votes';
    }
    return '$voteCount votes';
  }

  String get formattedPopularity {
    if (popularity == null) {
      return '';
    }
    return popularity!.toStringAsFixed(0);
  }

  String? get statusLabel {
    final trimmed = status?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  bool get isNowShowing {
    final label = statusLabel;
    if (label == null || label.toLowerCase() != 'released') {
      return false;
    }

    if (releaseDate == null || releaseDate!.isEmpty) {
      return false;
    }

    final parsed = DateTime.tryParse(releaseDate!);
    if (parsed == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(parsed).inDays;
    return difference >= 0 && difference <= 45;
  }

  String? get showingLabel {
    if (isNowShowing) {
      return 'Now Showing';
    }
    return statusLabel;
  }

  // Map genre IDs to genre names (movie + TV, 28 total)
  static Map<int, String> get genreMap => GenreCatalog.allGenreNames;

  List<String> get genres {
    if (genreIds == null || genreIds!.isEmpty) {
      return [];
    }
    return genreIds!
        .map((id) => genreMap[id])
        .whereType<String>()
        .toList();
  }

  String get genresText {
    final genreList = genres;
    if (genreList.isEmpty) {
      return '';
    }
    return genreList.take(3).join(', ');
  }
}
