import 'package:flutter/foundation.dart';

/// Represents the type of media returned by TMDB.
enum MediaKind {
  movie,
  tv,
}

MediaKind _parseMediaKind(String? raw, {MediaKind fallback = MediaKind.movie}) {
  switch (raw) {
    case 'tv':
      return MediaKind.tv;
    case 'movie':
      return MediaKind.movie;
    default:
      return fallback;
  }
}

String mediaKindLabel(MediaKind kind) {
  return switch (kind) {
    MediaKind.movie => 'Movie',
    MediaKind.tv => 'TV Show',
  };
}

/// Lightweight summary used across lists and search results.
@immutable
class MediaSummary {
  const MediaSummary({
    required this.id,
    required this.title,
    required this.kind,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
  });

  factory MediaSummary.fromJson(
    Map<String, dynamic> json, {
    MediaKind fallbackKind = MediaKind.movie,
  }) {
    final mediaTypeRaw = json['media_type'] as String?;
    final resolvedKind = _parseMediaKind(mediaTypeRaw, fallback: fallbackKind);
    final rawTitle = ((json['title'] ?? json['name']) as String?)?.trim() ?? '';
    final overview = (json['overview'] as String?)?.trim();

    return MediaSummary(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: rawTitle.isEmpty ? 'Untitled ${mediaKindLabel(resolvedKind)}' : rawTitle,
      kind: resolvedKind,
      overview: overview?.isEmpty == true ? null : overview,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
    );
  }

  final int id;
  final String title;
  final MediaKind kind;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w342$posterPath' : '';

  String get backdropUrl =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w780$backdropPath' : '';

  String get releaseYear =>
      (releaseDate != null && releaseDate!.isNotEmpty) ? releaseDate!.split('-').first : '';

  String get ratingLabel {
    if (voteAverage == null || voteAverage == 0) {
      return 'N/A';
    }
    return voteAverage!.toStringAsFixed(1);
  }
}

/// Detail payload for a movie or TV show.
@immutable
class MediaDetail {
  const MediaDetail({
    required this.summary,
    this.tagline,
    this.runtimeMinutes,
    this.episodeRuntimeMinutes,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.genres = const <String>[],
    this.status,
    this.homepage,
    this.productionCompanies = const <String>[],
    this.watchProviders = const <String>[],
  });

  factory MediaDetail.fromJson(
    Map<String, dynamic> json,
    MediaKind kind,
  ) {
    final genres = (json['genres'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((genre) => (genre['name'] as String?)?.trim())
            .whereType<String>()
            .toList(growable: false) ??
        const <String>[];

    final companies = (json['production_companies'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((company) => (company['name'] as String?)?.trim())
            .whereType<String>()
            .toList(growable: false) ??
        const <String>[];

    final providers = <String>[];
    final providersMap = json['watch/providers'] ?? json['watchProviders'];
    if (providersMap is Map<String, dynamic>) {
      final results = providersMap['results'];
      if (results is Map<String, dynamic>) {
        final us = results['US'] ?? results.values.firstOrNull;
        if (us is Map<String, dynamic>) {
          for (final key in ['flatrate', 'rent', 'buy', 'ads', 'free']) {
            final bucket = us[key];
            if (bucket is List) {
              for (final item in bucket.whereType<Map<String, dynamic>>()) {
                final providerName = (item['provider_name'] as String?)?.trim();
                if (providerName != null && providerName.isNotEmpty) {
                  providers.add(providerName);
                }
              }
            }
          }
        }
      }
    }

    return MediaDetail(
      summary: MediaSummary.fromJson(json, fallbackKind: kind),
      tagline: (json['tagline'] as String?)?.trim().nullable(),
      runtimeMinutes: (json['runtime'] as num?)?.toInt(),
      episodeRuntimeMinutes: ((json['episode_run_time'] as List?)?.firstOrNull as num?)?.toInt(),
      numberOfSeasons: json['number_of_seasons'] as int?,
      numberOfEpisodes: json['number_of_episodes'] as int?,
      genres: genres,
      status: (json['status'] as String?)?.trim().nullable(),
      homepage: (json['homepage'] as String?)?.trim().nullable(),
      productionCompanies: companies,
      watchProviders: providers.toSet().toList(growable: false),
    );
  }

  final MediaSummary summary;
  final String? tagline;
  final int? runtimeMinutes;
  final int? episodeRuntimeMinutes;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final List<String> genres;
  final String? status;
  final String? homepage;
  final List<String> productionCompanies;
  final List<String> watchProviders;

  String get runtimeLabel {
    if (summary.kind == MediaKind.movie) {
      if (runtimeMinutes == null || runtimeMinutes == 0) return '';
      final hours = runtimeMinutes! ~/ 60;
      final minutes = runtimeMinutes! % 60;
      if (hours == 0) return '$minutes min';
      if (minutes == 0) return '${hours}h';
      return '${hours}h ${minutes}m';
    }

    if (episodeRuntimeMinutes != null && episodeRuntimeMinutes! > 0) {
      return '${episodeRuntimeMinutes!} min / ep';
    }
    return '';
  }

  String get seasonsLabel {
    if (summary.kind != MediaKind.tv) return '';
    final seasons = numberOfSeasons ?? 0;
    final episodes = numberOfEpisodes ?? 0;
    if (seasons == 0 && episodes == 0) return '';
    if (seasons == 0) return '$episodes episodes';
    if (episodes == 0) return '$seasons season${seasons == 1 ? '' : 's'}';
    return '$seasons season${seasons == 1 ? '' : 's'} • $episodes episodes';
  }

  String get genreLabel => genres.join(', ');
}

extension _NullableString on String {
  String? nullable() {
    final trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
