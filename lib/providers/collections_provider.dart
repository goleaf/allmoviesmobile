import 'package:flutter/foundation.dart';

import '../core/constants/app_strings.dart';
import '../data/models/collection_model.dart';
import '../data/tmdb_repository.dart';

class CollectionsProvider extends ChangeNotifier {
  CollectionsProvider(this._repository);

  final TmdbRepository _repository;

  static const List<int> _popularCollectionIds = <int>[
    10, // Star Wars Collection
    1241, // Harry Potter Collection
    86311, // The Avengers Collection
    328, // Jurassic Park Collection
    87359, // Mission: Impossible Collection
    404609, // John Wick Collection
  ];

  static const Map<String, List<int>> _genreCollectionIds = <String, List<int>>{
    'Action & Adventure': <int>[86311, 87359, 9485],
    'Sci-Fi & Fantasy': <int>[10, 2344, 1241],
    'Animation & Family': <int>[10194, 121938, 137697],
    'Thriller & Crime': <int>[263, 404609, 645],
  };

  final List<CollectionDetails> _popularCollections = <CollectionDetails>[];
  final Map<String, List<CollectionDetails>> _collectionsByGenre =
      <String, List<CollectionDetails>>{};

  bool _isPopularLoading = false;
  bool _isGenresLoading = false;
  bool _hasInitialized = false;
  String? _popularError;
  String? _genresError;

  String _searchQuery = '';
  final List<Collection> _searchResults = <Collection>[];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _searchError;
  int _searchToken = 0;

  List<CollectionDetails> get popularCollections =>
      List<CollectionDetails>.unmodifiable(_popularCollections);

  Map<String, List<CollectionDetails>> get collectionsByGenre =>
      _collectionsByGenre.map(
        (key, value) =>
            MapEntry(key, List<CollectionDetails>.unmodifiable(value)),
      );

  bool get isPopularLoading => _isPopularLoading;
  bool get isGenresLoading => _isGenresLoading;
  String? get popularError => _popularError;
  String? get genresError => _genresError;

  String get searchQuery => _searchQuery;
  List<Collection> get searchResults =>
      List<Collection>.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;
  bool get hasSearchQuery => _searchQuery.trim().isNotEmpty;
  bool get hasSearchError => _searchError != null;
  bool get hasSearchResults => _searchResults.isNotEmpty;
  bool get hasSearched => _hasSearched;
  String? get searchError => _searchError;

  Future<void> ensureInitialized() async {
    if (_hasInitialized) {
      return;
    }
    _hasInitialized = true;
    await Future.wait<void>([
      loadPopularCollections(),
      loadCollectionsByGenre(),
    ]);
  }

  Future<void> loadPopularCollections({bool forceRefresh = false}) async {
    if (_isPopularLoading) {
      return;
    }

    _isPopularLoading = true;
    _popularError = null;
    notifyListeners();

    try {
      final collections = await _fetchCollections(
        _popularCollectionIds,
        forceRefresh: forceRefresh,
      );
      _popularCollections
        ..clear()
        ..addAll(collections);
      if (_popularCollections.isEmpty) {
        _popularError = AppStrings.collectionsUnavailable;
      }
    } catch (error) {
      _popularError = 'Failed to load collections: $error';
    } finally {
      _isPopularLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCollectionsByGenre({bool forceRefresh = false}) async {
    if (_isGenresLoading) {
      return;
    }

    _isGenresLoading = true;
    _genresError = null;
    notifyListeners();

    final updated = <String, List<CollectionDetails>>{};

    try {
      for (final entry in _genreCollectionIds.entries) {
        final collections = await _fetchCollections(
          entry.value,
          forceRefresh: forceRefresh,
        );
        if (collections.isNotEmpty) {
          updated[entry.key] = collections;
        }
      }

      _collectionsByGenre
        ..clear()
        ..addAll(updated);

      if (_collectionsByGenre.isEmpty) {
        _genresError = AppStrings.collectionsUnavailable;
      }
    } catch (error) {
      _genresError = 'Failed to load genre collections: $error';
    } finally {
      _isGenresLoading = false;
      notifyListeners();
    }
  }

  Future<List<CollectionDetails>> _fetchCollections(
    List<int> ids, {
    bool forceRefresh = false,
  }) async {
    if (ids.isEmpty) {
      return const <CollectionDetails>[];
    }

    final futures = ids.map((id) async {
      try {
        return await _repository.fetchCollectionDetails(
          id,
          forceRefresh: forceRefresh,
        );
      } catch (error) {
        debugPrint('Failed to load collection $id: $error');
        return null;
      }
    });

    final results = await Future.wait<CollectionDetails?>(futures);
    return results.whereType<CollectionDetails>().toList(growable: false);
  }

  Future<void> refreshAll() async {
    await Future.wait<void>([
      loadPopularCollections(forceRefresh: true),
      loadCollectionsByGenre(forceRefresh: true),
      if (hasSearchQuery) searchCollections(_searchQuery, forceRefresh: true),
    ]);
  }

  Future<void> searchCollections(
    String query, {
    bool forceRefresh = false,
  }) async {
    _searchQuery = query;
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      _searchToken++;
      _searchResults.clear();
      _searchError = null;
      _hasSearched = false;
      _isSearching = false;
      notifyListeners();
      return;
    }

    final token = ++_searchToken;
    _isSearching = true;
    _searchError = null;
    _hasSearched = true;
    notifyListeners();

    try {
      final response = await _repository.searchCollections(
        trimmed,
        page: 1,
        forceRefresh: forceRefresh,
      );
      if (_searchToken != token) {
        return;
      }
      _searchResults
        ..clear()
        ..addAll(response.results);
      _searchError = null;
    } catch (error) {
      if (_searchToken != token) {
        return;
      }
      _searchResults.clear();
      _searchError = 'Failed to search collections: $error';
    } finally {
      if (_searchToken == token) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _searchToken++;
    _searchQuery = '';
    _searchResults.clear();
    _searchError = null;
    _hasSearched = false;
    _isSearching = false;
    notifyListeners();
  }

  Future<CollectionDetails?> fetchCollectionPreview(int collectionId) async {
    try {
      return await _repository.fetchCollectionDetails(collectionId);
    } catch (error) {
      debugPrint(
        'Failed to fetch preview for collection $collectionId: $error',
      );
      return null;
    }
  }
}
