import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/core/constants/preferences_keys.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';

void main() {
  group('PreferencesProvider notifications', () {
    late SharedPreferences prefs;
    late PreferencesProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      provider = PreferencesProvider(prefs);
    });

    test('defaults to false when unset', () {
      expect(provider.notificationsNewReleases, isFalse);
      expect(provider.notificationsWatchlistAlerts, isFalse);
      expect(provider.notificationsRecommendations, isFalse);
      expect(provider.notificationsMarketing, isFalse);
    });

    test('persists updates to SharedPreferences', () async {
      await provider.setNotificationsNewReleases(true);
      await provider.setNotificationsWatchlistAlerts(true);
      await provider.setNotificationsRecommendations(true);
      await provider.setNotificationsMarketing(true);

      expect(provider.notificationsNewReleases, isTrue);
      expect(provider.notificationsWatchlistAlerts, isTrue);
      expect(provider.notificationsRecommendations, isTrue);
      expect(provider.notificationsMarketing, isTrue);

      expect(
        prefs.getBool(PreferenceKeys.notificationsNewReleases),
        isTrue,
      );
      expect(
        prefs.getBool(PreferenceKeys.notificationsWatchlistAlerts),
        isTrue,
      );
      expect(
        prefs.getBool(PreferenceKeys.notificationsRecommendations),
        isTrue,
      );
      expect(
        prefs.getBool(PreferenceKeys.notificationsMarketing),
        isTrue,
      );
    });
  });
}
