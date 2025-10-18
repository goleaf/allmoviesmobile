import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/certification_model.dart';
import '../../../data/services/cache_service.dart';
import '../../../providers/configuration_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/error_widget.dart';

/// Displays a consolidated, richly documented reference of TMDB configuration
/// metadata: cache policies, base URLs, supported locales, timezones, job
/// catalogs, and certification guides. Everything rendered by this screen is
/// backed by the endpoints summarized inside [ConfigurationProvider].
class ConfigInfoScreen extends StatefulWidget {
  const ConfigInfoScreen({super.key});

  /// Route identifier so the drawer and navigator can discover this screen.
  static const routeName = '/config/reference';

  @override
  State<ConfigInfoScreen> createState() => _ConfigInfoScreenState();
}

class _ConfigInfoScreenState extends State<ConfigInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off the data load once the widget tree is ready so every section can
    // describe the live TMDB payloads. Each fetch is documented within the
    // provider (see the endpoint list in ConfigurationProvider.load).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigurationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfigurationProvider>();
    final loc = AppLocalizations.of(context);
    final refreshLabel = loc.common['refresh'] ?? 'Refresh';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('configuration_reference.title')),
        actions: [
          IconButton(
            tooltip: refreshLabel,
            onPressed: provider.isLoading ? null : () => provider.refresh(),
            icon: provider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _ConfigBody(provider: provider),
    );
  }
}

/// Wraps the primary content area so loading, error, and data states remain
/// easy to read and test.
class _ConfigBody extends StatelessWidget {
  const _ConfigBody({required this.provider});

  final ConfigurationProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (provider.isLoading && !provider.hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && !provider.hasContent) {
      return ErrorDisplay(
        message: provider.errorMessage!,
        onRetry: () => provider.refresh(),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(provider: provider),
          const SizedBox(height: 16),
          _ApiConfigurationCard(provider: provider),
          const SizedBox(height: 16),
          _LocaleCatalogCard(provider: provider),
          const SizedBox(height: 16),
          _TimezoneCard(provider: provider),
          const SizedBox(height: 16),
          _JobsCard(provider: provider),
          const SizedBox(height: 16),
          _CertificationsCard(provider: provider),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 24),
            Text(
              provider.errorMessage!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 32),
          Text(
            loc.t('configuration_reference.disclaimer'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Displays cache policy timings and last-refresh metadata so developers know
/// exactly how long configuration datasets stay warm in the app cache.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.provider});

  final ConfigurationProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lastLoaded = provider.lastLoaded;

    Duration? elapsed;
    if (lastLoaded != null) {
      elapsed = DateTime.now().difference(lastLoaded);
    }

    String lastUpdatedLabel;
    if (lastLoaded == null) {
      lastUpdatedLabel = loc.t('configuration_reference.never_loaded');
    } else {
      lastUpdatedLabel = loc.t('configuration_reference.last_loaded').replaceAll(
        '{timestamp}',
        lastLoaded.toLocal().toString(),
      );
      if (elapsed != null) {
        lastUpdatedLabel +=
            ' • ${loc.t('configuration_reference.elapsed').replaceAll('{minutes}', elapsed.inMinutes.toString())}';
      }
    }

    return _InfoCard(
      title: loc.t('configuration_reference.summary_title'),
      subtitle: lastUpdatedLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CacheTile(
            label: loc.t('configuration_reference.cache_default'),
            seconds: CacheService.defaultTTL,
          ),
          _CacheTile(
            label: loc.t('configuration_reference.cache_movies'),
            seconds: CacheService.movieDetailsTTL,
          ),
          _CacheTile(
            label: loc.t('configuration_reference.cache_trending'),
            seconds: CacheService.trendingTTL,
          ),
          _CacheTile(
            label: loc.t('configuration_reference.cache_search'),
            seconds: CacheService.searchTTL,
          ),
          const SizedBox(height: 12),
          Text(
            loc.t('configuration_reference.cache_hint'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Renders TMDB image configuration data (base URLs, sizes, and change keys)
/// so integrators can quickly assemble CDN paths and understand cache
/// invalidation keys.
class _ApiConfigurationCard extends StatelessWidget {
  const _ApiConfigurationCard({required this.provider});

  final ConfigurationProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final configuration = provider.configuration;

    if (configuration == null) {
      return _InfoCard(
        title: loc.t('configuration_reference.api_title'),
        subtitle: loc.t('configuration_reference.api_empty'),
        child: const SizedBox.shrink(),
      );
    }

    final images = configuration.images;

    return _InfoCard(
      title: loc.t('configuration_reference.api_title'),
      subtitle: loc.t('configuration_reference.api_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('${loc.t('configuration_reference.base_url')}: ${images.baseUrl}'),
          SelectableText('${loc.t('configuration_reference.secure_base_url')}: ${images.secureBaseUrl}'),
          const SizedBox(height: 12),
          _ChipList(
            title: loc.t('configuration_reference.backdrop_sizes'),
            values: images.backdropSizes,
          ),
          _ChipList(
            title: loc.t('configuration_reference.logo_sizes'),
            values: images.logoSizes,
          ),
          _ChipList(
            title: loc.t('configuration_reference.poster_sizes'),
            values: images.posterSizes,
          ),
          _ChipList(
            title: loc.t('configuration_reference.profile_sizes'),
            values: images.profileSizes,
          ),
          _ChipList(
            title: loc.t('configuration_reference.still_sizes'),
            values: images.stillSizes,
          ),
          const Divider(height: 24),
          _ChipList(
            title: loc.t('configuration_reference.change_keys'),
            values: configuration.changeKeys,
            maxItems: 30,
          ),
        ],
      ),
    );
  }
}

/// Highlights supported languages and countries from TMDB so translators and QA
/// can plan coverage.
class _LocaleCatalogCard extends StatelessWidget {
  const _LocaleCatalogCard({required this.provider});

  final ConfigurationProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final languages = provider.languages
        .map((lang) => '${lang.englishName} (${lang.code})')
        .toList(growable: false);
    final countries = provider.countries
        .map((country) => '${country.englishName} (${country.code})')
        .toList(growable: false);

    return _InfoCard(
      title: loc.t('configuration_reference.locale_title'),
      subtitle: loc.t('configuration_reference.locale_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChipList(
            title: loc.t('configuration_reference.languages'),
            values: languages,
            maxItems: 42,
          ),
          const SizedBox(height: 16),
          _ChipList(
            title: loc.t('configuration_reference.countries'),
            values: countries,
            maxItems: 42,
          ),
        ],
      ),
    );
  }
}

/// Shows timezone coverage organized by ISO country code to help developers map
/// schedules and release windows.
class _TimezoneCard extends StatelessWidget {
  const _TimezoneCard({required this.provider});

  final ConfigurationProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final entries = provider.timezones;
    final totalZones = entries.fold<int>(
      0,
      (sum, tz) => sum + tz.zones.length,
    );

    if (entries.isEmpty) {
      return _InfoCard(
        title: loc.t('configuration_reference.timezones_title'),
        subtitle: loc.t('configuration_reference.empty_placeholder'),
        child: const SizedBox.shrink(),
      );
    }

    return _InfoCard(
      title: loc.t('configuration_reference.timezones_title'),
      subtitle: loc
          .t('configuration_reference.timezones_summary')
          .replaceAll('{countries}', entries.length.toString())
          .replaceAll('{zones}', totalZones.toString()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.take(12).map((timezone) {
          final chipValues = timezone.zones.take(8).toList(growable: false);
          final hasMore = timezone.zones.length > chipValues.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${timezone.countryCode} • ${timezone.zones.length}'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final zone in chipValues) Chip(label: Text(zone)),
                    if (hasMore)
                      Chip(
                        label: Text(
                          loc
                              .t('configuration_reference.more_zones')
                              .replaceAll('{count}',
                                  (timezone.zones.length - chipValues.length)
                                      .toString()),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Visualizes TMDB job departments so the crew browser can reference the full
/// taxonomy.
class _JobsCard extends StatelessWidget {
  const _JobsCard({required this.provider});

  final ConfigurationProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final jobs = provider.jobs;

    if (jobs.isEmpty) {
      return _InfoCard(
        title: loc.t('configuration_reference.jobs_title'),
        subtitle: loc.t('configuration_reference.empty_placeholder'),
        child: const SizedBox.shrink(),
      );
    }

    return _InfoCard(
      title: loc.t('configuration_reference.jobs_title'),
      subtitle: loc
          .t('configuration_reference.jobs_summary')
          .replaceAll('{departments}', jobs.length.toString()),
      child: Column(
        children: jobs.map((job) {
          final limited = job.jobs.take(10).toList(growable: false);
          final hasMore = job.jobs.length > limited.length;
          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(job.department),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final title in limited) Chip(label: Text(title)),
                        if (hasMore)
                          Chip(
                            label: Text(
                              loc
                                  .t('configuration_reference.more_jobs')
                                  .replaceAll('{count}',
                                      (job.jobs.length - limited.length)
                                          .toString()),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Summarizes movie and TV certification sets so content ratings remain
/// transparent across markets.
class _CertificationsCard extends StatelessWidget {
  const _CertificationsCard({required this.provider});

  final ConfigurationProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return _InfoCard(
      title: loc.t('configuration_reference.certifications_title'),
      subtitle: loc.t('configuration_reference.certifications_subtitle'),
      child: Column(
        children: [
          _CertificationGroup(
            heading: loc.t('configuration_reference.movie_certifications'),
            catalog: provider.movieCertifications,
          ),
          const SizedBox(height: 16),
          _CertificationGroup(
            heading: loc.t('configuration_reference.tv_certifications'),
            catalog: provider.tvCertifications,
          ),
        ],
      ),
    );
  }
}

/// Shared container used to give every section consistent elevation/padding.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// Formats TTL values in a human-friendly manner (seconds, minutes, and hours)
/// so the summary card can highlight cache policy intent.
class _CacheTile extends StatelessWidget {
  const _CacheTile({required this.label, required this.seconds});

  final String label;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds / 60).toStringAsFixed(1);
    final hours = (seconds / 3600).toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$seconds s / $minutes m / $hours h'),
        ],
      ),
    );
  }
}

/// Displays a short list of chips while gracefully hinting at additional
/// entries when the dataset is large.
class _ChipList extends StatelessWidget {
  const _ChipList({
    required this.title,
    required this.values,
    this.maxItems = 24,
  });

  final String title;
  final List<String> values;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayed = values.take(maxItems).toList(growable: false);
    final remaining = values.length - displayed.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (displayed.isEmpty)
          Text(
            AppLocalizations.of(context)
                .t('configuration_reference.empty_placeholder'),
            style: theme.textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in displayed) Chip(label: Text(value)),
              if (remaining > 0)
                Chip(
                  label: Text(
                    AppLocalizations.of(context)
                        .t('configuration_reference.more_generic')
                        .replaceAll('{count}', remaining.toString()),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Renders a certification group (movies or TV) with a concise preview of each
/// region's rating scale.
class _CertificationGroup extends StatelessWidget {
  const _CertificationGroup({
    required this.heading,
    required this.catalog,
  });

  final String heading;
  final Map<String, List<Certification>> catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final entries = catalog.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      return Text(
        loc.t('configuration_reference.certifications_empty'),
        style: theme.textTheme.bodySmall,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final entry in entries.take(12)) ...[
          Text('${entry.key} • ${entry.value.length}'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final certification in entry.value.take(8))
                Chip(label: Text(certification.certification)),
              if (entry.value.length > 8)
                Chip(
                  label: Text(
                    loc
                        .t('configuration_reference.more_ratings')
                        .replaceAll(
                          '{count}',
                          (entry.value.length - 8).toString(),
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
