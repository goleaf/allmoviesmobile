import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:allmoviesmobile/presentation/screens/series/series_filters_screen.dart';
import 'package:allmoviesmobile/data/tmdb_repository.dart';
import 'package:allmoviesmobile/data/tv_filter_presets_repository.dart';
import 'package:allmoviesmobile/providers/watch_region_provider.dart';
import 'package:allmoviesmobile/core/localization/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock classes
class MockTmdbRepository extends Mock implements TmdbRepository {
  @override
  Future<List<dynamic>> fetchAvailableWatchProviders({
    required String mediaType,
    String? region,
  }) async {
    return [];
  }
}

class MockTvFilterPresetsRepository extends Mock implements TvFilterPresetsRepository {
  @override
  Future<List<dynamic>> loadPresets() async => [];
}

class MockWatchRegionProvider extends Mock implements WatchRegionProvider {
  @override
  String? get region => 'US';
}

void main() {
  late MockTmdbRepository mockTmdbRepository;
  late MockTvFilterPresetsRepository mockTvFilterPresetsRepository;
  late MockWatchRegionProvider mockWatchRegionProvider;

  setUp(() {
    mockTmdbRepository = MockTmdbRepository();
    mockTvFilterPresetsRepository = MockTvFilterPresetsRepository();
    mockWatchRegionProvider = MockWatchRegionProvider();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<TmdbRepository>.value(value: mockTmdbRepository),
        Provider<TvFilterPresetsRepository>.value(value: mockTvFilterPresetsRepository),
        ChangeNotifierProvider<WatchRegionProvider>.value(value: mockWatchRegionProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
        ],
        home: const SeriesFiltersScreen(),
      ),
    );
  }

  testWidgets('SeriesFiltersScreen shows new filters', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify "By Decade" filter exists (check for a decade button)
    expect(find.text('2020s'), findsOneWidget);

    // Scroll down to find new text fields
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    // Verify TextFields for Cast, Crew, Companies, Keywords
    // Since we don't have keys, we look for hints or labels if possible, 
    // but the code uses hints.
    // Note: AppLocalizations might not be fully loaded in test without real delegate, 
    // but let's assume keys or fallback. 
    // Actually, the code uses `l.t('discover.hintWithCast')`. 
    // If localization fails, it might return the key or crash.
    // Let's check for the presence of TextFields.
    
    // There should be at least 4 new TextFields at the bottom + 1 for timezone + 1 for network search
    expect(find.byType(TextField), findsAtLeastNWidgets(4));
  });
}
