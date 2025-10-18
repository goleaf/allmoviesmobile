import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/navigation/deep_link_handler.dart';
import '../../core/navigation/deep_link_parser.dart';
import '../../data/models/discover_filters_model.dart';
import '../../data/models/episode_model.dart';
import '../../data/models/movie.dart';
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
import '../widgets/offline_banner.dart';
import 'breadcrumb_bar.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  late final Map<AppDestination, GlobalKey<NavigatorState>> _navigatorKeys;
  late AppDestination _currentDestination;
  bool _resolvedInitialDestination = false;

  DeepLinkHandler? _deepLinkHandler;
  Object? _lastDeepLinkError;
  List<BreadcrumbItem> _breadcrumbs = const [];

  @override
  void initState() {
    super.initState();
    _currentDestination = AppDestination.home;
    _navigatorKeys = {
      for (final destination in AppDestination.values)
        destination: GlobalKey<NavigatorState>(),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_resolvedInitialDestination) {
      _currentDestination = context.read<AppStateProvider>().currentDestination;
      _resolvedInitialDestination = true;
    }

    final handler = Provider.of<DeepLinkHandler>(context);
    if (handler != _deepLinkHandler) {
      _deepLinkHandler?.removeListener(_handlePendingDeepLink);
      _deepLinkHandler = handler;
      if (!handler.isInitialized) {
        unawaited(handler.initialize());
      }
      handler.addListener(_handlePendingDeepLink);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _handlePendingDeepLink());
    }
  }

  @override
  void dispose() {
    _deepLinkHandler?.removeListener(_handlePendingDeepLink);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  : BreadcrumbBar(
                      key: ValueKey<int>(_breadcrumbs.length),
                      items: _breadcrumbs,
                    ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentDestination.index,
                children: [
                  for (final destination in AppDestination.values)
                    _DestinationNavigator(
                      key: ValueKey<AppDestination>(destination),
                      navigatorKey: _navigatorKeys[destination]!,
                      destination: destination,
                      onRoutePersisted: _persistRoute,
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
    final navigator = _navigatorKeys[_currentDestination]!.currentState!;
    if (await navigator.maybePop()) {
      return false;
    }

    if (_currentDestination != AppDestination.home) {
      _selectDestination(AppDestination.home);
      return false;
    }

    return true;
  }

  void _persistRoute(AppDestination destination, Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) {
      return;
    }
    context.read<AppStateProvider>().persistLastRoute(
          destination: destination,
          route: name,
        );
  }

  void _handlePendingDeepLink() {
    if (!mounted) return;
    final handler = _deepLinkHandler;
    if (handler == null) return;

    final link = handler.consumePendingLink();
    if (link == null) {
      final error = handler.lastError;
      if (error != null && !identical(error, _lastDeepLinkError)) {
        _lastDeepLinkError = error;
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.t('errors.generic'))),
        );
      }
      return;
    }

    _lastDeepLinkError = null;
    unawaited(_openDeepLink(link));
  }

  Future<void> _openDeepLink(DeepLinkData link) async {
    if (!mounted) return;

    final loc = AppLocalizations.of(context);
    final repo = context.read<TmdbRepository>();
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    final placeholder = _buildPlaceholderBreadcrumbs(link, loc);
    if (placeholder.isNotEmpty) {
      setState(() => _breadcrumbs = placeholder);
    }

    Future<void> navigation = Future.value();

    Future<void> resolveBreadcrumbs([Episode? episode]) async {
      final resolved =
          await _resolveBreadcrumbs(link, repo, loc, episode: episode);
      if (resolved != null && mounted) {
        setState(() => _breadcrumbs = resolved);
      }
    }

    switch (link.type) {
      case DeepLinkType.movie:
        await _ensureDestination(AppDestination.movies);
        resolveBreadcrumbs();
        navigation = rootNavigator.pushNamed(
          MovieDetailScreen.routeName,
          arguments: link.id,
        );
        break;
      case DeepLinkType.tvShow:
        await _ensureDestination(AppDestination.tv);
        resolveBreadcrumbs();
        navigation = rootNavigator.pushNamed(
          TVDetailScreen.routeName,
          arguments: link.id,
        );
        break;
      case DeepLinkType.season:
        if (link.seasonNumber == null) {
          _showDeepLinkError(loc);
          return;
        }
        await _ensureDestination(AppDestination.tv);
        resolveBreadcrumbs();
        navigation = rootNavigator.pushNamed(
          SeasonDetailScreen.routeName,
          arguments: SeasonDetailArgs(
            tvId: link.id!,
            seasonNumber: link.seasonNumber!,
          ),
        );
        break;
      case DeepLinkType.episode:
        if (link.seasonNumber == null || link.episodeNumber == null) {
          _showDeepLinkError(loc);
          return;
        }
        await _ensureDestination(AppDestination.tv);
        try {
          final episode = await repo.fetchTvEpisode(
            link.id!,
            link.seasonNumber!,
            link.episodeNumber!,
          );
          resolveBreadcrumbs(episode);
          navigation = rootNavigator.pushNamed(
            EpisodeDetailScreen.routeName,
            arguments: EpisodeDetailArgs(tvId: link.id!, episode: episode),
          );
        } catch (_) {
          _showDeepLinkError(loc);
          _clearBreadcrumbs();
          return;
        }
        break;
      case DeepLinkType.person:
        resolveBreadcrumbs();
        navigation = rootNavigator.pushNamed(
          PersonDetailScreen.routeName,
          arguments: link.id,
        );
        break;
      case DeepLinkType.company:
        resolveBreadcrumbs();
        navigation = rootNavigator.pushNamed(
          CompanyDetailScreen.routeName,
          arguments: link.id,
        );
        break;
      case DeepLinkType.collection:
        resolveBreadcrumbs();
        navigation = rootNavigator.pushNamed(
          CollectionDetailScreen.routeName,
          arguments: link.id,
        );
        break;
      case DeepLinkType.search:
        await _ensureDestination(AppDestination.search);
        resolveBreadcrumbs();
        final navigator = _navigatorKeys[AppDestination.search]?.currentState;
        navigator?.popUntil((route) => route.isFirst);
        if (link.searchQuery != null && link.searchQuery!.isNotEmpty) {
          navigation = navigator?.pushNamed(
                SearchScreen.routeName,
                arguments: link.searchQuery,
              ) ??
              Future.value();
        }
        break;
    }

    navigation.whenComplete(() {
      if (mounted) {
        _clearBreadcrumbs();
      }
    });
  }

  List<BreadcrumbItem> _buildPlaceholderBreadcrumbs(
    DeepLinkData link,
    AppLocalizations loc,
  ) {
    final loadingLabel = loc.t('common.loading');

    BreadcrumbItem destinationItem(AppDestination destination, String label) {
      return BreadcrumbItem(
        label: label,
        onTap: () => _selectDestination(destination),
      );
    }

    switch (link.type) {
      case DeepLinkType.movie:
        return [
          destinationItem(AppDestination.movies, loc.t('navigation.movies')),
          BreadcrumbItem(label: loadingLabel),
        ];
      case DeepLinkType.tvShow:
        return [
          destinationItem(AppDestination.tv, loc.t('navigation.series')),
          BreadcrumbItem(label: loadingLabel),
        ];
      case DeepLinkType.season:
        return [
          destinationItem(AppDestination.tv, loc.t('navigation.series')),
          BreadcrumbItem(label: loadingLabel),
        ];
      case DeepLinkType.episode:
        return [
          destinationItem(AppDestination.tv, loc.t('navigation.series')),
          BreadcrumbItem(label: loadingLabel),
        ];
      case DeepLinkType.person:
        return [BreadcrumbItem(label: loadingLabel)];
      case DeepLinkType.company:
        return [BreadcrumbItem(label: loadingLabel)];
      case DeepLinkType.collection:
        return [BreadcrumbItem(label: loadingLabel)];
      case DeepLinkType.search:
        final query = link.searchQuery ?? '';
        return [
          destinationItem(AppDestination.search, loc.t('navigation.search')),
          if (query.isNotEmpty) BreadcrumbItem(label: '"$query"'),
        ];
    }
  }

  Future<List<BreadcrumbItem>?> _resolveBreadcrumbs(
    DeepLinkData link,
    TmdbRepository repository,
    AppLocalizations loc, {
    Episode? episode,
  }) async {
    BreadcrumbItem destinationItem(AppDestination destination, String label) {
      return BreadcrumbItem(
        label: label,
        onTap: () => _selectDestination(destination),
      );
    }

    try {
      switch (link.type) {
        case DeepLinkType.movie:
          final details = await repository.fetchMovieDetails(link.id!);
          return [
            destinationItem(AppDestination.movies, loc.t('navigation.movies')),
            BreadcrumbItem(label: details.title),
          ];
        case DeepLinkType.tvShow:
          final details = await repository.fetchTvDetails(link.id!);
          return [
            destinationItem(AppDestination.tv, loc.t('navigation.series')),
            BreadcrumbItem(label: details.name),
          ];
        case DeepLinkType.season:
          final show = await repository.fetchTvDetails(link.id!);
          Season season;
          try {
            season = await repository.fetchTvSeason(
              link.id!,
              link.seasonNumber!,
            );
          } catch (_) {
            season = Season(
              id: link.seasonNumber!,
              name: '${loc.t('tv.season')} ${link.seasonNumber}',
              overview: '',
              airDate: null,
              posterPath: null,
              seasonNumber: link.seasonNumber!,
              episodeCount: 0,
            );
          }
          final seasonLabel = season.name.isNotEmpty
              ? season.name
              : '${loc.t('tv.season')} ${link.seasonNumber}';
          return [
            destinationItem(AppDestination.tv, loc.t('navigation.series')),
            BreadcrumbItem(label: show.name),
            BreadcrumbItem(label: seasonLabel),
          ];
        case DeepLinkType.episode:
          final show = await repository.fetchTvDetails(link.id!);
          final resolvedEpisode = episode ??
              await repository.fetchTvEpisode(
                link.id!,
                link.seasonNumber!,
                link.episodeNumber!,
              );
          final seasonLabel =
              '${loc.t('tv.season')} ${resolvedEpisode.seasonNumber}';
          final episodeLabel = resolvedEpisode.name.isNotEmpty
              ? resolvedEpisode.name
              : '${loc.t('tv.episode')} ${resolvedEpisode.episodeNumber}';
          return [
            destinationItem(AppDestination.tv, loc.t('navigation.series')),
            BreadcrumbItem(label: show.name),
            BreadcrumbItem(label: seasonLabel),
            BreadcrumbItem(label: episodeLabel),
          ];
        case DeepLinkType.person:
          final detail = await repository.fetchPersonDetails(link.id!);
          final name = detail.name.isNotEmpty
              ? detail.name
              : 'Person #${detail.id}';
          return [BreadcrumbItem(label: name)];
        case DeepLinkType.company:
          final company = await repository.fetchCompanyDetails(link.id!);
          return [BreadcrumbItem(label: company.name)];
        case DeepLinkType.collection:
          final collection = await repository.fetchCollectionDetails(link.id!);
          final name = collection.name.isNotEmpty
              ? collection.name
              : loc.t('navigation.collections');
          return [BreadcrumbItem(label: name)];
        case DeepLinkType.search:
          final query = link.searchQuery ?? '';
          return [
            destinationItem(AppDestination.search, loc.t('navigation.search')),
            if (query.isNotEmpty) BreadcrumbItem(label: '"$query"'),
          ];
      }
    } catch (_) {
      return null;
    }
  }

  void _showDeepLinkError(AppLocalizations loc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.t('errors.generic'))),
    );
  }

  void _clearBreadcrumbs() {
    if (_breadcrumbs.isEmpty) {
      return;
    }
    setState(() => _breadcrumbs = const []);
  }

  void _selectDestination(AppDestination destination) {
    if (_currentDestination == destination) {
      _navigatorKeys[destination]!
          .currentState
          ?.popUntil((route) => route.isFirst);
      _clearBreadcrumbs();
      return;
    }

    setState(() {
      _currentDestination = destination;
      _breadcrumbs = const [];
    });
    context.read<AppStateProvider>().updateDestination(destination);
  }

  Future<void> _ensureDestination(AppDestination destination) async {
    if (_currentDestination == destination) {
      return;
    }
    setState(() {
      _currentDestination = destination;
    });
    context.read<AppStateProvider>().updateDestination(destination);
    await Future<void>.delayed(Duration.zero);
  }

  Widget _buildBottomNavigationBar() {
    final loc = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: _currentDestination.index,
      onDestinationSelected: (index) {
        final destination = AppDestination.values[index];
        _selectDestination(destination);
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
}

class _DestinationNavigator extends StatelessWidget {
  const _DestinationNavigator({
    super.key,
    required this.navigatorKey,
    required this.destination,
    required this.onRoutePersisted,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final AppDestination destination;
  final void Function(AppDestination destination, Route<dynamic>? route)
      onRoutePersisted;

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    Widget page;
    final isInitialRoute = settings.name == Navigator.defaultRouteName;

    switch (destination) {
      case AppDestination.home:
        if (isInitialRoute || settings.name == HomeScreen.routeName) {
          page = const HomeScreen();
        } else {
          page = _buildSharedRoute(settings);
        }
        break;
      case AppDestination.movies:
        if (isInitialRoute || settings.name == MoviesScreen.routeName) {
          page = const MoviesScreen();
        } else {
          page = _buildSharedRoute(settings);
        }
        break;
      case AppDestination.tv:
        if (isInitialRoute || settings.name == SeriesScreen.routeName) {
          page = const SeriesScreen();
        } else {
          page = _buildSharedRoute(settings);
        }
        break;
      case AppDestination.search:
        if (isInitialRoute || settings.name == SearchScreen.routeName) {
          final initialQuery = settings.arguments is String
              ? settings.arguments as String
              : null;
          page = SearchScreen(initialQuery: initialQuery);
        } else {
          page = _buildSharedRoute(settings);
        }
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
        final initial = settings.arguments is DiscoverFilters
            ? settings.arguments as DiscoverFilters
            : null;
        return MoviesFiltersScreen(initial: initial);
      case SeriesScreen.routeName:
        return const SeriesScreen();
      case SeriesFiltersScreen.routeName:
        final args = settings.arguments is SeriesFiltersScreenArguments
            ? settings.arguments as SeriesFiltersScreenArguments
            : null;
        return SeriesFiltersScreen(
          initialFilters: args?.initialFilters,
          presetSaved: args?.initialPresetName != null,
        );
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
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
      observers: [
        _AppStateNavigatorObserver(
          destination: destination,
          onPersist: (route) => onRoutePersisted(destination, route),
        ),
      ],
    );
  }
}

class _AppStateNavigatorObserver extends NavigatorObserver {
  _AppStateNavigatorObserver({
    required this.destination,
    required this.onPersist,
  });

  final AppDestination destination;
  final void Function(Route<dynamic>?) onPersist;

  void _persist(Route<dynamic>? route) {
    onPersist(route);
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
