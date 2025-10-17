import 'package:flutter/material.dart';

/// Shared wrapper used by every home screen section to render the title,
/// optional subtitle, and an action button above its content.
class HomeSection extends StatelessWidget {
  const HomeSection({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    required this.child,
  });

  /// Primary title displayed on top of the section.
  final String title;

  /// Optional subtitle placed under the title for additional context.
  final String? subtitle;

  /// Callback triggered when the optional "See all" button is pressed.
  final VoidCallback? onSeeAll;

  /// Body of the section, usually a carousel or grid of cards.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See all'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
