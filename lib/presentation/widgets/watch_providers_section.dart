import '../../core/utils/media_image_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/notification_item.dart';
import '../../data/models/watch_provider_model.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/notification_preferences_service.dart';
import 'media_image.dart';

/// Displays watch providers for a media item and raises in-app plus persisted
/// notifications when new services appear for the viewer's region.
///
/// Source endpoints:
/// - Movies: `GET /3/movie/{movie_id}/watch/providers`
/// - TV shows: `GET /3/tv/{tv_id}/watch/providers`
class WatchProvidersAvailabilitySection extends StatefulWidget {
  const WatchProvidersAvailabilitySection({
    super.key,
    required this.mediaType,
    required this.mediaId,
    required this.region,
    required this.providers,
  });

  final String mediaType;
  final int mediaId;
  final String region;
  final WatchProviderResults providers;

  @override
  State<WatchProvidersAvailabilitySection> createState() =>
      _WatchProvidersAvailabilitySectionState();
}

class _WatchProvidersAvailabilitySectionState
    extends State<WatchProvidersAvailabilitySection> {
  List<WatchProvider> _newProviders = const <WatchProvider>[];
  Set<int>? _lastSeenIds;
  String? _lastAnnouncementSignature;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  @override
  void didUpdateWidget(covariant WatchProvidersAvailabilitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final mediaChanged = widget.mediaId != oldWidget.mediaId ||
        widget.mediaType != oldWidget.mediaType;
    final regionChanged =
        widget.region.toUpperCase() != oldWidget.region.toUpperCase();
    final providersChanged =
        !_haveSameProviderIds(widget.providers, oldWidget.providers);

    if (mediaChanged || regionChanged) {
      _lastSeenIds = null;
      _lastAnnouncementSignature = null;
    }

    if (mediaChanged || regionChanged || providersChanged) {
      _checkAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    final region = widget.region;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_newProviders.isNotEmpty) ...[
          _NewAvailabilityBanner(region: region, newProviders: _newProviders),
          const SizedBox(height: 12),
        ],
        WatchProvidersSection(region: region, providers: widget.providers),
      ],
    );
  }

  bool _haveSameProviderIds(
    WatchProviderResults a,
    WatchProviderResults b,
  ) {
    return setEquals(_collectProviderIds(a), _collectProviderIds(b));
  }

  Set<int> _collectProviderIds(WatchProviderResults results) {
    final ids = <int>{};

    void add(List<WatchProvider> providers) {
      for (final provider in providers) {
        final id = provider.providerId ?? provider.id;
        if (id != null) {
          ids.add(id);
        }
      }
    }

    add(results.flatrate);
    add(results.buy);
    add(results.rent);
    add(results.ads);
    add(results.free);
    return ids;
  }

  List<WatchProvider> _extractProviders(
    WatchProviderResults results,
    Set<int> ids,
  ) {
    if (ids.isEmpty) {
      return const <WatchProvider>[];
    }

    final seen = <int>{};
    final combined = <WatchProvider>[
      ...results.flatrate,
      ...results.buy,
      ...results.rent,
      ...results.ads,
      ...results.free,
    ];

    return combined.where((provider) {
      final id = provider.providerId ?? provider.id;
      if (id == null || !ids.contains(id) || seen.contains(id)) {
        return false;
      }
      seen.add(id);
      return true;
    }).toList(growable: false);
  }

  Future<void> _checkAvailability() async {
    final storage = context.read<LocalStorageService>();
    final notificationPrefs = context.read<NotificationPreferences>();
    final recommendationsEnabled = notificationPrefs.recommendationsEnabled;
    final normalizedRegion = widget.region.toUpperCase();
    final currentIds = _collectProviderIds(widget.providers);

    if (_lastSeenIds != null && setEquals(_lastSeenIds!, currentIds)) {
      return;
    }
    _lastSeenIds = currentIds;

    final hadSnapshot = storage.hasWatchProviderSnapshot(
      widget.mediaType,
      widget.mediaId,
      normalizedRegion,
    );
    final previousIds = storage.getWatchProviderSnapshot(
      widget.mediaType,
      widget.mediaId,
      normalizedRegion,
    );

    await storage.saveWatchProviderSnapshot(
      widget.mediaType,
      widget.mediaId,
      normalizedRegion,
      currentIds,
    );

    if (!mounted) {
      return;
    }

    final newIds = currentIds.difference(previousIds);
    final shouldHighlight =
        recommendationsEnabled && hadSnapshot && newIds.isNotEmpty;
    final newProviders = shouldHighlight
        ? _extractProviders(widget.providers, newIds)
        : const <WatchProvider>[];

    setState(() {
      _newProviders = recommendationsEnabled ? newProviders : const [];
    });

    if (shouldHighlight && newProviders.isNotEmpty) {
      final signature = _signatureFor(newIds);
      if (_lastAnnouncementSignature != signature) {
        _lastAnnouncementSignature = signature;
        _scheduleSnackBar(newProviders, normalizedRegion);
        await _persistNotification(storage, newProviders, normalizedRegion);
      }
    } else if (!shouldHighlight) {
      _lastAnnouncementSignature = null;
    }
  }

  String _signatureFor(Set<int> ids) {
    final sorted = ids.toList(growable: false)..sort();
    return sorted.join('_');
  }

  List<String> _providerNames(List<WatchProvider> providers) {
    final names = <String>{};
    for (final provider in providers) {
      final name = provider.providerName?.trim();
      if (name != null && name.isNotEmpty) {
        names.add(name);
      }
    }
    return names.toList(growable: false);
  }

  void _scheduleSnackBar(List<WatchProvider> providers, String region) {
    final names = _providerNames(providers);
    if (names.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }
      final message = names.length == 1
          ? '${names.first} is now available to stream in $region.'
          : '${names.join(', ')} are now available to stream in $region.';
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  Future<void> _persistNotification(
    LocalStorageService storage,
    List<WatchProvider> providers,
    String region,
  ) async {
    final names = _providerNames(providers);
    if (names.isEmpty) {
      return;
    }

    final providerIds = providers
        .map((provider) => provider.providerId ?? provider.id)
        .whereType<int>()
        .toSet()
        .toList(growable: false);
    final notificationId =
        'watch_availability_${widget.mediaType}_${widget.mediaId}_$region';
    final message = names.length == 1
        ? '${names.first} is now available to stream in $region.'
        : '${names.join(', ')} are now available to stream in $region.';

    final notification = AppNotification(
      id: notificationId,
      title: 'New streaming availability',
      message: message,
      category: NotificationCategory.recommendation,
      metadata: <String, dynamic>{
        'mediaType': widget.mediaType,
        'mediaId': widget.mediaId,
        'region': region,
        'providerIds': providerIds,
        'providerNames': names,
      },
    );

    await storage.upsertNotification(notification);
  }
}

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

class _NewAvailabilityBanner extends StatelessWidget {
  const _NewAvailabilityBanner({
    required this.region,
    required this.newProviders,
  });

  final String region;
  final List<WatchProvider> newProviders;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final names = <String>{};
    for (final provider in newProviders) {
      final name = provider.providerName?.trim();
      if (name != null && name.isNotEmpty) {
        names.add(name);
      }
    }

    if (names.isEmpty) {
      return const SizedBox.shrink();
    }

    final message = names.length == 1
        ? '${names.first} is now available to stream in $region.'
        : '${names.join(', ')} are now available to stream in $region.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
