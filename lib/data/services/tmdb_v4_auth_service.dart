import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/api_key_resolver.dart';
import 'tmdb_v4_api_service.dart';

class TmdbV4RequestToken {
  const TmdbV4RequestToken({
    required this.token,
    required this.expiresAt,
  });

  final String token;
  final DateTime expiresAt;
}

class TmdbV4AccessToken {
  const TmdbV4AccessToken({
    required this.accessToken,
    required this.accountId,
  });

  final String accessToken;
  final String? accountId;
}

class TmdbV4AuthService {
  TmdbV4AuthService({
    http.Client? client,
    String? apiKey,
    TmdbV4ApiService? apiService,
  })  : _client = client ?? http.Client(),
        _apiKey = ApiKeyResolver.resolve(apiKey),
        _apiService = apiService;

  static const _baseHost = 'api.themoviedb.org';
  static const _authHost = 'www.themoviedb.org';

  final http.Client _client;
  final String _apiKey;
  final TmdbV4ApiService? _apiService;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Accept': 'application/json',
        'Content-Type': 'application/json;charset=utf-8',
      };

  Future<TmdbV4RequestToken> createRequestToken({
    required Uri redirectUri,
  }) async {
    final response = await _client.post(
      Uri.https(_baseHost, '/4/auth/request_token'),
      headers: _headers,
      body: jsonEncode({'redirect_to': redirectUri.toString()}),
    );

    final data = _decode(response);
    final token = data['request_token'] as String?;
    final expiresAtRaw = data['expires_at'] as String?;
    if (token == null || token.isEmpty) {
      throw const TmdbV4ApiException('TMDB did not return a request token.');
    }

    final expiresAt = expiresAtRaw == null
        ? DateTime.now().toUtc()
        : DateTime.tryParse(expiresAtRaw)?.toUtc() ?? DateTime.now().toUtc();

    return TmdbV4RequestToken(token: token, expiresAt: expiresAt);
  }

  Uri buildAuthorizationUrl(String requestToken) {
    return Uri.https(
      _authHost,
      '/auth/access',
      {'request_token': requestToken},
    );
  }

  Future<TmdbV4AccessToken> createAccessToken({
    required String requestToken,
  }) async {
    final response = await _client.post(
      Uri.https(_baseHost, '/4/auth/access_token'),
      headers: _headers,
      body: jsonEncode({'request_token': requestToken}),
    );

    final data = _decode(response);
    final accessToken = data['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw const TmdbV4ApiException('TMDB did not return an access token.');
    }

    final accountId = data['account_id'] as String?;
    _apiService?.setUserAccessToken(accessToken);

    return TmdbV4AccessToken(
      accessToken: accessToken,
      accountId: accountId,
    );
  }

  Future<void> revokeAccessToken(String accessToken) async {
    final response = await _client.delete(
      Uri.https(_baseHost, '/4/auth/access_token'),
      headers: _headers,
      body: jsonEncode({'access_token': accessToken}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TmdbV4ApiException(
        response.body.isEmpty
            ? 'Unable to revoke TMDB access token.'
            : response.body,
        statusCode: response.statusCode,
      );
    }

    _apiService?.setUserAccessToken(null);
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TmdbV4ApiException(
        response.body.isEmpty
            ? 'Unexpected TMDB authentication response.'
            : response.body,
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const TmdbV4ApiException('TMDB returned an unexpected payload.');
  }

  void dispose() {
    _client.close();
  }
}
