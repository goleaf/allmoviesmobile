import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import '../../data/models/episode_model.dart';
import '../../data/tmdb_repository.dart';
import '../../presentation/navigation/episode_detail_args.dart';
import '../../presentation/navigation/season_detail_args.dart';
import '../../presentation/screens/collections/collection_detail_screen.dart';
import '../../presentation/screens/company_detail/company_detail_screen.dart';
import '../../presentation/screens/episode_detail/episode_detail_screen.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
import '../../presentation/screens/person_detail/person_detail_screen.dart';
import '../../presentation/screens/season_detail/season_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/tv_detail/tv_detail_screen.dart';
import 'deep_link_parser.dart';

/// Handles incoming deep links (custom scheme and universal links) and
/// navigates to the correct screen inside the application.
class DeepLinkHandler {
  DeepLinkHandler({
    required GlobalKey<NavigatorState> navigatorKey,
    required TmdbRepository repository,
  })  : _navigatorKey = navigatorKey,
        _repository = repository;

  final GlobalKey<NavigatorState> _navigatorKey;
  final TmdbRepository _repository;
  StreamSubscription<Uri?>? _subscription;
  String? _lastProcessedRawLink;

  /// Subscribes to `uni_links` streams and handles the initial deep link.
  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    await _handleInitialUri();
    _subscription = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          unawaited(_handleUri(uri));
        }
      },
      onError: (Object error) {
        _showSnackBar(
          'Failed to process deep link: $error',
        );
      },
    );
  }

  /// Cancels the underlying deep link subscription.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleInitialUri() async {
    try {
      final Uri? initialUri = await getInitialUri();
      if (initialUri != null) {
        await _handleUri(initialUri);
      }
    } on Exception catch (error) {
      _showSnackBar('Unable to parse initial deep link: $error');
    }
  }

  Future<void> _handleUri(Uri uri) async {
    final String rawLink = uri.toString();
    if (_lastProcessedRawLink == rawLink) {
      return;
    }
    _lastProcessedRawLink = rawLink;

    final DeepLinkData? data = DeepLinkParser.parseUri(uri);
    if (data == null) {
      _showSnackBar('Unsupported deep link: $rawLink');
      return;
    }

    await _openDeepLink(data);
  }

  Future<void> _openDeepLink(DeepLinkData data) async {
    final NavigatorState? navigator = _navigatorKey.currentState;
    final BuildContext? context = _navigatorKey.currentContext;
    if (navigator == null || context == null) {
      return;
    }

    await Future<void>.delayed(Duration.zero);

    switch (data.type) {
      case DeepLinkType.movie:
        navigator.pushNamed(
          MovieDetailScreen.routeName,
          arguments: data.id ?? 0,
        );
        break;
      case DeepLinkType.tvShow:
        navigator.pushNamed(
          TVDetailScreen.routeName,
          arguments: data.id ?? 0,
        );
        break;
      case DeepLinkType.season:
        if (data.id == null || data.seasonNumber == null) {
          _showSnackBar('Missing identifiers for season deep link.');
          return;
        }
        navigator.pushNamed(
          SeasonDetailScreen.routeName,
          arguments: SeasonDetailArgs(
            tvId: data.id!,
            seasonNumber: data.seasonNumber!,
          ),
        );
        break;
      case DeepLinkType.episode:
        if (data.id == null ||
            data.seasonNumber == null ||
            data.episodeNumber == null) {
          _showSnackBar('Missing identifiers for episode deep link.');
          return;
        }
        final Episode? episode = await _loadEpisode(
          tvId: data.id!,
          seasonNumber: data.seasonNumber!,
          episodeNumber: data.episodeNumber!,
        );
        if (episode == null) {
          _showSnackBar('Episode not found.');
          return;
        }
        navigator.pushNamed(
          EpisodeDetailScreen.routeName,
          arguments: EpisodeDetailArgs(tvId: data.id!, episode: episode),
        );
        break;
      case DeepLinkType.person:
        if (data.id == null) {
          _showSnackBar('Missing person identifier.');
          return;
        }
        navigator.pushNamed(
          PersonDetailScreen.routeName,
          arguments: data.id!,
        );
        break;
      case DeepLinkType.company:
        if (data.id == null) {
          _showSnackBar('Missing company identifier.');
          return;
        }
        navigator.pushNamed(
          CompanyDetailScreen.routeName,
          arguments: data.id!,
        );
        break;
      case DeepLinkType.collection:
        if (data.id == null) {
          _showSnackBar('Missing collection identifier.');
          return;
        }
        navigator.pushNamed(
          CollectionDetailScreen.routeName,
          arguments: data.id!,
        );
        break;
      case DeepLinkType.search:
        final String? query = data.searchQuery;
        if (query == null || query.isEmpty) {
          _showSnackBar('Missing search query.');
          return;
        }
        navigator.pushNamed(
          SearchScreen.routeName,
          arguments: query,
        );
        break;
    }

    _announceNavigation(data, context);
  }

  /// TMDB Endpoint: `GET /3/tv/{tv_id}/season/{season_number}/episode/{episode_number}`
  /// Retrieves an episode payload (JSON with episode metadata, credits, videos)
  /// and maps it into the strongly typed [Episode] model.
  Future<Episode?> _loadEpisode({
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    try {
      return await _repository.fetchTvEpisode(
        tvId,
        seasonNumber,
        episodeNumber,
      );
    } catch (error) {
      _showSnackBar('Failed to load episode: $error');
      return null;
    }
  }

  void _announceNavigation(DeepLinkData data, BuildContext context) {
    final String label = data.type.name.replaceAll('_', ' ');
    _showSnackBar('Opened deep link for ${label.toLowerCase()}');
  }

  void _showSnackBar(String message) {
    final BuildContext? context = _navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
