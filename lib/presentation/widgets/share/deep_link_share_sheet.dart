import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/navigation/deep_link_parser.dart';

/// Presents a bottom sheet with sharing utilities for a generated deep link.
Future<void> showDeepLinkShareSheet(
  BuildContext context, {
  required String title,
  required Uri httpLink,
  Uri? customSchemeLink,
}) {
  final String canonical = httpLink.toString();
  final String? custom = customSchemeLink?.toString();

  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share "$title"',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _LinkPreviewRow(label: 'HTTPS link', value: canonical),
            if (custom != null) ...[
              const SizedBox(height: 12),
              _LinkPreviewRow(
                label: '${DeepLinkConfig.alternateScheme} scheme',
                value: custom,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share link'),
                    onPressed: () async {
                      await Share.shareUri(httpLink);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy link'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: canonical));
                      if (sheetContext.mounted) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(content: Text('Link copied to clipboard.')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QrImageView(
                    data: canonical,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scan to open the deep link on another device.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}

class _LinkPreviewRow extends StatelessWidget {
  const _LinkPreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'RobotoMono',
            ),
          ),
        ),
      ],
    );
  }
}
