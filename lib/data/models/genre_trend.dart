import 'package:flutter/foundation.dart';

import 'movie.dart';

@immutable
class GenreTrend {
  GenreTrend({
    required this.genreId,
    required this.totalTitles,
    required this.averageRating,
    required this.averagePopularity,
    required List<Movie> topMovies,
  }) : topMovies = List<Movie>.unmodifiable(topMovies);

  final int genreId;
  final int totalTitles;
  final double averageRating;
  final double averagePopularity;
  final List<Movie> topMovies;

  List<String> get topTitles =>
      topMovies.map((movie) => movie.title).where((title) => title.isNotEmpty).toList(growable: false);
}
