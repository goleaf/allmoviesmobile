import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';

import 'deep_link_parser.dart';

/// Coordinates receiving and parsing deep links for the application.
class DeepLinkHandler extends ChangeNotifier {
  DeepLinkHandler({
    Stream<Uri?>? uriStream,
    Future<Uri?> Function()? initialUriGetter,
  })  : _uriStream = uriStream ?? uriLinkStream,
        _initialUriGetter = initialUriGetter ?? getInitialUri;

  final Stream<Uri?> _uriStream;
  final Future<Uri?> Function() _initialUriGetter;

  StreamSubscription<Uri?>? _subscription;
  DeepLinkData? _pendingLink;
  Object? _lastError;
  bool _initialized = false;

  /// Pending deep link data awaiting consumption.
  DeepLinkData? get pendingLink => _pendingLink;

  /// The last error encountered while listening for deep links.
  Object? get lastError => _lastError;

  bool get isInitialized => _initialized;

  /// Starts listening for incoming deep links.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final initialUri = await _initialUriGetter();
      _setPendingFromUri(initialUri);
    } on Exception catch (error) {
      _lastError = error;
      notifyListeners();
    }

    _subscription = _uriStream.listen(
      _setPendingFromUri,
      onError: (Object error) {
        _lastError = error;
        notifyListeners();
      },
    );
  }

  void _setPendingFromUri(Uri? uri) {
    final data = uri == null ? null : DeepLinkParser.parseUri(uri);
    if (data == null) {
      return;
    }
    _pendingLink = data;
    notifyListeners();
  }

  /// Consumes the currently pending deep link, if any.
  DeepLinkData? consumePendingLink() {
    final link = _pendingLink;
    _pendingLink = null;
    return link;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
