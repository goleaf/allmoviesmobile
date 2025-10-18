import 'package:flutter/foundation.dart';

import '../data/models/paginated_response.dart';
import '../data/models/movie.dart';
import '../data/models/search_result_model.dart';
import '../data/tmdb_repository.dart';

enum TrendingMediaType {
  all('all'),
  movie('movie'),
  tv('tv'),
  person('person');

  const TrendingMediaType(this.value);
  final String value;
}

enum TrendingWindow {
  day('day'),
  week('week');

  const TrendingWindow(this.value);
  final String value;
}

class TrendingState {
  const TrendingState({
    this.items = const <SearchResult>[],
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  static const _sentinel = Object();

  final List<SearchResult> items;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  TrendingState copyWith({
    List<SearchResult>? items,
    bool? isLoading,
    bool? hasLoaded,
    Object? errorMessage = _sentinel,
  }) {
    return TrendingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class TrendingTitlesProvider extends ChangeNotifier {
  TrendingTitlesProvider(this._repository);

  final TmdbRepository _repository;

  final Map<_TrendingKey, TrendingState> _states = {
    for (final mediaType in TrendingMediaType.values)
      for (final window in TrendingWindow.values)
        _TrendingKey(mediaType, window): const TrendingState(),
  };

  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  TrendingState stateFor(TrendingMediaType mediaType, TrendingWindow window) =>
      _states[_TrendingKey(mediaType, window)] ?? const TrendingState();

  Future<void> ensureLoaded({
    TrendingMediaType mediaType = TrendingMediaType.all,
    TrendingWindow window = TrendingWindow.day,
  }) async {
    final key = _TrendingKey(mediaType, window);
    final state = _states[key] ?? const TrendingState();
    if (!state.hasLoaded && !state.isLoading) {
      await load(mediaType: mediaType, window: window);
    }
  }

  Future<void> load({
    TrendingMediaType mediaType = TrendingMediaType.all,
    TrendingWindow window = TrendingWindow.day,
    bool forceRefresh = false,
  }) async {
    final key = _TrendingKey(mediaType, window);
    final state = _states[key] ?? const TrendingState();

    if (state.isLoading) {
      return;
    }

    if (state.hasLoaded && !forceRefresh) {
      return;
    }

    _states[key] = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final PaginatedResponse<Movie> response = await _repository
          .fetchTrendingTitles(
            mediaType: mediaType.value,
            timeWindow: window.value,
          );
      _states[key] = TrendingState(
        items: response.results
            .map(
              (movie) => _mapToSearchResult(movie, mediaType),
            )
            .toList(),
        hasLoaded: true,
      );
    } on TmdbException catch (error) {
      _states[key] = TrendingState(
        items: const <SearchResult>[],
        hasLoaded: true,
        errorMessage: error.message,
      );
    } catch (error) {
      _states[key] = TrendingState(
        items: const <SearchResult>[],
        hasLoaded: true,
        errorMessage: 'Failed to load trending titles: $error',
      );
    } finally {
      final current = _states[key];
      if (current != null) {
        _states[key] = current.copyWith(isLoading: false);
      }
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    notifyListeners();

    try {
      await Future.wait<void>(
        _states.keys.map(
          (key) => load(
            mediaType: key.mediaType,
            window: key.window,
            forceRefresh: true,
          ),
        ),
      );
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  bool hasLoaded(TrendingMediaType mediaType, TrendingWindow window) {
    return stateFor(mediaType, window).hasLoaded;
  }

  TrendingWindow alternateWindow(TrendingWindow window) {
    return window == TrendingWindow.day ? TrendingWindow.week : TrendingWindow.day;
  }

  int? rankDelta({
    required TrendingMediaType mediaType,
    required TrendingWindow window,
    required SearchResult item,
  }) {
    final currentState = stateFor(mediaType, window);
    final otherWindow = alternateWindow(window);
    final otherState = stateFor(mediaType, otherWindow);

    if (!otherState.hasLoaded) {
      return null;
    }

    final currentIndex = currentState.items.indexWhere(
      (entry) => entry.id == item.id && entry.mediaType == item.mediaType,
    );

    if (currentIndex == -1) {
      return null;
    }

    final otherIndex = otherState.items.indexWhere(
      (entry) => entry.id == item.id && entry.mediaType == item.mediaType,
    );

    if (otherIndex == -1) {
      return null;
    }

    final currentRank = currentIndex + 1;
    final otherRank = otherIndex + 1;
    return otherRank - currentRank;
  }

  bool containsItem({
    required TrendingMediaType mediaType,
    required TrendingWindow window,
    required SearchResult item,
  }) {
    final state = stateFor(mediaType, window);
    return state.items.any(
      (entry) => entry.id == item.id && entry.mediaType == item.mediaType,
    );
  }

  SearchResult _mapToSearchResult(Movie movie, TrendingMediaType bucket) {
    final mediaType = switch (bucket) {
      TrendingMediaType.movie => MediaType.movie,
      TrendingMediaType.tv => MediaType.tv,
      TrendingMediaType.person => MediaType.person,
      TrendingMediaType.all => switch (movie.mediaType) {
          'tv' => MediaType.tv,
          'person' => MediaType.person,
          _ => MediaType.movie,
        },
    };

    final resolvedTitle = mediaType == MediaType.person ? null : movie.title;
    final resolvedName = mediaType == MediaType.movie ? null : movie.title;
    final resolvedPoster = mediaType == MediaType.person
        ? movie.profilePath ?? movie.posterPath
        : movie.posterPath ?? movie.backdropPath;
    final resolvedProfile = mediaType == MediaType.person
        ? movie.profilePath ?? movie.posterPath
        : movie.posterPath;

    return SearchResult(
      id: movie.id,
      mediaType: mediaType,
      title: resolvedTitle,
      name: resolvedName,
      overview: movie.overview,
      posterPath: resolvedPoster,
      profilePath: resolvedProfile,
      backdropPath: movie.backdropPath,
      popularity: movie.popularity,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      releaseDate: mediaType == MediaType.person ? null : movie.releaseDate,
      firstAirDate: mediaType == MediaType.tv ? movie.releaseDate : null,
    );
  }
}

@immutable
class _TrendingKey {
  const _TrendingKey(this.mediaType, this.window);

  final TrendingMediaType mediaType;
  final TrendingWindow window;

  @override
  bool operator ==(Object other) {
    return other is _TrendingKey &&
        other.mediaType == mediaType &&
        other.window == window;
  }

  @override
  int get hashCode => Object.hash(mediaType, window);
}
