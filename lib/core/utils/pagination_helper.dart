import 'package:flutter/foundation.dart';

/// Helper class for managing paginated API responses
class PaginationHelper<T> with ChangeNotifier {
  PaginationHelper({required this.fetchPage, this.initialPage = 1});

  final Future<List<T>> Function(int page) fetchPage;
  final int initialPage;

  List<T> _items = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<T> get items => _items;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty && !_isLoading;
  int get itemCount => _items.length;

  /// Load the first page
  Future<void> loadInitial() async {
    _isLoading = true;
    _errorMessage = null;
    _items = [];
    _currentPage = initialPage - 1;
    _hasMore = true;
    notifyListeners();

    await loadMore();
  }

  /// Load the next page
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    if (_currentPage == initialPage - 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newItems = await fetchPage(nextPage);

      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        _currentPage = nextPage;

        // If we got fewer items than expected, assume no more pages
        // (TMDB typically returns 20 items per page)
        if (newItems.length < 20) {
          _hasMore = false;
        }
      }
    } catch (error) {
      _errorMessage = error.toString();
      _hasMore = false; // Stop trying if there's an error
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refresh - reload from first page
  Future<void> refresh() async {
    _currentPage = initialPage - 1;
    _hasMore = true;
    await loadInitial();
  }

  /// Reset pagination state
  void reset() {
    _items = [];
    _currentPage = initialPage - 1;
    _hasMore = true;
    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _items = [];
    super.dispose();
  }
}

/// Simple pagination state without ChangeNotifier
class SimplePagination<T> {
  SimplePagination({this.initialPage = 1});

  final int initialPage;

  List<T> items = [];
  int currentPage = 0;
  bool hasMore = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;

  bool get isEmpty => items.isEmpty && !isLoading;
  int get itemCount => items.length;

  void reset() {
    items = [];
    currentPage = initialPage - 1;
    hasMore = true;
    isLoading = false;
    isLoadingMore = false;
    errorMessage = null;
  }
}

/// Pagination controller for managing multiple paginated lists
class PaginationController {
  final Map<String, PaginationHelper> _paginators = {};

  /// Get or create a paginator for a specific key
  PaginationHelper<T> getPaginator<T>(
    String key,
    Future<List<T>> Function(int page) fetchPage,
  ) {
    if (!_paginators.containsKey(key)) {
      _paginators[key] = PaginationHelper<T>(fetchPage: fetchPage);
    }
    return _paginators[key] as PaginationHelper<T>;
  }

  /// Remove a paginator
  void removePaginator(String key) {
    final paginator = _paginators[key];
    paginator?.dispose();
    _paginators.remove(key);
  }

  /// Remove all paginators
  void removeAll() {
    for (final paginator in _paginators.values) {
      paginator.dispose();
    }
    _paginators.clear();
  }

  /// Get paginator if exists
  PaginationHelper<T>? tryGetPaginator<T>(String key) {
    return _paginators[key] as PaginationHelper<T>?;
  }
}
