import 'package:flutter/foundation.dart';

import '../data/models/collection_detail_view.dart';
import '../data/services/tmdb_comprehensive_service.dart';

class CollectionDetailsProvider extends ChangeNotifier {
  CollectionDetailsProvider({
    TmdbComprehensiveService? comprehensiveService,
  }) : _service = comprehensiveService ?? TmdbComprehensiveService();

  final TmdbComprehensiveService _service;

  CollectionDetailViewData? _collection;
  bool _isLoading = false;
  String? _errorMessage;

  CollectionDetailViewData? get collection => _collection;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCollection(int collectionId) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detailsFuture = _service.getCollectionDetails(collectionId);
      final imagesFuture = _service.getCollectionImages(collectionId);
      final translationsFuture = _service.getCollectionTranslations(collectionId);

      final responses = await Future.wait([
        detailsFuture,
        imagesFuture,
        translationsFuture,
      ]);

      var viewData = CollectionDetailViewData.fromResponses(
        details: responses[0],
        images: responses[1],
        translations: responses[2],
      );

      final revenueResult = await _calculateRevenues(viewData.parts);
      viewData = viewData.copyWith(
        parts: revenueResult.enrichedParts,
        totalRevenue: revenueResult.totalRevenue,
      );

      _collection = viewData;
    } catch (error, stackTrace) {
      _errorMessage = error.toString();
      debugPrint('Failed to load collection details: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<_RevenueComputationResult> _calculateRevenues(
    List<CollectionPartItem> parts,
  ) async {
    num totalRevenue = 0;
    final enrichedParts = <CollectionPartItem>[];

    for (final part in parts) {
      num? revenue;
      try {
        final details = await _service.getMovieDetails(part.id);
        final value = details['revenue'];
        if (value is num && value > 0) {
          revenue = value;
          totalRevenue += value;
        }
      } catch (error) {
        debugPrint('Failed to fetch revenue for part ${part.id}: $error');
      }
      enrichedParts.add(part.copyWith(revenue: revenue));
    }

    return _RevenueComputationResult(
      enrichedParts: enrichedParts,
      totalRevenue: totalRevenue,
    );
  }
}

class _RevenueComputationResult {
  const _RevenueComputationResult({
    required this.enrichedParts,
    required this.totalRevenue,
  });

  final List<CollectionPartItem> enrichedParts;
  final num totalRevenue;
}
