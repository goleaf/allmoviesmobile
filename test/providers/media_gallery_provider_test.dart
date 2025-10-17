import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/providers/media_gallery_provider.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';

class _MockTmdbRepository extends Mock implements TmdbRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaGalleryProvider', () {
    test('loadMovieImages updates loading state and stores images', () async {
      final repo = _MockTmdbRepository();
      final provider = MediaGalleryProvider(repo);
      final images = MediaImages(posters: const []);

      when(() => repo.fetchMovieImages(1, forceRefresh: false))
          .thenAnswer((_) async => images);

      final loadFuture = provider.loadMovieImages(1);
      expect(provider.isLoading, isTrue);

      await loadFuture;

      expect(provider.isLoading, isFalse);
      expect(provider.images, equals(images));
      expect(provider.hasError, isFalse);
      verify(() => repo.fetchMovieImages(1, forceRefresh: false)).called(1);
    });

    test('loadMovieImages captures errors and exposes message', () async {
      final repo = _MockTmdbRepository();
      final provider = MediaGalleryProvider(repo);

      when(() => repo.fetchMovieImages(2, forceRefresh: false))
          .thenThrow(Exception('failure'));

      await provider.loadMovieImages(2);

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('Exception'));
      verify(() => repo.fetchMovieImages(2, forceRefresh: false)).called(1);
    });

    test('refresh reuses previous request with force refresh', () async {
      final repo = _MockTmdbRepository();
      final provider = MediaGalleryProvider(repo);
      final images = MediaImages(posters: const []);

      when(() => repo.fetchMovieImages(10, forceRefresh: false))
          .thenAnswer((_) async => images);
      when(() => repo.fetchMovieImages(10, forceRefresh: true))
          .thenAnswer((_) async => images);

      await provider.loadMovieImages(10);
      await provider.refresh();

      verify(() => repo.fetchMovieImages(10, forceRefresh: false)).called(1);
      verify(() => repo.fetchMovieImages(10, forceRefresh: true)).called(1);
    });

    test('loadTvImages caches last request and avoids duplicate fetches', () async {
      final repo = _MockTmdbRepository();
      final provider = MediaGalleryProvider(repo);
      final images = MediaImages(stills: const []);

      when(() => repo.fetchTvImages(5, forceRefresh: false))
          .thenAnswer((_) async => images);

      await provider.loadTvImages(5);
      await provider.loadTvImages(5);

      expect(provider.images, equals(images));
      verify(() => repo.fetchTvImages(5, forceRefresh: false)).called(1);
    });

    test('refresh without prior load performs no work', () async {
      final repo = _MockTmdbRepository();
      final provider = MediaGalleryProvider(repo);

      await provider.refresh();

      verifyZeroInteractions(repo);
    });
  });
}
