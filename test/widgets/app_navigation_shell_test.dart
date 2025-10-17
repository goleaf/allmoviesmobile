import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/presentation/navigation/app_navigation_shell.dart';

void main() {
  testWidgets('Bottom navigation switches destinations', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppNavigationShell()));
    await tester.pumpAndSettle();

    // Initially on Home
    expect(find.byType(NavigationBar), findsOneWidget);

    // Tap Movies destination
    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();

    // Tap TV destination
    await tester.tap(find.text('Series'));
    await tester.pumpAndSettle();

    // Tap Search destination
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}


