import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/presentation/navigation/fullscreen_modal.dart';

void main() {
  testWidgets('pushFullscreenModal shows close button and pops', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await pushFullscreenModal(
                    context,
                    builder: (_) => const Text('Content'),
                    title: 'Title',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Content'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Content'), findsNothing);
  });
}
