import 'package:flutter/material.dart';

import '../../../providers/home_highlights_provider.dart';

/// Helper widget that renders loading, empty and error states consistently
/// for any home section backed by a [HomeSectionState].
class HomeSectionStateView<T> extends StatelessWidget {
  const HomeSectionStateView({
    super.key,
    required this.state,
    required this.builder,
    required this.emptyMessage,
    this.loadingHeight = 200,
  });

  /// Current state for the section being rendered.
  final HomeSectionState<T> state;

  /// Builder invoked when the section contains data.
  final Widget Function(List<T> items) builder;

  /// Message shown when the section has no items to display.
  final String emptyMessage;

  /// Height used for the loading indicator placeholder.
  final double loadingHeight;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return SizedBox(
        height: loadingHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return _MessagePlaceholder(message: state.errorMessage!);
    }

    if (state.items.isEmpty) {
      return _MessagePlaceholder(message: emptyMessage);
    }

    return builder(state.items);
  }
}

/// Internal widget used to render empty/error messages.
class _MessagePlaceholder extends StatelessWidget {
  const _MessagePlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
