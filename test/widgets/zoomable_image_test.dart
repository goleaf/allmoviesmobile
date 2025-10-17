import 'dart:ui';

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

  group('Zoomable image dialog', () {
    testWidgets('supports pinch zoom and closing the dialog', (tester) async {
      final repo = StubTmdbRepository(
        movieLoader: (_, {forceRefresh = false}) async => MediaImages(
          posters: const [
            ImageModel(
              filePath: '/poster.jpg',
              width: 200,
              height: 300,
              aspectRatio: 0.66,
            ),
          ],
        ),
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

      await tester.tap(find.byType(AspectRatio).first);
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(Dialog);
      expect(dialogFinder, findsOneWidget);

      final viewerFinder = find.descendant(
        of: dialogFinder,
        matching: find.byType(InteractiveViewer),
      );
      expect(viewerFinder, findsOneWidget);

      final viewerState = tester.state<InteractiveViewerState>(viewerFinder);
      final initialScale =
          viewerState.transformationController.value.getMaxScaleOnAxis();

      final center = tester.getCenter(viewerFinder);
      final gesture1 =
          await tester.startGesture(center + const Offset(-20, 0));
      final gesture2 = await tester.startGesture(center + const Offset(20, 0));
      await gesture1.moveBy(const Offset(-40, 0));
      await gesture2.moveBy(const Offset(40, 0));
      await tester.pump();
      await gesture1.up();
      await gesture2.up();

      final zoomedScale =
          viewerState.transformationController.value.getMaxScaleOnAxis();
      expect(zoomedScale, greaterThan(initialScale));

      expect(
        find.descendant(
          of: dialogFinder,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsWidgets,
      );

      await tester.tap(
        find.descendant(of: dialogFinder, matching: find.byIcon(Icons.close)),
      );
      await tester.pumpAndSettle();

      expect(dialogFinder, findsNothing);
    });

    testWidgets('shows error placeholder when image loading fails', (tester) async {
      final repo = StubTmdbRepository(
        movieLoader: (_, {forceRefresh = false}) async => MediaImages(
          posters: const [
            ImageModel(
              filePath: '/broken.jpg',
              width: 200,
              height: 300,
              aspectRatio: 0.66,
            ),
          ],
        ),
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

      await tester.tap(find.byType(AspectRatio).first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final dialogFinder = find.byType(Dialog);
      expect(dialogFinder, findsOneWidget);

      expect(
        find.descendant(
          of: dialogFinder,
          matching: find.byIcon(Icons.broken_image),
        ),
        findsOneWidget,
      );
    });
  });
}
