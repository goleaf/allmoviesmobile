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
    this.voteCount,
    this.popularity,
    this.originalLanguage,
    this.originalTitle,
    this.adult = false,
    this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final mediaType = json['media_type'] as String?;
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
      mediaType: mediaType,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      originalLanguage: json['original_language'] as String?,
      originalTitle: (json['original_title'] ?? json['original_name']) as String?,
      adult: json['adult'] as bool? ?? false,
      genreIds: genreIds,
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
  final int? voteCount;
  final double? popularity;
  final String? originalLanguage;
  final String? originalTitle;
  final bool adult;
  final List<int>? genreIds;

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

  // Map genre IDs to genre names
  static const Map<int, String> genreMap = {
    // Movie genres
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
    // TV genres
    10759: 'Action & Adventure',
    10762: 'Kids',
    10763: 'News',
    10764: 'Reality',
    10765: 'Sci-Fi & Fantasy',
    10766: 'Soap',
    10767: 'Talk',
    10768: 'War & Politics',
  };

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
