import '../models/movie.dart';
import '../services/tmdb_api_service.dart';

enum MovieCollection { trending, popular }

class MovieRepository {
  MovieRepository({required this.apiService});

  final TmdbApiService apiService;

  bool get hasApiKey => apiService.apiKey.trim().isNotEmpty;

  Future<Map<MovieCollection, List<Movie>>> fetchMovies() async {
    final trendingJson = await apiService.fetchTrendingMovies();
    final popularJson = await apiService.fetchPopularMovies();

    return {
      MovieCollection.trending:
          trendingJson.map((json) => Movie.fromJson(json, mediaType: 'movie')).toList(growable: false),
      MovieCollection.popular:
          popularJson.map((json) => Movie.fromJson(json, mediaType: 'movie')).toList(growable: false),
    };
  }
}
