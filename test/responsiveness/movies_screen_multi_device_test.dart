import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_utils/pump_app.dart';

class _FakeTmdbRepository extends TmdbRepository {
  PaginatedResponse<Movie> _buildResponse(String label) {
    return PaginatedResponse<Movie>(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [
        Movie(
          id: label.hashCode,
          title: '$label Movie',
          overview: '$label overview',
        ),
      ],
    );
  }

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingMoviesPaginated({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async => _buildResponse('Trending');

  @override
  Future<PaginatedResponse<Movie>> fetchNowPlayingMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => _buildResponse('Now Playing');

  @override
  Future<PaginatedResponse<Movie>> fetchPopularMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => _buildResponse('Popular');

  @override
  Future<PaginatedResponse<Movie>> fetchTopRatedMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => _buildResponse('Top Rated');

  @override
  Future<PaginatedResponse<Movie>> fetchUpcomingMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => _buildResponse('Upcoming');

  @override
  Future<PaginatedResponse<Movie>> discoverMovies({
    int page = 1,
    discoverFilters,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) async => _buildResponse('Discover');

  @override
  Future<PaginatedResponse<Movie>> searchMovies(
    String query, {
    int page = 1,
    filters,
    bool forceRefresh = false,
  }) async => _buildResponse('Search $query');
}

class _DeviceScenario {
  const _DeviceScenario({
    required this.name,
    required this.size,
    required this.pixelRatio,
    required this.platform,
    this.textScale = 1.0,
    this.brightness,
  });

  final String name;
  final Size size;
  final double pixelRatio;
  final TargetPlatform platform;
  final double textScale;
  final Brightness? brightness;
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized()
      as TestWidgetsFlutterBinding;

  const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  final scenarios = <_DeviceScenario>[
    const _DeviceScenario(
      name: 'Android phone (Pixel 6, Android 14)',
      size: Size(1080, 2340),
      pixelRatio: 3.0,
      platform: TargetPlatform.android,
      textScale: 1.0,
      brightness: Brightness.light,
    ),
    const _DeviceScenario(
      name: 'Android legacy phone (Pixel 2, Android 11)',
      size: Size(900, 1600),
      pixelRatio: 2.5,
      platform: TargetPlatform.android,
      textScale: 1.1,
      brightness: Brightness.dark,
    ),
    const _DeviceScenario(
      name: 'iPhone 14 Pro (iOS 17)',
      size: Size(1179, 2556),
      pixelRatio: 3.0,
      platform: TargetPlatform.iOS,
      textScale: 1.0,
      brightness: Brightness.light,
    ),
    const _DeviceScenario(
      name: 'iPad Pro 12.9" (iPadOS 17 tablet mode)',
      size: Size(2048, 2732),
      pixelRatio: 2.0,
      platform: TargetPlatform.iOS,
      textScale: 1.2,
      brightness: Brightness.light,
    ),
    const _DeviceScenario(
      name: 'Flutter web desktop (Chrome 128)',
      size: Size(1920, 1080),
      pixelRatio: 1.5,
      platform: TargetPlatform.fuchsia,
      textScale: 1.0,
      brightness: Brightness.light,
    ),
  ];

  for (final scenario in scenarios) {
    testWidgets('MoviesScreen adapts for ${scenario.name}', (tester) async {
      binding.window.physicalSizeTestValue = scenario.size;
      binding.window.devicePixelRatioTestValue = scenario.pixelRatio;
      binding.platformDispatcher.textScaleFactorTestValue = scenario.textScale;
      if (scenario.brightness != null) {
        binding.platformDispatcher.platformBrightnessTestValue =
            scenario.brightness!;
      }
      debugDefaultTargetPlatformOverride = scenario.platform;

      addTearDown(() {
        binding.window.clearPhysicalSizeTestValue();
        binding.window.clearDevicePixelRatioTestValue();
        binding.platformDispatcher.clearAllTestValues();
        debugDefaultTargetPlatformOverride = null;
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      final providers = <SingleChildWidget>[
        Provider<LocalStorageService>.value(value: storage),
        ChangeNotifierProvider(
          create: (_) => MoviesProvider(
            _FakeTmdbRepository(),
            regionProvider: WatchRegionProvider(prefs),
            storageService: storage,
            autoInitialize: false,
          ),
        ),
      ];

      await pumpApp(
        tester,
        const MoviesScreen(),
        providers: providers,
        localizationsDelegates: delegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(MoviesScreen), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
