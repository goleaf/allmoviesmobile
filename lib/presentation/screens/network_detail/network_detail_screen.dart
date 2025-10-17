// removed unused cached_network_image import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/network_detailed_model.dart';
// removed unused api_config import
import '../../../data/tmdb_repository.dart';
import '../../../providers/network_details_provider.dart';
import '../../../providers/network_shows_provider.dart';
import '../../widgets/movie_card.dart';
import '../tv_detail/tv_detail_screen.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../widgets/media_image.dart';

class NetworkDetailArguments {
  const NetworkDetailArguments({
    required this.networkId,
    this.name,
    this.logoPath,
  });

  final int networkId;
  final String? name;
  final String? logoPath;
}

class NetworkDetailScreen extends StatelessWidget {
  const NetworkDetailScreen({
    super.key,
    required this.networkId,
    this.initialName,
    this.initialLogoPath,
  });

  static const routeName = '/network-detail';

  final int networkId;
  final String? initialName;
  final String? initialLogoPath;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NetworkDetailsProvider>(
          create: (_) =>
              NetworkDetailsProvider(repository, networkId: networkId),
        ),
        ChangeNotifierProvider<NetworkShowsProvider>(
          create: (_) => NetworkShowsProvider(repository, networkId: networkId),
        ),
      ],
      child: _NetworkDetailContent(
        initialName: initialName,
        initialLogoPath: initialLogoPath,
      ),
    );
  }
}

class _NetworkDetailContent extends StatelessWidget {
  const _NetworkDetailContent({
    required this.initialName,
    required this.initialLogoPath,
  });

  final String? initialName;
  final String? initialLogoPath;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FullscreenModalScaffold(
      title: Consumer<NetworkDetailsProvider>(
        builder: (context, provider, _) {
          return Text(
            provider.network?.name ??
                initialName ??
                loc.t('network.details_title'),
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<NetworkDetailsProvider>().refresh(),
            context.read<NetworkShowsProvider>().refreshShows(),
          ]);
        },
        child: Consumer<NetworkDetailsProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (provider.isLoading && !provider.hasData)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.errorMessage != null && !provider.hasData)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorView(
                      message: provider.errorMessage!,
                      onRetry: () =>
                          context.read<NetworkDetailsProvider>().refresh(),
                    ),
                  )
                else ...[
                  if (provider.isLoading)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  SliverToBoxAdapter(
                    child: _HeaderSection(
                      logoPath: provider.network?.logoPath ?? initialLogoPath,
                      networkName: provider.network?.name ?? initialName,
                    ),
                  ),
                  if (provider.network != null)
                    SliverToBoxAdapter(
                      child: _InfoSection(network: provider.network!),
                    ),
                  SliverToBoxAdapter(
                    child: _AlternativeNamesSection(
                      alternativeNames:
                          provider.network?.alternativeNames ?? const [],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _LogoVariationsSection(logos: provider.logos),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(child: _NetworkShowsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.logoPath, required this.networkName});

  final String? logoPath;
  final String? networkName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = logoPath;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            ),
            child: (path != null && path.isNotEmpty)
                ? MediaImage(
                    path: path,
                    type: MediaImageType.logo,
                    size: MediaImageSize.w185,
                    height: 120,
                    fit: BoxFit.contain,
                    placeholder: const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: const Icon(
                      Icons.broken_image_outlined,
                      size: 56,
                    ),
                  )
                : const Icon(Icons.apartment, size: 72),
          ),
          const SizedBox(height: 16),
          if (networkName != null && networkName!.isNotEmpty)
            Text(
              networkName!,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.network});

  final NetworkDetailed network;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final infoTiles = <Widget>[];

    if (network.headquarters != null && network.headquarters!.isNotEmpty) {
      infoTiles.add(
        _InfoTile(
          icon: Icons.location_city,
          label: loc.t('network.headquarters'),
          value: network.headquarters!,
        ),
      );
    }

    infoTiles.add(
      _InfoTile(
        icon: Icons.flag,
        label: loc.t('network.origin_country'),
        value: network.originCountry,
      ),
    );

    if (network.homepage != null && network.homepage!.isNotEmpty) {
      infoTiles.add(_HomepageTile(homepage: network.homepage!));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('network.details_title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...infoTiles,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomepageTile extends StatelessWidget {
  const _HomepageTile({required this.homepage});

  final String homepage;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.link, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('network.homepage'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  homepage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: loc.t('common.copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: homepage));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.t('network.copied'))),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AlternativeNamesSection extends StatelessWidget {
  const _AlternativeNamesSection({required this.alternativeNames});

  final List<AlternativeName> alternativeNames;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('network.alternative_names'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (alternativeNames.isEmpty)
            Text(
              loc.t('network.no_alternative_names'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: alternativeNames
                  .map(
                    (name) => Chip(
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(name.name),
                          Text(
                            name.type,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _LogoVariationsSection extends StatelessWidget {
  const _LogoVariationsSection({required this.logos});

  final List<ImageModel> logos;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('network.logo_variations'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (logos.isEmpty)
            Text(
              loc.t('network.no_logo_variations'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final logo = logos[index];
                  final filePath = logo.filePath;
                  return Container(
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: MediaImage(
                      path: filePath,
                      type: MediaImageType.logo,
                      size: MediaImageSize.w185,
                      fit: BoxFit.contain,
                      placeholder: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: const Icon(Icons.broken_image_outlined),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: logos.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworkShowsSection extends StatelessWidget {
  const _NetworkShowsSection();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<NetworkShowsProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('network.tv_shows'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _ShowsFilters(provider: provider),
              const SizedBox(height: 16),
              if (provider.isLoading && provider.shows.isEmpty)
                const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.errorMessage != null && provider.shows.isEmpty)
                _ErrorView(
                  message: provider.errorMessage!,
                  onRetry: provider.refreshShows,
                )
              else if (provider.shows.isEmpty)
                SizedBox(
                  height: 80,
                  child: Center(
                    child: Text(
                      loc.t('network.empty_shows'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                _ShowsGrid(shows: provider.shows),
              const SizedBox(height: 12),
              if (provider.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.canLoadMore && provider.shows.isNotEmpty)
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton(
                    onPressed: provider.loadMoreShows,
                    child: Text(loc.t('network.load_more')),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ShowsFilters extends StatelessWidget {
  const _ShowsFilters({required this.provider});

  final NetworkShowsProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final sortOptions = <String, String>{
      loc.t('network.sort.popularity'): 'popularity.desc',
      loc.t('network.sort.rating'): 'vote_average.desc',
      loc.t('network.sort.newest'): 'first_air_date.desc',
    };

    final languageOptions = <String?, String>{
      null: loc.t('network.filters.language_any'),
      'en': loc.t('network.filters.language_en'),
      'es': loc.t('network.filters.language_es'),
      'ko': loc.t('network.filters.language_ko'),
    };

    final ratingChips = <double?>[null, 7.0, 8.0];

    final ratingLabels = {
      null: loc.t('network.filters.rating_any'),
      7.0: loc.t('network.filters.rating_seven'),
      8.0: loc.t('network.filters.rating_eight'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: loc.t('network.sort_label'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: sortOptions.values.contains(provider.sortBy)
                        ? provider.sortBy
                        : sortOptions.values.first,
                    items: sortOptions.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.value,
                            child: Text(entry.key),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.updateSortBy(value);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: loc.t('network.filters.language_label'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: provider.originalLanguage,
                    items: languageOptions.entries
                        .map(
                          (entry) => DropdownMenuItem<String?>(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: provider.updateOriginalLanguage,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ratingChips
              .map(
                (value) => ChoiceChip(
                  label: Text(ratingLabels[value] ?? ''),
                  selected: provider.minVoteAverage == value,
                  onSelected: (_) => provider.updateMinVoteAverage(value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ShowsGrid extends StatelessWidget {
  const _ShowsGrid({required this.shows});

  final List<Movie> shows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var crossAxisCount = (constraints.maxWidth / 180).floor();
        if (crossAxisCount < 2) {
          crossAxisCount = 2;
        } else if (crossAxisCount > 4) {
          crossAxisCount = 4;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: shows.length,
          itemBuilder: (context, index) {
            final show = shows[index];
            return MovieCard(
              id: show.id,
              title: show.title,
              posterPath: show.posterPath,
              voteAverage: show.voteAverage,
              releaseDate: show.releaseDate,
              heroTag: 'tv-poster-${show.id}',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TVDetailScreen(tvShow: show),
                    fullscreenDialog: true,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(loc.t('network.retry')),
          ),
        ],
      ),
    );
  }
}

class MissingNetworkArgumentsScreen extends StatelessWidget {
  const MissingNetworkArgumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FullscreenModalScaffold(
      title: Text(loc.t('network.details_title')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            loc.t('errors.missing_network_args'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
