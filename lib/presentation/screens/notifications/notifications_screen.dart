import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/notification_item.dart';
import '../../../providers/notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('notifications.title')),
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, provider, _) {
              final hasUnread = provider.unreadCount > 0;
              return TextButton(
                onPressed: hasUnread ? () => provider.markAllRead() : null,
                child: Text(loc.t('notifications.mark_all_read')),
              );
            },
          ),
          Consumer<NotificationsProvider>(
            builder: (context, provider, _) {
              final hasAny = provider.hasNotifications;
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: loc.t('notifications.clear_all'),
                onPressed: hasAny
                    ? () async {
                        final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: Text(loc.t('notifications.clear_all')),
                                  content:
                                      Text(loc.t('notifications.clear_all_confirm')),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(false),
                                      child: Text(loc.common['cancel'] ?? 'Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: Text(loc.common['confirm'] ?? 'Confirm'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                        if (confirmed) {
                          await provider.clearAll();
                        }
                      }
                    : null,
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, _) {
          final notifications = provider.notifications;
          if (notifications.isEmpty) {
            return _EmptyState(message: loc.t('notifications.empty'));
          }

          final groups = _groupNotifications(notifications);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _NotificationGroupSection(group: group);
            },
          );
        },
      ),
    );
  }
}

class _NotificationGroupSection extends StatelessWidget {
  const _NotificationGroupSection({required this.group});

  final _NotificationGroup group;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final label = _categoryLabel(loc, group.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final notification in group.notifications)
            _NotificationTile(notification: notification),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isUnread = !notification.isRead;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timestamp = _formatTimestamp(context, notification.createdAt);

    Future<void> markRead() {
      return context
          .read<NotificationsProvider>()
          .markNotificationsRead([notification.id]);
    }

    Future<void> openAction() async {
      final route = notification.actionRoute;
      if (route == null || route.isEmpty) {
        await markRead();
        return;
      }
      final navigator = Navigator.of(context);
      await markRead();
      if (!navigator.mounted) {
        return;
      }
      await navigator.pushNamed(
        route,
        arguments: notification.metadata.isEmpty ? null : notification.metadata,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isUnread
          ? colorScheme.secondaryContainer.withOpacity(0.35)
          : null,
      child: ListTile(
        leading: Icon(
          isUnread ? Icons.mark_chat_unread : Icons.drafts_outlined,
          color: isUnread ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.message),
              const SizedBox(height: 8),
              Text(
                timestamp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: _NotificationActions(
          isUnread: isUnread,
          onMarkRead: markRead,
          onOpen: notification.actionRoute == null ? null : openAction,
        ),
        onTap:
            notification.actionRoute != null ? openAction : (isUnread ? markRead : null),
      ),
    );
  }
}

class _NotificationActions extends StatelessWidget {
  const _NotificationActions({
    required this.isUnread,
    required this.onMarkRead,
    this.onOpen,
  });

  final bool isUnread;
  final Future<void> Function() onMarkRead;
  final Future<void> Function()? onOpen;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (onOpen != null)
          TextButton(
            onPressed: () => onOpen!(),
            child: Text(loc.t('notifications.view')),
          ),
        TextButton(
          onPressed: isUnread ? () => onMarkRead() : null,
          child: Text(loc.t('notifications.mark_read')),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationGroup {
  _NotificationGroup({
    required this.category,
    required this.notifications,
  });

  final NotificationCategory category;
  final List<AppNotification> notifications;
}

List<_NotificationGroup> _groupNotifications(
  List<AppNotification> notifications,
) {
  final groups = <_NotificationGroup>[];
  for (final category in NotificationCategory.values) {
    final items = notifications
        .where((notification) => notification.category == category)
        .toList(growable: false);
    if (items.isNotEmpty) {
      groups.add(_NotificationGroup(category: category, notifications: items));
    }
  }
  return groups;
}

String _categoryLabel(
  AppLocalizations loc,
  NotificationCategory category,
) {
  final key = 'notifications.category.${category.name}';
  final label = loc.t(key);
  if (label != key) {
    return label;
  }
  final name = category.name.replaceAll('_', ' ');
  return name[0].toUpperCase() + name.substring(1);
}

String _formatTimestamp(BuildContext context, DateTime timestamp) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_Hm().format(timestamp.toLocal());
}
