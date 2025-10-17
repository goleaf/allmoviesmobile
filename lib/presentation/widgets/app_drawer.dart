import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/movies/movies_screen.dart';
import '../screens/people/people_screen.dart';
import '../screens/series/series_screen.dart';

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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? 'Guest'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.fullName.substring(0, 1).toUpperCase() ?? 'G',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          const Divider(),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(AppStrings.logout),
            onTap: () async {
              await authProvider.logout();
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeScreen.routeName,
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
