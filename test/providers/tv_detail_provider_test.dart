import 'dart:collection';

import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/data/models/season_model.dart';
import 'package:allmovies_mobile/data/models/tv_detailed_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/tv_detail_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _ImageResponse {
  _ImageResponse.success(this.images) : error = null;
  _ImageResponse.error(this.error) : images = null;

  final MediaImages? images;
  final Object? error;
}

class _FakeTvRepository extends TmdbRepository {
  _FakeTvRepository({
    required this.details,
    required this.seasonResponses,
  }) : super(apiKey: 'test');

  final TVDetailed details;
  final Map<int, Season> seasonResponses;
  final Map<int, Queue<_ImageResponse>> _imageQueues = {};

  int detailsCalls = 0;
  final Map<int, int> seasonCalls = {};
  final Map<int, int> seasonImageCalls = {};

  void setImageResponses(int seasonNumber, List<_ImageResponse> responses) {
    _imageQueues[seasonNumber] = Queue<_ImageResponse>.from(responses);
  }

  @override
  Future<TVDetailed> fetchTvDetails(
    int tvId, {
    bool forceRefresh = false,
  }) async {
    detailsCalls += 1;
    return details;
  }

  @override
  Future<Season> fetchTvSeason(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    seasonCalls.update(seasonNumber, (value) => value + 1, ifAbsent: () => 1);
    return seasonResponses[seasonNumber]!;
  }

  @override
  Future<MediaImages> fetchTvSeasonImages(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    seasonImageCalls.update(
      seasonNumber,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
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
}

void main() {
  final season1 = Season(
    id: 1,
    name: 'Season 1',
    seasonNumber: 1,
    episodeCount: 8,
  );
  final season2 = Season(
    id: 2,
    name: 'Season 2',
    seasonNumber: 2,
    episodeCount: 10,
  );

  final details = TVDetailed(
    id: 10,
    name: 'Demo',
    originalName: 'Demo',
    voteAverage: 7.2,
    voteCount: 100,
    seasons: [season1, season2],
  );

  const poster = ImageModel(
    filePath: '/poster.jpg',
    width: 500,
    height: 750,
    aspectRatio: 0.66,
  );

  group('TvDetailProvider season images', () {
    test('fetches and caches images when selecting seasons', () async {
      final repo = _FakeTvRepository(
        details: details,
        seasonResponses: {1: season1, 2: season2},
      )
        ..setImageResponses(1, [_ImageResponse.success(MediaImages(posters: [poster]))])
        ..setImageResponses(2, [_ImageResponse.success(MediaImages(posters: [poster]))]);

      final provider = TvDetailProvider(repo, tvId: 99);

      await provider.load();
      expect(repo.seasonImageCalls[1], 1);
      expect(provider.seasonImagesForNumber(1)?.posters, isNotEmpty);

      await provider.selectSeason(1);
      expect(repo.seasonImageCalls[1], 1, reason: 'should cache season 1 images');

      await provider.selectSeason(2);
      expect(repo.seasonImageCalls[2], 1);
      expect(provider.seasonImagesForNumber(2)?.posters, isNotEmpty);
    });

    test('handles empty image responses gracefully', () async {
      final repo = _FakeTvRepository(
        details: details,
        seasonResponses: {1: season1},
      )
        ..setImageResponses(1, [_ImageResponse.success(MediaImages.empty())]);

      final provider = TvDetailProvider(repo, tvId: 99);

      await provider.load();
      final images = provider.seasonImagesForNumber(1);
      expect(images, isNotNull);
      expect(images!.hasAny, isFalse);
    });

    test('exposes errors and retries image loading', () async {
      final repo = _FakeTvRepository(
        details: details,
        seasonResponses: {1: season1},
      )
        ..setImageResponses(1, [
          _ImageResponse.error(const TmdbException('Failed to load images')),
          _ImageResponse.success(MediaImages(posters: [poster])),
        ]);

      final provider = TvDetailProvider(repo, tvId: 99);

      await provider.load();
      expect(provider.seasonImagesError(1), 'Failed to load images');
      expect(provider.seasonImagesForNumber(1), isNull);

      await provider.retrySeasonImages(1);
      expect(provider.seasonImagesError(1), isNull);
      expect(provider.seasonImagesForNumber(1)?.posters, isNotEmpty);
      expect(repo.seasonImageCalls[1], 2,
          reason: 'retry should force refetch of season images');
    });
  });
}
