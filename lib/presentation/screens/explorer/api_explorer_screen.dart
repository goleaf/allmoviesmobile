import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/certification_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/person_model.dart';
import '../../../data/models/watch_provider_model.dart';
import '../../../data/services/api_config.dart';
import '../../../providers/api_explorer_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/error_widget.dart';

class ApiExplorerScreen extends StatefulWidget {
  const ApiExplorerScreen({super.key});

  static const routeName = '/explorer';

  @override
  State<ApiExplorerScreen> createState() => _ApiExplorerScreenState();
}

class _ApiExplorerScreenState extends State<ApiExplorerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiExplorerProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApiExplorerProvider>();
    final snapshot = provider.snapshot;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.apiExplorer),
        actions: [
          IconButton(
            tooltip: 'Refresh TMDB data',
            onPressed: provider.isLoading
                ? null
                : () => provider.load(forceRefresh: true),
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
      body: Builder(
        builder: (context) {
          if (provider.isLoading && snapshot == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && snapshot == null) {
            return ErrorDisplay(
              message: provider.errorMessage!,
              onRetry: () => provider.load(forceRefresh: true),
            );
          }

          if (snapshot == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () => provider.load(forceRefresh: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _ExplorerHeader(snapshot: snapshot),
                ),
                _MovieCarouselSection(
                  title: 'Trending across TMDB',
                  subtitle:
                      'The most popular movies, series, and personalities from the last 24 hours.',
                  movies: snapshot.trendingAll,
                ),
                _MovieCarouselSection(
                  title: 'Spotlight movies',
                  subtitle:
                      'High-impact films climbing the leaderboards right now.',
                  movies: snapshot.trendingMovies,
                ),
                _MovieCarouselSection(
                  title: 'Spotlight series',
                  subtitle: 'Must-watch TV series curated from TMDB discover.',
                  movies: snapshot.trendingTv,
                ),
                _MovieCarouselSection(
                  title: 'Discover movies',
                  subtitle:
                      'Smart discovery feed using popularity, filters, and localization.',
                  movies: snapshot.discoverMovies,
                ),
                _MovieCarouselSection(
                  title: 'Discover series',
                  subtitle:
                      'Trending television powered by the TMDB discovery engine.',
                  movies: snapshot.discoverTv,
                ),
                _PeopleShowcaseSection(people: snapshot.popularPeople),
                _ChipSection(
                  title: 'Supported languages',
                  subtitle: 'Browse the catalogue in your preferred language.',
                  labels: snapshot.languages
                      .map((lang) => '${lang.englishName} (${lang.code})'),
                ),
                _ChipSection(
                  title: 'Certified countries',
                  subtitle:
                      'Regional marketplaces connected to TMDB content and ratings.',
                  labels: snapshot.countries
                      .map((country) => '${country.englishName} (${country.code})'),
                ),
                _ChipSection(
                  title: 'Watch provider regions',
                  subtitle:
                      'Stream, rent, or buy titles with global partner availability.',
                  labels: snapshot.watchProviderRegions
                      .map((region) => '${region.englishName} (${region.countryCode})'),
                ),
                _TimezoneSection(snapshot: snapshot),
                _WatchProvidersSection(snapshot: snapshot),
                _CertificationSection(
                  title: 'Movie certifications',
                  snapshot: snapshot,
                  certifications: snapshot.movieCertifications,
                ),
                _CertificationSection(
                  title: 'TV certifications',
                  snapshot: snapshot,
                  certifications: snapshot.tvCertifications,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExplorerHeader extends StatelessWidget {
  const _ExplorerHeader({required this.snapshot});

  final ApiExplorerSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = snapshot.configuration.images;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.api_outlined,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Powered by TMDB v4',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Secure image base: ${images.secureBaseUrl}\nChange keys: ${images.posterSizes.length} poster presets',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.image_outlined,
                    label: 'Poster sizes: ${images.posterSizes.join(', ')}',
                  ),
                  _InfoChip(
                    icon: Icons.wallpaper,
                    label: 'Backdrop sizes: ${images.backdropSizes.join(', ')}',
                  ),
                  _InfoChip(
                    icon: Icons.portrait,
                    label: 'Profile sizes: ${images.profileSizes.join(', ')}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      avatar: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class _MovieCarouselSection extends StatelessWidget {
  const _MovieCarouselSection({
    required this.title,
    required this.subtitle,
    required this.movies,
  });

  final String title;
  final String subtitle;
  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return _MoviePosterCard(movie: movie);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: movies.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoviePosterCard extends StatelessWidget {
  const _MoviePosterCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posterUrl = ApiConfig.getPosterUrl(movie.posterPath);

    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: posterUrl.isEmpty
                  ? Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.movie_creation_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        movie.formattedRating,
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (movie.releaseYear != null)
                        Text(
                          movie.releaseYear!,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
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

class _PeopleShowcaseSection extends StatelessWidget {
  const _PeopleShowcaseSection({required this.people});

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Influential people',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover trending actors, directors, and creative talent.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final person = people[index];
                  return _PersonCard(person: person);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: people.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final profileUrl = ApiConfig.getProfileUrl(person.profilePath);
    final theme = Theme.of(context);

    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: profileUrl.isEmpty
                  ? Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.person_outline,
                        size: 56,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: profileUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.person_off_outlined,
                          size: 56,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.knownForDepartment ?? 'Creative',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
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

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.subtitle,
    required this.labels,
  });

  final String title;
  final String subtitle;
  final Iterable<String> labels;

  @override
  Widget build(BuildContext context) {
    final entries = labels.toList();
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Card(
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entries
                      .map((label) => Chip(
                            label: Text(label),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimezoneSection extends StatelessWidget {
  const _TimezoneSection({required this.snapshot});

  final ApiExplorerSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.timezones.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);
    final countryMap = {
      for (final country in snapshot.countries) country.code: country.englishName
    };
    final preview = snapshot.timezones.take(6).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global timezones',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan releases with insight into regional availability windows.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ...preview.asMap().entries.map((entry) {
                  final index = entry.key;
                  final timezone = entry.value;
                  final zones = timezone.zones;
                  final zonePreview = zones.take(3).join(', ');
                  final extraCount = zones.length - 3;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.public),
                        title: Text(
                          '${countryMap[timezone.countryCode] ?? timezone.countryCode} (${timezone.countryCode})',
                          style: theme.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          extraCount > 0
                              ? '$zonePreview, +$extraCount more'
                              : zonePreview,
                        ),
                      ),
                      if (index != preview.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WatchProvidersSection extends StatelessWidget {
  const _WatchProvidersSection({required this.snapshot});

  final ApiExplorerSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.watchProvidersMovie.isEmpty &&
        snapshot.watchProvidersTv.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);
    final regionMap = {
      for (final region in snapshot.watchProviderRegions)
        region.countryCode: region.englishName
    };

    final prioritizedRegions = <String>['US', 'GB', 'CA', 'AU', 'IN', 'BR'];
    final combinedKeys = {
      ...snapshot.watchProvidersMovie.keys,
      ...snapshot.watchProvidersTv.keys,
    };

    final displayRegions = <String>[
      ...prioritizedRegions.where(combinedKeys.contains),
      ...combinedKeys.where((code) => !prioritizedRegions.contains(code)),
    ].take(6).toList();

    if (displayRegions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch providers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Streaming, rental, and purchase options by territory.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ...displayRegions.map((code) {
                  final movieProviders = snapshot.watchProvidersMovie[code];
                  final tvProviders = snapshot.watchProvidersTv[code];
                  final countryName = regionMap[code] ?? code;

                  return ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      '$countryName ($code)',
                      style: theme.textTheme.titleSmall,
                    ),
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    children: [
                      if (movieProviders != null)
                        _ProviderWrap(
                          label: 'Movies',
                          providers: _uniqueProviders(movieProviders),
                        ),
                      if (tvProviders != null)
                        _ProviderWrap(
                          label: 'TV',
                          providers: _uniqueProviders(tvProviders),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<WatchProvider> _uniqueProviders(WatchProviderResults results) {
    final seen = <int>{};
    final providers = <WatchProvider>[];

    void addAll(List<WatchProvider> list) {
      for (final provider in list) {
        final id = provider.providerId ?? provider.id;
        if (id != null && seen.add(id)) {
          providers.add(provider);
        }
      }
    }

    addAll(results.flatrate);
    addAll(results.buy);
    addAll(results.rent);

    providers.sort((a, b) {
      final left = a.displayPriority ?? 999;
      final right = b.displayPriority ?? 999;
      return left.compareTo(right);
    });

    return providers;
  }
}

class _ProviderWrap extends StatelessWidget {
  const _ProviderWrap({required this.label, required this.providers});

  final String label;
  final List<WatchProvider> providers;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: providers
                .map(
                  (provider) => Chip(
                    avatar: () {
                      final logoUrl = ApiConfig.getPosterUrl(
                        provider.logoPath,
                        size: ApiConfig.profileSizeMedium,
                      );
                      if (logoUrl.isEmpty) {
                        return const Icon(Icons.live_tv);
                      }
                      return CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(logoUrl),
                      );
                    }(),
                    label: Text(provider.providerName ?? 'Unknown'),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CertificationSection extends StatelessWidget {
  const _CertificationSection({
    required this.title,
    required this.snapshot,
    required this.certifications,
  });

  final String title;
  final ApiExplorerSnapshot snapshot;
  final Map<String, List<Certification>> certifications;

  @override
  Widget build(BuildContext context) {
    if (certifications.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);
    final countryMap = {
      for (final country in snapshot.countries) country.code: country.englishName
    };

    final prioritizedRegions = <String>['US', 'GB', 'CA', 'AU', 'IN'];
    final keys = <String>[
      ...prioritizedRegions.where(certifications.containsKey),
      ...certifications.keys
          .where((code) => !prioritizedRegions.contains(code))
          .toList(),
    ].take(6);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Card(
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
                const SizedBox(height: 4),
                Text(
                  'Official content ratings sourced from regional boards.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ...keys.map((code) {
                  final items = certifications[code];
                  if (items == null || items.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final displayName = countryMap[code] ?? code;

                  return ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    title: Text(
                      '$displayName ($code)',
                      style: theme.textTheme.titleSmall,
                    ),
                    children: [
                      ...items.take(6).map(
                        (item) => ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              item.certification,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Text(item.meaning),
                          subtitle: Text('Order: ${item.order}'),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
