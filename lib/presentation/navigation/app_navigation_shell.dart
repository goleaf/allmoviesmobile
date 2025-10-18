import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/navigation/deep_link_handler.dart';
import '../../core/navigation/deep_link_parser.dart';
import '../../data/models/company_model.dart';
import '../../data/models/episode_model.dart';
import '../../data/models/movie.dart';
import '../../data/tmdb_repository.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/diagnostics_provider.dart';
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
import '../widgets/offline_banner.dart';
import '../widgets/performance/performance_stats_banner.dart';

/// Hosts the root shell that powers the bottom navigation experience.
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  static const List<AppDestination> _destinations = <AppDestination>[
    AppDestination.home,
    AppDestination.movies,
    AppDestination.tv,
    AppDestination.search,
  ];

  final Map<AppDestination, GlobalKey<NavigatorState>> _navigatorKeys = {
    for (final destination in _destinations)
      destination: GlobalKey<NavigatorState>(),
  };

  late AppDestination _currentDestination;
  DeepLinkHandler? _deepLinkHandler;
  bool _isHandlingDeepLink = false;

  @override
  void initState() {
    super.initState();
    _currentDestination =
        context.read<AppStateProvider>().currentDestination;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final handler = Provider.of<DeepLinkHandler>(context);
    if (handler != _deepLinkHandler) {
      _deepLinkHandler?.removeListener(_handlePendingDeepLink);
      _deepLinkHandler = handler;
      _deepLinkHandler?.addListener(_handlePendingDeepLink);
      WidgetsBinding.instance.addPostFrameCallback((_) => _handlePendingDeepLink());
    }
  }

  @override
  void dispose() {
    _deepLinkHandler?.removeListener(_handlePendingDeepLink);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiagnosticsProvider>(
      builder: (context, diagnostics, child) {
        final shell = Scaffold(
          body: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: IndexedStack(
                  index: _destinations.indexOf(_currentDestination),
                  children: [
                    for (final destination in _destinations)
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
        );

        return WillPopScope(
          onWillPop: _handleWillPop,
          child: Stack(
            children: [
              shell,
              if (diagnostics.profilerEnabled)
                PerformanceStatsBanner(
                  statsListenable: diagnostics.statsListenable,
                ),
            ],
          ),
        );
      },
    );
  }

  /// Handles the Android back button and ensures we navigate back to the
  /// correct destination instead of immediately closing the app.
  Future<bool> _handleWillPop() async {
    final currentNavigator = _navigatorKeys[_currentDestination]!.currentState!;

    if (await currentNavigator.maybePop()) {
      return false;
    }

    if (_currentDestination != AppDestination.home) {
      setState(() {
        _currentDestination = AppDestination.home;
      });
      context.read<AppStateProvider>().updateDestination(AppDestination.home);
      return false;
    }

    return true;
  }

  /// Responds to any pending deep links dispatched by [DeepLinkHandler].
  ///
  /// Each deep link is consumed once to avoid duplicate navigation events.
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

  /// Routes an incoming [DeepLinkData] to the appropriate destination.
  ///
  /// TMDB endpoints used for the associated payloads:
  /// - Movies: `GET /3/movie/{movie_id}` returns the JSON consumed by
  ///   [MovieDetailScreen].
  /// - TV shows: `GET /3/tv/{series_id}` provides the base data for
  ///   [TVDetailScreen].
  /// - Episodes: `GET /3/tv/{tv_id}/season/{season_number}/episode/{episode_number}`
  ///   supplies the detailed episode JSON used in [EpisodeDetailScreen].
  /// - Companies & Collections: `GET /3/company/{company_id}` and
  ///   `GET /3/collection/{collection_id}` drive their respective screens.
  Future<void> _openDeepLink(DeepLinkData link) async {
    final rootNavigatorState = Navigator.of(context, rootNavigator: true);
    final repo = context.read<TmdbRepository>();
    final loc = AppLocalizations.of(context);

    Future<void> showError(String message) async {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    switch (link.type) {
      case DeepLinkType.movie:
        await _ensureDestination(AppDestination.movies);
        await _pushRootNamed(
          navigator: rootNavigatorState,
          routeName: MovieDetailScreen.routeName,
          arguments: Movie(id: link.id!, title: 'Movie #${link.id}'),
        );
        break;
      case DeepLinkType.tvShow:
        await _ensureDestination(AppDestination.tv);
        await _pushRootNamed(
          navigator: rootNavigatorState,
          routeName: TVDetailScreen.routeName,
          arguments: Movie(
            id: link.id!,
            title: 'Series #${link.id}',
            mediaType: 'tv',
          ),
        );
        break;
      case DeepLinkType.season:
        await _ensureDestination(AppDestination.tv);
        await _pushRootNamed(
          navigator: rootNavigatorState,
          routeName: SeasonDetailScreen.routeName,
          arguments: SeasonDetailArgs(
            tvId: link.id!,
            seasonNumber: link.seasonNumber!,
          ),
        );
        break;
      case DeepLinkType.episode:
        await _ensureDestination(AppDestination.tv);
        try {
          final Episode episode = await repo.fetchTvEpisode(
            link.id!,
            link.seasonNumber!,
            link.episodeNumber!,
          );
          if (!mounted) return;
          await _pushRootNamed(
            navigator: rootNavigatorState,
            routeName: EpisodeDetailScreen.routeName,
            arguments: EpisodeDetailArgs(tvId: link.id!, episode: episode),
          );
        } catch (error) {
          // Falls back to the localized generic error when the API call fails.
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.person:
        await _pushRootNamed(
          navigator: rootNavigatorState,
          routeName: PersonDetailScreen.routeName,
          arguments: link.id!,
        );
        break;
      case DeepLinkType.company:
        await _pushRootNamed(
          navigator: rootNavigatorState,
          routeName: CompanyDetailScreen.routeName,
          arguments: Company(id: link.id!, name: 'Company #${link.id}'),
        );
        break;
      case DeepLinkType.collection:
        await _pushRootNamed(
          navigator: rootNavigatorState,
          routeName: CollectionDetailScreen.routeName,
          arguments: link.id!,
        );
        break;
      case DeepLinkType.search:
        await _ensureDestination(AppDestination.search);
        final navigator = _navigatorKeys[AppDestination.search]?.currentState;
        navigator?.popUntil((route) => route.isFirst);
        navigator?.pushNamed(
          SearchScreen.routeName,
          arguments: link.searchQuery,
        );
        break;
    }
  }

  /// Pushes a new route on the root navigator while keeping the helper code
  /// consistent for every deep link branch.
  Future<void> _pushRootNamed({
    required NavigatorState navigator,
    required String routeName,
    Object? arguments,
  }) async {
    await navigator.pushNamed(routeName, arguments: arguments);
  }

  /// Updates the current bottom navigation destination and waits for the UI
  /// to rebuild before proceeding with deep link navigation.
  Future<void> _ensureDestination(AppDestination destination) async {
    if (_currentDestination == destination) return;
    setState(() {
      _currentDestination = destination;
    });
    context.read<AppStateProvider>().updateDestination(destination);
    await Future<void>.delayed(Duration.zero);
  }

  /// Builds the Material 3 bottom navigation bar, wiring destinations to
  /// [AppStateProvider] so the selection persists across app restarts.
  Widget _buildBottomNavigationBar() {
    final l = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: _destinations.indexOf(_currentDestination),
      onDestinationSelected: (index) {
        final selected = _destinations[index];

        if (_currentDestination == selected) {
          _navigatorKeys[selected]!.currentState?.popUntil(
            (route) => route.isFirst,
          );
          return;
        }

        setState(() {
          _currentDestination = selected;
        });
        context.read<AppStateProvider>().updateDestination(selected);
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

/// Dedicated nested navigator for each bottom navigation destination. This
/// keeps navigation stacks isolated so users can switch tabs without losing
/// their previous navigation history.
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

  /// Resolves routes shared across multiple navigators (filters, search, etc.).
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
        final args = settings.arguments;
        if (args is SeriesFiltersScreenArguments) {
          return SeriesFiltersScreen(
            initialFilters: args.initialFilters,
            presetSaved: args.presetSaved,
          );
        }
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

/// Persists the last visited route for a destination so the shell can
/// restore users to the same screen when they return to a tab.
class _AppStateNavigatorObserver extends NavigatorObserver {
  _AppStateNavigatorObserver({
    required this.context,
    required this.destination,
  });

  final BuildContext context;
  final AppDestination destination;

  /// Saves the latest route for the current destination inside
  /// [AppStateProvider] so it can be restored later.
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
