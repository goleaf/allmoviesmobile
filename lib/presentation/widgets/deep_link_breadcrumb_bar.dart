import 'package:flutter/material.dart';

import '../../providers/deep_link_breadcrumbs_provider.dart';

/// Visual component that renders the breadcrumb bar used after following a
/// deep link.
class DeepLinkBreadcrumbBar extends StatelessWidget {
  const DeepLinkBreadcrumbBar({
    super.key,
    required this.breadcrumbs,
    required this.onBreadcrumbTap,
    required this.onClear,
  });

  /// Ordered segments representing the current navigation context.
  final List<DeepLinkBreadcrumb> breadcrumbs;

  /// Invoked whenever the user taps an actionable breadcrumb.
  final ValueChanged<DeepLinkBreadcrumb> onBreadcrumbTap;

  /// Clears the breadcrumb state.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.surfaceVariant;
    final foreground = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: background,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int index = 0; index < breadcrumbs.length; index++)
                        _BreadcrumbChip(
                          breadcrumb: breadcrumbs[index],
                          isLast: index == breadcrumbs.length - 1,
                          onTap: onBreadcrumbTap,
                          foreground: foreground,
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close),
                color: foreground,
                onPressed: onClear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({
    required this.breadcrumb,
    required this.isLast,
    required this.onTap,
    required this.foreground,
  });

  final DeepLinkBreadcrumb breadcrumb;
  final bool isLast;
  final ValueChanged<DeepLinkBreadcrumb> onTap;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.bodyMedium?.copyWith(color: foreground);

    final chip = InkWell(
      onTap: breadcrumb.isActionable ? () => onTap(breadcrumb) : null,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          breadcrumb.label,
          style: style,
        ),
      ),
    );

    if (isLast) {
      return chip;
    }

    return Row(
      children: [
        chip,
        Icon(Icons.chevron_right, size: 18, color: foreground),
      ],
    );
  }
}
