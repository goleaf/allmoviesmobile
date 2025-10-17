import 'package:flutter/foundation.dart';

import '../data/models/certification_model.dart';
import '../data/models/configuration_model.dart';
import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/models/person_model.dart';
import '../data/models/watch_provider_model.dart';
import '../data/tmdb_repository.dart';

class ApiExplorerSnapshot {
  const ApiExplorerSnapshot({
    required this.configuration,
    required this.trendingAll,
    required this.trendingMovies,
    required this.trendingTv,
    required this.discoverMovies,
    required this.discoverTv,
    required this.popularPeople,
    required this.languages,
    required this.countries,
    required this.timezones,
    required this.watchProviderRegions,
    required this.watchProvidersMovie,
    required this.watchProvidersTv,
    required this.movieCertifications,
    required this.tvCertifications,
  });

  final ApiConfiguration configuration;
  final List<Movie> trendingAll;
  final List<Movie> trendingMovies;
  final List<Movie> trendingTv;
  final List<Movie> discoverMovies;
  final List<Movie> discoverTv;
  final List<Person> popularPeople;
  final List<LanguageInfo> languages;
  final List<CountryInfo> countries;
  final List<Timezone> timezones;
  final List<WatchProviderRegion> watchProviderRegions;
  final Map<String, WatchProviderResults> watchProvidersMovie;
  final Map<String, WatchProviderResults> watchProvidersTv;
  final Map<String, List<Certification>> movieCertifications;
  final Map<String, List<Certification>> tvCertifications;
}

class ApiExplorerProvider extends ChangeNotifier {
  ApiExplorerProvider(this._repository);

  final TmdbRepository _repository;

  ApiExplorerSnapshot? _snapshot;
  ApiExplorerSnapshot? get snapshot => _snapshot;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await Future.wait<dynamic>([
        _repository.fetchTrendingTitles(
          mediaType: 'all',
          timeWindow: 'day',
          forceRefresh: forceRefresh,
        ),
        _repository.fetchTrendingTitles(
          mediaType: 'movie',
          timeWindow: 'day',
          forceRefresh: forceRefresh,
        ),
        _repository.fetchTrendingTitles(
          mediaType: 'tv',
          timeWindow: 'day',
          forceRefresh: forceRefresh,
        ),
        _repository.discoverMovies(
          filters: const {
            'sort_by': 'popularity.desc',
            'with_original_language': 'en',
          },
          forceRefresh: forceRefresh,
        ),
        _repository.discoverTvSeries(
          filters: const {
            'sort_by': 'popularity.desc',
            'with_original_language': 'en',
          },
          forceRefresh: forceRefresh,
        ),
        _repository.fetchPopularPeople(forceRefresh: forceRefresh),
        _repository.fetchConfiguration(forceRefresh: forceRefresh),
        _repository.fetchLanguages(forceRefresh: forceRefresh),
        _repository.fetchCountries(forceRefresh: forceRefresh),
        _repository.fetchTimezones(forceRefresh: forceRefresh),
        _repository.fetchWatchProviderRegions(forceRefresh: forceRefresh),
        _repository.fetchWatchProviders(
          mediaType: 'movie',
          forceRefresh: forceRefresh,
        ),
        _repository.fetchWatchProviders(
          mediaType: 'tv',
          forceRefresh: forceRefresh,
        ),
        _repository.fetchMovieCertifications(forceRefresh: forceRefresh),
        _repository.fetchTvCertifications(forceRefresh: forceRefresh),
      ]);

      final trendingAll = responses[0] as PaginatedResponse<Movie>;
      final trendingMovies = responses[1] as PaginatedResponse<Movie>;
      final trendingTv = responses[2] as PaginatedResponse<Movie>;
      final discoverMovies = responses[3] as PaginatedResponse<Movie>;
      final discoverTv = responses[4] as PaginatedResponse<Movie>;
      final popularPeople = responses[5] as PaginatedResponse<Person>;
      final configuration = responses[6] as ApiConfiguration;
      final languages = responses[7] as List<LanguageInfo>;
      final countries = responses[8] as List<CountryInfo>;
      final timezones = responses[9] as List<Timezone>;
      final providerRegions = responses[10] as List<WatchProviderRegion>;
      final watchProvidersMovie =
          responses[11] as Map<String, WatchProviderResults>;
      final watchProvidersTv =
          responses[12] as Map<String, WatchProviderResults>;
      final movieCertifications =
          responses[13] as Map<String, List<Certification>>;
      final tvCertifications =
          responses[14] as Map<String, List<Certification>>;

      _snapshot = ApiExplorerSnapshot(
        configuration: configuration,
        trendingAll: _takeFirst(trendingAll.results, 12),
        trendingMovies: _takeFirst(trendingMovies.results, 12),
        trendingTv: _takeFirst(trendingTv.results, 12),
        discoverMovies: _takeFirst(discoverMovies.results, 12),
        discoverTv: _takeFirst(discoverTv.results, 12),
        popularPeople: _takeFirst(popularPeople.results, 12),
        languages: _takeFirst(languages, 24),
        countries: _takeFirst(countries, 24),
        timezones: _takeFirst(timezones, 24),
        watchProviderRegions: List<WatchProviderRegion>.unmodifiable(
          providerRegions,
        ),
        watchProvidersMovie: watchProvidersMovie,
        watchProvidersTv: watchProvidersTv,
        movieCertifications: movieCertifications,
        tvCertifications: tvCertifications,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<T> _takeFirst<T>(List<T> items, int maxItems) {
    if (items.length <= maxItems) {
      return List<T>.from(items);
    }
    return items.sublist(0, maxItems);
  }
}
