import 'models/tmdb_v4_endpoint.dart';

class TmdbV4Catalog {
  const TmdbV4Catalog._();

  static final List<TmdbV4EndpointGroup> groups = [
    TmdbV4EndpointGroup(
      name: 'Foundation',
      description:
          'Baseline configuration, trending, and discovery endpoints from TMDB v4.',
      endpoints: const [
        TmdbV4Endpoint(
          id: 'configuration',
          title: 'API configuration',
          description:
              'Fetches CDN base URLs and supported sizes used throughout TMDB.',
          category: 'System',
          path: '/configuration',
        ),
        TmdbV4Endpoint(
          id: 'trending-movie-day',
          title: 'Trending movies today',
          description:
              'High-level snapshot of movie popularity over the last day.',
          category: 'Trending',
          path: '/trending/movie/day',
        ),
        TmdbV4Endpoint(
          id: 'trending-tv-week',
          title: 'Trending TV this week',
          description:
              'Popular television shows calculated using the weekly trending window.',
          category: 'Trending',
          path: '/trending/tv/week',
        ),
        TmdbV4Endpoint(
          id: 'discover-movie',
          title: 'Discover movies',
          description:
              'Discover movies with curated filters mirroring the TMDB UI experience.',
          category: 'Discover',
          path: '/discover/movie',
          sampleQuery: {
            'sort_by': 'popularity.desc',
            'include_adult': 'false',
            'language': 'en-US',
          },
        ),
        TmdbV4Endpoint(
          id: 'discover-tv',
          title: 'Discover TV',
          description:
              'Explore TV shows using the discover API with default popularity filters.',
          category: 'Discover',
          path: '/discover/tv',
          sampleQuery: {
            'sort_by': 'popularity.desc',
            'include_adult': 'false',
            'language': 'en-US',
          },
        ),
        TmdbV4Endpoint(
          id: 'search-multi',
          title: 'Search multi',
          description:
              'Perform a blended search across movies, TV shows, and people.',
          category: 'Search',
          path: '/search/multi',
          sampleQuery: {'query': 'Inception', 'language': 'en-US', 'page': '1'},
        ),
      ],
    ),
    TmdbV4EndpointGroup(
      name: 'Movies',
      description: 'Core movie lookups and relationship data.',
      endpoints: const [
        TmdbV4Endpoint(
          id: 'movie-details',
          title: 'Movie details',
          description: 'Rich details for a single movie.',
          category: 'Movies',
          path: '/movie/550',
          notes: 'Uses Fight Club (id: 550) as a demo payload.',
        ),
        TmdbV4Endpoint(
          id: 'movie-credits',
          title: 'Movie credits',
          description: 'Cast and crew information for a given movie.',
          category: 'Movies',
          path: '/movie/550/credits',
          notes: 'Demo uses Fight Club (id: 550).',
        ),
        TmdbV4Endpoint(
          id: 'movie-alternative-titles',
          title: 'Movie alternative titles',
          description: 'Localized alternative titles for a specific movie.',
          category: 'Movies',
          path: '/movie/550/alternative_titles',
        ),
        TmdbV4Endpoint(
          id: 'movie-watch-providers',
          title: 'Movie watch providers',
          description: 'Streaming partner availability by region for a movie.',
          category: 'Movies',
          path: '/movie/550/watch/providers',
        ),
        TmdbV4Endpoint(
          id: 'movie-reviews',
          title: 'Movie reviews',
          description: 'User and critic reviews for a specific movie.',
          category: 'Movies',
          path: '/movie/550/reviews',
        ),
      ],
    ),
    TmdbV4EndpointGroup(
      name: 'Television',
      description: 'TV show metadata, credits, and recommendations.',
      endpoints: const [
        TmdbV4Endpoint(
          id: 'tv-details',
          title: 'TV show details',
          description: 'Metadata for a single TV show.',
          category: 'Television',
          path: '/tv/1399',
          notes: 'Demo uses Game of Thrones (id: 1399).',
        ),
        TmdbV4Endpoint(
          id: 'tv-aggregate-credits',
          title: 'TV aggregate credits',
          description: 'Aggregated cast and crew roles across seasons.',
          category: 'Television',
          path: '/tv/1399/aggregate_credits',
        ),
        TmdbV4Endpoint(
          id: 'tv-watch-providers',
          title: 'TV watch providers',
          description:
              'Streaming partner availability by region for a TV show.',
          category: 'Television',
          path: '/tv/1399/watch/providers',
        ),
        TmdbV4Endpoint(
          id: 'tv-season-details',
          title: 'TV season details',
          description: 'Episode breakdown for a specific season.',
          category: 'Television',
          path: '/tv/1399/season/1',
        ),
        TmdbV4Endpoint(
          id: 'tv-episode-details',
          title: 'TV episode details',
          description: 'Full metadata for a single episode.',
          category: 'Television',
          path: '/tv/1399/season/1/episode/1',
        ),
      ],
    ),
    TmdbV4EndpointGroup(
      name: 'People',
      description: 'Person, credits, and social data from TMDB.',
      endpoints: const [
        TmdbV4Endpoint(
          id: 'person-details',
          title: 'Person details',
          description: 'Biography and metadata for a person.',
          category: 'People',
          path: '/person/500',
          notes: 'Demo uses Brad Pitt (id: 500).',
        ),
        TmdbV4Endpoint(
          id: 'person-credits',
          title: 'Person combined credits',
          description:
              'Filmography combining movie and TV credits for a person.',
          category: 'People',
          path: '/person/500/combined_credits',
        ),
        TmdbV4Endpoint(
          id: 'person-images',
          title: 'Person images',
          description: 'Profile images available for a person.',
          category: 'People',
          path: '/person/500/images',
        ),
        TmdbV4Endpoint(
          id: 'person-external-ids',
          title: 'Person external IDs',
          description:
              'External identifiers (IMDB, Twitter, etc.) for a person.',
          category: 'People',
          path: '/person/500/external_ids',
        ),
      ],
    ),
    TmdbV4EndpointGroup(
      name: 'Lists & Collection tools',
      description:
          'Community-curated lists and collection utilities provided by TMDB.',
      endpoints: const [
        TmdbV4Endpoint(
          id: 'list-details',
          title: 'List details',
          description: 'Information about a curated TMDB list.',
          category: 'Lists',
          path: '/list/1',
          notes: 'List 1 is TMDB\'s demo curated movie list.',
        ),
        TmdbV4Endpoint(
          id: 'list-items',
          title: 'List items',
          description: 'Paginated items contained in a TMDB list.',
          category: 'Lists',
          path: '/list/1/items',
        ),
        TmdbV4Endpoint(
          id: 'list-translations',
          title: 'List translations',
          description: 'Localized translations available for a TMDB list.',
          category: 'Lists',
          path: '/list/1/translations',
        ),
        TmdbV4Endpoint(
          id: 'create-list',
          title: 'Create list (POST)',
          description:
              'Create a new curated list under the authenticated user account.',
          category: 'Lists',
          path: '/list',
          method: TmdbV4HttpMethod.post,
          supportsExecution: false,
          notes:
              'POST endpoints require user-scoped authentication and are showcased as documentation only.',
        ),
        TmdbV4Endpoint(
          id: 'delete-list',
          title: 'Delete list (DELETE)',
          description:
              'Remove a curated list owned by the authenticated user account.',
          category: 'Lists',
          path: '/list/1',
          method: TmdbV4HttpMethod.delete,
          supportsExecution: false,
          notes:
              'Requires write-scoped TMDB v4 token. Disabled in the in-app explorer.',
        ),
      ],
    ),
    TmdbV4EndpointGroup(
      name: 'Account sandbox',
      description:
          'Account endpoints that require a user-scoped access token. They are documented but disabled for security.',
      endpoints: const [
        TmdbV4Endpoint(
          id: 'account-details',
          title: 'Account details',
          description:
              'Fetches profile, language, and region preferences for the authenticated account.',
          category: 'Account',
          path: '/account',
          supportsExecution: false,
          notes:
              'Requires a user-generated access token. Provide your own token via --dart-define to enable.',
        ),
        TmdbV4Endpoint(
          id: 'account-lists',
          title: 'Account lists',
          description: 'Lists created by the authenticated account.',
          category: 'Account',
          path: '/account/{account_id}/lists',
          supportsExecution: false,
          notes:
              'Account scoped endpoints need a valid account id and user token. Replace {account_id} manually if you override execution.',
        ),
        TmdbV4Endpoint(
          id: 'account-favorites',
          title: 'Favorite movies and TV',
          description: 'Combined favorites for an authenticated account.',
          category: 'Account',
          path: '/account/{account_id}/favorites',
          supportsExecution: false,
        ),
        TmdbV4Endpoint(
          id: 'account-recommendations',
          title: 'Account recommendations',
          description:
              'Personalized recommendations generated from the account history.',
          category: 'Account',
          path: '/account/{account_id}/recommendations',
          supportsExecution: false,
        ),
      ],
    ),
  ];
}
