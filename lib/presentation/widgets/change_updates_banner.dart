import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/notification_item.dart';
import '../../providers/change_tracking_provider.dart';

class ChangeUpdatesBanner extends StatelessWidget {
  const ChangeUpdatesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeTrackingProvider>(
      builder: (context, tracker, _) {
        if (!tracker.hasUnread) {
          return const SizedBox.shrink();
        }

        final loc = AppLocalizations.of(context);
        final colorScheme = Theme.of(context).colorScheme;
        final unreadCount = tracker.unreadCount;
        final latest = tracker.updates.first;
        final descriptionTemplate = unreadCount == 1
            ? loc.t('change_tracking.banner_description_single')
            : loc.t('change_tracking.banner_description_multiple');
        final description = descriptionTemplate.replaceFirst(
          '{count}',
          unreadCount.toString(),
        );
        final latestSummary = _latestSummary(latest);

        return Material(
          color: colorScheme.primaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.bolt,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('change_tracking.banner_title'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          latestSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton(
                              onPressed: tracker.isFetching
                                  ? null
                                  : () => _openUpdatesSheet(context),
                              child: Text(loc.t('change_tracking.view')),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: tracker.isFetching
                                  ? null
                                  : () => tracker.markAllRead(),
                              child: Text(loc.t('change_tracking.mark_read')),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: loc.t('change_tracking.refresh'),
                              onPressed:
                                  tracker.isFetching ? null : () => tracker.refresh(),
                              icon: tracker.isFetching
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _latestSummary(AppNotification notification) {
    final summaryBuffer = StringBuffer(notification.title);
    if (notification.message.isNotEmpty) {
      summaryBuffer
        ..write(' • ')
        ..write(notification.message);
    }
    return summaryBuffer.toString();
  }

  Future<void> _openUpdatesSheet(BuildContext context) async {
    final tracker = context.read<ChangeTrackingProvider>();
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ChangeNotifierProvider<ChangeTrackingProvider>.value(
          value: tracker,
          child: const _ChangeUpdatesSheet(),
        );
      },
    );
  }
}

class _ChangeUpdatesSheet extends StatelessWidget {
  const _ChangeUpdatesSheet();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Consumer<ChangeTrackingProvider>(
        builder: (context, tracker, _) {
          final updates = tracker.updates;
          if (updates.isEmpty) {
            return Center(
              child: Text(loc.t('change_tracking.empty')),
            );
          }

          final formatter = DateFormat.yMMMd().add_Hm();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.t('change_tracking.sheet_title'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: tracker.hasUnread ? () => tracker.markAllRead() : null,
                    child: Text(loc.t('change_tracking.mark_read')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: updates.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = updates[index];
                    final typeLabel = _typeLabelFor(loc, notification);
                    final timestamp = formatter.format(
                      notification.createdAt.toLocal(),
                    );
                    return ListTile(
                      leading: Icon(
                        _iconFor(notification),
                        color: colorScheme.primary,
                      ),
                      title: Text('$typeLabel • ${notification.title}'),
                      subtitle: Text(notification.message),
                      trailing: Text(
                        timestamp,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _typeLabelFor(
    AppLocalizations loc,
    AppNotification notification,
  ) {
    final type = notification.metadata['type']?.toString() ?? 'movie';
    return switch (type) {
      'tv' => loc.t('change_tracking.updated_tv'),
      'person' => loc.t('change_tracking.updated_person'),
      _ => loc.t('change_tracking.updated_movie'),
    };
  }

  static IconData _iconFor(AppNotification notification) {
    final type = notification.metadata['type']?.toString() ?? 'movie';
    return switch (type) {
      'tv' => Icons.tv,
      'person' => Icons.person_outline,
      _ => Icons.local_movies,
    };
  }
}
