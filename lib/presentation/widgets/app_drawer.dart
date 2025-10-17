import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/localization/app_localizations.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/config/config_info_screen.dart';
import '../screens/explorer/api_explorer_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/movies/movies_screen.dart';
import '../screens/people/people_screen.dart';
import '../screens/series/series_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/keywords/keyword_browser_screen.dart';

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

    final accessibility = AppLocalizations.of(context).accessibility;
    final navigationLabel =
        accessibility['navigation_drawer'] ?? 'Main navigation menu';

    return Drawer(
      width: screenWidth,
      child: Semantics(
        container: true,
        label: navigationLabel,
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
                    AppLocalizations.of(context).t('app.name'),
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
            title: Text(AppLocalizations.of(context).t('navigation.home')),
            selected: currentRoute == HomeScreen.routeName,
            onTap: () => _navigateTo(context, HomeScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.movie_creation_outlined),
            title: Text(AppLocalizations.of(context).t('navigation.movies')),
            selected: currentRoute == MoviesScreen.routeName,
            onTap: () => _navigateTo(context, MoviesScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.live_tv_outlined),
            title: Text(AppLocalizations.of(context).t('navigation.series')),
            selected: currentRoute == SeriesScreen.routeName,
            onTap: () => _navigateTo(context, SeriesScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: Text(AppLocalizations.of(context).t('navigation.people')),
            selected: currentRoute == PeopleScreen.routeName,
            onTap: () => _navigateTo(context, PeopleScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: Text(AppLocalizations.of(context).t('navigation.companies')),
            selected: currentRoute == CompaniesScreen.routeName,
            onTap: () => _navigateTo(context, CompaniesScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.sell_outlined),
            title: Text(
              AppLocalizations.of(context).t('search.popular_searches'),
            ),
            selected: currentRoute == KeywordBrowserScreen.routeName,
            onTap: () => _navigateTo(context, KeywordBrowserScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: Text(AppLocalizations.of(context).t('discover.title')),
            selected: currentRoute == ApiExplorerScreen.routeName,
            onTap: () => _navigateTo(context, ApiExplorerScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.settings_input_component_outlined),
            title: Text(
              AppLocalizations.of(context).t('navigation.configuration'),
            ),
            selected: currentRoute == ConfigInfoScreen.routeName,
            onTap: () => _navigateTo(context, ConfigInfoScreen.routeName),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(AppLocalizations.of(context).t('navigation.settings')),
            selected: currentRoute == SettingsScreen.routeName,
            onTap: () => _navigateTo(context, SettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context).t('settings.about')),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: AppLocalizations.of(context).t('app.name'),
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.movie_outlined, size: 48),
              );
            },
          ),
          const Spacer(),
          const SizedBox(height: 16),
        ],
        ),
      ),
    );
  }
}
