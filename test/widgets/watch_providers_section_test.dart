import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/watch_provider_model.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/presentation/widgets/watch_providers_section.dart';

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

  group('WatchProvidersAvailabilitySection', () {
    testWidgets('does not show banner on first snapshot load', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      final providers = WatchProviderResults(
        flatrate: const [
          WatchProvider(
            id: 1,
            providerId: 8,
            providerName: 'Netflix',
            logoPath: '/logo.png',
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<LocalStorageService>.value(value: storage),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WatchProvidersAvailabilitySection(
                mediaType: 'movie',
                mediaId: 1,
                region: 'US',
                providers: providers,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('is now available to stream'), findsNothing);
      expect(find.text('Where to Watch (US)'), findsOneWidget);
    });

    testWidgets('shows banner when new provider detected', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await storage.saveWatchProviderSnapshot('movie', 1, 'US', const <int>{8});

      final providers = WatchProviderResults(
        flatrate: const [
          WatchProvider(
            id: 1,
            providerId: 8,
            providerName: 'Netflix',
            logoPath: '/netflix.png',
          ),
          WatchProvider(
            id: 2,
            providerId: 9,
            providerName: 'Hulu',
            logoPath: '/hulu.png',
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<LocalStorageService>.value(value: storage),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WatchProvidersAvailabilitySection(
                mediaType: 'movie',
                mediaId: 1,
                region: 'US',
                providers: providers,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Hulu is now available to stream in US.'),
        findsOneWidget,
      );
      expect(find.text('Where to Watch (US)'), findsOneWidget);
    });
  });
}
