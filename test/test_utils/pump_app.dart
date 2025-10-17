import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<SingleChildWidget>? providers,
  List<LocalizationsDelegate<dynamic>>? localizationsDelegates,
  List<Locale>? supportedLocales,
  NavigatorObserver? navigatorObserver,
  GlobalKey<NavigatorState>? navigatorKey,
  RouteFactory? onGenerateRoute,
  ThemeData? theme,
}) async {
  final app = MaterialApp(
    navigatorKey: navigatorKey,
    home: child,
    onGenerateRoute: onGenerateRoute,
    theme: theme,
    localizationsDelegates: localizationsDelegates,
    supportedLocales: (supportedLocales ?? const [Locale('en')]).whereType<Locale>(),
    navigatorObservers: navigatorObserver != null ? [navigatorObserver] : const <NavigatorObserver>[],
  );

  final wrapped = providers != null && providers.isNotEmpty
      ? MultiProvider(providers: providers, child: app)
      : app;

  await tester.pumpWidget(wrapped);
  await tester.pumpAndSettle();
}


