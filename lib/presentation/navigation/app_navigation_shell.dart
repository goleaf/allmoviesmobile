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
import '../../data/models/person_detail_model.dart';
import '../../data/models/person_model.dart';
import '../../data/models/season_model.dart';
import '../../data/models/tv_detailed_model.dart';
import '../../data/tmdb_repository.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/deep_link_breadcrumbs_provider.dart';
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

/// Hosts the bottom navigation shell and coordinates deep-link specific flows.
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

  AppDestination? _currentDestination;
  DeepLinkHandler? _deepLinkHandler;
  bool _isHandlingDeepLink = false;

  AppDestination get _activeDestination =>
      _currentDestination ?? AppDestination.home;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentDestination ??= context.read<AppStateProvider>().currentDestination;

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
    final breadcrumbProvider = context.watch<DeepLinkBreadcrumbsProvider>();

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            if (breadcrumbProvider.hasBreadcrumbs)
              DeepLinkBreadcrumbBar(
                breadcrumbs: breadcrumbProvider.breadcrumbs,
                onBreadcrumbTap: _handleBreadcrumbTap,
                onClear: breadcrumbProvider.clear,
              ),
            Expanded(
              child: IndexedStack(
                index: _activeDestination.index,
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

  /// Handles system back navigation by delegating to the currently active
  /// nested navigator. When that stack is already at its root we fall back to
  /// switching the shell to the home destination.
  Future<bool> _handleWillPop() async {
    final currentNavigator = _navigatorKeys[_activeDestination]!.currentState!;

    if (await currentNavigator.maybePop()) {
      return false;
    }

    if (_activeDestination != AppDestination.home) {
      await _ensureDestination(AppDestination.home, shouldNotify: true);
      return false;
    }

    context.read<DeepLinkBreadcrumbsProvider>().clear();
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

  /// Entry point that performs the heavy lifting for each supported deep link.
  Future<void> _openDeepLink(DeepLinkData link) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final repo = context.read<TmdbRepository>();
    final loc = AppLocalizations.of(context);
    final breadcrumbProvider = context.read<DeepLinkBreadcrumbsProvider>();

    Future<void> showError(String message) async {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    breadcrumbProvider.clear();

    switch (link.type) {
      case DeepLinkType.movie:
        if (link.id == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        await _ensureDestination(AppDestination.movies);
        MovieDetailed? detailed;
        try {
          // GET /3/movie/{movie_id} – used to resolve the movie title for the
          // breadcrumb trail.
          detailed = await repo.fetchMovieDetails(link.id!);
        } catch (_) {
          detailed = null;
        }
        final resolvedTitle = (detailed?.title?.isNotEmpty ?? false)
            ? detailed!.title!
            : 'Movie #${link.id}';
        final movieArg = Movie(id: link.id!, title: resolvedTitle);

        breadcrumbProvider.setBreadcrumbs([
          DeepLinkBreadcrumb(
            label: loc.t('navigation.movies'),
            destination: AppDestination.movies,
            routeName: MoviesScreen.routeName,
          ),
          DeepLinkBreadcrumb(label: resolvedTitle),
        ]);

        await rootNavigator.pushNamed(
          MovieDetailScreen.routeName,
          arguments: movieArg,
        );
        break;
      case DeepLinkType.tvShow:
        if (link.id == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        await _ensureDestination(AppDestination.tv);
        TVDetailed? detailed;
        try {
          // GET /3/tv/{tv_id} – resolves the show name for breadcrumbs.
          detailed = await repo.fetchTvDetails(link.id!);
        } catch (_) {
          detailed = null;
        }
        final resolvedName = (detailed?.name?.isNotEmpty ?? false)
            ? detailed!.name!
            : 'Series #${link.id}';
        final showMovie = Movie(
          id: link.id!,
          title: resolvedName,
          mediaType: 'tv',
        );

        breadcrumbProvider.setBreadcrumbs([
          DeepLinkBreadcrumb(
            label: loc.t('navigation.series'),
            destination: AppDestination.tv,
            routeName: SeriesScreen.routeName,
          ),
          DeepLinkBreadcrumb(
            label: resolvedName,
            destination: AppDestination.tv,
            routeName: TVDetailScreen.routeName,
            arguments: showMovie,
          ),
        ]);

        await rootNavigator.pushNamed(
          TVDetailScreen.routeName,
          arguments: showMovie,
        );
        break;
      case DeepLinkType.season:
        if (link.id == null || link.seasonNumber == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        await _ensureDestination(AppDestination.tv);
        TVDetailed? detailed;
        Season? season;
        try {
          // GET /3/tv/{tv_id}
          detailed = await repo.fetchTvDetails(link.id!);
          // GET /3/tv/{tv_id}/season/{season_number}
          season = await repo.fetchTvSeason(link.id!, link.seasonNumber!);
        } catch (_) {
          detailed = null;
          season = null;
        }
        final showName = (detailed?.name?.isNotEmpty ?? false)
            ? detailed!.name!
            : 'Series #${link.id}';
        final seasonLabel = (season?.name?.isNotEmpty ?? false)
            ? season!.name!
            : 'Season ${link.seasonNumber}';
        final showMovie = Movie(
          id: link.id!,
          title: showName,
          mediaType: 'tv',
        );
        final seasonArgs = SeasonDetailArgs(
          tvId: link.id!,
          seasonNumber: link.seasonNumber!,
        );

        breadcrumbProvider.setBreadcrumbs([
          DeepLinkBreadcrumb(
            label: loc.t('navigation.series'),
            destination: AppDestination.tv,
            routeName: SeriesScreen.routeName,
          ),
          DeepLinkBreadcrumb(
            label: showName,
            destination: AppDestination.tv,
            routeName: TVDetailScreen.routeName,
            arguments: showMovie,
          ),
          DeepLinkBreadcrumb(
            label: seasonLabel,
            destination: AppDestination.tv,
            routeName: SeasonDetailScreen.routeName,
            arguments: seasonArgs,
          ),
        ]);

        await rootNavigator.pushNamed(
          SeasonDetailScreen.routeName,
          arguments: seasonArgs,
        );
        break;
      case DeepLinkType.episode:
        if (link.id == null ||
            link.seasonNumber == null ||
            link.episodeNumber == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        await _ensureDestination(AppDestination.tv);
        try {
          // GET /3/tv/{tv_id}
          final show = await repo.fetchTvDetails(link.id!);
          // GET /3/tv/{tv_id}/season/{season_number}
          final season = await repo.fetchTvSeason(
            link.id!,
            link.seasonNumber!,
          );
          // GET /3/tv/{tv_id}/season/{season_number}/episode/{episode_number}
          final episode = await repo.fetchTvEpisode(
            link.id!,
            link.seasonNumber!,
            link.episodeNumber!,
          );

          final showName = (show.name?.isNotEmpty ?? false)
              ? show.name!
              : 'Series #${link.id}';
          final showMovie = Movie(
            id: link.id!,
            title: showName,
            mediaType: 'tv',
          );
          final seasonLabel = (season.name?.isNotEmpty ?? false)
              ? season.name!
              : 'Season ${link.seasonNumber}';
          final episodeLabel = episode.name.isNotEmpty
              ? episode.name
              : 'Episode ${link.episodeNumber}';
          final seasonArgs = SeasonDetailArgs(
            tvId: link.id!,
            seasonNumber: link.seasonNumber!,
          );

          breadcrumbProvider.setBreadcrumbs([
            DeepLinkBreadcrumb(
              label: loc.t('navigation.series'),
              destination: AppDestination.tv,
              routeName: SeriesScreen.routeName,
            ),
            DeepLinkBreadcrumb(
              label: showName,
              destination: AppDestination.tv,
              routeName: TVDetailScreen.routeName,
              arguments: showMovie,
            ),
            DeepLinkBreadcrumb(
              label: seasonLabel,
              destination: AppDestination.tv,
              routeName: SeasonDetailScreen.routeName,
              arguments: seasonArgs,
            ),
            DeepLinkBreadcrumb(label: episodeLabel),
          ]);

          await rootNavigator.pushNamed(
            EpisodeDetailScreen.routeName,
            arguments: EpisodeDetailArgs(tvId: link.id!, episode: episode),
          );
        } catch (_) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.person:
        if (link.id == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        PersonDetail? personDetail;
        Person? summary;
        try {
          // GET /3/person/{person_id}
          personDetail = await repo.fetchPersonDetails(link.id!);
        } catch (_) {
          personDetail = null;
        }
        final resolvedName = (personDetail?.name?.isNotEmpty ?? false)
            ? personDetail!.name
            : 'Person #${link.id}';
        summary = personDetail == null
            ? Person(id: link.id!, name: resolvedName)
            : Person(id: link.id!, name: personDetail!.name);

        breadcrumbProvider.setBreadcrumbs([
          DeepLinkBreadcrumb(label: resolvedName),
        ]);

        await rootNavigator.pushNamed(
          PersonDetailScreen.routeName,
          arguments: summary,
        );
        break;
      case DeepLinkType.company:
        if (link.id == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        Company? company;
        try {
          // GET /3/company/{company_id}
          company = await repo.fetchCompanyDetails(link.id!);
        } catch (_) {
          company = null;
        }
        final resolvedCompany = company ??
            Company(
              id: link.id!,
              name: 'Company #${link.id}',
            );

        breadcrumbProvider.setBreadcrumbs([
          DeepLinkBreadcrumb(label: resolvedCompany.name),
        ]);

        await rootNavigator.pushNamed(
          CompanyDetailScreen.routeName,
          arguments: resolvedCompany,
        );
        break;
      case DeepLinkType.collection:
        if (link.id == null) {
          await showError(loc.t('errors.generic'));
          return;
        }
        CollectionDetails? collection;
        try {
          // GET /3/collection/{collection_id}
          collection = await repo.fetchCollectionDetails(link.id!);
        } catch (_) {
          collection = null;
        }
        final resolvedName = (collection?.name?.isNotEmpty ?? false)
            ? collection!.name
            : 'Collection #${link.id}';

        breadcrumbProvider.setBreadcrumbs([
          DeepLinkBreadcrumb(label: resolvedName),
        ]);

        await rootNavigator.pushNamed(
          CollectionDetailScreen.routeName,
          arguments: link.id!,
        );
        break;
      case DeepLinkType.search:
        final query = link.searchQuery?.trim();
        if (query == null || query.isEmpty) {
          await showError(loc.t('errors.generic'));
          return;
        }
        await _ensureDestination(AppDestination.search);
        breadcrumbProvider.setBreadcrumbs([
          DeepLinkBreadcrumb(
            label: loc.t('navigation.search'),
            destination: AppDestination.search,
            routeName: SearchScreen.routeName,
          ),
          DeepLinkBreadcrumb(label: '"$query"'),
        ]);

        final navigator = _navigatorKeys[AppDestination.search]?.currentState;
        navigator?.popUntil((route) => route.isFirst);
        navigator?.pushNamed(
          SearchScreen.routeName,
          arguments: query,
        );
        break;
    }
  }

  Future<void> _ensureDestination(
    AppDestination destination, {
    bool shouldNotify = false,
  }) async {
    if (_activeDestination == destination) {
      return;
    }
    setState(() {
      _currentDestination = destination;
    });
    if (shouldNotify) {
      context.read<AppStateProvider>().updateDestination(destination);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AppStateProvider>().updateDestination(destination);
      });
    }
    await Future<void>.delayed(Duration.zero);
  }

  NavigationBar _buildBottomNavigationBar() {
    final loc = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: _activeDestination.index,
      onDestinationSelected: (index) {
        final selected = AppDestination.values[index];
        if (_activeDestination == selected) {
          _navigatorKeys[selected]!.currentState?.popUntil(
            (route) => route.isFirst,
          );
          return;
        }

        setState(() {
          _currentDestination = selected;
        });
        context.read<AppStateProvider>().updateDestination(selected);
        context.read<DeepLinkBreadcrumbsProvider>().clear();
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: loc.t('navigation.home'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.movie_outlined),
          selectedIcon: const Icon(Icons.movie),
          label: loc.t('navigation.movies'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.tv_outlined),
          selectedIcon: const Icon(Icons.tv),
          label: loc.t('navigation.series'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.search),
          selectedIcon: const Icon(Icons.search),
          label: loc.t('navigation.search'),
        ),
      ],
    );
  }

  Future<void> _handleBreadcrumbTap(DeepLinkBreadcrumb breadcrumb) async {
    if (!breadcrumb.isActionable) {
      return;
    }
    await _ensureDestination(breadcrumb.destination!, shouldNotify: true);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    rootNavigator.popUntil((route) => route.isFirst);
    if (!mounted || breadcrumb.routeName == null) {
      return;
    }
    await Future<void>.delayed(Duration.zero);
    await rootNavigator.pushNamed(
      breadcrumb.routeName!,
      arguments: breadcrumb.arguments,
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
    final isInitialRoute = settings.name == Navigator.defaultRouteName;

    switch (destination) {
      case AppDestination.home:
        if (isInitialRoute || settings.name == HomeScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
            settings: settings,
          );
        }
        break;
      case AppDestination.movies:
        if (isInitialRoute || settings.name == MoviesScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const MoviesScreen(),
            settings: settings,
          );
        }
        break;
      case AppDestination.tv:
        if (isInitialRoute || settings.name == SeriesScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const SeriesScreen(),
            settings: settings,
          );
        }
        break;
      case AppDestination.search:
        if (isInitialRoute || settings.name == SearchScreen.routeName) {
          final initialQuery = settings.arguments is String
              ? settings.arguments as String
              : null;
          return MaterialPageRoute(
            builder: (_) => SearchScreen(initialQuery: initialQuery),
            settings: settings,
          );
        }
        break;
    }

    return MaterialPageRoute(
      builder: (_) => _buildSharedRoute(settings),
      settings: settings,
    );
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
        final args = settings.arguments;
        if (args is SeriesFiltersScreenArguments) {
          return SeriesFiltersScreen(
            initialFilters: args.initialFilters,
            presetSaved: args.initialPresetName != null,
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
