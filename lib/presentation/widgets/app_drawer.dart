import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/explorer/api_explorer_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/movies/movies_screen.dart';
import '../screens/people/people_screen.dart';
import '../screens/series/series_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/videos/videos_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pop(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == routeName) {
      return;
    }
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_filter,
                    size: 64,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: currentRoute == HomeScreen.routeName,
            onTap: () => _navigateTo(context, HomeScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.movie_creation_outlined),
            title: const Text(AppStrings.movies),
            selected: currentRoute == MoviesScreen.routeName,
            onTap: () => _navigateTo(context, MoviesScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text(AppStrings.videos),
            selected: currentRoute == VideosScreen.routeName,
            onTap: () => _navigateTo(context, VideosScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.live_tv_outlined),
            title: const Text(AppStrings.series),
            selected: currentRoute == SeriesScreen.routeName,
            onTap: () => _navigateTo(context, SeriesScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: const Text(AppStrings.people),
            selected: currentRoute == PeopleScreen.routeName,
            onTap: () => _navigateTo(context, PeopleScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text(AppStrings.companies),
            selected: currentRoute == CompaniesScreen.routeName,
            onTap: () => _navigateTo(context, CompaniesScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: const Text(AppStrings.apiExplorer),
            selected: currentRoute == ApiExplorerScreen.routeName,
            onTap: () => _navigateTo(context, ApiExplorerScreen.routeName),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            selected: currentRoute == SettingsScreen.routeName,
            onTap: () => _navigateTo(context, SettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: AppStrings.appName,
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.movie_outlined, size: 48),
              );
            },
          ),
          const Spacer(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
