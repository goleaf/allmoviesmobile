import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/providers/keyword_browser_provider.dart';
import 'package:allmovies_mobile/presentation/screens/keywords/keyword_browser_screen.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:allmovies_mobile/core/localization/app_localizations.dart';

class _FakeRepo extends TmdbRepository {}

void main() {
  testWidgets('KeywordBrowserScreen builds', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => KeywordBrowserProvider(_FakeRepo()),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const KeywordBrowserScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(KeywordBrowserScreen), findsOneWidget);
  });
}
