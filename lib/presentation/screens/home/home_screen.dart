import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/collection_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/person_model.dart';
import '../../../data/models/saved_media_item.dart';
import '../../../providers/continue_watching_provider.dart';
import '../../../providers/home_highlights_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/home/home_collection_card.dart';
import '../../widgets/home/home_continue_watching_card.dart';
import '../../widgets/home/home_media_card.dart';
import '../../widgets/home/home_person_card.dart';
import '../../widgets/home/home_quick_access_card.dart';
import '../../widgets/home/home_search_bar.dart';
import '../../widgets/home/home_section.dart';
import '../../widgets/home/home_section_state_view.dart';
import '../collections/browse_collections_screen.dart';
import '../movies/movies_filters_screen.dart';
import '../movies/movies_screen.dart';
import '../people/people_screen.dart';
import '../search/search_screen.dart';
import '../series/series_screen.dart';
import '../series/series_filters_screen.dart';
import '../watchlist/watchlist_screen.dart';

/// Entry point for the redesigned home experience showcasing curated content
/// from across the application.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Global keys exposed for widget testing to reliably access each section.
class HomeScreenKeys {
  static const Key quickAccess = Key('home_quick_access_section');
  static const Key moviesOfMoment = Key('home_movies_of_moment_section');
  static const Key tvOfMoment = Key('home_tv_of_moment_section');
  static const Key continueWatching = Key('home_continue_watching_section');
  static const Key newReleases = Key('home_new_releases_section');
  static const Key recommendations = Key('home_recommendations_section');
  static const Key popularPeople = Key('home_popular_people_section');
  static const Key featuredCollections =
      Key('home_featured_collections_section');
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<HomeHighlightsProvider>().ensureInitialized();
      context.read<ContinueWatchingProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final highlights = context.watch<HomeHighlightsProvider>();
    final continueWatching = context.watch<ContinueWatchingProvider>();
    final l = AppLocalizations.of(context);

    final quickAccessItems = _buildQuickAccessConfigs(context, l);

    return Scaffold(
      appBar: AppBar(
        title: HomeSearchBar(
          hintText:
              l.search['search_placeholder'] ?? 'Search movies, TV, and people',
          onTap: () {
            Navigator.pushNamed(context, SearchScreen.routeName);
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await highlights.refreshAll();
          await continueWatching.refresh();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildQuickAccessSection(quickAccessItems, l),
            _buildMoviesOfMomentSection(highlights, l),
            _buildTvOfMomentSection(highlights, l),
            _buildContinueWatchingSection(continueWatching, l),
            _buildNewReleasesSection(highlights, l),
            _buildRecommendationsSection(highlights, l),
            _buildPopularPeopleSection(highlights, l),
            _buildFeaturedCollectionsSection(highlights, l),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(
    List<HomeQuickAccessConfig> items,
    AppLocalizations l,
  ) {
    return HomeSection(
      key: HomeScreenKeys.quickAccess,
      title: l.t('home.quick_access'),
      subtitle: l.t('home.quick_access_subtitle'),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            const SizedBox(width: 12),
            for (final config in items) ...[
              HomeQuickAccessCard(config: config),
              const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoviesOfMomentSection(
    HomeHighlightsProvider highlights,
    AppLocalizations l,
  ) {
    return HomeSection(
      key: HomeScreenKeys.moviesOfMoment,
      title: l.t('home.of_the_moment_movies'),
      subtitle: l.t('home.of_the_moment_subtitle'),
      child: HomeSectionStateView<Movie>(
        state: highlights.moviesOfMoment,
        emptyMessage: l.t('home.no_trending_movies'),
        builder: (items) => _buildHorizontalCarousel<Movie>(
          items,
          itemBuilder: (context, movie) => HomeMediaCard(media: movie),
        ),
      ),
    );
  }

  Widget _buildTvOfMomentSection(
    HomeHighlightsProvider highlights,
    AppLocalizations l,
  ) {
    return HomeSection(
      key: HomeScreenKeys.tvOfMoment,
      title: l.t('home.of_the_moment_tv'),
      subtitle: l.t('home.of_the_moment_subtitle_tv'),
      child: HomeSectionStateView<Movie>(
        state: highlights.tvOfMoment,
        emptyMessage: l.t('home.no_trending_tv'),
        builder: (items) => _buildHorizontalCarousel<Movie>(
          items,
          itemBuilder: (context, show) => HomeMediaCard(media: show),
        ),
      ),
    );
  }

  Widget _buildContinueWatchingSection(
    ContinueWatchingProvider provider,
    AppLocalizations l,
  ) {
    Widget content;
    if (provider.isLoading) {
      content = const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (provider.errorMessage != null) {
      content = SizedBox(
        height: 150,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (provider.items.isEmpty) {
      content = SizedBox(
        height: 150,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.t('home.no_continue_watching'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else {
      content = _buildHorizontalCarousel<SavedMediaItem>(
        provider.items,
        height: 210,
        itemBuilder: (context, item) =>
            HomeContinueWatchingCard(item: item),
      );
    }

    return HomeSection(
      key: HomeScreenKeys.continueWatching,
      title: l.t('home.continue_watching'),
      subtitle: l.t('home.continue_watching_subtitle'),
      onSeeAll: () {
        Navigator.pushNamed(context, WatchlistScreen.routeName);
      },
      child: content,
    );
  }

  Widget _buildNewReleasesSection(
    HomeHighlightsProvider highlights,
    AppLocalizations l,
  ) {
    return HomeSection(
      key: HomeScreenKeys.newReleases,
      title: l.t('home.new_releases'),
      subtitle: l.t('home.new_releases_subtitle'),
      child: HomeSectionStateView<Movie>(
        state: highlights.newReleases,
        emptyMessage: l.t('home.no_new_releases'),
        builder: (items) => _buildHorizontalCarousel<Movie>(
          items,
          itemBuilder: (context, movie) => HomeMediaCard(media: movie),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(
    HomeHighlightsProvider highlights,
    AppLocalizations l,
  ) {
    return HomeSection(
      key: HomeScreenKeys.recommendations,
      title: l.t('home.personalized_recommendations'),
      subtitle: l.t('home.personalized_recommendations_subtitle'),
      child: HomeSectionStateView<Movie>(
        state: highlights.recommendations,
        emptyMessage: l.t('home.no_recommendations'),
        builder: (items) => _buildHorizontalCarousel<Movie>(
          items,
          itemBuilder: (context, movie) => HomeMediaCard(media: movie),
        ),
      ),
    );
  }

  Widget _buildPopularPeopleSection(
    HomeHighlightsProvider highlights,
    AppLocalizations l,
  ) {
    return HomeSection(
      key: HomeScreenKeys.popularPeople,
      title: l.t('home.popular_people'),
      subtitle: l.t('home.popular_people_subtitle'),
      onSeeAll: () {
        Navigator.pushNamed(context, PeopleScreen.routeName);
      },
      child: HomeSectionStateView<Person>(
        state: highlights.popularPeople,
        emptyMessage: l.t('home.no_people'),
        builder: (items) => _buildHorizontalCarousel<Person>(
          items,
          height: 170,
          itemBuilder: (context, person) => HomePersonCard(person: person),
        ),
      ),
    );
  }

  Widget _buildFeaturedCollectionsSection(
    HomeHighlightsProvider highlights,
    AppLocalizations l,
  ) {
    return HomeSection(
      key: HomeScreenKeys.featuredCollections,
      title: l.t('home.featured_collections'),
      subtitle: l.t('home.featured_collections_subtitle'),
      onSeeAll: () {
        Navigator.pushNamed(
          context,
          CollectionsBrowserScreen.routeName,
        );
      },
      child: HomeSectionStateView<CollectionDetails>(
        state: highlights.featuredCollections,
        emptyMessage: l.t('home.no_collections'),
        builder: (items) => _buildHorizontalCarousel<CollectionDetails>(
          items,
          height: 210,
          itemBuilder: (context, collection) =>
              HomeCollectionCard(collection: collection),
        ),
      ),
    );
  }

  Widget _buildHorizontalCarousel<T>(
    List<T> items, {
    required Widget Function(BuildContext context, T item) itemBuilder,
    double height = 240,
  }) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      ),
    );
  }

  List<HomeQuickAccessConfig> _buildQuickAccessConfigs(
    BuildContext context,
    AppLocalizations l,
  ) {
    return [
      HomeQuickAccessConfig(
        icon: Icons.movie_filter,
        label: l.t('home.quick_access_movies'),
        onTap: () => Navigator.pushNamed(context, MoviesScreen.routeName),
      ),
      HomeQuickAccessConfig(
        icon: Icons.live_tv,
        label: l.t('home.quick_access_series'),
        onTap: () => Navigator.pushNamed(context, SeriesScreen.routeName),
      ),
      HomeQuickAccessConfig(
        icon: Icons.manage_search,
        label: l.t('home.quick_access_filters'),
        onTap: () =>
            Navigator.pushNamed(context, MoviesFiltersScreen.routeName),
      ),
      HomeQuickAccessConfig(
        icon: Icons.hub,
        label: l.t('home.quick_access_genres'),
        onTap: () =>
            Navigator.pushNamed(context, SeriesFiltersScreen.routeName),
      ),
    ];
  }
}
