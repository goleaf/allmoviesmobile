import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const [
          _SettingsHeader(title: 'Appearance'),
          _ComingSoonTile(
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            message: 'Theme customization is planned for a future update.',
          ),
          _SettingsHeader(title: 'Localization'),
          _ComingSoonTile(
            icon: Icons.language,
            title: 'Language',
            message: 'Language selection is not available yet.',
          ),
          _SettingsHeader(title: 'About'),
          _StaticInfoTile(
            icon: Icons.info_outline,
            title: 'App Version',
            value: '1.0.0',
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;

  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ComingSoonTile({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(message),
      trailing: const Chip(
        label: Text('Planned'),
      ),
    );
  }
}

class _StaticInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StaticInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
