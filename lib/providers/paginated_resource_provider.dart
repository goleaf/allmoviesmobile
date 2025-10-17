import 'package:flutter/foundation.dart';

import '../data/models/paginated_response.dart';

abstract class PaginatedResourceProvider<T> extends ChangeNotifier {
  PaginatedResourceProvider();

  final List<T> _items = [];
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 1;

  List<T> get items => List.unmodifiable(_items);
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _currentPage < _totalPages;

  @protected
  Future<PaginatedResponse<T>> loadPage(int page, {bool forceRefresh = false});

  @protected
  void onItemsReplaced(List<T> items) {}

  @protected
  void onItemsAppended(List<T> items) {}

  Future<void> loadInitial({bool forceRefresh = false}) async {
    if (_isInitialLoading) {
      return;
    }

    _isInitialLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await loadPage(1, forceRefresh: forceRefresh);
      _items
        ..clear()
        ..addAll(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
      onItemsReplaced(response.results);
    } catch (error) {
      _items.clear();
      _errorMessage = error.toString();
      _currentPage = 0;
      _totalPages = 1;
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadInitial(forceRefresh: true);

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) {
      return;
    }

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await loadPage(nextPage);
      _items.addAll(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
      onItemsAppended(response.results);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
