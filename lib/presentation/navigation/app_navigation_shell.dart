import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';
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

class _NavigationIntent extends Intent {
  const _NavigationIntent(this.direction);

  final _NavigationDirection direction;
}

enum _NavigationDirection { previous, next }

class _AppNavigationShellState extends State<AppNavigationShell> {
  final Map<AppDestination, GlobalKey<NavigatorState>> _navigatorKeys = {
    for (final destination in AppDestination.values)
      destination: GlobalKey<NavigatorState>(),
  };

  AppDestination _currentDestination = AppDestination.movies;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentLabel = _destinationLabel(_currentDestination, l);
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.arrowRight):
              const _NavigationIntent(_NavigationDirection.next),
          const SingleActivator(LogicalKeyboardKey.arrowLeft):
              const _NavigationIntent(_NavigationDirection.previous),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _NavigationIntent: CallbackAction<_NavigationIntent>(
              onInvoke: (intent) {
                _handleKeyboardNavigation(intent.direction);
                return null;
              },
            ),
          },
          child: Scaffold(
            body: Semantics(
              container: true,
              label: '$currentLabel ${l.t('navigation.sectionSuffix')}',
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
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
            ),
            bottomNavigationBar: Semantics(
              container: true,
              label: l.t('navigation.mainNavigation'),
              child: _buildBottomNavigationBar(),
            ),
          ),
        ),
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
          tooltip: l.t('navigation.movies'),
        ),
        NavigationDestination(
          icon: Icon(Icons.tv_outlined),
          selectedIcon: Icon(Icons.tv),
          label: l.t('navigation.series'),
          tooltip: l.t('navigation.series'),
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          selectedIcon: Icon(Icons.search),
          label: l.t('navigation.search'),
          tooltip: l.t('navigation.search'),
        ),
      ],
    );
  }

  void _handleKeyboardNavigation(_NavigationDirection direction) {
    final destinations = AppDestination.values;
    final currentIndex = _currentDestination.index;
    final nextIndex = direction == _NavigationDirection.next
        ? (currentIndex + 1) % destinations.length
        : (currentIndex - 1 + destinations.length) % destinations.length;

    setState(() {
      _currentDestination = destinations[nextIndex];
    });
  }

  String _destinationLabel(AppDestination destination, AppLocalizations l) {
    switch (destination) {
      case AppDestination.movies:
        return l.t('navigation.movies');
      case AppDestination.tv:
        return l.t('navigation.series');
      case AppDestination.search:
        return l.t('navigation.search');
    }
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
