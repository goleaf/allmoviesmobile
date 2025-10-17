import 'package:flutter/foundation.dart';

import '../data/models/saved_media_item.dart';
import 'watchlist_provider.dart';

/// Provider that surfaces items the user has started watching but not
/// completed yet. The data is derived from the persisted watchlist.
class ContinueWatchingProvider extends ChangeNotifier {
  ContinueWatchingProvider();

  WatchlistProvider? _watchlistProvider;
  List<SavedMediaItem> _items = const <SavedMediaItem>[];
  String? _errorMessage;
  bool _isLoading = false;

  /// Cached listener instance to attach/detach from the watchlist provider.
  late final VoidCallback _watchlistListener = _handleWatchlistChanged;

  /// Items currently surfaced on the home screen.
  List<SavedMediaItem> get items => List.unmodifiable(_items);

  /// Optional error message when the watchlist could not be processed.
  String? get errorMessage => _errorMessage;

  /// Whether the provider is refreshing the derived list.
  bool get isLoading => _isLoading;

  /// Binds the provider to the shared [WatchlistProvider]. Whenever the
  /// watchlist changes we recompute the continue watching suggestions.
  void attachWatchlist(WatchlistProvider watchlistProvider) {
    if (identical(_watchlistProvider, watchlistProvider)) {
      return;
    }

    _watchlistProvider?.removeListener(_watchlistListener);
    _watchlistProvider = watchlistProvider;
    _watchlistProvider?.addListener(_watchlistListener);
    _recomputeFromWatchlist();
  }

  /// Forces a manual refresh of the continue watching entries.
  Future<void> refresh() async {
    _recomputeFromWatchlist();
  }

  void _handleWatchlistChanged() {
    _recomputeFromWatchlist();
  }

  void _recomputeFromWatchlist() {
    final WatchlistProvider? provider = _watchlistProvider;
    if (provider == null) {
      _items = const <SavedMediaItem>[];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<SavedMediaItem> pending = provider.watchlistItems
          .where((SavedMediaItem item) => !item.watched)
          .toList(growable: false);
      pending.sort(
        (SavedMediaItem a, SavedMediaItem b) =>
            (b.updatedAt).compareTo(a.updatedAt),
      );
      _items = pending.take(12).toList(growable: false);
    } catch (error) {
      _errorMessage = 'Failed to parse watchlist: $error';
      _items = const <SavedMediaItem>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _watchlistProvider?.removeListener(_watchlistListener);
    super.dispose();
  }

  /// Utility exposed for widget tests to seed deterministic data without
  /// relying on the real watchlist service.
  @visibleForTesting
  void setTestState({
    List<SavedMediaItem>? items,
    String? errorMessage,
    bool? isLoading,
  }) {
    _items = items ?? _items;
    _errorMessage = errorMessage;
    _isLoading = isLoading ?? false;
    notifyListeners();
  }
}
