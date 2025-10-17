import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/presentation/widgets/watch_providers_section.dart';
import 'package:allmovies_mobile/data/models/watch_provider_model.dart';

void main() {
  group('WatchProvidersSection', () {
    testWidgets('renders nothing when all lists are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WatchProvidersSection(
              region: 'US',
              providers: WatchProviderResults(),
            ),
          ),
        ),
      );

      expect(find.textContaining('Where to Watch'), findsNothing);
    });

    testWidgets('renders groups when lists have items', (tester) async {
      final providers = WatchProviderResults(
        flatrate: const [
          WatchProvider(
            id: 1,
            providerId: 8,
            providerName: 'Netflix',
            logoPath: '/logo.png',
          ),
        ],
        rent: const [
          WatchProvider(
            id: 2,
            providerId: 10,
            providerName: 'Apple TV',
            logoPath: '/a.png',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: WatchProvidersSection(region: 'US', providers: providers),
            ),
          ),
        ),
      );

      expect(find.text('Where to Watch (US)'), findsOneWidget);
      expect(find.text('Stream:'), findsOneWidget);
      expect(find.text('Rent:'), findsOneWidget);
    });
  });
}
