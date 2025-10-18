import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uni_links/uni_links.dart';

import 'deep_link_parser.dart';
import '../../data/tmdb_repository.dart';

/// Coordinates receiving and parsing deep links for the application.
class DeepLinkHandler extends ChangeNotifier {
  DeepLinkHandler({
    Stream<Uri?>? uriStream,
    Future<Uri?> Function()? initialUriGetter,
    GlobalKey<NavigatorState>? navigatorKey,
    TmdbRepository? repository,
  })  : _uriStream = uriStream ?? uriLinkStream,
        _initialUriGetter = initialUriGetter ?? getInitialUri,
        _navigatorKey = navigatorKey,
        _repository = repository;

  final Stream<Uri?> _uriStream;
  final Future<Uri?> Function() _initialUriGetter;
  final GlobalKey<NavigatorState>? _navigatorKey;
  final TmdbRepository? _repository;

  StreamSubscription<Uri?>? _subscription;
  DeepLinkData? _pendingLink;
  Object? _lastError;
  bool _initialized = false;

  /// Navigator exposed for routing from outside the widget tree.
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  /// Repository used for resolving deep-linked content when needed.
  TmdbRepository? get repository => _repository;

  /// Pending deep link data awaiting consumption.
  DeepLinkData? get pendingLink => _pendingLink;

  /// The last error encountered while listening for deep links.
  Object? get lastError => _lastError;

  bool get isInitialized => _initialized;

  /// Starts listening for incoming deep links.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final initialUri = await _initialUriGetter();
      _setPendingFromUri(initialUri);
    } on Exception catch (error) {
      _lastError = error;
      notifyListeners();
    }

    _subscription = _uriStream.listen(
      _setPendingFromUri,
      onError: (Object error) {
        _lastError = error;
        notifyListeners();
      },
    );
  }

  void _setPendingFromUri(Uri? uri) {
    final data = uri == null ? null : DeepLinkParser.parseUri(uri);
    if (data == null) {
      return;
    }
    _pendingLink = data;
    notifyListeners();
  }

  /// Consumes the currently pending deep link, if any.
  DeepLinkData? consumePendingLink() {
    final link = _pendingLink;
    _pendingLink = null;
    return link;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Builds a movie deep link with either universal (HTTPS) or custom schemes.
  static Uri buildMovieUri(int movieId, {bool universal = false}) {
    final uri = DeepLinkBuilder.movie(movieId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a TV show deep link.
  static Uri buildTvShowUri(int tvId, {bool universal = false}) {
    final uri = DeepLinkBuilder.tvShow(tvId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a TV season deep link.
  static Uri buildSeasonUri(
    int tvId,
    int seasonNumber, {
    bool universal = false,
  }) {
    final uri = DeepLinkBuilder.season(tvId, seasonNumber);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a TV episode deep link.
  static Uri buildEpisodeUri(
    int tvId,
    int seasonNumber,
    int episodeNumber, {
    bool universal = false,
  }) {
    final uri = DeepLinkBuilder.episode(tvId, seasonNumber, episodeNumber);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a person deep link.
  static Uri buildPersonUri(int personId, {bool universal = false}) {
    final uri = DeepLinkBuilder.person(personId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a company deep link.
  static Uri buildCompanyUri(int companyId, {bool universal = false}) {
    final uri = DeepLinkBuilder.company(companyId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a collection deep link.
  static Uri buildCollectionUri(int collectionId, {bool universal = false}) {
    final uri = DeepLinkBuilder.collection(collectionId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }
}
