import 'package:allmovies_mobile/core/utils/media_image_helper.dart';
import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/presentation/widgets/image_gallery.dart';
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

  testWidgets('ImageGallery chrome toggles on tap', (tester) async {
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

    final thumbnailsFinder =
        find.byKey(const ValueKey('imageGallery/thumbnails'));

    expect(
      tester.widget<AnimatedOpacity>(thumbnailsFinder).opacity,
      1,
    );

    await tester.tap(find.byType(InteractiveViewer));
    await tester.pumpAndSettle();

    expect(
      tester.widget<AnimatedOpacity>(thumbnailsFinder).opacity,
      0,
    );

    await tester.tap(find.byType(InteractiveViewer));
    await tester.pumpAndSettle();

    expect(
      tester.widget<AnimatedOpacity>(thumbnailsFinder).opacity,
      1,
    );
  });
}
