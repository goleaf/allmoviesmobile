import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../data/models/watch_provider_model.dart';
import 'media_image.dart';
import '../../core/utils/media_image_helper.dart';

class WatchProvidersSection extends StatelessWidget {
  const WatchProvidersSection({
    super.key,
    required this.region,
    required this.providers,
  });

  final String region;
  final WatchProviderResults providers;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty(providers)) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Where to Watch ($region)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if ((providers.link ?? '').isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _openLink(context, providers.link!),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildRows(context, providers),
          ],
        ),
      ),
    );
  }

  bool _isEmpty(WatchProviderResults p) {
    return p.flatrate.isEmpty &&
        p.rent.isEmpty &&
        p.buy.isEmpty &&
        p.ads.isEmpty &&
        p.free.isEmpty;
  }

  List<Widget> _buildRows(BuildContext context, WatchProviderResults p) {
    final rows = <Widget>[];

    void addRow(String title, List<WatchProvider> list) {
      if (list.isEmpty) return;
      final copy = List<WatchProvider>.from(list);
      copy.sort((a, b) {
        final ap = a.displayPriority ?? 9999;
        final bp = b.displayPriority ?? 9999;
        if (ap != bp) return ap.compareTo(bp);
        final an = a.providerName ?? '';
        final bn = b.providerName ?? '';
        return an.compareTo(bn);
      });
      rows.add(
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      );
      rows.add(const SizedBox(height: 8));
      rows.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: copy
              .map(
                (provider) => _ProviderLogo(logoPath: provider.logoPath ?? ''),
              )
              .toList(),
        ),
      );
      rows.add(const SizedBox(height: 12));
    }

    addRow('Stream:', p.flatrate);
    addRow('Rent:', p.rent);
    addRow('Buy:', p.buy);
    addRow('With Ads:', p.ads);
    addRow('Free:', p.free);

    if (rows.isNotEmpty) {
      rows.removeLast();
    }
    return rows;
  }

  void _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({required this.logoPath});

  final String logoPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: MediaImage(
        path: logoPath,
        type: MediaImageType.logo,
        size: MediaImageSize.w92,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }
}
