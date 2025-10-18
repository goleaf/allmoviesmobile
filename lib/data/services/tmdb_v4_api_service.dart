import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/tmdb_v4_endpoint.dart';
import '../utils/api_key_resolver.dart';

class TmdbV4ApiException implements Exception {
  const TmdbV4ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'TmdbV4ApiException(statusCode: $statusCode, message: $message)';
}

class TmdbV4ApiService {
  TmdbV4ApiService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = ApiKeyResolver.resolve(apiKey);

  final http.Client _client;
  final String _apiKey;
  String? _userAccessToken;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${_userAccessToken ?? _apiKey}',
    'Accept': 'application/json',
    'Content-Type': 'application/json;charset=utf-8',
  };

  void setUserAccessToken(String? token) {
    _userAccessToken = token?.isEmpty ?? true ? null : token;
  }

  Future<dynamic> execute(
    TmdbV4Endpoint endpoint, {
    String? accountId,
  }) async {
    switch (endpoint.method) {
      case TmdbV4HttpMethod.get:
        return _get(endpoint, accountId: accountId);
      case TmdbV4HttpMethod.post:
        return _post(endpoint, accountId: accountId);
      case TmdbV4HttpMethod.delete:
        return _delete(endpoint, accountId: accountId);
    }
  }

  Future<dynamic> _get(
    TmdbV4Endpoint endpoint, {
    String? accountId,
  }) async {
    final response = await _client.get(
      endpoint.buildUri(accountId: accountId),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> _post(
    TmdbV4Endpoint endpoint, {
    String? accountId,
  }) async {
    final body = endpoint.sampleBody == null
        ? null
        : jsonEncode(endpoint.sampleBody);
    final response = await _client.post(
      endpoint.buildUri(accountId: accountId),
      headers: _headers,
      body: body,
    );
    return _handleResponse(response);
  }

  Future<dynamic> _delete(
    TmdbV4Endpoint endpoint, {
    String? accountId,
  }) async {
    final response = await _client.delete(
      endpoint.buildUri(accountId: accountId),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    throw TmdbV4ApiException(
      response.body.isEmpty ? 'Unexpected TMDB response' : response.body,
      statusCode: response.statusCode,
    );
  }
}
