import 'package:flutter/foundation.dart';

class ApiKeyResolver {
  const ApiKeyResolver._();

  static const String _fallbackApiKey = '755c09802f113640bd146fb59ad22411';

  static String resolve(String? providedKey) {
    final envKey = const String.fromEnvironment('TMDB_API_KEY', defaultValue: '');
    final candidate = (providedKey ?? envKey).trim();
    if (candidate.isNotEmpty) {
      return candidate;
    }

    if (kDebugMode) {
      debugPrint(
        'TMDB_API_KEY was not provided. Falling back to the baked-in public key.\n'
        'For production apps, configure the key securely via --dart-define or secrets storage.',
      );
    }

    return _fallbackApiKey;
  }
}
