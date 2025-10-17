import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allmoviesmobile/core/localization/app_localizations.dart';
import 'package:allmoviesmobile/presentation/navigation/app_navigation_shell.dart';

/// Utility that pumps the [AppNavigationShell] for a specific configuration
/// (screen size + platform). This allows us to simulate the behaviour of the
/// app across phones, tablets, desktop and web targets.
Future<void> pumpShell(
  WidgetTester tester, {
  required Size logicalSize,
  required TargetPlatform platform,
}) async {
  final binding = tester.binding;

  // Configure the fake device metrics so the widget tree reacts as if it was
  // running on the desired form factor (phone/tablet/desktop).
  binding.window.devicePixelRatioTestValue = 1.0;
  binding.window.physicalSizeTestValue = logicalSize;

  addTearDown(() {
    binding.window.clearDevicePixelRatioTestValue();
    binding.window.clearPhysicalSizeTestValue();
  });

  debugDefaultTargetPlatformOverride = platform;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppNavigationShell(),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppNavigationShell multi-device smoke tests', () {
    testWidgets('renders without issues on a typical Android phone',
        (tester) async {
      await pumpShell(
        tester,
        logicalSize: const Size(390, 844), // Pixel 7 size approximation.
        platform: TargetPlatform.android,
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('renders correctly on an iPhone-sized device', (tester) async {
      await pumpShell(
        tester,
        logicalSize: const Size(375, 812), // iPhone 13 size approximation.
        platform: TargetPlatform.iOS,
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('switches to navigation rail on tablet widths', (tester) async {
      await pumpShell(
        tester,
        logicalSize: const Size(1024, 1366), // iPad Pro 12.9" portrait.
        platform: TargetPlatform.android,
      );

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
    });

    testWidgets('extends the navigation rail on desktop/web sized layouts',
        (tester) async {
      await pumpShell(
        tester,
        logicalSize: const Size(1440, 900),
        platform: TargetPlatform.macOS,
      );

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
    });

    testWidgets('remains stable across multiple platform overrides',
        (tester) async {
      for (final platform in const [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ]) {
        await pumpShell(
          tester,
          logicalSize: const Size(390, 844),
          platform: platform,
        );

        expect(find.byType(NavigationBar), findsWidgets);
      }
    });
  });
}
