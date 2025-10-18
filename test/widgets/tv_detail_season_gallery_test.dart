import 'dart:collection';

import 'package:allmovies_mobile/data/models/episode_model.dart';
import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/season_model.dart';
import 'package:allmovies_mobile/data/models/tv_detailed_model.dart';
import 'package:allmovies_mobile/data/models/watch_provider_model.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/services/notification_preferences_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:allmovies_mobile/providers/favorites_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/providers/watchlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ImageResponse {
  _ImageResponse.success(this.images) : error = null;
  _ImageResponse.error(this.error) : images = null;

  final MediaImages? images;
  final Object? error;
}

class _TvDetailRepoStub extends TmdbRepository {
  _TvDetailRepoStub({
    required this.details,
    required this.seasonResponses,
  }) : super(apiKey: 'test');

  final TVDetailed details;
  final Map<int, Season> seasonResponses;
  final Map<int, Queue<_ImageResponse>> _imageQueues = {};

  void setImageResponses(int seasonNumber, List<_ImageResponse> responses) {
    _imageQueues[seasonNumber] = Queue<_ImageResponse>.from(responses);
  }

  @override
  Future<TVDetailed> fetchTvDetails(
    int tvId, {
    bool forceRefresh = false,
  }) async => details;

  @override
  Future<Season> fetchTvSeason(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async => seasonResponses[seasonNumber]!;

  @override
  Future<MediaImages> fetchTvSeasonImages(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    final queue = _imageQueues.putIfAbsent(seasonNumber, Queue.new);
    if (queue.isEmpty) {
      return MediaImages.empty();
    }
    final response = queue.removeFirst();
    if (response.error != null) {
      throw response.error!;
    }
    return response.images ?? MediaImages.empty();
  }

  @override
  Future<Map<String, WatchProviderResults>> fetchTvWatchProviders(int tvId,
          {bool forceRefresh = false}) async =>
      {};
}

Future<void> _pumpDetailScreen(
  WidgetTester tester,
  _TvDetailRepoStub repository,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService(prefs);
  final notificationPrefs = NotificationPreferences(prefs);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<TmdbRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storage)),
        ChangeNotifierProvider(
          create: (_) => WatchlistProvider(
            storage,
            notificationPreferences: notificationPrefs,
          ),
        ),
        ChangeNotifierProvider(create: (_) => WatchRegionProvider(prefs)),
      ],
      child: MaterialApp(
        home: TVDetailScreen(
          tvShow: const Movie(id: 10, title: 'Demo Show', mediaType: 'tv'),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _scrollToGallery(WidgetTester tester) async {
  final finder = find.text('Season images');
  if (finder.evaluate().isNotEmpty) {
    return;
  }
  await tester.scrollUntilVisible(
    find.text('Season images'),
    400,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  const poster = ImageModel(
    filePath: '/poster.jpg',
    width: 500,
    height: 750,
    aspectRatio: 0.66,
  );

  final episode = Episode(
    id: 100,
    name: 'Pilot',
    episodeNumber: 1,
    seasonNumber: 1,
  );

  final season = Season(
    id: 1,
    name: 'Season 1',
    seasonNumber: 1,
    episodeCount: 1,
    episodes: [episode],
  );

  final details = TVDetailed(
    id: 10,
    name: 'Demo Show',
    originalName: 'Demo Show',
    voteAverage: 8.5,
    voteCount: 150,
    seasons: [season],
  );

  testWidgets('displays galleries when images load successfully',
      (tester) async {
    final repo = _TvDetailRepoStub(
      details: details,
      seasonResponses: {1: season},
    )..setImageResponses(
        1,
        [
          _ImageResponse.success(
            MediaImages(
              posters: [poster],
              backdrops: [poster],
              stills: [poster],
            ),
          ),
        ],
      );

    await _pumpDetailScreen(tester, repo);
    await _scrollToGallery(tester);

    expect(find.text('Season images'), findsOneWidget);
    expect(find.text('Posters'), findsOneWidget);
    expect(find.text('Backdrops'), findsOneWidget);
    expect(find.text('Stills'), findsOneWidget);
  });

  testWidgets('shows empty state when no images are returned', (tester) async {
    final repo = _TvDetailRepoStub(
      details: details,
      seasonResponses: {1: season},
    )..setImageResponses(1, [_ImageResponse.success(MediaImages.empty())]);

    await _pumpDetailScreen(tester, repo);
    await _scrollToGallery(tester);

    expect(find.text('No images available for this season'), findsOneWidget);
  });

  testWidgets('shows error state and retries image loading', (tester) async {
    final repo = _TvDetailRepoStub(
      details: details,
      seasonResponses: {1: season},
    )
      ..setImageResponses(1, [
        _ImageResponse.error(
          const TmdbException('Failed to load season images'),
        ),
        _ImageResponse.success(MediaImages(posters: [poster])),
      ]);

    await _pumpDetailScreen(tester, repo);
    await _scrollToGallery(tester);

    expect(find.text('Failed to load season images'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pumpAndSettle();
    await _scrollToGallery(tester);

    expect(find.text('Season images'), findsOneWidget);
    expect(find.text('Posters'), findsOneWidget);
  });
}
