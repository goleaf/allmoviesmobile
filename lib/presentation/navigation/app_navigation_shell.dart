import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/navigation/deep_link_handler.dart';
import '../../core/navigation/deep_link_parser.dart';
import '../../data/models/company_model.dart';
import '../../data/models/episode_model.dart';
import '../../data/models/movie.dart';
import '../../data/tmdb_repository.dart';
import '../navigation/season_detail_args.dart';
import '../screens/collections/collection_detail_screen.dart';
import '../screens/company_detail/company_detail_screen.dart';
import '../screens/episode_detail/episode_detail_screen.dart';
import '../navigation/episode_detail_args.dart';
import '../screens/movie_detail/movie_detail_screen.dart';
import '../screens/person_detail/person_detail_screen.dart';
import '../screens/season_detail/season_detail_screen.dart';
import '../screens/tv_detail/tv_detail_screen.dart';
// Home/More removed in this app variant; keep movies/search/series only
import '../screens/movies/movies_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/series/series_screen.dart';
import '../screens/movies/movies_filters_screen.dart';
import '../screens/series/series_filters_screen.dart';

enum AppDestination { movies, tv, search }

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

  AppDestination _currentDestination = AppDestination.movies;
  DeepLinkHandler? _deepLinkHandler;
  bool _isHandlingDeepLink = false;

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
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentDestination.index,
          children: [
            for (final destination in AppDestination.values)
              _DestinationNavigator(
                navigatorKey: _navigatorKeys[destination]!,
                destination: destination,
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

    if (_currentDestination != AppDestination.movies) {
      setState(() {
        _currentDestination = AppDestination.movies;
      });
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

    switch (link.type) {
      case DeepLinkType.movie:
        await _ensureDestination(AppDestination.movies);
        await rootNavigator.pushNamed(
          MovieDetailScreen.routeName,
          arguments: Movie(id: link.id!, title: 'Movie #${link.id}'),
        );
        break;
      case DeepLinkType.tvShow:
        await _ensureDestination(AppDestination.tv);
        await rootNavigator.pushNamed(
          TVDetailScreen.routeName,
          arguments: Movie(
            id: link.id!,
            title: 'Series #${link.id}',
            mediaType: 'tv',
          ),
        );
        break;
      case DeepLinkType.season:
        await _ensureDestination(AppDestination.tv);
        await rootNavigator.pushNamed(
          SeasonDetailScreen.routeName,
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
          await rootNavigator.pushNamed(
            EpisodeDetailScreen.routeName,
            arguments: EpisodeDetailArgs(tvId: link.id!, episode: episode),
          );
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.person:
        await rootNavigator.pushNamed(
          PersonDetailScreen.routeName,
          arguments: link.id!,
        );
        break;
      case DeepLinkType.company:
        await rootNavigator.pushNamed(
          CompanyDetailScreen.routeName,
          arguments: Company(id: link.id!, name: 'Company #${link.id}'),
        );
        break;
      case DeepLinkType.collection:
        await rootNavigator.pushNamed(
          CollectionDetailScreen.routeName,
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

  Future<void> _ensureDestination(AppDestination destination) async {
    if (_currentDestination == destination) return;
    setState(() {
      _currentDestination = destination;
    });
    await Future<void>.delayed(Duration.zero);
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

        setState(() {
          _currentDestination = selected;
        });
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.movie_outlined),
          selectedIcon: Icon(Icons.movie),
          label: l.t('navigation.movies'),
        ),
        NavigationDestination(
          icon: Icon(Icons.tv_outlined),
          selectedIcon: Icon(Icons.tv),
          label: l.t('navigation.series'),
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          selectedIcon: Icon(Icons.search),
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
    return Navigator(key: navigatorKey, onGenerateRoute: _onGenerateRoute);
  }
}
