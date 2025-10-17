import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/localization/app_localizations.dart';

Future<void> showShareLinkSheet(
  BuildContext context, {
  required String title,
  required Uri link,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _ShareLinkSheet(title: title, link: link),
  );
}

class _ShareLinkSheet extends StatelessWidget {
  const _ShareLinkSheet({
    required this.title,
    required this.link,
  });

  final String title;
  final Uri link;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final linkString = link.toString();
    final shareTitle = loc.t('share.title');
    final resolvedShareTitle =
        shareTitle == 'share.title' ? (loc.movie['share'] ?? 'Share') : shareTitle;
    final copyLabel = loc.t('share.copy_link');
    final resolvedCopyLabel =
        copyLabel == 'share.copy_link' ? 'Copy link' : copyLabel;
    final copiedLabel = loc.t('share.copied');
    final resolvedCopiedLabel =
        copiedLabel == 'share.copied' ? 'Link copied' : copiedLabel;
    final shareActionLabel = loc.movie['share'] ?? 'Share';

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            resolvedShareTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SelectableText(
                  linkString,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ColoredBox(
                        color: Colors.white,
                        child: QrImageView(
                          data: linkString,
                          version: QrVersions.auto,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: Text(resolvedCopyLabel),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: linkString));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(resolvedCopiedLabel)),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(shareActionLabel),
                  onPressed: () {
                    Share.share('$title — $linkString');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
