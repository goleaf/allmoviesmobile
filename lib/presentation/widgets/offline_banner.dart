import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../providers/offline_provider.dart';

/// Displays a prominent banner when the app is offline or still processing
/// queued sync operations.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineProvider>(
      builder: (context, provider, _) {
        final l = AppLocalizations.of(context);
        final showOffline = provider.isOffline;
        final pendingSync = provider.pendingTasks.isNotEmpty;

        if (!showOffline && !pendingSync) {
          return const SizedBox.shrink();
        }

        final colorScheme = Theme.of(context).colorScheme;
        final background = showOffline
            ? colorScheme.errorContainer
            : colorScheme.tertiaryContainer;
        final foreground = showOffline
            ? colorScheme.onErrorContainer
            : colorScheme.onTertiaryContainer;
        final message = showOffline
            ? l.t('offline.banner_offline')
            : l.t('offline.banner_syncing');

        return Material(
          color: background,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    showOffline ? Icons.wifi_off : Icons.sync,
                    color: foreground,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: foreground),
                    ),
                  ),
                  if (!showOffline)
                    TextButton(
                      onPressed: () => provider.service.syncPendingActions(),
                      child: Text(
                        l.t('offline.sync_now'),
                        style: TextStyle(color: foreground),
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
}
