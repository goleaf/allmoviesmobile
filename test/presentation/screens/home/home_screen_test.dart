import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:allmoviesmobile/core/localization/app_localizations.dart';
import 'package:allmoviesmobile/data/models/collection_model.dart';
import 'package:allmoviesmobile/data/models/movie.dart';
import 'package:allmoviesmobile/data/models/person_model.dart';
import 'package:allmoviesmobile/data/models/saved_media_item.dart';
import 'package:allmoviesmobile/data/tmdb_repository.dart';
import 'package:allmoviesmobile/presentation/screens/home/home_screen.dart';
import 'package:allmoviesmobile/providers/continue_watching_provider.dart';
import 'package:allmoviesmobile/providers/home_highlights_provider.dart';

class _TestHomeHighlightsProvider extends HomeHighlightsProvider {
  _TestHomeHighlightsProvider()
      : super(_NoopTmdbRepository());

  @override
  Future<void> ensureInitialized() async {
    // Prevent network calls during tests.
  }

  @override
  Future<void> refreshAll() async {
    // Prevent refresh side effects in tests.
  }
}

class _NoopTmdbRepository extends TmdbRepository {}

void main() {
  group('HomeScreen', () {
    late _TestHomeHighlightsProvider highlightsProvider;
    late ContinueWatchingProvider continueWatchingProvider;

    const movie = Movie(
      id: 1,
      title: 'Sample Movie',
      mediaType: 'movie',
      releaseDate: '2024-01-01',
    );
    const show = Movie(
      id: 2,
      title: 'Sample Show',
      mediaType: 'tv',
      releaseDate: '2024-02-01',
    );
    final person = Person(
      id: 3,
      name: 'Sample Person',
      knownForDepartment: 'Acting',
    );
    final collection = CollectionDetails(
      id: 4,
      name: 'Sample Collection',
      overview: 'A collection overview.',
    );
    final savedItem = SavedMediaItem(
      id: 5,
      type: SavedMediaType.movie,
      title: 'Saved Movie',
      backdropPath: '/path.jpg',
      voteAverage: 8.0,
      releaseDate: '2023-01-01',
    );

    setUp(() {
      highlightsProvider = _TestHomeHighlightsProvider();
      highlightsProvider
        ..setTestSectionState(
          HomeHighlightsSection.ofMomentMovies,
          const HomeSectionState<Movie>(items: <Movie>[movie]),
        )
        ..setTestSectionState(
          HomeHighlightsSection.ofMomentTv,
          const HomeSectionState<Movie>(items: <Movie>[show]),
        )
        ..setTestSectionState(
          HomeHighlightsSection.popularPeople,
          HomeSectionState<Person>(items: <Person>[person]),
        )
        ..setTestSectionState(
          HomeHighlightsSection.featuredCollections,
          HomeSectionState<CollectionDetails>(
            items: <CollectionDetails>[collection],
          ),
        )
        ..setTestSectionState(
          HomeHighlightsSection.newReleases,
          const HomeSectionState<Movie>(items: <Movie>[movie]),
        )
        ..setTestSectionState(
          HomeHighlightsSection.recommendations,
          const HomeSectionState<Movie>(items: <Movie>[show]),
        );

      continueWatchingProvider = ContinueWatchingProvider()
        ..setTestState(items: <SavedMediaItem>[savedItem]);
    });

    Future<void> pumpHomeScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<HomeHighlightsProvider>.value(
              value: highlightsProvider,
            ),
            ChangeNotifierProvider<ContinueWatchingProvider>.value(
              value: continueWatchingProvider,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders all sections when providers have content',
        (tester) async {
      await pumpHomeScreen(tester);

      expect(find.byKey(HomeScreenKeys.quickAccess), findsOneWidget);
      expect(find.byKey(HomeScreenKeys.moviesOfMoment), findsOneWidget);
      expect(find.byKey(HomeScreenKeys.tvOfMoment), findsOneWidget);
      expect(find.byKey(HomeScreenKeys.continueWatching), findsOneWidget);
      expect(find.byKey(HomeScreenKeys.newReleases), findsOneWidget);
      expect(find.byKey(HomeScreenKeys.recommendations), findsOneWidget);
      expect(find.byKey(HomeScreenKeys.popularPeople), findsOneWidget);
      expect(find.byKey(HomeScreenKeys.featuredCollections), findsOneWidget);
      expect(find.text('Quick access'), findsOneWidget);
      expect(find.text('Of the moment • Movies'), findsOneWidget);
      expect(find.text('Of the moment • TV'), findsOneWidget);
      expect(find.text('Continue watching'), findsOneWidget);
      expect(find.text('New releases'), findsOneWidget);
      expect(find.text('Recommended for you'), findsOneWidget);
      expect(find.text('Popular people'), findsOneWidget);
      expect(find.text('Featured collections'), findsOneWidget);
      expect(find.text('Search movies, TV, and people'), findsOneWidget);
    });

    testWidgets('shows empty state for movies carousel when no data',
        (tester) async {
      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.ofMomentMovies,
        const HomeSectionState<Movie>(items: <Movie>[]),
      );

      await pumpHomeScreen(tester);

      expect(
        find.text('Trending movies are currently unavailable.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error state for movies carousel when error occurs',
        (tester) async {
      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.ofMomentMovies,
        const HomeSectionState<Movie>(
          errorMessage: 'Movies failed to load',
        ),
      );

      await pumpHomeScreen(tester);

      expect(find.text('Movies failed to load'), findsOneWidget);
    });

    testWidgets('shows empty state for TV carousel when no data',
        (tester) async {
      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.ofMomentTv,
        const HomeSectionState<Movie>(items: <Movie>[]),
      );

      await pumpHomeScreen(tester);

      expect(
        find.text('Trending TV shows are currently unavailable.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error state for TV carousel when error occurs',
        (tester) async {
      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.ofMomentTv,
        const HomeSectionState<Movie>(errorMessage: 'TV failed'),
      );

      await pumpHomeScreen(tester);

      expect(find.text('TV failed'), findsOneWidget);
    });

    testWidgets('shows empty and error state for continue watching',
        (tester) async {
      continueWatchingProvider.setTestState(items: const <SavedMediaItem>[]);
      await pumpHomeScreen(tester);
      expect(
        find.text('Add movies or shows to your watchlist to keep track of progress.'),
        findsOneWidget,
      );

      continueWatchingProvider.setTestState(
        errorMessage: 'Watchlist error',
      );
      await pumpHomeScreen(tester);
      expect(find.text('Watchlist error'), findsOneWidget);
    });

    testWidgets('shows empty and error state for new releases carousel',
        (tester) async {
      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.newReleases,
        const HomeSectionState<Movie>(items: <Movie>[]),
      );
      await pumpHomeScreen(tester);
      expect(
        find.text('No new releases available right now.'),
        findsOneWidget,
      );

      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.newReleases,
        const HomeSectionState<Movie>(errorMessage: 'New releases error'),
      );
      await pumpHomeScreen(tester);
      expect(find.text('New releases error'), findsOneWidget);
    });

    testWidgets('shows empty and error state for recommendations carousel',
        (tester) async {
      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.recommendations,
        const HomeSectionState<Movie>(items: <Movie>[]),
      );
      await pumpHomeScreen(tester);
      expect(
        find.text('No recommendations are available at this time.'),
        findsOneWidget,
      );

      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.recommendations,
        const HomeSectionState<Movie>(errorMessage: 'Recommendations error'),
      );
      await pumpHomeScreen(tester);
      expect(find.text('Recommendations error'), findsOneWidget);
    });

    testWidgets('shows empty and error state for popular people carousel',
        (tester) async {
      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.popularPeople,
        const HomeSectionState<Person>(items: <Person>[]),
      );
      await pumpHomeScreen(tester);
      expect(
        find.text('Popular people are currently unavailable.'),
        findsOneWidget,
      );

      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.popularPeople,
        const HomeSectionState<Person>(errorMessage: 'People error'),
      );
      await pumpHomeScreen(tester);
      expect(find.text('People error'), findsOneWidget);
    });

    testWidgets('shows empty and error state for featured collections carousel',
        (tester) async {
      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.featuredCollections,
        const HomeSectionState<CollectionDetails>(items: <CollectionDetails>[]),
      );
      await pumpHomeScreen(tester);
      expect(
        find.text('Featured collections are currently unavailable.'),
        findsOneWidget,
      );

      highlightsProvider.setTestSectionState(
        HomeHighlightsSection.featuredCollections,
        const HomeSectionState<CollectionDetails>(
          errorMessage: 'Collections error',
        ),
      );
      await pumpHomeScreen(tester);
      expect(find.text('Collections error'), findsOneWidget);
    });
  });
}
