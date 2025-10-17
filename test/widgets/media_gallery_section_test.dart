import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/presentation/widgets/media_gallery_section.dart';
import 'package:allmovies_mobile/providers/media_gallery_provider.dart';

import '../test_support/test_wrapper.dart';
import 'media_gallery_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaGallerySection', () {
    testWidgets('shows loading indicator while provider is loading', (
      tester,
    ) async {
      final repo = StubTmdbRepository(
        movieLoader: (_, {forceRefresh = false}) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return MediaImages.empty();
        },
      );
      final provider = MediaGalleryProvider(repo);

      await pumpTestApp(
        tester,
        ChangeNotifierProvider<MediaGalleryProvider>.value(
          value: provider,
          child: const Scaffold(body: MediaGallerySection()),
        ),
      );

      final loadFuture = provider.loadMovieImages(1);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await loadFuture;
      await tester.pumpAndSettle();
    });

    testWidgets('renders error message with retry on failure', (tester) async {
      final repo = StubTmdbRepository(
        movieLoader: (_, {forceRefresh = false}) async {
          throw Exception('network error');
        },
      );
      final provider = MediaGalleryProvider(repo);

      await pumpTestApp(
        tester,
        ChangeNotifierProvider<MediaGalleryProvider>.value(
          value: provider,
          child: const Scaffold(body: MediaGallerySection()),
        ),
      );

      await provider.loadMovieImages(1);
      await tester.pumpAndSettle();

      expect(find.text('Images'), findsOneWidget);
      expect(find.text('Failed to load data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('collapses when there is no media available', (tester) async {
      final repo = StubTmdbRepository(
        movieLoader: (_, {forceRefresh = false}) async => MediaImages.empty(),
      );
      final provider = MediaGalleryProvider(repo);

      await pumpTestApp(
        tester,
        ChangeNotifierProvider<MediaGalleryProvider>.value(
          value: provider,
          child: const Scaffold(body: MediaGallerySection()),
        ),
      );

      await provider.loadMovieImages(1);
      await tester.pumpAndSettle();

      expect(find.text('Images'), findsNothing);
      expect(find.byType(MediaGallerySection), findsOneWidget);
    });

    testWidgets('renders posters, backdrops, and stills with blur previews', (
      tester,
    ) async {
      final images = MediaImages(
        posters: const [
          ImageModel(
            filePath: '/poster.jpg',
            width: 200,
            height: 300,
            aspectRatio: 0.66,
          ),
        ],
        backdrops: const [
          ImageModel(
            filePath: '/backdrop.jpg',
            width: 1920,
            height: 1080,
            aspectRatio: 16 / 9,
          ),
        ],
        stills: const [
          ImageModel(
            filePath: '/still.jpg',
            width: 1920,
            height: 1080,
            aspectRatio: 16 / 9,
          ),
        ],
      );
      final repo = StubTmdbRepository(
        movieLoader: (_, {forceRefresh = false}) async => images,
      );
      final provider = MediaGalleryProvider(repo);

      await pumpTestApp(
        tester,
        ChangeNotifierProvider<MediaGalleryProvider>.value(
          value: provider,
          child: const Scaffold(body: MediaGallerySection()),
        ),
      );

      await provider.loadMovieImages(1);
      await tester.pumpAndSettle();

      expect(find.text('Images'), findsOneWidget);
      expect(find.text('Posters'), findsOneWidget);
      expect(find.text('Backdrops'), findsOneWidget);
      expect(find.text('Stills'), findsOneWidget);
      expect(find.byType(ImageFiltered), findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}

