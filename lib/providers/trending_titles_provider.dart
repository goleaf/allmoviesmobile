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
    this.errorMessage,
  });

  static const _sentinel = Object();

  final List<SearchResult> items;
  final bool isLoading;
  final String? errorMessage;

  TrendingState copyWith({
    List<SearchResult>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return TrendingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
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

  TrendingState stateFor(
    TrendingMediaType mediaType,
    TrendingWindow window,
  ) =>
      _states[_TrendingKey(mediaType, window)] ?? const TrendingState();

  Future<void> ensureLoaded({
    TrendingMediaType mediaType = TrendingMediaType.all,
    TrendingWindow window = TrendingWindow.day,
  }) async {
    final key = _TrendingKey(mediaType, window);
    final state = _states[key] ?? const TrendingState();
    if (state.items.isEmpty && !state.isLoading) {
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

    if (state.items.isNotEmpty && !forceRefresh) {
      return;
    }

    _states[key] = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final PaginatedResponse<Movie> response =
          await _repository.fetchTrendingTitles(
        mediaType: mediaType.value,
        timeWindow: window.value,
      );
      _states[key] = TrendingState(items: response.results
          .map((m) => SearchResult(
                id: m.id,
                mediaType: mediaType == TrendingMediaType.person
                    ? MediaType.person
                    : (mediaType == TrendingMediaType.tv
                        ? MediaType.tv
                        : MediaType.movie),
                title: m.title,
                name: m.title,
                overview: m.overview,
                posterPath: m.posterPath,
                profilePath: m.posterPath,
                backdropPath: m.backdropPath,
                popularity: m.popularity,
                voteAverage: m.voteAverage,
                voteCount: m.voteCount,
                releaseDate: m.releaseDate,
              ))
          .toList());
    } on TmdbException catch (error) {
      _states[key] = TrendingState(
        items: const <SearchResult>[],
        errorMessage: error.message,
      );
    } catch (error) {
      _states[key] = TrendingState(
        items: const <SearchResult>[],
        errorMessage: 'Failed to load trending titles: $error',
      );
    } finally {
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
