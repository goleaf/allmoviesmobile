import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/watch_region_provider.dart';
import '../../../data/models/watch_provider_model.dart';

/// A reusable widget for selecting watch providers.
///
/// * `mediaType` should be either `'movie'` or `'tv'`.
/// * `selectedProviderIds` is a set of currently selected provider IDs.
/// * `onProvidersChanged` is called with the updated set when selection changes.
class WatchProviderSelector extends StatefulWidget {
  const WatchProviderSelector({
    super.key,
    required this.mediaType,
    required this.selectedProviderIds,
    required this.onProvidersChanged,
  });

  final String mediaType;
  final Set<int> selectedProviderIds;
  final ValueChanged<Set<int>> onProvidersChanged;

  @override
  State<WatchProviderSelector> createState() => _WatchProviderSelectorState();
}

class _WatchProviderSelectorState extends State<WatchProviderSelector> {
  List<WatchProvider> _availableProviders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProviders());
  }

  Future<void> _loadProviders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final region = context.read<WatchRegionProvider?>()?.region ?? 'US';
      final repo = context.read<TmdbRepository>();
      final providers = await repo.fetchAvailableWatchProviders(
        mediaType: widget.mediaType,
        region: region,
      );
      providers.sort((a, b) => (a.displayPriority ?? 999).compareTo(b.displayPriority ?? 999));
      if (mounted) {
        setState(() {
          _availableProviders = providers;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleSelection(int providerId) {
    final newSelection = Set<int>.from(widget.selectedProviderIds);
    if (newSelection.contains(providerId)) {
      newSelection.remove(providerId);
    } else {
      newSelection.add(providerId);
    }
    widget.onProvidersChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_availableProviders.isEmpty) {
      return const Text('No providers found for this region.');
    }
    return SizedBox(
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _availableProviders.length,
        itemBuilder: (context, index) {
          final provider = _availableProviders[index];
          final isSelected = widget.selectedProviderIds.contains(provider.providerId);
          return InkWell(
            onTap: () => _toggleSelection(provider.providerId!),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (provider.logoPath != null)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: 'https://image.tmdb.org/t/p/original${provider.logoPath}',
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => const Icon(Icons.tv),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    provider.providerName ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
