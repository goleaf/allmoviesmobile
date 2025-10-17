import 'package:allmovies_mobile/presentation/screens/collections/browse_collections_screen.dart';
import 'package:allmovies_mobile/providers/collections_provider.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../test_support/test_wrapper.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/collection_model.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<CollectionDetails> fetchCollectionDetails(
    int collectionId, {
    bool forceRefresh = false,
  }) async {
    return CollectionDetails(
      id: collectionId,
      name: 'Collection $collectionId',
      overview: 'Overview',
      posterPath: '/p.jpg',
      backdropPath: '/b.jpg',
      parts: const [],
    );
  }

  @override
  Future<PaginatedResponse<Collection>> searchCollections(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return PaginatedResponse<Collection>(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [
        const Collection(
          id: 1,
          name: 'Search Hit',
          posterPath: null,
          backdropPath: null,
        ),
      ],
    );
  }
}

void main() {
  testWidgets(
    'CollectionsBrowserScreen renders curated sections and search results',
    (tester) async {
      await pumpTestApp(
        tester,
        MultiProvider(
          providers: [
            Provider<TmdbRepository>.value(value: _FakeRepo()),
            ChangeNotifierProvider(
              create: (ctx) => CollectionsProvider(_FakeRepo()),
            ),
          ],
          child: const MaterialApp(home: CollectionsBrowserScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Popular and By Genre headings present
      expect(find.textContaining('Popular collections'), findsOneWidget);
      expect(find.textContaining('Collections by genre'), findsOneWidget);

      // Trigger search
      await tester.enterText(find.byType(TextField), 'star');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.textContaining('Search results'), findsOneWidget);
      expect(find.text('Search Hit'), findsWidgets);
    },
  );
}
