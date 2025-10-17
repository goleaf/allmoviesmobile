import 'package:flutter/foundation.dart';

import 'movie.dart';

@immutable
class GenreStatistics {
  const GenreStatistics({
    required Set<int> genreIds,
    required this.sampleSize,
    required this.averageRating,
    required this.averagePopularity,
    required this.averageVoteCount,
    this.releaseYearRange,
    required List<String> topTitles,
  })  : genreIds = Set<int>.unmodifiable(Set<int>.from(genreIds)),
        topTitles = List<String>.unmodifiable(List<String>.from(topTitles));

  final Set<int> genreIds;
  final int sampleSize;
  final double averageRating;
  final double averagePopularity;
  final double averageVoteCount;
  final String? releaseYearRange;
  final List<String> topTitles;

  bool get hasData => sampleSize > 0;

  static GenreStatistics empty(Set<int> genreIds) => GenreStatistics(
        genreIds: genreIds,
        sampleSize: 0,
        averageRating: 0,
        averagePopularity: 0,
        averageVoteCount: 0,
        releaseYearRange: null,
        topTitles: const [],
      );

  factory GenreStatistics.fromMovies(Set<int> genreIds, List<Movie> movies) {
    if (movies.isEmpty) {
      return GenreStatistics.empty(genreIds);
    }

    var ratingSum = 0.0;
    var ratingCount = 0;
    var popularitySum = 0.0;
    var popularityCount = 0;
    var voteCountSum = 0.0;
    var voteCountCount = 0;
    final years = <int>[];

    for (final movie in movies) {
      final rating = movie.voteAverage;
      if (rating != null) {
        ratingSum += rating;
        ratingCount++;
      }

      final popularity = movie.popularity;
      if (popularity != null) {
        popularitySum += popularity;
        popularityCount++;
      }

      final votes = movie.voteCount;
      if (votes != null) {
        voteCountSum += votes.toDouble();
        voteCountCount++;
      }

      final yearString = movie.releaseYear;
      if (yearString != null) {
        final parsed = int.tryParse(yearString);
        if (parsed != null) {
          years.add(parsed);
        }
      }
    }

    String? releaseRange;
    if (years.isNotEmpty) {
      years.sort();
      releaseRange = years.first == years.last
          ? '${years.first}'
          : '${years.first}-${years.last}';
    }

    final sortedByRelevance = movies
      .where((m) => m.voteAverage != null && m.voteAverage! > 0)
      .toList()
      ..sort((a, b) {
        final ratingA = a.voteAverage!;
        final ratingB = b.voteAverage!;
        if (ratingA != ratingB) {
          return ratingB.compareTo(ratingA);
        }
        final popularityA = a.popularity ?? 0;
        final popularityB = b.popularity ?? 0;
        return popularityB.compareTo(popularityA);
      });

    final topTitles = <String>[];
    for (final movie in sortedByRelevance) {
      final title = movie.title.trim();
      if (title.isEmpty) continue;
      topTitles.add(title);
      if (topTitles.length >= 3) {
        break;
      }
    }

    return GenreStatistics(
      genreIds: genreIds,
      sampleSize: movies.length,
      averageRating: ratingCount == 0 ? 0 : ratingSum / ratingCount,
      averagePopularity:
          popularityCount == 0 ? 0 : popularitySum / popularityCount,
      averageVoteCount: voteCountCount == 0 ? 0 : voteCountSum / voteCountCount,
      releaseYearRange: releaseRange,
      topTitles: topTitles,
    );
  }
}
