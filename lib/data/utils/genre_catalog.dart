import '../models/genre_model.dart';

/// Static catalog of TMDB genre definitions for movies and TV.
/// Provides fallback data when the remote API cannot be reached and also
/// offers a canonical source for mapping genre IDs to display names.
class GenreCatalog {
  GenreCatalog._();

  /// Complete list of official TMDB movie genres (19 entries).
  static const List<Genre> movieGenres = [
    Genre(id: 28, name: 'Action'),
    Genre(id: 12, name: 'Adventure'),
    Genre(id: 16, name: 'Animation'),
    Genre(id: 35, name: 'Comedy'),
    Genre(id: 80, name: 'Crime'),
    Genre(id: 99, name: 'Documentary'),
    Genre(id: 18, name: 'Drama'),
    Genre(id: 10751, name: 'Family'),
    Genre(id: 14, name: 'Fantasy'),
    Genre(id: 36, name: 'History'),
    Genre(id: 27, name: 'Horror'),
    Genre(id: 10402, name: 'Music'),
    Genre(id: 9648, name: 'Mystery'),
    Genre(id: 10749, name: 'Romance'),
    Genre(id: 878, name: 'Science Fiction'),
    Genre(id: 10770, name: 'TV Movie'),
    Genre(id: 53, name: 'Thriller'),
    Genre(id: 10752, name: 'War'),
    Genre(id: 37, name: 'Western'),
  ];

  /// Complete list of official TMDB TV genres (16 entries).
  static const List<Genre> tvGenres = [
    Genre(id: 10759, name: 'Action & Adventure'),
    Genre(id: 16, name: 'Animation'),
    Genre(id: 35, name: 'Comedy'),
    Genre(id: 80, name: 'Crime'),
    Genre(id: 99, name: 'Documentary'),
    Genre(id: 18, name: 'Drama'),
    Genre(id: 10751, name: 'Family'),
    Genre(id: 10762, name: 'Kids'),
    Genre(id: 9648, name: 'Mystery'),
    Genre(id: 10763, name: 'News'),
    Genre(id: 10764, name: 'Reality'),
    Genre(id: 10765, name: 'Sci-Fi & Fantasy'),
    Genre(id: 10766, name: 'Soap'),
    Genre(id: 10767, name: 'Talk'),
    Genre(id: 10768, name: 'War & Politics'),
    Genre(id: 37, name: 'Western'),
  ];

  /// Map of movie genre IDs to names.
  static const Map<int, String> movieGenreNames = {
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
  };

  /// Map of TV genre IDs to names.
  static const Map<int, String> tvGenreNames = {
    10759: 'Action & Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    10762: 'Kids',
    9648: 'Mystery',
    10763: 'News',
    10764: 'Reality',
    10765: 'Sci-Fi & Fantasy',
    10766: 'Soap',
    10767: 'Talk',
    10768: 'War & Politics',
    37: 'Western',
  };

  /// Combined map of all unique genre IDs across movies and TV (27 entries).
  static const Map<int, String> allGenreNames = {
    ...movieGenreNames,
    ...tvGenreNames,
  };

  /// Returns a fallback list of genres for the given flag.
  static List<Genre> fallbackGenres({required bool isTv}) {
    return isTv ? tvGenres : movieGenres;
  }

  /// Lookup a genre name by identifier. Returns `null` if not known.
  static String? nameForId(int id) => allGenreNames[id];
}
