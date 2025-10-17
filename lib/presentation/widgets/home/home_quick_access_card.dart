import 'package:flutter/material.dart';

/// Model describing a quick access shortcut displayed on the home screen.
class HomeQuickAccessConfig {
  const HomeQuickAccessConfig({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Visual representation of a quick access entry.
class HomeQuickAccessCard extends StatelessWidget {
  const HomeQuickAccessCard({
    super.key,
    required this.config,
  });

  final HomeQuickAccessConfig config;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 120,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: config.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  config.icon,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  config.label,
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
