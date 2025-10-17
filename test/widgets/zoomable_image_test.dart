import 'package:allmovies_mobile/core/utils/media_image_helper.dart';
import 'package:allmovies_mobile/presentation/widgets/zoomable_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

void main() {
  testWidgets('ZoomableImage toggles zoom on double tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ZoomableImage(
            imagePath: null,
            type: MediaImageType.poster,
          ),
        ),
      ),
    );

    final viewerFinder = find.byType(InteractiveViewer);
    final viewer = tester.widget<InteractiveViewer>(viewerFinder);
    final controller = viewer.transformationController!;

    expect(controller.value, equals(vector_math.Matrix4.identity()));

    await tester.tap(find.byType(ZoomableImage));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(ZoomableImage));
    await tester.pumpAndSettle();

    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1.0));

    await tester.tap(find.byType(ZoomableImage));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(ZoomableImage));
    await tester.pumpAndSettle();

    expect(controller.value.getMaxScaleOnAxis(), closeTo(1.0, 0.05));
  });
}
