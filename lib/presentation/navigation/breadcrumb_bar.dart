import 'package:flutter/material.dart';

/// Describes a single crumb in the [BreadcrumbBar].
@immutable
class BreadcrumbItem {
  const BreadcrumbItem({
    required this.label,
    this.onTap,
  });

  /// The text displayed for the crumb.
  final String label;

  /// Callback invoked when the crumb is activated.
  final VoidCallback? onTap;

  bool get isActionable => onTap != null;
}

/// Displays a horizontal list of navigation breadcrumbs.
class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({
    super.key,
    required this.items,
  });

  final List<BreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Material(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < items.length; index++) ...[
                _BreadcrumbChip(item: items[index]),
                if (index < items.length - 1)
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: color,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({required this.item});

  final BreadcrumbItem item;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: item.isActionable ? FontWeight.w600 : null);

    if (!item.isActionable) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          item.label,
          style: textStyle,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: item.onTap,
        child: Text(
          item.label,
          style: textStyle,
        ),
      ),
    );
  }
}
