import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Minimal Firebase configuration used for optional push notification support.
///
/// Replace the placeholder values in this file with the credentials from your
/// Firebase project (or whichever FCM-compatible provider you are using) when
/// wiring the app to a real backend. Until then the push notification layer
/// gracefully disables itself.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static const String _placeholderValue = 'REPLACE_WITH_REAL_VALUE';

  /// Returns the platform specific options for the current runtime.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return null;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return null;
    }
  }

  /// Whether the options for the current platform contain placeholder values.
  static bool get isConfiguredForCurrentPlatform {
    final options = currentPlatform;
    if (options == null) {
      return false;
    }
    return !_isPlaceholder(options);
  }

  /// Indicates that the provided [options] still contain placeholder values.
  static bool isPlaceholder(FirebaseOptions? options) {
    if (options == null) {
      return true;
    }
    return options.apiKey == _placeholderValue ||
        options.projectId == 'allmovies-placeholder' ||
        options.appId.contains('placeholder');
  }

  /// Firebase options for Android devices.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _placeholderValue,
    appId: '1:000000000000:android:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'allmovies-placeholder',
    storageBucket: 'allmovies-placeholder.appspot.com',
  );

  /// Firebase options for iOS devices.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _placeholderValue,
    appId: '1:000000000000:ios:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'allmovies-placeholder',
    storageBucket: 'allmovies-placeholder.appspot.com',
    iosBundleId: 'com.allmovies.app',
  );
}
