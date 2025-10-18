import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/navigation/deep_link_parser.dart';
import '../data/services/tmdb_v4_auth_service.dart';
import '../data/tmdb_v4_repository.dart';

class TmdbV4AuthProvider extends ChangeNotifier {
  TmdbV4AuthProvider({
    required TmdbV4AuthService authService,
    required TmdbV4Repository repository,
    FlutterSecureStorage? secureStorage,
  })  : _authService = authService,
        _repository = repository,
        _storage = secureStorage ?? const FlutterSecureStorage() {
    _restoreSession();
  }

  static const _accessTokenKey = 'tmdb_v4_access_token';
  static const _accountIdKey = 'tmdb_v4_account_id';
  static final Uri _redirectUri = DeepLinkConfig.buildUri(
    const ['auth', 'tmdb_v4'],
    useAlternateScheme: true,
  );

  final TmdbV4AuthService _authService;
  final TmdbV4Repository _repository;
  final FlutterSecureStorage _storage;

  String? _accessToken;
  String? _accountId;
  String? _pendingRequestToken;
  DateTime? _pendingExpiration;
  bool _isSigningIn = false;
  bool _isSigningOut = false;
  bool _sessionRestored = false;
  String? _errorMessage;

  String? get accessToken => _accessToken;
  String? get accountId => _accountId;
  bool get isSigningIn => _isSigningIn;
  bool get isSigningOut => _isSigningOut;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get hasPendingAuthorization => _pendingRequestToken != null;
  bool get hasRestoredSession => _sessionRestored;
  String? get errorMessage => _errorMessage;
  Uri get redirectUri => _redirectUri;

  Future<void> _restoreSession() async {
    try {
      final storedToken = await _storage.read(key: _accessTokenKey);
      final storedAccountId = await _storage.read(key: _accountIdKey);
      if (storedToken != null && storedToken.isNotEmpty) {
        _accessToken = storedToken;
        _accountId = storedAccountId;
        _repository.setUserAccessToken(_accessToken);
      }
    } catch (error) {
      _errorMessage = 'Failed to restore TMDB session: $error';
    } finally {
      _sessionRestored = true;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_accessToken == null || _isSigningOut) {
      return;
    }
    _isSigningOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.revokeAccessToken(_accessToken!);
    } catch (error) {
      _errorMessage = 'Failed to revoke TMDB access token: $error';
    } finally {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _accountIdKey);
      _accessToken = null;
      _accountId = null;
      _pendingRequestToken = null;
      _repository.setUserAccessToken(null);
      _isSigningOut = false;
      notifyListeners();
    }
  }

  Future<Uri?> beginAuthorization() async {
    if (_isSigningIn) {
      return null;
    }

    _isSigningIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.createRequestToken(
        redirectUri: _redirectUri,
      );
      _pendingRequestToken = token.token;
      _pendingExpiration = token.expiresAt;
      return _authService.buildAuthorizationUrl(token.token);
    } catch (error) {
      _errorMessage = 'Failed to start TMDB authentication: $error';
      _isSigningIn = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> openAuthorizationPage() async {
    final url = await beginAuthorization();
    if (url == null) {
      return;
    }
    unawaited(launchUrl(url, mode: LaunchMode.externalApplication));
  }

  Future<void> handleAuthorizationRedirect({
    required String requestToken,
    required bool approved,
  }) async {
    if (_pendingRequestToken == null ||
        _pendingRequestToken != requestToken ||
        _isSigningOut) {
      return;
    }

    if (!approved) {
      _errorMessage = 'TMDB access request was not approved.';
      _pendingRequestToken = null;
      _pendingExpiration = null;
      _isSigningIn = false;
      notifyListeners();
      return;
    }

    if (_pendingExpiration != null &&
        DateTime.now().toUtc().isAfter(_pendingExpiration!)) {
      _errorMessage = 'The TMDB request token has expired. Please try again.';
      _pendingRequestToken = null;
      _pendingExpiration = null;
      _isSigningIn = false;
      notifyListeners();
      return;
    }

    try {
      final access = await _authService.createAccessToken(
        requestToken: requestToken,
      );
      _accessToken = access.accessToken;
      _accountId = access.accountId;
      _repository.setUserAccessToken(_accessToken);
      await _storage.write(key: _accessTokenKey, value: _accessToken);
      if (_accountId != null) {
        await _storage.write(key: _accountIdKey, value: _accountId);
      } else {
        await _storage.delete(key: _accountIdKey);
      }
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to exchange TMDB access token: $error';
    } finally {
      _pendingRequestToken = null;
      _pendingExpiration = null;
      _isSigningIn = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
