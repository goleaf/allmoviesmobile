import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../providers/genres_provider.dart';
import '../../../providers/series_provider.dart';
import '../../widgets/app_drawer.dart';
import 'series_category_screen.dart';

class SeriesScreen extends StatefulWidget {
  static const routeName = '/series';

  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  late final List<_PrimaryBrowseItem> _primaryItems;
  late final List<_BrowseChipData> _networkChips;
  late final List<_BrowseChipData> _countryChips;
  late final List<_BrowseChipData> _languageChips;
  late final List<_BrowseChipData> _certificationChips;
  late final List<_BrowseChipData> _typeChips;

  @override
  void initState() {
    super.initState();
    _prepareBrowseData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GenresProvider>().fetchTVGenres();
    });
  }

  void _prepareBrowseData() {
    final now = DateTime.now();
    final lastYear = DateTime(now.year - 1, now.month, now.day);
    final formatter = DateFormat('yyyy-MM-dd');
    final today = formatter.format(now);
    final lastYearString = formatter.format(lastYear);

    _primaryItems = [
      _PrimaryBrowseItem(
        title: 'Popular TV shows',
        description: 'Fan-favorite series everyone is watching.',
        icon: Icons.local_fire_department_outlined,
        accentColor: Colors.orange,
        destination: SeriesCategoryArguments(
          title: 'Popular TV shows',
          subtitle: 'These series are trending with viewers right now.',
          category: 'popular',
        ),
      ),
      _PrimaryBrowseItem(
        title: 'Top rated series',
        description: 'Critically acclaimed and highly rated must-watch shows.',
        icon: Icons.star_outline,
        accentColor: Colors.amber,
        destination: SeriesCategoryArguments(
          title: 'Top rated series',
          subtitle: 'Highest rated series according to TMDB users.',
          category: 'top_rated',
        ),
      ),
      _PrimaryBrowseItem(
        title: 'Currently airing',
        description: 'Shows with new episodes broadcasting this season.',
        icon: Icons.live_tv,
        accentColor: Colors.green,
        destination: SeriesCategoryArguments(
          title: 'Currently airing',
          subtitle: 'Series that are on the air right now.',
          category: 'on_the_air',
        ),
      ),
      _PrimaryBrowseItem(
        title: 'Airing today',
        description: 'Catch episodes premiering within the next 24 hours.',
        icon: Icons.calendar_today_outlined,
        accentColor: Colors.blue,
        destination: SeriesCategoryArguments(
          title: 'Airing today',
          subtitle: 'Shows scheduled to air new episodes today.',
          category: 'airing_today',
        ),
      ),
      _PrimaryBrowseItem(
        title: 'Latest TV additions',
        description: 'Fresh debuts and newly added series across networks.',
        icon: Icons.new_releases_outlined,
        accentColor: Colors.purple,
        destination: SeriesCategoryArguments(
          title: 'Latest TV additions',
          subtitle: 'Recently released series sorted by first air date.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {
            'sort_by': 'first_air_date.desc',
            'first_air_date.lte': today,
            'first_air_date.gte': lastYearString,
            'include_null_first_air_dates': 'false',
          },
        ),
      ),
    ];

    _networkChips = [
      _BrowseChipData(
        label: 'Netflix',
        icon: Icons.local_movies_outlined,
        destination: SeriesCategoryArguments(
          title: 'Netflix series',
          subtitle: 'Originals and exclusives streaming on Netflix.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '213'},
        ),
      ),
      _BrowseChipData(
        label: 'HBO',
        icon: Icons.movie_creation_outlined,
        destination: SeriesCategoryArguments(
          title: 'HBO series',
          subtitle: 'Premium dramas and comedies from HBO.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '49'},
        ),
      ),
      _BrowseChipData(
        label: 'Disney+',
        icon: Icons.auto_awesome,
        destination: SeriesCategoryArguments(
          title: 'Disney+ series',
          subtitle: 'Family favorites and franchises on Disney+.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '2739'},
        ),
      ),
      _BrowseChipData(
        label: 'Apple TV+',
        icon: Icons.tv_outlined,
        destination: SeriesCategoryArguments(
          title: 'Apple TV+ series',
          subtitle: 'Award-winning originals from Apple TV+.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '2552'},
        ),
      ),
      _BrowseChipData(
        label: 'Amazon Prime',
        icon: Icons.shopping_bag_outlined,
        destination: SeriesCategoryArguments(
          title: 'Prime Video series',
          subtitle: 'Series available on Amazon Prime Video.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '1024'},
        ),
      ),
      _BrowseChipData(
        label: 'Hulu',
        icon: Icons.stream,
        destination: SeriesCategoryArguments(
          title: 'Hulu series',
          subtitle: 'Exclusive and next-day episodes on Hulu.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '453'},
        ),
      ),
      _BrowseChipData(
        label: 'Paramount+',
        icon: Icons.park_outlined,
        destination: SeriesCategoryArguments(
          title: 'Paramount+ series',
          subtitle: 'Shows from Paramount+ and CBS All Access.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '4330'},
        ),
      ),
      _BrowseChipData(
        label: 'Peacock',
        icon: Icons.slow_motion_video,
        destination: SeriesCategoryArguments(
          title: 'Peacock series',
          subtitle: 'NBCUniversal hits streaming on Peacock.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '3353'},
        ),
      ),
      _BrowseChipData(
        label: 'BBC',
        icon: Icons.public,
        destination: SeriesCategoryArguments(
          title: 'BBC series',
          subtitle: 'British favourites from the BBC.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '4'},
        ),
      ),
      _BrowseChipData(
        label: 'The CW',
        icon: Icons.auto_graph,
        destination: SeriesCategoryArguments(
          title: 'The CW series',
          subtitle: 'Superheroes and teen dramas from The CW.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_networks': '71'},
        ),
      ),
    ];

    _countryChips = [
      _BrowseChipData(
        label: 'United States',
        destination: SeriesCategoryArguments(
          title: 'US TV shows',
          subtitle: 'Series produced in the United States.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'US'},
        ),
      ),
      _BrowseChipData(
        label: 'United Kingdom',
        destination: SeriesCategoryArguments(
          title: 'UK TV shows',
          subtitle: 'British series from the UK.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'GB'},
        ),
      ),
      _BrowseChipData(
        label: 'Japan',
        destination: SeriesCategoryArguments(
          title: 'Japanese TV shows',
          subtitle: 'Drama and anime from Japan.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'JP'},
        ),
      ),
      _BrowseChipData(
        label: 'South Korea',
        destination: SeriesCategoryArguments(
          title: 'Korean TV shows',
          subtitle: 'K-dramas and variety shows from South Korea.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'KR'},
        ),
      ),
      _BrowseChipData(
        label: 'India',
        destination: SeriesCategoryArguments(
          title: 'Indian TV shows',
          subtitle: 'Popular series produced in India.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'IN'},
        ),
      ),
      _BrowseChipData(
        label: 'Spain',
        destination: SeriesCategoryArguments(
          title: 'Spanish TV shows',
          subtitle: 'Series produced in Spain and Latin regions.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'ES'},
        ),
      ),
      _BrowseChipData(
        label: 'France',
        destination: SeriesCategoryArguments(
          title: 'French TV shows',
          subtitle: 'Series produced in France.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'FR'},
        ),
      ),
      _BrowseChipData(
        label: 'Germany',
        destination: SeriesCategoryArguments(
          title: 'German TV shows',
          subtitle: 'Series produced in Germany.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'DE'},
        ),
      ),
      _BrowseChipData(
        label: 'Canada',
        destination: SeriesCategoryArguments(
          title: 'Canadian TV shows',
          subtitle: 'Series produced in Canada.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'CA'},
        ),
      ),
      _BrowseChipData(
        label: 'Australia',
        destination: SeriesCategoryArguments(
          title: 'Australian TV shows',
          subtitle: 'Series produced in Australia.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_origin_country': 'AU'},
        ),
      ),
    ];

    _languageChips = [
      _BrowseChipData(
        label: 'English',
        destination: SeriesCategoryArguments(
          title: 'English-language TV shows',
          subtitle: 'Series produced in English.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'en'},
        ),
      ),
      _BrowseChipData(
        label: 'Spanish',
        destination: SeriesCategoryArguments(
          title: 'Spanish-language TV shows',
          subtitle: 'Series produced in Spanish.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'es'},
        ),
      ),
      _BrowseChipData(
        label: 'Japanese',
        destination: SeriesCategoryArguments(
          title: 'Japanese-language TV shows',
          subtitle: 'Series produced in Japanese.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'ja'},
        ),
      ),
      _BrowseChipData(
        label: 'Korean',
        destination: SeriesCategoryArguments(
          title: 'Korean-language TV shows',
          subtitle: 'Series produced in Korean.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'ko'},
        ),
      ),
      _BrowseChipData(
        label: 'Hindi',
        destination: SeriesCategoryArguments(
          title: 'Hindi-language TV shows',
          subtitle: 'Series produced in Hindi.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'hi'},
        ),
      ),
      _BrowseChipData(
        label: 'French',
        destination: SeriesCategoryArguments(
          title: 'French-language TV shows',
          subtitle: 'Series produced in French.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'fr'},
        ),
      ),
      _BrowseChipData(
        label: 'German',
        destination: SeriesCategoryArguments(
          title: 'German-language TV shows',
          subtitle: 'Series produced in German.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'de'},
        ),
      ),
      _BrowseChipData(
        label: 'Portuguese',
        destination: SeriesCategoryArguments(
          title: 'Portuguese-language TV shows',
          subtitle: 'Series produced in Portuguese.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'pt'},
        ),
      ),
      _BrowseChipData(
        label: 'Italian',
        destination: SeriesCategoryArguments(
          title: 'Italian-language TV shows',
          subtitle: 'Series produced in Italian.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'it'},
        ),
      ),
      _BrowseChipData(
        label: 'Chinese',
        destination: SeriesCategoryArguments(
          title: 'Chinese-language TV shows',
          subtitle: 'Series produced in Mandarin or Cantonese.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_original_language': 'zh'},
        ),
      ),
    ];

    _certificationChips = [
      _BrowseChipData(
        label: 'TV-Y',
        destination: SeriesCategoryArguments(
          title: 'TV-Y shows',
          subtitle: 'Programming suitable for all children.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {
            'certification.lte': 'TV-Y',
            'certification_country': 'US',
          },
        ),
      ),
      _BrowseChipData(
        label: 'TV-Y7',
        destination: SeriesCategoryArguments(
          title: 'TV-Y7 shows',
          subtitle: 'Series suitable for ages 7 and up.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {
            'certification.lte': 'TV-Y7',
            'certification_country': 'US',
          },
        ),
      ),
      _BrowseChipData(
        label: 'TV-G',
        destination: SeriesCategoryArguments(
          title: 'TV-G shows',
          subtitle: 'General audience programming.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {
            'certification.lte': 'TV-G',
            'certification_country': 'US',
          },
        ),
      ),
      _BrowseChipData(
        label: 'TV-PG',
        destination: SeriesCategoryArguments(
          title: 'TV-PG shows',
          subtitle: 'Parental guidance suggested television.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {
            'certification.lte': 'TV-PG',
            'certification_country': 'US',
          },
        ),
      ),
      _BrowseChipData(
        label: 'TV-14',
        destination: SeriesCategoryArguments(
          title: 'TV-14 shows',
          subtitle: 'Recommended for ages 14 and above.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {
            'certification.lte': 'TV-14',
            'certification_country': 'US',
          },
        ),
      ),
      _BrowseChipData(
        label: 'TV-MA',
        destination: SeriesCategoryArguments(
          title: 'TV-MA shows',
          subtitle: 'Intended for mature audiences.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {
            'certification': 'TV-MA',
            'certification_country': 'US',
          },
        ),
      ),
    ];

    _typeChips = [
      _BrowseChipData(
        label: 'Scripted',
        destination: SeriesCategoryArguments(
          title: 'Scripted series',
          subtitle: 'Narrative dramas and comedies.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_type': '4'},
        ),
      ),
      _BrowseChipData(
        label: 'Reality',
        destination: SeriesCategoryArguments(
          title: 'Reality series',
          subtitle: 'Unscripted and competition shows.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_type': '3'},
        ),
      ),
      _BrowseChipData(
        label: 'Documentary',
        destination: SeriesCategoryArguments(
          title: 'Documentary series',
          subtitle: 'Informative documentary storytelling.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_type': '0'},
        ),
      ),
      _BrowseChipData(
        label: 'Talk Show',
        destination: SeriesCategoryArguments(
          title: 'Talk shows',
          subtitle: 'Daily talk and late-night programming.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_type': '5'},
        ),
      ),
      _BrowseChipData(
        label: 'News',
        destination: SeriesCategoryArguments(
          title: 'News shows',
          subtitle: 'Breaking news and daily updates.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_type': '1'},
        ),
      ),
      _BrowseChipData(
        label: 'Mini-series',
        destination: SeriesCategoryArguments(
          title: 'Mini-series',
          subtitle: 'Limited event television.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_type': '2'},
        ),
      ),
      _BrowseChipData(
        label: 'Animation',
        destination: SeriesCategoryArguments(
          title: 'Animated series',
          subtitle: 'Cartoons and animated storytelling.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_genres': '16'},
        ),
      ),
      _BrowseChipData(
        label: 'Kids',
        destination: SeriesCategoryArguments(
          title: 'Kids series',
          subtitle: 'Shows created for young viewers.',
          requestType: SeriesRequestType.discover,
          discoverFilters: {'with_genres': '10762'},
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.series),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Browse TV Shows',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Explore curated collections and drill into genres, networks, languages, and more.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ..._primaryItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PrimaryBrowseCard(
                  item: item,
                  onTap: (arguments) => _openCategory(context, arguments),
                ),
              )),
          const SizedBox(height: 16),
          _BrowseSection(
            title: 'TV by genre',
            child: _GenreChipSection(onSelected: (arguments) => _openCategory(context, arguments)),
          ),
          const SizedBox(height: 24),
          _BrowseSection(
            title: 'TV by network',
            child: _ChipWrap(
              chips: _networkChips,
              onSelected: (arguments) => _openCategory(context, arguments),
            ),
          ),
          const SizedBox(height: 24),
          _BrowseSection(
            title: 'TV by country',
            child: _ChipWrap(
              chips: _countryChips,
              onSelected: (arguments) => _openCategory(context, arguments),
            ),
          ),
          const SizedBox(height: 24),
          _BrowseSection(
            title: 'TV by language',
            child: _ChipWrap(
              chips: _languageChips,
              onSelected: (arguments) => _openCategory(context, arguments),
            ),
          ),
          const SizedBox(height: 24),
          _BrowseSection(
            title: 'TV by certification',
            child: _ChipWrap(
              chips: _certificationChips,
              onSelected: (arguments) => _openCategory(context, arguments),
            ),
          ),
          const SizedBox(height: 24),
          _BrowseSection(
            title: 'TV by type',
            child: _ChipWrap(
              chips: _typeChips,
              onSelected: (arguments) => _openCategory(context, arguments),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _openCategory(BuildContext context, SeriesCategoryArguments arguments) {
    Navigator.pushNamed(
      context,
      SeriesCategoryScreen.routeName,
      arguments: arguments,
    );
  }
}

class _PrimaryBrowseItem {
  const _PrimaryBrowseItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.destination,
    this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final SeriesCategoryArguments destination;
  final Color? accentColor;
}

class _PrimaryBrowseCard extends StatelessWidget {
  const _PrimaryBrowseCard({required this.item, required this.onTap});

  final _PrimaryBrowseItem item;
  final ValueChanged<SeriesCategoryArguments> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = item.accentColor?.withOpacity(0.12) ??
        colorScheme.primaryContainer.withOpacity(0.4);
    final iconColor = item.accentColor ?? colorScheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(item.destination),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrowseSection extends StatelessWidget {
  const _BrowseSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _BrowseChipData {
  const _BrowseChipData({
    required this.label,
    required this.destination,
    this.icon,
  });

  final String label;
  final SeriesCategoryArguments destination;
  final IconData? icon;
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.chips, required this.onSelected});

  final List<_BrowseChipData> chips;
  final ValueChanged<SeriesCategoryArguments> onSelected;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) {
      return const Text('Coming soon');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips
          .map(
            (chip) => ActionChip(
              avatar: chip.icon != null
                  ? Icon(chip.icon, size: 18)
                  : null,
              label: Text(chip.label),
              onPressed: () => onSelected(chip.destination),
            ),
          )
          .toList(),
    );
  }
}

class _GenreChipSection extends StatelessWidget {
  const _GenreChipSection({required this.onSelected});

  final ValueChanged<SeriesCategoryArguments> onSelected;

  @override
  Widget build(BuildContext context) {
    return Consumer<GenresProvider>(
      builder: (context, provider, _) {
        final genres = provider.tvGenres;

        if (provider.isLoading && genres.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null && genres.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unable to load genres right now.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: provider.fetchTVGenres,
                child: const Text('Retry'),
              ),
            ],
          );
        }

        if (genres.isEmpty) {
          return const Text('Genres will appear here soon.');
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres
              .map(
                (genre) => ActionChip(
                  label: Text(genre.name),
                  onPressed: () => onSelected(
                    SeriesCategoryArguments(
                      title: '${genre.name} series',
                      subtitle: 'Browse TV shows in the ${genre.name.toLowerCase()} genre.',
                      requestType: SeriesRequestType.discover,
                      discoverFilters: {'with_genres': '${genre.id}'},
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
