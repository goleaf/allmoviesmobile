import 'package:allmovies_mobile/core/utils/media_image_helper.dart';
import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/presentation/widgets/image_gallery.dart';
import 'package:allmovies_mobile/presentation/widgets/zoomable_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ImageGallery shows indicator and gradients', (tester) async {
    final images = [
      const ImageModel(
        filePath: '',
        width: 500,
        height: 281,
        aspectRatio: 1.78,
      ),
      const ImageModel(
        filePath: '',
        width: 500,
        height: 281,
        aspectRatio: 1.78,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ImageGallery(
          images: images,
          mediaType: MediaImageType.backdrop,
        ),
      ),
    );

    expect(find.text('1 / 2'), findsOneWidget);

    final gradientFinder = find.byWidgetPredicate((widget) {
      if (widget is IgnorePointer) {
        final child = widget.child;
        if (child is Container) {
          final decoration = child.decoration;
          if (decoration is BoxDecoration && decoration.gradient != null) {
            return true;
          }
        }
      }
      return false;
    });

    expect(gradientFinder, findsNWidgets(2));

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
  });

  testWidgets('ImageGallery toggles chrome visibility on tap', (tester) async {
    final images = [
      const ImageModel(
        filePath: '',
        width: 500,
        height: 281,
        aspectRatio: 1.78,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ImageGallery(
          images: images,
          mediaType: MediaImageType.backdrop,
        ),
      ),
    );

    await tester.pumpAndSettle();

    AnimatedOpacity _findOpacity(Key key) =>
        tester.widget<AnimatedOpacity>(find.byKey(key));

    expect(
      _findOpacity(const ValueKey('galleryTopBarOpacity')).opacity,
      closeTo(1, 0.01),
    );

    expect(
      _findOpacity(const ValueKey('edgeGradient_top')).opacity,
      closeTo(1, 0.01),
    );

    await tester.tap(find.byType(ZoomableImage));
    await tester.pump(const Duration(milliseconds: 220));

    expect(
      _findOpacity(const ValueKey('galleryTopBarOpacity')).opacity,
      closeTo(0, 0.01),
    );
    expect(
      _findOpacity(const ValueKey('edgeGradient_top')).opacity,
      closeTo(0, 0.01),
    );

    await tester.tap(find.byType(ZoomableImage));
    await tester.pump(const Duration(milliseconds: 220));

    expect(
      _findOpacity(const ValueKey('galleryTopBarOpacity')).opacity,
      closeTo(1, 0.01),
    );
    expect(
      _findOpacity(const ValueKey('edgeGradient_top')).opacity,
      closeTo(1, 0.01),
    );
  });
}
