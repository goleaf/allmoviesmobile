import 'package:flutter/foundation.dart';

/// Supported deep link destinations within the app.
enum DeepLinkType {
  movie,
  tvShow,
  season,
  episode,
  person,
  company,
  collection,
  search,
}

/// Configuration values used when building or matching deep link URLs.
class DeepLinkConfig {
  DeepLinkConfig._();

  /// Primary HTTP(S) scheme used for shareable links.
  static const String primaryScheme = 'https';

  /// Alternative custom scheme that can be used internally.
  static const String alternateScheme = 'allmovies';

  /// Domain that hosts the shareable deep links.
  static const String host = 'allmovies.app';

  /// Additional host variants that we should recognise.
  static const List<String> additionalHosts = <String>[
    'www.allmovies.app',
  ];

  /// Builds a fully qualified deep link URI.
  static Uri buildUri(
    List<String> pathSegments, {
    Map<String, String>? queryParameters,
    bool useAlternateScheme = false,
  }) {
    final sanitizedSegments = pathSegments.where((segment) => segment.isNotEmpty);
    final sanitizedQuery = queryParameters == null || queryParameters.isEmpty
        ? null
        : Map<String, String>.fromEntries(
            queryParameters.entries.where(
              (entry) => entry.key.isNotEmpty,
            ),
          );

    return Uri(
      scheme: useAlternateScheme ? alternateScheme : primaryScheme,
      host: useAlternateScheme ? null : host,
      pathSegments: sanitizedSegments.toList(),
      queryParameters: sanitizedQuery,
    );
  }

  /// Returns true when the provided [uri] should be handled by the app.
  static bool matches(Uri uri) {
    if (!uri.hasScheme && uri.pathSegments.isNotEmpty) {
      // Relative path (e.g. "/movie/123") should be considered valid.
      return true;
    }

    if (uri.scheme == alternateScheme) {
      return true;
    }

    if (uri.scheme == primaryScheme &&
        (uri.host == host || additionalHosts.contains(uri.host))) {
      return true;
    }

    return false;
  }
}

/// Parsed deep link data.
@immutable
class DeepLinkData {
  const DeepLinkData._({
    required this.type,
    this.id,
    this.seasonNumber,
    this.episodeNumber,
    this.searchQuery,
  });

  /// The destination content type.
  final DeepLinkType type;

  /// Identifier for the requested content.
  ///
  /// - Movie: movie id
  /// - TV show: tv id
  /// - Season / Episode: tv id
  /// - Person / Company / Collection: entity id
  final int? id;

  /// Season number for TV season or episode deep links.
  final int? seasonNumber;

  /// Episode number for episode deep links.
  final int? episodeNumber;

  /// Search query for search deep links.
  final String? searchQuery;

  factory DeepLinkData.movie(int movieId) => DeepLinkData._(
        type: DeepLinkType.movie,
        id: movieId,
      );

  factory DeepLinkData.tvShow(int tvId) => DeepLinkData._(
        type: DeepLinkType.tvShow,
        id: tvId,
      );

  factory DeepLinkData.season(int tvId, int seasonNumber) => DeepLinkData._(
        type: DeepLinkType.season,
        id: tvId,
        seasonNumber: seasonNumber,
      );

  factory DeepLinkData.episode(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) =>
      DeepLinkData._(
        type: DeepLinkType.episode,
        id: tvId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );

  factory DeepLinkData.person(int personId) => DeepLinkData._(
        type: DeepLinkType.person,
        id: personId,
      );

  factory DeepLinkData.company(int companyId) => DeepLinkData._(
        type: DeepLinkType.company,
        id: companyId,
      );

  factory DeepLinkData.collection(int collectionId) => DeepLinkData._(
        type: DeepLinkType.collection,
        id: collectionId,
      );

  factory DeepLinkData.search(String query) => DeepLinkData._(
        type: DeepLinkType.search,
        searchQuery: query,
      );
}

/// Parses incoming deep link URIs into strongly typed data.
class DeepLinkParser {
  const DeepLinkParser._();

  /// Parses a raw link string and returns the corresponding [DeepLinkData].
  static DeepLinkData? parse(String? rawLink) {
    if (rawLink == null || rawLink.trim().isEmpty) {
      return null;
    }
    return parseUri(Uri.parse(rawLink));
  }

  /// Parses a [Uri] and returns the corresponding [DeepLinkData].
  static DeepLinkData? parseUri(Uri uri) {
    if (!DeepLinkConfig.matches(uri)) {
      return null;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      return _matchSearch(uri);
    }

    switch (segments.first) {
      case 'movie':
        if (segments.length >= 2) {
          final id = int.tryParse(segments[1]);
          if (id != null) {
            return DeepLinkData.movie(id);
          }
        }
        return null;
      case 'tv':
        if (segments.length >= 2) {
          final tvId = int.tryParse(segments[1]);
          if (tvId == null) {
            return null;
          }
          if (segments.length >= 4 && segments[2] == 'season') {
            final seasonNumber = int.tryParse(segments[3]);
            if (seasonNumber == null) {
              return null;
            }
            if (segments.length >= 6 && segments[4] == 'episode') {
              final episodeNumber = int.tryParse(segments[5]);
              if (episodeNumber == null) {
                return null;
              }
              return DeepLinkData.episode(tvId, seasonNumber, episodeNumber);
            }
            return DeepLinkData.season(tvId, seasonNumber);
          }
          return DeepLinkData.tvShow(tvId);
        }
        return null;
      case 'person':
        return _parseSingleId(segments, DeepLinkData.person);
      case 'company':
        return _parseSingleId(segments, DeepLinkData.company);
      case 'collection':
        return _parseSingleId(segments, DeepLinkData.collection);
      case 'search':
        return _matchSearch(uri, fallbackSegments: segments);
      default:
        return null;
    }
  }

  static DeepLinkData? _matchSearch(
    Uri uri, {
    List<String>? fallbackSegments,
  }) {
    final query = uri.queryParameters['q'] ??
        (fallbackSegments != null && fallbackSegments.length > 1
            ? fallbackSegments.sublist(1).join(' ').trim()
            : null);

    if (query == null || query.isEmpty) {
      return null;
    }
    return DeepLinkData.search(query);
  }

  static DeepLinkData? _parseSingleId(
    List<String> segments,
    DeepLinkData Function(int id) builder,
  ) {
    if (segments.length >= 2) {
      final id = int.tryParse(segments[1]);
      if (id != null) {
        return builder(id);
      }
    }
    return null;
  }
}

/// Helper for building shareable deep link URLs.
class DeepLinkBuilder {
  const DeepLinkBuilder._();

  static Uri movie(int movieId) =>
      DeepLinkConfig.buildUri(<String>['movie', '$movieId']);

  static Uri tvShow(int tvId) =>
      DeepLinkConfig.buildUri(<String>['tv', '$tvId']);

  static Uri season(int tvId, int seasonNumber) => DeepLinkConfig.buildUri(
        <String>['tv', '$tvId', 'season', '$seasonNumber'],
      );

  static Uri episode(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) =>
      DeepLinkConfig.buildUri(
        <String>[
          'tv',
          '$tvId',
          'season',
          '$seasonNumber',
          'episode',
          '$episodeNumber',
        ],
      );

  static Uri person(int personId) =>
      DeepLinkConfig.buildUri(<String>['person', '$personId']);

  static Uri company(int companyId) =>
      DeepLinkConfig.buildUri(<String>['company', '$companyId']);

  static Uri collection(int collectionId) =>
      DeepLinkConfig.buildUri(<String>['collection', '$collectionId']);

  static Uri search(String query) => DeepLinkConfig.buildUri(
        const <String>['search'],
        queryParameters: <String, String>{'q': query},
      );

  /// Builds a custom-scheme variant of the provided deep link [uri].
  static Uri asCustomScheme(Uri uri) {
    return DeepLinkConfig.buildUri(
      uri.pathSegments,
      queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
      useAlternateScheme: true,
    );
  }
}
