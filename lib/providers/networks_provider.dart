import '../data/models/network_model.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

class NetworksProvider extends PaginatedResourceProvider<Network> {
  NetworksProvider(
    this._repository, {
    String initialQuery = 'netflix',
    Map<String, String>? featuredCountries,
  }) : _query = initialQuery.trim().isEmpty ? 'netflix' : initialQuery.trim(),
       _featuredCountries =
           featuredCountries != null && featuredCountries.isNotEmpty
           ? Map.unmodifiable({
               for (final entry in featuredCountries.entries)
                 entry.key.toUpperCase(): entry.value,
             })
           : _defaultFeaturedCountries {
    loadInitial();
    _loadStaticData();
  }

  final TmdbRepository _repository;
  String _query;
  final Map<String, String> _featuredCountries;

  static const Map<String, String> _defaultFeaturedCountries = {
    'US': 'United States',
    'GB': 'United Kingdom',
    'JP': 'Japan',
    'KR': 'South Korea',
    'DE': 'Germany',
    'IN': 'India',
  };

  List<Network> _popularNetworks = [];
  Map<String, List<Network>> _networksByCountry = {};
  bool _isLoadingStatic = false;
  String? _staticError;

  String get query => _query;
  List<Network> get networks => items;
  List<Network> get popularNetworks => _popularNetworks;
  Map<String, List<Network>> get networksByCountry =>
      Map<String, List<Network>>.unmodifiable(_networksByCountry);
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;
  bool get isLoadingStatic => _isLoadingStatic;
  String? get staticError => _staticError;

  List<String> get featuredCountryCodes =>
      List<String>.unmodifiable(_featuredCountries.keys);

  String countryLabel(String code) =>
      _featuredCountries[code.toUpperCase()] ?? code.toUpperCase();

  Future<void> refreshNetworks() => loadInitial(forceRefresh: true);

  Future<void> loadMoreNetworks() => loadMore();

  Future<void> refreshStaticData({bool forceRefresh = false}) =>
      _loadStaticData(forceRefresh: forceRefresh);

  Future<void> searchNetworks(String newQuery) async {
    final sanitized = newQuery.trim();
    if (sanitized.isEmpty) {
      _query = 'netflix';
      await loadInitial(forceRefresh: true);
      return;
    }

    if (sanitized.toLowerCase() == _query.toLowerCase() && items.isNotEmpty) {
      return;
    }

    _query = sanitized;
    await loadInitial(forceRefresh: true);
  }

  @override
  Future<PaginatedResponse<Network>> loadPage(
    int page, {
    bool forceRefresh = false,
  }) {
    return _repository.fetchNetworks(
      query: _query,
      page: page,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _loadStaticData({bool forceRefresh = false}) async {
    if (_isLoadingStatic) {
      return;
    }

    _isLoadingStatic = true;
    _staticError = null;
    notifyListeners();

    final Map<String, List<Network>> countryResults = {};
    List<Network> popular = _popularNetworks;

    try {
      final response = await _repository.fetchPopularNetworks(
        page: 1,
        forceRefresh: forceRefresh,
      );
      popular = response.results;
    } catch (error) {
      _staticError ??= error.toString();
    }

    for (final country in _featuredCountries.keys) {
      try {
        final response = await _repository.fetchNetworks(
          country: country,
          page: 1,
          forceRefresh: forceRefresh,
        );
        countryResults[country] = response.results;
      } catch (error) {
        _staticError ??= error.toString();
      }
    }

    _popularNetworks = popular;
    _networksByCountry = countryResults;

    _isLoadingStatic = false;
    notifyListeners();
  }
}
