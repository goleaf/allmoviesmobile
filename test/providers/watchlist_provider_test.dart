import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/providers/watchlist_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('WatchlistProvider toggles and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final provider = WatchlistProvider(storage);
    expect(provider.count, 0);
    await provider.toggleWatchlist(11);
    expect(provider.isInWatchlist(11), isTrue);
    await provider.toggleWatchlist(11);
    expect(provider.isInWatchlist(11), isFalse);
  });
}


