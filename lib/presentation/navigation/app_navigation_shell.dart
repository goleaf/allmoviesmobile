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
import '../navigation/app_destination.dart';
import '../navigation/episode_detail_args.dart';
import '../navigation/season_detail_args.dart';
import '../screens/collections/collection_detail_screen.dart';
import '../screens/company_detail/company_detail_screen.dart';
import '../screens/episode_detail/episode_detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/movie_detail/movie_detail_screen.dart';
import '../screens/movies/movies_screen.dart';
import '../screens/person_detail/person_detail_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/season_detail/season_detail_screen.dart';
import '../screens/series/series_filters_screen.dart';
import '../screens/series/series_screen.dart';
import '../screens/tv_detail/tv_detail_screen.dart';
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

  late AppDestination _currentDestination;
  DeepLinkHandler? _deepLinkHandler;
  bool _isHandlingDeepLink = false;
  List<_BreadcrumbEntry> _breadcrumbTrail = const <_BreadcrumbEntry>[];

  @override
  void initState() {
    super.initState();
    // Restore the last selected destination from persisted state so the
    // navigation shell mirrors the user's previous session.
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
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            _QuickFiltersBar(
              current: _currentDestination,
              onSelected: (destination) =>
                  _switchDestination(destination, popToRoot: true),
            ),
            if (_breadcrumbTrail.isNotEmpty)
              _BreadcrumbBar(
                entries: _breadcrumbTrail,
                onClear: _clearBreadcrumbs,
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
      _switchDestination(AppDestination.home, popToRoot: true);
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
        rootNavigator.pushNamed(
          MovieDetailScreen.routeName,
          arguments: Movie(id: link.id!, title: 'Movie #${link.id}'),
        );
        _setBreadcrumbs([
          _BreadcrumbEntry(
            label: loc.t('navigation.movies'),
            onTap: () =>
                _switchDestination(AppDestination.movies, popToRoot: true),
          ),
          _BreadcrumbEntry(label: 'Movie #${link.id}'),
        ]);
        break;
      case DeepLinkType.tvShow:
        await _ensureDestination(AppDestination.tv);
        rootNavigator.pushNamed(
          TVDetailScreen.routeName,
          arguments: Movie(
            id: link.id!,
            title: 'Series #${link.id}',
            mediaType: 'tv',
          ),
        );
        _setBreadcrumbs([
          _BreadcrumbEntry(
            label: loc.t('navigation.series'),
            onTap: () =>
                _switchDestination(AppDestination.tv, popToRoot: true),
          ),
          _BreadcrumbEntry(label: 'Series #${link.id}'),
        ]);
        break;
      case DeepLinkType.season:
        await _ensureDestination(AppDestination.tv);
        final tvArgs = Movie(
          id: link.id!,
          title: 'Series #${link.id}',
          mediaType: 'tv',
        );
        rootNavigator.pushNamed(
          TVDetailScreen.routeName,
          arguments: tvArgs,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          rootNavigator.pushNamed(
            SeasonDetailScreen.routeName,
            arguments: SeasonDetailArgs(
              tvId: link.id!,
              seasonNumber: link.seasonNumber!,
            ),
          );
        });
        _setBreadcrumbs([
          _BreadcrumbEntry(
            label: loc.t('navigation.series'),
            onTap: () =>
                _switchDestination(AppDestination.tv, popToRoot: true),
          ),
          _BreadcrumbEntry(
            label: 'Series #${link.id}',
            onTap: () {
              rootNavigator.pushNamed(
                TVDetailScreen.routeName,
                arguments: tvArgs,
              );
            },
          ),
          _BreadcrumbEntry(label: 'Season ${link.seasonNumber}'),
        ]);
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
          final tvArgs = Movie(
            id: link.id!,
            title: 'Series #${link.id}',
            mediaType: 'tv',
          );
          rootNavigator
            ..pushNamed(
              TVDetailScreen.routeName,
              arguments: tvArgs,
            )
            ..pushNamed(
              SeasonDetailScreen.routeName,
              arguments: SeasonDetailArgs(
                tvId: link.id!,
                seasonNumber: link.seasonNumber!,
              ),
            )
            ..pushNamed(
              EpisodeDetailScreen.routeName,
              arguments: EpisodeDetailArgs(tvId: link.id!, episode: episode),
            );
          _setBreadcrumbs([
            _BreadcrumbEntry(
              label: loc.t('navigation.series'),
              onTap: () =>
                  _switchDestination(AppDestination.tv, popToRoot: true),
            ),
            _BreadcrumbEntry(
              label: 'Series #${link.id}',
              onTap: () {
                rootNavigator.pushNamed(
                  TVDetailScreen.routeName,
                  arguments: tvArgs,
                );
              },
            ),
            _BreadcrumbEntry(
              label: 'Season ${link.seasonNumber}',
              onTap: () {
                rootNavigator.pushNamed(
                  SeasonDetailScreen.routeName,
                  arguments: SeasonDetailArgs(
                    tvId: link.id!,
                    seasonNumber: link.seasonNumber!,
                  ),
                );
              },
            ),
            _BreadcrumbEntry(label: 'Episode ${link.episodeNumber}'),
          ]);
        } catch (error) {
          await showError(loc.t('errors.generic'));
        }
        break;
      case DeepLinkType.person:
        rootNavigator.pushNamed(
          PersonDetailScreen.routeName,
          arguments: link.id!,
        );
        _setBreadcrumbs([
          _BreadcrumbEntry(
            label: loc.t('navigation.search'),
            onTap: () =>
                _switchDestination(AppDestination.search, popToRoot: true),
          ),
          _BreadcrumbEntry(label: 'Person #${link.id}'),
        ]);
        break;
      case DeepLinkType.company:
        rootNavigator.pushNamed(
          CompanyDetailScreen.routeName,
          arguments: Company(id: link.id!, name: 'Company #${link.id}'),
        );
        _setBreadcrumbs([
          _BreadcrumbEntry(
            label: loc.t('navigation.search'),
            onTap: () =>
                _switchDestination(AppDestination.search, popToRoot: true),
          ),
          _BreadcrumbEntry(label: 'Company #${link.id}'),
        ]);
        break;
      case DeepLinkType.collection:
        rootNavigator.pushNamed(
          CollectionDetailScreen.routeName,
          arguments: link.id!,
        );
        _setBreadcrumbs([
          _BreadcrumbEntry(
            label: loc.t('navigation.movies'),
            onTap: () =>
                _switchDestination(AppDestination.movies, popToRoot: true),
          ),
          _BreadcrumbEntry(label: 'Collection #${link.id}'),
        ]);
        break;
      case DeepLinkType.search:
        await _ensureDestination(AppDestination.search);
        final navigator = _navigatorKeys[AppDestination.search]?.currentState;
        navigator?.popUntil((route) => route.isFirst);
        navigator?.pushNamed(
          SearchScreen.routeName,
          arguments: link.searchQuery,
        );
        _setBreadcrumbs([
          _BreadcrumbEntry(
            label: loc.t('navigation.search'),
            onTap: () =>
                _switchDestination(AppDestination.search, popToRoot: true),
          ),
          _BreadcrumbEntry(label: link.searchQuery ?? ''),
        ]);
        break;
    }
  }

  Future<void> _ensureDestination(AppDestination destination) async {
    if (_currentDestination == destination) {
      return;
    }
    _switchDestination(destination);
    await Future<void>.delayed(Duration.zero);
  }

  /// Updates the active [AppDestination] while ensuring the associated navigator
  /// stack is optionally reset to its root route.
  ///
  /// This method keeps the persisted [AppStateProvider] destination in sync so
  /// that returning users land on the same tab they last explored.
  void _switchDestination(AppDestination destination, {bool popToRoot = false}) {
    if (_currentDestination == destination) {
      if (popToRoot) {
        _navigatorKeys[destination]
            ?.currentState
            ?.popUntil((route) => route.isFirst);
        _clearBreadcrumbs();
      }
      return;
    }

    setState(() {
      _currentDestination = destination;
    });
    context.read<AppStateProvider>().updateDestination(destination);
    if (popToRoot) {
      _navigatorKeys[destination]
          ?.currentState
          ?.popUntil((route) => route.isFirst);
    }
    _clearBreadcrumbs();
  }

  /// Stores a breadcrumb trail describing the navigation steps that were
  /// reconstructed while opening a deep link.
  ///
  /// Each breadcrumb corresponds to a human-readable label derived from the
  /// deep link metadata so the user can easily jump to higher level screens.
  void _setBreadcrumbs(List<_BreadcrumbEntry> entries) {
    setState(() {
      _breadcrumbTrail = entries;
    });
  }

  /// Clears the breadcrumb bar once the user navigates manually, preventing
  /// stale deep link context from appearing in the shell UI.
  void _clearBreadcrumbs() {
    if (_breadcrumbTrail.isEmpty) {
      return;
    }
    setState(() {
      _breadcrumbTrail = const <_BreadcrumbEntry>[];
    });
  }

  Widget _buildBottomNavigationBar() {
    final l = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: _currentDestination.index,
      onDestinationSelected: (index) {
        final selected = AppDestination.values[index];

        if (_currentDestination == selected) {
          _switchDestination(selected, popToRoot: true);
          return;
        }

        _switchDestination(selected);
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
        final args = settings.arguments;
        if (args is SeriesFiltersScreenArgs) {
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

/// Describes a single breadcrumb in the deep-link navigation trail.
class _BreadcrumbEntry {
  const _BreadcrumbEntry({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;
}

/// Displays the ordered breadcrumb trail for a previously opened deep link.
class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar({
    required this.entries,
    required this.onClear,
  });

  final List<_BreadcrumbEntry> entries;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < entries.length; i++) ...[
                        _BreadcrumbChip(entry: entries[i]),
                        if (i < entries.length - 1)
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: colorScheme.outline,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)
                        .navigation['clear_breadcrumbs'] ??
                    'Clear breadcrumbs',
                icon: const Icon(Icons.close),
                onPressed: onClear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual representation of a single breadcrumb that optionally navigates back
/// to a parent route when tapped.
class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({required this.entry});

  final _BreadcrumbEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActionable = entry.onTap != null;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(entry.label),
        onPressed: entry.onTap,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isActionable
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
          fontWeight: isActionable ? FontWeight.w600 : FontWeight.w500,
        ),
        backgroundColor: isActionable
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : colorScheme.surfaceContainerHighest,
        side: BorderSide(
          color: isActionable
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

/// Horizontal list of quick navigation filters that mirrors the bottom
/// navigation destinations inside the primary app bar.
class _QuickFiltersBar extends StatelessWidget {
  const _QuickFiltersBar({
    required this.current,
    required this.onSelected,
  });

  final AppDestination current;
  final ValueChanged<AppDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final filters = <({AppDestination destination, String label, IconData icon})>[
      (
        destination: AppDestination.home,
        label: loc.t('navigation.home'),
        icon: Icons.home_outlined,
      ),
      (
        destination: AppDestination.movies,
        label: loc.t('navigation.movies'),
        icon: Icons.movie_outlined,
      ),
      (
        destination: AppDestination.tv,
        label: loc.t('navigation.series'),
        icon: Icons.tv_outlined,
      ),
      (
        destination: AppDestination.search,
        label: loc.t('navigation.search'),
        icon: Icons.search,
      ),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = current == filter.destination;
              return FilterChip(
                selected: isSelected,
                onSelected: (_) => onSelected(filter.destination),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.icon,
                      size: 16,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(filter.label),
                  ],
                ),
                showCheckmark: false,
                selectedColor:
                    Theme.of(context).colorScheme.primaryContainer,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            },
          ),
        ),
      ),
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
