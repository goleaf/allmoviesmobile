import 'package:flutter/foundation.dart';

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
    this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final mediaType = json['media_type'] as String?;
    final title = ((json['title'] ?? json['name']) as String?)?.trim() ?? '';
    final overviewRaw = (json['overview'] as String?)?.trim();
    final overview = (overviewRaw == null || overviewRaw.isEmpty) ? null : overviewRaw;

    return Movie(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: title,
      overview: overview,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      mediaType: mediaType,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
    );
  }

  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? mediaType;
  final String? releaseDate;
  final double? voteAverage;

  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;

  String? get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : null;

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
}
