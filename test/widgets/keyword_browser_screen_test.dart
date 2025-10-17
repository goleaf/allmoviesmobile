import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/providers/keyword_browser_provider.dart';
import 'package:allmovies_mobile/presentation/screens/keywords/keyword_browser_screen.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';

class _FakeRepo extends TmdbRepository {}

void main() {
  testWidgets('KeywordBrowserScreen builds with drawer and app bar', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => KeywordBrowserProvider(_FakeRepo())),
        ],
        child: const MaterialApp(home: KeywordBrowserScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(KeywordBrowserScreen), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}


