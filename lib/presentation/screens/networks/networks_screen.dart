import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/network_model.dart';
import '../../../data/services/api_config.dart';
import '../../../providers/networks_provider.dart';
import '../../widgets/app_drawer.dart';

class NetworksScreen extends StatefulWidget {
  const NetworksScreen({super.key});

  static const routeName = '/networks';

  @override
  State<NetworksScreen> createState() => _NetworksScreenState();
}

class _NetworksScreenState extends State<NetworksScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _didInitQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitQuery) {
      final provider = context.read<NetworksProvider>();
      _searchController.text = provider.query;
      _didInitQuery = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworksProvider>();
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.networks)),
      drawer: const AppDrawer(),
      body: _NetworksBody(
        provider: provider,
        controller: _searchController,
        localization: localization,
      ),
    );
  }
}

class _NetworksBody extends StatelessWidget {
  const _NetworksBody({
    required this.provider,
    required this.controller,
    required this.localization,
  });

  final NetworksProvider provider;
  final TextEditingController controller;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.networks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.networks.isEmpty) {
      return _ErrorView(
        message: localization.t('network.error_loading'),
        onRetry: () async {
          await Future.wait([
            provider.refreshNetworks(),
            provider.refreshStaticData(forceRefresh: true),
          ]);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          provider.refreshNetworks(),
          provider.refreshStaticData(forceRefresh: true),
        ]);
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          final shouldLoadMore =
              metrics.axis == Axis.vertical &&
              metrics.pixels >= metrics.maxScrollExtent - 200 &&
              provider.canLoadMore &&
              !provider.isLoadingMore &&
              !provider.isLoading;

          if (shouldLoadMore) {
            provider.loadMoreNetworks();
          }

          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _SearchField(
              controller: controller,
              hintText: localization.t('network.search_placeholder'),
              helperText: localization.t('network.search_hint'),
              isLoading: provider.isLoading,
              onSearch: provider.searchNetworks,
            ),
            const SizedBox(height: 16),
            _PopularNetworksSection(
              provider: provider,
              localization: localization,
            ),
            const SizedBox(height: 16),
            _NetworksByCountrySection(
              provider: provider,
              localization: localization,
            ),
            const SizedBox(height: 16),
            _SearchResultsSection(
              provider: provider,
              localization: localization,
            ),
            if (provider.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.helperText,
    required this.isLoading,
    required this.onSearch,
  });

  final TextEditingController controller;
  final String hintText;
  final String helperText;
  final bool isLoading;
  final Future<void> Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: hintText,
        helperText: helperText,
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => onSearch(controller.text),
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSubmitted: onSearch,
    );
  }
}

class _PopularNetworksSection extends StatelessWidget {
  const _PopularNetworksSection({
    required this.provider,
    required this.localization,
  });

  final NetworksProvider provider;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final networks = provider.popularNetworks;
    final isLoading = provider.isLoadingStatic && networks.isEmpty;
    final theme = Theme.of(context);

    if (networks.isEmpty && !isLoading) {
      if (provider.staticError != null) {
        return _SectionCard(
          title: localization.t('network.popular'),
          child: Text(
            provider.staticError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final displayNetworks = networks.take(12).toList();

    return _SectionCard(
      title: localization.t('network.popular'),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayNetworks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final network = displayNetworks[index];
                  return _PopularNetworkTile(network: network);
                },
              ),
            ),
    );
  }
}

class _NetworksByCountrySection extends StatelessWidget {
  const _NetworksByCountrySection({
    required this.provider,
    required this.localization,
  });

  final NetworksProvider provider;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final entries = provider.networksByCountry.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();
    final isLoading = provider.isLoadingStatic && entries.isEmpty;
    final theme = Theme.of(context);

    if (entries.isEmpty && !isLoading) {
      if (provider.staticError != null) {
        return _SectionCard(
          title: localization.t('network.by_country'),
          child: Text(
            provider.staticError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: localization.t('network.by_country'),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.map((entry) {
                final label = provider.countryLabel(entry.key);
                final networks = entry.value.take(10).toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: networks
                            .map((network) => _NetworkChip(network: network))
                            .toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _SearchResultsSection extends StatelessWidget {
  const _SearchResultsSection({
    required this.provider,
    required this.localization,
  });

  final NetworksProvider provider;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = provider.networks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.t('network.search_results'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (results.isEmpty)
          _EmptyView(message: localization.t('network.empty'))
        else ...[
          ...results.map((network) => _NetworkCard(network: network)),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                provider.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PopularNetworkTile extends StatelessWidget {
  const _PopularNetworkTile({required this.network});

  final Network network;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoUrl = ApiConfig.getPosterUrl(
      network.logoPath,
      size: ApiConfig.profileSizeMedium,
    );

    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceVariant,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.surface,
            backgroundImage: logoUrl.isNotEmpty
                ? CachedNetworkImageProvider(logoUrl)
                : null,
            child: logoUrl.isEmpty
                ? Icon(Icons.live_tv, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            network.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkChip extends StatelessWidget {
  const _NetworkChip({required this.network});

  final Network network;

  @override
  Widget build(BuildContext context) {
    final logoUrl = ApiConfig.getPosterUrl(
      network.logoPath,
      size: ApiConfig.profileSizeSmall,
    );

    return Chip(
      avatar: logoUrl.isNotEmpty
          ? CircleAvatar(backgroundImage: CachedNetworkImageProvider(logoUrl))
          : const Icon(Icons.apartment),
      label: Text(network.name),
    );
  }
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({required this.network});

  final Network network;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoUrl = ApiConfig.getPosterUrl(
      network.logoPath,
      size: ApiConfig.profileSizeMedium,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.surfaceVariant,
              backgroundImage: logoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(logoUrl)
                  : null,
              child: logoUrl.isEmpty
                  ? Icon(Icons.live_tv, color: theme.colorScheme.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (network.originCountry != null &&
                      network.originCountry!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        network.originCountry!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(
                AppLocalizations.of(context).common['retry'] ?? 'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
