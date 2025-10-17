import 'package:allmovies_mobile/core/utils/media_image_helper.dart';
import 'package:allmovies_mobile/presentation/widgets/zoomable_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

bool _matrixIsIdentity(Matrix4 matrix) {
  final identity = Matrix4.identity();
  for (var i = 0; i < 16; i++) {
    final difference = (matrix.storage[i] - identity.storage[i]).abs();
    if (difference > 0.001) {
      return false;
    }
  }
  return true;
}

Future<void> _doubleTapWidget(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 40));
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 125));
  await tester.pump(const Duration(milliseconds: 125));
}

void main() {
  testWidgets('ZoomableImage double tap toggles zoom with callbacks', (tester) async {
    var startCount = 0;
    var endCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZoomableImage(
            imagePath: null,
            type: MediaImageType.backdrop,
            onInteractionStart: () => startCount++,
            onInteractionEnd: () => endCount++,
          ),
        ),
      ),
    );

    Matrix4 currentMatrix() {
      final interactiveViewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      final controller = interactiveViewer.transformationController;
      expect(controller, isNotNull, reason: 'ZoomableImage supplies a TransformationController');
      return Matrix4.copy(controller!.value);
    }

    expect(_matrixIsIdentity(currentMatrix()), isTrue);

    final gestureTarget = find.byType(GestureDetector);
    expect(gestureTarget, findsOneWidget);

    await _doubleTapWidget(tester, gestureTarget);
    await tester.pump(const Duration(milliseconds: 300));

    expect(startCount, 1);
    expect(endCount, 1);
    expect(_matrixIsIdentity(currentMatrix()), isFalse);

    await _doubleTapWidget(tester, gestureTarget);
    await tester.pump(const Duration(milliseconds: 300));

    expect(startCount, 2);
    expect(endCount, 2);
    expect(_matrixIsIdentity(currentMatrix()), isTrue);
  });

  testWidgets('ZoomableImage forwards single taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZoomableImage(
            imagePath: null,
            type: MediaImageType.poster,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ZoomableImage));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
