import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../screens/home/home_screen.dart';
import '../screens/movies/movies_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/series/series_screen.dart';
import '../screens/movies/movies_filters_screen.dart';
import '../screens/series/series_filters_screen.dart';

enum AppDestination { home, movies, tv, search }

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

  @override
  Widget build(BuildContext context) {
    // Multi-device friendly layout: we adapt the navigation chrome to the
    // available width so phones keep the bottom navigation bar while larger
    // displays (tablets / desktop / web) switch to a rail to maximise vertical
    // space usage. The body is shared via an IndexedStack to preserve the
    // state of each destination.
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final useRail = width >= 600;
          final extendedRail = width >= 1024;
          final navigationBody = _buildDestinationStack();

          if (useRail) {
            return Scaffold(
              body: Row(
                children: [
                  _buildNavigationRail(extended: extendedRail),
                  Expanded(child: navigationBody),
                ],
              ),
            );
          }

          return Scaffold(
            body: navigationBody,
            bottomNavigationBar: _buildBottomNavigationBar(),
          );
        },
      ),
    );
  }

  Widget _buildDestinationStack() {
    return IndexedStack(
      index: _currentDestination.index,
      children: [
        for (final destination in AppDestination.values)
          _DestinationNavigator(
            navigatorKey: _navigatorKeys[destination]!,
            destination: destination,
          ),
      ],
    );
  }

  List<_NavigationItem> _destinationItems(AppLocalizations l) {
    // Centralised definition of navigation entries so the bar and the rail stay
    // in sync across all device classes.
    final items = <_NavigationItem>[
      const _NavigationItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        localizationKey: 'navigation.home',
      ),
      const _NavigationItem(
        icon: Icons.movie_outlined,
        selectedIcon: Icons.movie,
        localizationKey: 'navigation.movies',
      ),
      const _NavigationItem(
        icon: Icons.tv_outlined,
        selectedIcon: Icons.tv,
        localizationKey: 'navigation.series',
      ),
      const _NavigationItem(
        icon: Icons.search,
        selectedIcon: Icons.search,
        localizationKey: 'navigation.search',
      ),
    ];

    // Resolve the localization keys once per build; this keeps the rest of the
    // navigation code focused on rendering widgets.
    return items
        .map((item) => item.withLabel(l.t(item.localizationKey)))
        .toList();
  }

  Future<bool> _handleWillPop() async {
    final currentNavigator = _navigatorKeys[_currentDestination]!.currentState!;

    if (await currentNavigator.maybePop()) {
      return false;
    }

    if (_currentDestination != AppDestination.home) {
      setState(() {
        _currentDestination = AppDestination.home;
      });
      return false;
    }

    return true;
  }

  Widget _buildBottomNavigationBar() {
    final l = AppLocalizations.of(context);
    final items = _destinationItems(l);
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
        for (final item in items)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.resolvedLabel,
          ),
      ],
    );
  }

  Widget _buildNavigationRail({required bool extended}) {
    final l = AppLocalizations.of(context);
    final items = _destinationItems(l);
    return NavigationRail(
      extended: extended,
      selectedIndex: _currentDestination.index,
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.selected,
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
        for (final item in items)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.resolvedLabel),
          ),
      ],
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.localizationKey,
    this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String localizationKey;
  final String? label;

  _NavigationItem withLabel(String label) {
    return _NavigationItem(
      icon: icon,
      selectedIcon: selectedIcon,
      localizationKey: localizationKey,
      label: label,
    );
  }

  String get resolvedLabel => label ?? localizationKey;
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
    return Navigator(key: navigatorKey, onGenerateRoute: _onGenerateRoute);
  }
}
