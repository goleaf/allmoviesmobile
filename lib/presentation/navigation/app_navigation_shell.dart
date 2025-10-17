import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/navigation/deep_link_handler.dart';
import '../../core/navigation/deep_link_parser.dart';
import '../../data/models/collection_model.dart';
import '../../data/models/company_model.dart';
import '../../data/models/episode_model.dart';
import '../../data/models/movie.dart';
import '../../data/models/movie_detailed_model.dart';
import '../../data/models/movie_mappers.dart';
import '../../data/models/person_detail_model.dart';
import '../../data/models/person_model.dart';
import '../../data/models/season_model.dart';
import '../../data/models/tv_detailed_model.dart';
import '../../data/tmdb_repository.dart';
import '../../providers/app_state_provider.dart';
import '../navigation/app_destination.dart';
import '../navigation/episode_detail_args.dart';
import '../navigation/season_detail_args.dart';
import '../screens/collections/collection_detail_screen.dart';
import '../screens/company_detail/company_detail_screen.dart';
import '../screens/episode_detail/episode_detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/movie_detail/movie_detail_screen.dart';
import '../screens/movies/movies_filters_screen.dart';
import '../screens/movies/movies_screen.dart';
import '../screens/person_detail/person_detail_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/season_detail/season_detail_screen.dart';
import '../screens/series/series_filters_screen.dart';
import '../screens/series/series_screen.dart';
import '../screens/tv_detail/tv_detail_screen.dart';
import '../widgets/deep_link_breadcrumb_bar.dart';
import '../widgets/offline_banner.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  final Map<AppDestination, GlobalKey<NavigatorState>> _navigatorKeys = {
    for (final destination in AppDestination.values)
      destination: GlobalKey<NavigatorState>(),
  };

  AppDestination _currentDestination = AppDestination.home;
  DeepLinkHandler? _deepLinkHandler;
  bool _isHandlingDeepLink = false;
  bool _hasSyncedDestination = false;
  List<DeepLinkBreadcrumb> _breadcrumbs = const <DeepLinkBreadcrumb>[];
  Timer? _breadcrumbDismissTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasSyncedDestination) {
      _currentDestination = context.read<AppStateProvider>().currentDestination;
      _hasSyncedDestination = true;
    }

    final handler = Provider.of<DeepLinkHandler>(context);
    if (handler != _deepLinkHandler) {
      _deepLinkHandler?.removeListener(_handlePendingDeepLink);
      _deepLinkHandler = handler
        ..addListener(_handlePendingDeepLink);
      WidgetsBinding.instance.addPostFrameCallback((_) => _handlePendingDeepLink());
    }
  }

  @override
  void dispose() {
    _breadcrumbDismissTimer?.cancel();
    _deepLinkHandler?.removeListener(_handlePendingDeepLink);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breadcrumbKey = _breadcrumbs.map((crumb) => crumb.label).join('>');

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _breadcrumbs.isEmpty
                  ? const SizedBox.shrink()
                  : DeepLinkBreadcrumbBar(
                      key: ValueKey<String>(breadcrumbKey),
                      crumbs: _breadcrumbs,
                      onClear: _clearBreadcrumbs,
                    ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentDestination.index,
                children: [
                  for (final destination in AppDestination.values)
                    _DestinationNavigator(
                      navigatorKey: _navigatorKeys[destination]!,
                      destination: destination,
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Future<bool> _handleWillPop() async {
    final currentNavigator = _navigatorKeys[_currentDestination]!.currentState!;

    if (await currentNavigator.maybePop()) {
      return false;
    }

    if (_currentDestination != AppDestination.home) {
      await _navigateToDestination(AppDestination.home);
      return false;
    }

    return true;
  }

  Future<void> _handlePendingDeepLink() async {
    if (!mounted || _isHandlingDeepLink) return;
    final handler = _deepLinkHandler;
    if (handler == null) return;

    final link = handler.consumePendingLink();
    if (link == null) return;

    _isHandlingDeepLink = true;
    try {
      await _openDeepLink(link);
    } finally {
      _isHandlingDeepLink = false;
    }
  }

  Future<void> _openDeepLink(DeepLinkData link) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final repo = context.read<TmdbRepository>();
    final loc = AppLocalizations.of(context);

    Future<void> showError(String message) async {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    List<DeepLinkBreadcrumb> breadcrumbs = const <DeepLinkBreadcrumb>[];

    switch (link.type) {
      case DeepLinkType.movie:
        final movieId = link.id;
        if (movieId == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        try {
          final MovieDetailed movieDetails = await repo.fetchMovieDetails(movieId);
          final Movie summary = movieDetails.toMovieSummary();
          await _ensureDestination(AppDestination.movies);
          await rootNavigator.pushNamed(
            MovieDetailScreen.routeName,
            arguments: summary,
          );
          final movieTitle = movieDetails.title.isEmpty
              ? 'Movie #$movieId'
              : movieDetails.title;
          breadcrumbs = [
            _destinationBreadcrumb(AppDestination.movies, loc.t('navigation.movies')),
            DeepLinkBreadcrumb(label: movieTitle),
          ];
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.tvShow:
        final tvId = link.id;
        if (tvId == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        try {
          final TVDetailed tvDetails = await repo.fetchTvDetails(tvId);
          final Movie summary = tvDetails.toMovieSummaryFromTv();
          await _ensureDestination(AppDestination.tv);
          await rootNavigator.pushNamed(
            TVDetailScreen.routeName,
            arguments: summary,
          );
          final title = tvDetails.name.isEmpty ? 'TV #$tvId' : tvDetails.name;
          breadcrumbs = [
            _destinationBreadcrumb(AppDestination.tv, loc.t('navigation.series')),
            DeepLinkBreadcrumb(label: title),
          ];
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.season:
        final tvId = link.id;
        final seasonNumber = link.seasonNumber;
        if (tvId == null || seasonNumber == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        try {
          final TVDetailed tvDetails = await repo.fetchTvDetails(tvId);
          final Season season = await repo.fetchTvSeason(tvId, seasonNumber);
          final showTitle = tvDetails.name.isEmpty ? 'TV #$tvId' : tvDetails.name;
          final seasonLabel = season.name.isNotEmpty
              ? season.name
              : '${loc.t('tv.season')} $seasonNumber';
          await _ensureDestination(AppDestination.tv);
          await rootNavigator.pushNamed(
            SeasonDetailScreen.routeName,
            arguments: SeasonDetailArgs(tvId: tvId, seasonNumber: seasonNumber),
          );
          breadcrumbs = [
            _destinationBreadcrumb(AppDestination.tv, loc.t('navigation.series')),
            DeepLinkBreadcrumb(label: showTitle),
            DeepLinkBreadcrumb(label: seasonLabel),
          ];
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.episode:
        final tvId = link.id;
        final seasonNumber = link.seasonNumber;
        final episodeNumber = link.episodeNumber;
        if (tvId == null || seasonNumber == null || episodeNumber == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        try {
          final TVDetailed tvDetails = await repo.fetchTvDetails(tvId);
          final Season season = await repo.fetchTvSeason(tvId, seasonNumber);
          final Episode episode =
              await repo.fetchTvEpisode(tvId, seasonNumber, episodeNumber);
          final showTitle = tvDetails.name.isEmpty ? 'TV #$tvId' : tvDetails.name;
          final seasonLabel = season.name.isNotEmpty
              ? season.name
              : '${loc.t('tv.season')} $seasonNumber';
          final episodeLabel = episode.name.isNotEmpty
              ? episode.name
              : '${loc.t('tv.episode')} $episodeNumber';
          await _ensureDestination(AppDestination.tv);
          await rootNavigator.pushNamed(
            EpisodeDetailScreen.routeName,
            arguments: EpisodeDetailArgs(tvId: tvId, episode: episode),
          );
          breadcrumbs = [
            _destinationBreadcrumb(AppDestination.tv, loc.t('navigation.series')),
            DeepLinkBreadcrumb(label: showTitle),
            DeepLinkBreadcrumb(label: seasonLabel),
            DeepLinkBreadcrumb(label: episodeLabel),
          ];
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.person:
        final personId = link.id;
        if (personId == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        try {
          final PersonDetail personDetail =
              await repo.fetchPersonDetails(personId);
          final Person initialPerson = Person(
            id: personDetail.id,
            name: personDetail.name,
            profilePath: personDetail.profilePath,
            biography: personDetail.biography,
            knownForDepartment: personDetail.knownForDepartment,
            birthday: personDetail.birthday,
            placeOfBirth: personDetail.placeOfBirth,
            alsoKnownAs: personDetail.alsoKnownAs,
            popularity: personDetail.popularity,
          );
          await rootNavigator.pushNamed(
            PersonDetailScreen.routeName,
            arguments: initialPerson,
          );
          final name = personDetail.name.isEmpty
              ? 'Person #$personId'
              : personDetail.name;
          breadcrumbs = [
            DeepLinkBreadcrumb(label: loc.t('navigation.people')),
            DeepLinkBreadcrumb(label: name),
          ];
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.company:
        final companyId = link.id;
        if (companyId == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        try {
          final Company company = await repo.fetchCompanyDetails(companyId);
          await rootNavigator.pushNamed(
            CompanyDetailScreen.routeName,
            arguments: company,
          );
          final name = company.name.isEmpty ? 'Company #$companyId' : company.name;
          breadcrumbs = [
            DeepLinkBreadcrumb(label: loc.t('navigation.companies')),
            DeepLinkBreadcrumb(label: name),
          ];
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.collection:
        final collectionId = link.id;
        if (collectionId == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        try {
          final CollectionDetails collectionDetails =
              await repo.fetchCollectionDetails(collectionId);
          await rootNavigator.pushNamed(
            CollectionDetailScreen.routeName,
            arguments: <String, Object?>{
              'id': collectionId,
              'name': collectionDetails.name,
              'posterPath': collectionDetails.posterPath,
              'backdropPath': collectionDetails.backdropPath,
          },
          );
          final name = collectionDetails.name.isEmpty
              ? 'Collection #$collectionId'
              : collectionDetails.name;
          breadcrumbs = [
            DeepLinkBreadcrumb(label: loc.t('navigation.collections')),
            DeepLinkBreadcrumb(label: name),
          ];
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.search:
        final query = link.searchQuery;
        if (query == null || query.isEmpty) {
          await showError(loc.t('errors.generic'));
          return;
        }
        await _ensureDestination(AppDestination.search);
        final navigator = _navigatorKeys[AppDestination.search]?.currentState;
        navigator?.popUntil((route) => route.isFirst);
        navigator?.pushNamed(
          SearchScreen.routeName,
          arguments: query,
        );
        breadcrumbs = [
          _destinationBreadcrumb(AppDestination.search, loc.t('navigation.search')),
          DeepLinkBreadcrumb(label: query),
        ];
        break;
    }

    if (breadcrumbs.isEmpty) {
      return;
    }

    _updateBreadcrumbs(breadcrumbs);
  }

  DeepLinkBreadcrumb _destinationBreadcrumb(
    AppDestination destination,
    String label,
  ) {
    return DeepLinkBreadcrumb(
      label: label,
      onTap: () => _handleDestinationBreadcrumbTap(destination),
    );
  }

  void _handleDestinationBreadcrumbTap(AppDestination destination) {
    _clearBreadcrumbs();
    unawaited(_navigateToDestination(destination));
  }

  Future<void> _navigateToDestination(AppDestination destination) async {
    if (!mounted) return;

    if (_currentDestination == destination) {
      _navigatorKeys[destination]!
          .currentState
          ?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _currentDestination = destination;
    });
    context.read<AppStateProvider>().updateDestination(destination);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> _ensureDestination(AppDestination destination) {
    if (_currentDestination == destination) {
      return Future<void>.value();
    }
    return _navigateToDestination(destination);
  }

  void _updateBreadcrumbs(List<DeepLinkBreadcrumb> crumbs) {
    _breadcrumbDismissTimer?.cancel();
    _breadcrumbDismissTimer = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _breadcrumbs = crumbs;
    });

    if (crumbs.isEmpty) {
      return;
    }

    _breadcrumbDismissTimer = Timer(const Duration(seconds: 12), () {
      if (!mounted) return;
      setState(() {
        _breadcrumbs = const <DeepLinkBreadcrumb>[];
      });
    });
  }

  void _clearBreadcrumbs() {
    _breadcrumbDismissTimer?.cancel();
    _breadcrumbDismissTimer = null;

    if (!mounted || _breadcrumbs.isEmpty) {
      return;
    }

    setState(() {
      _breadcrumbs = const <DeepLinkBreadcrumb>[];
    });
  }

  Widget _buildBottomNavigationBar() {
    final l = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: _currentDestination.index,
      onDestinationSelected: (index) {
        final selected = AppDestination.values[index];

        if (_currentDestination == selected) {
          _navigatorKeys[selected]!.currentState?.popUntil(
            (route) => route.isFirst,
          );
          return;
        }

        _clearBreadcrumbs();
        unawaited(_navigateToDestination(selected));
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l.t('navigation.home'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.movie_outlined),
          selectedIcon: const Icon(Icons.movie),
          label: l.t('navigation.movies'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.tv_outlined),
          selectedIcon: const Icon(Icons.tv),
          label: l.t('navigation.series'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.search),
          selectedIcon: const Icon(Icons.search),
          label: l.t('navigation.search'),
        ),
      ],
    );
  }
}

class _DestinationNavigator extends StatelessWidget {
  const _DestinationNavigator({
    required this.navigatorKey,
    required this.destination,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final AppDestination destination;

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    Widget page;
    final isInitialRoute = settings.name == Navigator.defaultRouteName;

    switch (destination) {
      case AppDestination.home:
        if (isInitialRoute || settings.name == HomeScreen.routeName) {
          page = const HomeScreen();
          break;
        }
        page = _buildSharedRoute(settings);
        break;
      case AppDestination.movies:
        if (isInitialRoute || settings.name == MoviesScreen.routeName) {
          page = const MoviesScreen();
          break;
        }
        page = _buildSharedRoute(settings);
        break;
      case AppDestination.tv:
        if (isInitialRoute || settings.name == SeriesScreen.routeName) {
          page = const SeriesScreen();
          break;
        }
        page = _buildSharedRoute(settings);
        break;
      case AppDestination.search:
        if (isInitialRoute || settings.name == SearchScreen.routeName) {
          final initialQuery = settings.arguments is String
              ? settings.arguments as String
              : null;
          page = SearchScreen(initialQuery: initialQuery);
          break;
        }
        page = _buildSharedRoute(settings);
        break;
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  Widget _buildSharedRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return const HomeScreen();
      case MoviesScreen.routeName:
        return const MoviesScreen();
      case MoviesFiltersScreen.routeName:
        return const MoviesFiltersScreen();
      case SeriesScreen.routeName:
        return const SeriesScreen();
      case SeriesFiltersScreen.routeName:
        return const SeriesFiltersScreen();
      case SearchScreen.routeName:
        final initialQuery = settings.arguments is String
            ? settings.arguments as String
            : null;
        return SearchScreen(initialQuery: initialQuery);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppStateProvider>();
    final initialRoute =
        appState.lastRouteFor(destination) ?? Navigator.defaultRouteName;

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: _onGenerateRoute,
      initialRoute: initialRoute,
      observers: [
        _AppStateNavigatorObserver(
          context: context,
          destination: destination,
        ),
      ],
    );
  }
}

class _AppStateNavigatorObserver extends NavigatorObserver {
  _AppStateNavigatorObserver({
    required this.context,
    required this.destination,
  });

  final BuildContext context;
  final AppDestination destination;

  void _persist(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) {
      return;
    }
    context.read<AppStateProvider>().persistLastRoute(
          destination: destination,
          route: name,
        );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _persist(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _persist(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _persist(newRoute);
  }
}
