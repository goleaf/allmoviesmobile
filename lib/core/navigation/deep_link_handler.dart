import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import '../../data/models/company_model.dart';
import '../../data/models/episode_model.dart';
import '../../data/models/movie.dart';
import '../../data/models/season_model.dart';
import '../../data/models/person_model.dart';
import '../../data/tmdb_repository.dart';
import '../../presentation/navigation/season_detail_args.dart';
import '../../presentation/screens/collections/collection_detail_screen.dart';
import '../../presentation/screens/company_detail/company_detail_screen.dart';
import '../../presentation/screens/episode_detail/episode_detail_screen.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
import '../../presentation/screens/person_detail/person_detail_screen.dart';
import '../../presentation/screens/season_detail/season_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/tv_detail/tv_detail_screen.dart';

class DeepLinkHandler {
  DeepLinkHandler({
    required GlobalKey<NavigatorState> navigatorKey,
    required TmdbRepository repository,
  })  : _navigatorKey = navigatorKey,
        _repository = repository;

  static const String customScheme = 'allmovies';
  static const String customHost = 'app';
  static const String universalHost = 'allmovies.app';

  final GlobalKey<NavigatorState> _navigatorKey;
  final TmdbRepository _repository;

  StreamSubscription<Uri?>? _subscription;
  Uri? _pendingInitialUri;
  String? _lastHandled;

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _pendingInitialUri = initialUri;
        _schedulePendingUriProcessing();
      }
    } on Exception catch (error) {
      debugPrint('Failed to read initial deep link: $error');
    }

    _subscription = uriLinkStream.listen(
      (uri) {
        if (uri == null) {
          return;
        }
        _handleIncoming(uri);
      },
      onError: (Object error) {
        debugPrint('Deep link stream error: $error');
      },
    );
  }

  void dispose() {
    unawaited(_subscription?.cancel());
  }

  Future<void> handleUri(Uri uri) async {
    if (!_supportsUri(uri)) {
      return;
    }

    final match = _parse(uri);
    if (match == null) {
      return;
    }

    if (_lastHandled == uri.toString()) {
      return;
    }
    _lastHandled = uri.toString();

    final navigator = _navigatorKey.currentState;
    final context = _navigatorKey.currentContext;

    if (navigator == null || context == null) {
      _pendingInitialUri = uri;
      _schedulePendingUriProcessing();
      return;
    }

    try {
      switch (match.type) {
        case _DeepLinkType.movie:
          await _openMovie(navigator, match.id);
          break;
        case _DeepLinkType.tv:
          await _openTv(navigator, match.id);
          break;
        case _DeepLinkType.season:
          await _openSeason(navigator, match.id, match.seasonNumber!);
          break;
        case _DeepLinkType.episode:
          await _openEpisode(
            navigator,
            match.id,
            match.seasonNumber!,
            match.episodeNumber!,
          );
          break;
        case _DeepLinkType.person:
          await _openPerson(navigator, match.id);
          break;
        case _DeepLinkType.company:
          await _openCompany(navigator, match.id);
          break;
        case _DeepLinkType.collection:
          await _openCollection(navigator, match.id);
          break;
        case _DeepLinkType.search:
          await _openSearch(navigator, match.query ?? '');
          break;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to handle deep link $uri: $error\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open link. Please try again.')),
        );
      }
    }
  }

  void _handleIncoming(Uri uri) {
    unawaited(handleUri(uri));
  }

  void _schedulePendingUriProcessing() {
    final uri = _pendingInitialUri;
    if (uri == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = _pendingInitialUri;
      _pendingInitialUri = null;
      if (pending != null) {
        _handleIncoming(pending);
      }
    });
  }

  bool _supportsUri(Uri uri) {
    if (!uri.hasScheme) {
      return false;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme == customScheme) {
      return true;
    }
    if (scheme == 'https' || scheme == 'http') {
      final host = uri.host.toLowerCase();
      return host == universalHost || host.endsWith('.$universalHost');
    }
    return false;
  }

  _DeepLinkMatch? _parse(Uri uri) {
    final pathSegments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment.toLowerCase())
        .toList(growable: false);

    if (pathSegments.isEmpty) {
      return null;
    }

    switch (pathSegments.first) {
      case 'movie':
        if (pathSegments.length >= 2) {
          final id = int.tryParse(pathSegments[1]);
          if (id != null) {
            return _DeepLinkMatch.movie(id);
          }
        }
        break;
      case 'tv':
        if (pathSegments.length == 2) {
          final id = int.tryParse(pathSegments[1]);
          if (id != null) {
            return _DeepLinkMatch.tv(id);
          }
        }
        if (pathSegments.length >= 4 && pathSegments[2] == 'season') {
          final id = int.tryParse(pathSegments[1]);
          final seasonNumber = int.tryParse(pathSegments[3]);
          if (id == null || seasonNumber == null) {
            break;
          }
          if (pathSegments.length >= 6 && pathSegments[4] == 'episode') {
            final episodeNumber = int.tryParse(pathSegments[5]);
            if (episodeNumber != null) {
              return _DeepLinkMatch.episode(
                id,
                seasonNumber,
                episodeNumber,
              );
            }
          }
          return _DeepLinkMatch.season(id, seasonNumber);
        }
        break;
      case 'person':
        if (pathSegments.length >= 2) {
          final id = int.tryParse(pathSegments[1]);
          if (id != null) {
            return _DeepLinkMatch.person(id);
          }
        }
        break;
      case 'company':
        if (pathSegments.length >= 2) {
          final id = int.tryParse(pathSegments[1]);
          if (id != null) {
            return _DeepLinkMatch.company(id);
          }
        }
        break;
      case 'collection':
        if (pathSegments.length >= 2) {
          final id = int.tryParse(pathSegments[1]);
          if (id != null) {
            return _DeepLinkMatch.collection(id);
          }
        }
        break;
      case 'search':
        final query = uri.queryParameters['q'] ?? uri.queryParameters['query'];
        if (query != null && query.isNotEmpty) {
          return _DeepLinkMatch.search(query);
        }
        if (pathSegments.length >= 2) {
          final encodedQuery = uri.pathSegments[1];
          if (encodedQuery.isNotEmpty) {
            return _DeepLinkMatch.search(Uri.decodeComponent(encodedQuery));
          }
        }
        break;
    }

    return null;
  }

  Future<void> _openMovie(NavigatorState navigator, int movieId) {
    final movie = Movie(
      id: movieId,
      title: 'Movie #$movieId',
      mediaType: 'movie',
    );
    return navigator.push(
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
        settings: RouteSettings(name: '/movie/$movieId'),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openTv(NavigatorState navigator, int tvId) {
    final tvShow = Movie(
      id: tvId,
      title: 'TV Show #$tvId',
      mediaType: 'tv',
    );
    return navigator.push(
      MaterialPageRoute(
        builder: (_) => TVDetailScreen(tvShow: tvShow),
        settings: RouteSettings(name: '/tv/$tvId'),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openSeason(
    NavigatorState navigator,
    int tvId,
    int seasonNumber,
  ) {
    return navigator.push(
      MaterialPageRoute(
        builder: (_) => SeasonDetailScreen(
          args: SeasonDetailArgs(tvId: tvId, seasonNumber: seasonNumber),
        ),
        settings: RouteSettings(name: '/tv/$tvId/season/$seasonNumber'),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openEpisode(
    NavigatorState navigator,
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    Season season;
    try {
      season = await _repository.fetchTvSeason(tvId, seasonNumber);
    } on Exception {
      rethrow;
    }

    final episode = season.episodes.firstWhere(
      (candidate) => candidate.episodeNumber == episodeNumber,
      orElse: () => throw StateError(
        'Episode S$seasonNumber E$episodeNumber not found for TV $tvId',
      ),
    );

    return navigator.push(
      MaterialPageRoute(
        builder: (_) => EpisodeDetailScreen(
          episode: episode,
          tvId: tvId,
        ),
        settings: RouteSettings(
          name: '/tv/$tvId/season/$seasonNumber/episode/$episodeNumber',
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openPerson(NavigatorState navigator, int personId) {
    return navigator.push(
      MaterialPageRoute(
        builder: (_) => PersonDetailScreen(personId: personId),
        settings: RouteSettings(name: '/person/$personId'),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openCompany(NavigatorState navigator, int companyId) {
    final company = Company(id: companyId, name: 'Company #$companyId');
    return navigator.push(
      MaterialPageRoute(
        builder: (_) => CompanyDetailScreen(initialCompany: company),
        settings: RouteSettings(name: '/company/$companyId'),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openCollection(NavigatorState navigator, int collectionId) {
    return navigator.push(
      MaterialPageRoute(
        builder: (_) => CollectionDetailScreen(
          collectionId: collectionId,
          initialName: 'Collection #$collectionId',
        ),
        settings: RouteSettings(name: '/collection/$collectionId'),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openSearch(NavigatorState navigator, String query) {
    return navigator.push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: query),
        settings: RouteSettings(name: '/search?q=$query'),
      ),
    );
  }

  static Uri buildMovieUri(int movieId, {bool universal = false}) =>
      _buildUri(['movie', '$movieId'], universal: universal);

  static Uri buildTvUri(int tvId, {bool universal = false}) =>
      _buildUri(['tv', '$tvId'], universal: universal);

  static Uri buildSeasonUri(
    int tvId,
    int seasonNumber, {
    bool universal = false,
  }) =>
      _buildUri(
        ['tv', '$tvId', 'season', '$seasonNumber'],
        universal: universal,
      );

  static Uri buildEpisodeUri(
    int tvId,
    int seasonNumber,
    int episodeNumber, {
    bool universal = false,
  }) =>
      _buildUri(
        ['tv', '$tvId', 'season', '$seasonNumber', 'episode', '$episodeNumber'],
        universal: universal,
      );

  static Uri buildPersonUri(int personId, {bool universal = false}) =>
      _buildUri(['person', '$personId'], universal: universal);

  static Uri buildCompanyUri(int companyId, {bool universal = false}) =>
      _buildUri(['company', '$companyId'], universal: universal);

  static Uri buildCollectionUri(int collectionId, {bool universal = false}) =>
      _buildUri(['collection', '$collectionId'], universal: universal);

  static Uri buildSearchUri(String query, {bool universal = false}) =>
      _buildUri(
        ['search'],
        universal: universal,
        queryParameters: {'q': query},
      );

  static Uri _buildUri(
    List<String> segments, {
    required bool universal,
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri(
      scheme: universal ? 'https' : customScheme,
      host: universal ? universalHost : customHost,
      pathSegments: segments,
      queryParameters: queryParameters,
    );
  }
}

enum _DeepLinkType {
  movie,
  tv,
  season,
  episode,
  person,
  company,
  collection,
  search,
}

class _DeepLinkMatch {
  const _DeepLinkMatch._({
    required this.type,
    this.id,
    this.seasonNumber,
    this.episodeNumber,
    this.query,
  });

  factory _DeepLinkMatch.movie(int movieId) =>
      _DeepLinkMatch._(type: _DeepLinkType.movie, id: movieId);

  factory _DeepLinkMatch.tv(int tvId) =>
      _DeepLinkMatch._(type: _DeepLinkType.tv, id: tvId);

  factory _DeepLinkMatch.season(int tvId, int seasonNumber) =>
      _DeepLinkMatch._(
        type: _DeepLinkType.season,
        id: tvId,
        seasonNumber: seasonNumber,
      );

  factory _DeepLinkMatch.episode(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) =>
      _DeepLinkMatch._(
        type: _DeepLinkType.episode,
        id: tvId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );

  factory _DeepLinkMatch.person(int personId) =>
      _DeepLinkMatch._(type: _DeepLinkType.person, id: personId);

  factory _DeepLinkMatch.company(int companyId) =>
      _DeepLinkMatch._(type: _DeepLinkType.company, id: companyId);

  factory _DeepLinkMatch.collection(int collectionId) =>
      _DeepLinkMatch._(type: _DeepLinkType.collection, id: collectionId);

  factory _DeepLinkMatch.search(String query) =>
      _DeepLinkMatch._(type: _DeepLinkType.search, query: query);

  final _DeepLinkType type;
  final int? id;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? query;
}
