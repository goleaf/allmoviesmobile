import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  String _normalizeRoute(String? routeName) {
    if (routeName == null || routeName == Navigator.defaultRouteName) {
      return AppRoutes.home;
    }
    return routeName;
  }

  void _navigateTo(BuildContext context, String targetRoute, String currentRoute) {
    Navigator.pop(context);
    if (currentRoute == targetRoute) {
      return;
    }
    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final currentRoute = _normalizeRoute(ModalRoute.of(context)?.settings.name);

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
            selected: currentRoute == AppRoutes.home,
            onTap: () => _navigateTo(context, AppRoutes.home, currentRoute),
          ),
          ListTile(
            leading: const Icon(Icons.movie_outlined),
            title: const Text('Movies'),
            selected: currentRoute == AppRoutes.movies,
            onTap: () => _navigateTo(context, AppRoutes.movies, currentRoute),
          ),
          ListTile(
            leading: const Icon(Icons.tv_outlined),
            title: const Text('Series'),
            selected: currentRoute == AppRoutes.series,
            onTap: () => _navigateTo(context, AppRoutes.series, currentRoute),
          ),
          ListTile(
            leading: const Icon(Icons.person_search_outlined),
            title: const Text('People'),
            selected: currentRoute == AppRoutes.people,
            onTap: () => _navigateTo(context, AppRoutes.people, currentRoute),
          ),
          ListTile(
            leading: const Icon(Icons.apartment_outlined),
            title: const Text('Companies'),
            selected: currentRoute == AppRoutes.companies,
            onTap: () => _navigateTo(context, AppRoutes.companies, currentRoute),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            },
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
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
