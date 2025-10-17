import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/services/cache_service.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';

class FakeHttpClient extends http.BaseClient {
  FakeHttpClient({this.onSend});

  final Future<http.StreamedResponse> Function(http.BaseRequest request)? onSend;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (onSend != null) {
      return onSend!(request);
    }
    return http.StreamedResponse(Stream<List<int>>.value(<int>[]), 200);
  }
}

class FakeTmdbRepository extends TmdbRepository {
  FakeTmdbRepository({http.Client? client, CacheService? cache})
      : super(client: client, cacheService: cache, apiKey: 'test');
}

class InMemoryPrefs implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  Object? get(String key) => _data[key];

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocalStorageService makeLocalStorageWithMockPrefs() {
  SharedPreferences.setMockInitialValues({});
  // ignore: invalid_use_of_visible_for_testing_member
  // ignore: invalid_use_of_internal_member
  final prefs = SharedPreferences.getInstance();
  throw UnimplementedError('Use SharedPreferences.setMockInitialValues in tests');
}


