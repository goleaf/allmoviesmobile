import 'package:meta/meta.dart';

@immutable
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.originalLanguage,
    required this.isAdult,
    required this.mediaType,
  });

  factory Movie.fromJson(Map<String, dynamic> json, {required String mediaType}) {
    final releaseDate = json['release_date'] as String? ?? json['first_air_date'] as String?;

    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: (json['poster_path'] ?? '') as String,
      backdropPath: (json['backdrop_path'] ?? '') as String,
      releaseDate: releaseDate,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] as int? ?? 0,
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
          .whereType<int>()
          .toList(growable: false),
      originalLanguage: (json['original_language'] ?? '') as String,
      isAdult: json['adult'] as bool? ?? false,
      mediaType: mediaType,
    );
  }

  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String? releaseDate;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final String originalLanguage;
  final bool isAdult;
  final String mediaType;

  DateTime? get releaseDateTime {
    if (releaseDate == null || releaseDate!.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(releaseDate!);
    } catch (_) {
      return null;
    }
  }

  String? get posterImageUrl {
    if (posterPath.isEmpty) {
      return null;
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String? get backdropImageUrl {
    if (backdropPath.isEmpty) {
      return null;
    }
    return 'https://image.tmdb.org/t/p/w780$backdropPath';
  }
}
