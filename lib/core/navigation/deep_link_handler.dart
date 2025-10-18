import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';

import 'deep_link_parser.dart';

/// Coordinates receiving and parsing deep links for the application.
class DeepLinkHandler extends ChangeNotifier {
  DeepLinkHandler({
    Stream<Uri?>? uriStream,
    Future<Uri?> Function()? initialUriGetter,
  }) : _uriStream = uriStream ?? uriLinkStream,
       _initialUriGetter = initialUriGetter ?? getInitialUri;

  final Stream<Uri?> _uriStream;
  final Future<Uri?> Function() _initialUriGetter;

  StreamSubscription<Uri?>? _subscription;
  DeepLinkData? _pendingLink;
  Object? _lastError;
  bool _initialized = false;

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

  /// Manually queue a deep link event (used by push notifications).
  void enqueueLink(DeepLinkData link) {
    _pendingLink = link;
    notifyListeners();
  }

  /// Parses the provided [uri] and queues it when valid.
  void enqueueUri(Uri uri) => _setPendingFromUri(uri);

  /// Consumes the currently pending deep link, if any.
  DeepLinkData? consumePendingLink() {
    final link = _pendingLink;
    _pendingLink = null;
    return link;
  }

  /// Injects a deep link directly into the handler.
  ///
  /// This is primarily intended for tests where platform deep link
  /// integrations are not available.
  @visibleForTesting
  void debugInjectPendingLink(DeepLinkData link) {
    _pendingLink = link;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Builds a custom-scheme URI for a movie deep link.
  static Uri buildMovieUri(int movieId, {bool universal = false}) {
    final uri = DeepLinkBuilder.movie(movieId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a custom-scheme URI for a TV show deep link.
  static Uri buildTvShowUri(int tvId, {bool universal = false}) {
    final uri = DeepLinkBuilder.tvShow(tvId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a custom-scheme URI for a TV season deep link.
  static Uri buildSeasonUri(
    int tvId,
    int seasonNumber, {
    bool universal = false,
  }) {
    final uri = DeepLinkBuilder.season(tvId, seasonNumber);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a custom-scheme URI for a TV episode deep link.
  static Uri buildEpisodeUri(
    int tvId,
    int seasonNumber,
    int episodeNumber, {
    bool universal = false,
  }) {
    final uri = DeepLinkBuilder.episode(tvId, seasonNumber, episodeNumber);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a custom-scheme URI for a person deep link.
  static Uri buildPersonUri(int personId, {bool universal = false}) {
    final uri = DeepLinkBuilder.person(personId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a custom-scheme URI for a company deep link.
  static Uri buildCompanyUri(int companyId, {bool universal = false}) {
    final uri = DeepLinkBuilder.company(companyId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a custom-scheme URI for a collection deep link.
  static Uri buildCollectionUri(int collectionId, {bool universal = false}) {
    final uri = DeepLinkBuilder.collection(collectionId);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }

  /// Builds a custom-scheme URI for a search deep link.
  static Uri buildSearchUri(String query, {bool universal = false}) {
    final uri = DeepLinkBuilder.search(query);
    return universal ? uri : DeepLinkBuilder.asCustomScheme(uri);
  }
}
