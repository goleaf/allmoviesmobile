import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/error/error_mapper.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../models/movie.dart';
import 'entities/movie_entity.dart';

class LocalDatabaseService {
  LocalDatabaseService({
    required AppLogger logger,
    ErrorMapper? errorMapper,
  })  : _logger = logger,
        _errorMapper = errorMapper ?? const ErrorMapper();

  static const String _moviesBoxName = 'movies';
  static const String _collectionsBoxName = 'movieCollections';
  static const String _favoritesBoxName = 'favorites';
  static const String _watchlistBoxName = 'watchlist';
  static const String _recentlyViewedBoxName = 'recentlyViewed';
  static const String _searchHistoryBoxName = 'searchHistory';

  final AppLogger _logger;
  final ErrorMapper _errorMapper;

  Box<MovieEntity>? _moviesBox;
  Box<List<dynamic>>? _collectionsBox;
  Box<bool>? _favoritesBox;
  Box<bool>? _watchlistBox;
  Box<List<dynamic>>? _recentlyViewedBox;
  Box<List<dynamic>>? _searchHistoryBox;

  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(movieEntityTypeId)) {
        Hive.registerAdapter(MovieEntityAdapter());
      }

      _moviesBox ??= await Hive.openBox<MovieEntity>(_moviesBoxName);
      _collectionsBox ??= await Hive.openBox<List<dynamic>>(_collectionsBoxName);
      _favoritesBox ??= await Hive.openBox<bool>(_favoritesBoxName);
      _watchlistBox ??= await Hive.openBox<bool>(_watchlistBoxName);
      _recentlyViewedBox ??= await Hive.openBox<List<dynamic>>(_recentlyViewedBoxName);
      _searchHistoryBox ??= await Hive.openBox<List<dynamic>>(_searchHistoryBoxName);

      _logger.debug('Local database initialized.');
    } catch (error, stackTrace) {
      throw _errorMapper
          .map(error, stackTrace: stackTrace, endpoint: 'LocalDatabaseService.init');
    }
  }

  Future<void> cacheMovies(String cacheKey, List<Movie> movies) async {
    await _ensureInitialized();

    try {
      final movieIds = <int>[];
      for (final movie in movies) {
        final entity = MovieEntity.fromMovie(movie);
        await _moviesBox!.put(movie.id, entity);
        movieIds.add(movie.id);
      }
      await _collectionsBox!.put(cacheKey, movieIds);
      _logger.debug('Cached ${movieIds.length} movies for $cacheKey');
    } catch (error, stackTrace) {
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        endpoint: 'LocalDatabaseService.cacheMovies',
      );
    }
  }

  Future<List<Movie>> getCachedMovies(String cacheKey) async {
    await _ensureInitialized();

    try {
      final ids = _collectionsBox!.get(cacheKey)?.cast<int>() ?? <int>[];
      return ids
          .map((id) => _moviesBox!.get(id))
          .whereNotNull()
          .map((entity) => entity.toMovie())
          .toList(growable: false);
    } catch (error, stackTrace) {
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        endpoint: 'LocalDatabaseService.getCachedMovies',
      );
    }
  }

  Future<void> addFavorite(int id) async {
    await _ensureInitialized();
    await _favoritesBox!.put(id, true);
    _logger.debug('Added $id to favorites');
  }

  Future<void> removeFavorite(int id) async {
    await _ensureInitialized();
    await _favoritesBox!.delete(id);
    _logger.debug('Removed $id from favorites');
  }

  Future<Set<int>> getFavorites() async {
    await _ensureInitialized();
    return _favoritesBox!.keys.cast<int>().toSet();
  }

  Future<bool> isFavorite(int id) async {
    await _ensureInitialized();
    return _favoritesBox!.containsKey(id);
  }

  Future<void> addWatchlist(int id) async {
    await _ensureInitialized();
    await _watchlistBox!.put(id, true);
    _logger.debug('Added $id to watchlist');
  }

  Future<void> removeWatchlist(int id) async {
    await _ensureInitialized();
    await _watchlistBox!.delete(id);
    _logger.debug('Removed $id from watchlist');
  }

  Future<Set<int>> getWatchlist() async {
    await _ensureInitialized();
    return _watchlistBox!.keys.cast<int>().toSet();
  }

  Future<bool> isInWatchlist(int id) async {
    await _ensureInitialized();
    return _watchlistBox!.containsKey(id);
  }

  Future<void> addRecentlyViewed(int id, {int limit = 20}) async {
    await _ensureInitialized();

    final current = _recentlyViewedBox!.get('items')?.cast<int>().toList() ?? <int>[];
    current.remove(id);
    current.insert(0, id);
    await _recentlyViewedBox!.put('items', current.take(limit).toList());
  }

  Future<List<int>> getRecentlyViewed({int limit = 20}) async {
    await _ensureInitialized();
    final items = _recentlyViewedBox!.get('items')?.cast<int>().toList() ?? <int>[];
    return items.take(limit).toList(growable: false);
  }

  Future<void> addSearchQuery(String query, {int limit = 10}) async {
    await _ensureInitialized();

    final normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }

    final current = _searchHistoryBox!.get('items')?.cast<String>().toList() ?? <String>[];
    current.remove(normalized);
    current.insert(0, normalized);
    await _searchHistoryBox!.put('items', current.take(limit).toList());
  }

  Future<List<String>> getSearchHistory({int limit = 10}) async {
    await _ensureInitialized();
    final items = _searchHistoryBox!.get('items')?.cast<String>().toList() ?? <String>[];
    return items.take(limit).toList(growable: false);
  }

  Future<void> clearSearchHistory() async {
    await _ensureInitialized();
    await _searchHistoryBox!.delete('items');
  }

  Future<void> clearAll() async {
    await _ensureInitialized();
    await Future.wait([
      _moviesBox!.clear(),
      _collectionsBox!.clear(),
      _favoritesBox!.clear(),
      _watchlistBox!.clear(),
      _recentlyViewedBox!.clear(),
      _searchHistoryBox!.clear(),
    ]);
    _logger.warning('Cleared all local database data');
  }

  Future<void> dispose() async {
    await _moviesBox?.close();
    await _collectionsBox?.close();
    await _favoritesBox?.close();
    await _watchlistBox?.close();
    await _recentlyViewedBox?.close();
    await _searchHistoryBox?.close();
  }

  Future<void> _ensureInitialized() async {
    if (!Hive.isBoxOpen(_moviesBoxName)) {
      throw const AppStorageException('Local database not initialized.');
    }
  }
}
