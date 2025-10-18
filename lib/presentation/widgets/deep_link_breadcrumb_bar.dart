import 'package:flutter/material.dart';

class DeepLinkBreadcrumb {
  const DeepLinkBreadcrumb({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;
}

class DeepLinkBreadcrumbBar extends StatelessWidget {
  const DeepLinkBreadcrumbBar({
    super.key,
    required this.crumbs,
    required this.onClear,
  });

  final List<DeepLinkBreadcrumb> crumbs;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = theme.brightness == Brightness.dark
        ? colorScheme.surfaceVariant.withOpacity(0.6)
        : colorScheme.surfaceVariant;
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Material(
      color: backgroundColor,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.link, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildCrumbWidgets(context, textStyle),
                ),
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonLabel,
              icon: const Icon(Icons.close),
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCrumbWidgets(
    BuildContext context,
    TextStyle? textStyle,
  ) {
    if (crumbs.isEmpty) {
      return const <Widget>[];
    }

    final colorScheme = Theme.of(context).colorScheme;
    final widgets = <Widget>[];

    for (var index = 0; index < crumbs.length; index++) {
      final crumb = crumbs[index];
      widgets.add(
        _DeepLinkCrumbChip(
          label: crumb.label,
          onTap: crumb.onTap,
          textStyle: textStyle,
          highlightColor: colorScheme.primary,
        ),
      );

      if (index != crumbs.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

class _DeepLinkCrumbChip extends StatelessWidget {
  const _DeepLinkCrumbChip({
    required this.label,
    required this.highlightColor,
    this.onTap,
    this.textStyle,
  });

  final String label;
  final Color highlightColor;
  final VoidCallback? onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = textStyle ?? Theme.of(context).textTheme.labelLarge;
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: onTap == null
            ? effectiveStyle
            : effectiveStyle?.copyWith(color: highlightColor),
      ),
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: child,
    );
  }
}
