import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';

class SectionNavigationActions extends StatelessWidget {
  final String? currentRoute;

  const SectionNavigationActions({super.key, this.currentRoute});

  bool _isCurrentRoute(String? normalizedRoute, String route) {
    return normalizedRoute == route;
  }

  String _normalizeRoute(String? routeName) {
    if (routeName == null || routeName == Navigator.defaultRouteName) {
      return AppRoutes.home;
    }
    return routeName;
  }

  void _navigateTo(BuildContext context, String targetRoute, String currentRoute) {
    if (currentRoute == targetRoute) {
      return;
    }
    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedRoute = _normalizeRoute(currentRoute);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: _isCurrentRoute(normalizedRoute, AppRoutes.home)
              ? null
              : () => _navigateTo(context, AppRoutes.home, normalizedRoute),
        ),
        IconButton(
          tooltip: 'Movies',
          icon: const Icon(Icons.movie_outlined),
          onPressed: _isCurrentRoute(normalizedRoute, AppRoutes.movies)
              ? null
              : () => _navigateTo(context, AppRoutes.movies, normalizedRoute),
        ),
        IconButton(
          tooltip: 'Series',
          icon: const Icon(Icons.tv_outlined),
          onPressed: _isCurrentRoute(normalizedRoute, AppRoutes.series)
              ? null
              : () => _navigateTo(context, AppRoutes.series, normalizedRoute),
        ),
        IconButton(
          tooltip: 'People',
          icon: const Icon(Icons.person_search_outlined),
          onPressed: _isCurrentRoute(normalizedRoute, AppRoutes.people)
              ? null
              : () => _navigateTo(context, AppRoutes.people, normalizedRoute),
        ),
        IconButton(
          tooltip: 'Companies',
          icon: const Icon(Icons.apartment_outlined),
          onPressed: _isCurrentRoute(normalizedRoute, AppRoutes.companies)
              ? null
              : () => _navigateTo(context, AppRoutes.companies, normalizedRoute),
        ),
        IconButton(
          tooltip: 'Collections',
          icon: const Icon(Icons.collections_bookmark_outlined),
          onPressed: _isCurrentRoute(normalizedRoute, AppRoutes.collections)
              ? null
              : () => _navigateTo(context, AppRoutes.collections, normalizedRoute),
        ),
      ],
    );
  }
}
