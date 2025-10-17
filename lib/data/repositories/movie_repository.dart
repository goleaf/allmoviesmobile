import '../models/movie.dart';
import '../services/tmdb_api_service.dart';

enum MovieCollection { trending, popular }

class MovieRepository {
  MovieRepository({required this.apiService});

  final TmdbApiService apiService;

  bool get hasApiKey => apiService.apiKey.trim().isNotEmpty;

  Future<Map<MovieCollection, List<Movie>>> fetchMovies() async {
    final trendingPayload = await apiService.fetchTrending(mediaType: 'movie');
    final popularPayload = await apiService.fetchMovieCategory('popular');

    return {
      MovieCollection.trending:
          (trendingPayload['results'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map((json) => Movie.fromJson(json, mediaType: 'movie'))
              .toList(growable: false),
      MovieCollection.popular: (popularPayload['results'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((json) => Movie.fromJson(json, mediaType: 'movie'))
          .toList(growable: false),
    };
  }
}
