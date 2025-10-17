import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showDeepLinkShareSheet(
  BuildContext context, {
  required String title,
  required Uri deepLink,
  String? fallbackUrl,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final linkText = deepLink.toString();

  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final textTheme = theme.textTheme;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share "$title"',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: linkText,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                linkText,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      Share.share('$title\n$linkText');
                      Navigator.of(sheetContext).pop();
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share link'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: linkText));
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')), 
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy link'),
                  ),
                ],
              ),
              if (fallbackUrl != null && fallbackUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'TMDB reference',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  fallbackUrl,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
