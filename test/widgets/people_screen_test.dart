import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/person_detail_model.dart';
import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/people_provider.dart';
import 'package:allmovies_mobile/presentation/screens/people/people_screen.dart';
import 'package:allmovies_mobile/core/localization/app_localizations.dart';

import '../test_utils/pump_app.dart';

/// Fake implementation of [TmdbRepository] used to keep the widget tests
/// deterministic and avoid any real network access.
class _FakeRepo extends TmdbRepository {
  _FakeRepo({
    this.trending = const [Person(id: 2, name: 'Trending Person')],
    this.popular = const [Person(id: 1, name: 'Popular Person')],
    this.detail,
  });

  final List<Person> trending;
  final List<Person> popular;
  final PersonDetail? detail;

  @override
  Future<PaginatedResponse<Person>> fetchPopularPeople({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    // Provide a single-page response so the provider treats the load as
    // complete and renders list content synchronously for the tests.
    return PaginatedResponse<Person>(
      page: 1,
      totalPages: 1,
      totalResults: popular.length,
      results: popular,
    );
  }

  @override
  Future<List<Person>> fetchTrendingPeople({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => trending;

  @override
  Future<PersonDetail> fetchPersonDetails(
    int personId, {
    bool forceRefresh = false,
  }) async {
    // Return a minimal detail payload – the UI only cares about the id so we
    // keep the object intentionally small for quicker test execution.
    return detail ?? PersonDetail(id: personId, name: 'Detail $personId');
  }
}

/// Simple observer that captures pushed routes so we can ensure the expected
/// navigation happens when a person is tapped.
class _TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  testWidgets('PeopleScreen builds with localized tabs', (tester) async {
    await pumpApp(
      tester,
      const PeopleScreen(),
      providers: [
        ChangeNotifierProvider(
          create: (_) => PeopleProvider(_FakeRepo()),
        ),
      ],
      localizationsDelegates: delegates,
    );

    expect(find.byType(PeopleScreen), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Trending'), findsWidgets);
    expect(find.text('Popular'), findsWidgets);
  });

  testWidgets('Tapping a person pushes the detail route with the id', (
    tester,
  ) async {
    final observer = _TestNavigatorObserver();

    await pumpApp(
      tester,
      const PeopleScreen(),
      providers: [
        ChangeNotifierProvider(
          create: (_) => PeopleProvider(_FakeRepo()),
        ),
      ],
      localizationsDelegates: delegates,
      navigatorObserver: observer,
      onGenerateRoute: (settings) {
        if (settings.name == '/person') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          );
        }
        return null;
      },
    );

    // Tap the first person card – our fake repository only returns two names,
    // so finding the text is stable.
    await tester.tap(find.text('Trending Person'));
    await tester.pumpAndSettle();

    final pushedDetailRoute = observer.pushed
        .where((route) => route.settings.name == '/person')
        .cast<MaterialPageRoute<dynamic>>()
        .single;
    expect(pushedDetailRoute.settings.arguments, equals(2));
  });

  testWidgets('Empty lists surface the localized empty state message', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const PeopleScreen(),
      providers: [
        ChangeNotifierProvider(
          create: (_) => PeopleProvider(
            _FakeRepo(trending: const [], popular: const []),
          ),
        ),
      ],
      localizationsDelegates: delegates,
    );

    // Scrollable empty content should still render a friendly message.
    expect(find.text('No results found'), findsOneWidget);
  });

  testWidgets('Selecting a department filters the people lists', (tester) async {
    await pumpApp(
      tester,
      const PeopleScreen(),
      providers: [
        ChangeNotifierProvider(
          create: (_) => PeopleProvider(
            _FakeRepo(
              trending: const [
                Person(
                  id: 10,
                  name: 'Actor One',
                  knownForDepartment: 'Acting',
                ),
                Person(
                  id: 11,
                  name: 'Director One',
                  knownForDepartment: 'Directing',
                ),
              ],
              popular: const [
                Person(
                  id: 12,
                  name: 'Producer One',
                  knownForDepartment: 'Production',
                ),
              ],
            ),
          ),
        ),
      ],
      localizationsDelegates: delegates,
    );

    await tester.pumpAndSettle();

    expect(find.text('Actor One'), findsOneWidget);
    expect(find.text('Director One'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Directing'));
    await tester.pumpAndSettle();

    expect(find.text('Actor One'), findsNothing);
    expect(find.text('Director One'), findsOneWidget);
    expect(find.text('Producer One'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All departments'));
    await tester.pumpAndSettle();

    expect(find.text('Actor One'), findsOneWidget);
    expect(find.text('Director One'), findsOneWidget);
  });
}
