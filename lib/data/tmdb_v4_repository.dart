import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/tmdb_v4_endpoint.dart';
import 'services/tmdb_v4_api_service.dart';
import 'tmdb_v4_catalog.dart';

class TmdbV4Repository {
  TmdbV4Repository({
    http.Client? client,
    String? apiKey,
    TmdbV4ApiService? service,
  }) : _service = service ?? TmdbV4ApiService(client: client, apiKey: apiKey);

  final TmdbV4ApiService _service;

  List<TmdbV4EndpointGroup> get groups => TmdbV4Catalog.groups;

  void setUserAccessToken(String? token) {
    _service.setUserAccessToken(token);
  }

  Future<String> execute(
    TmdbV4Endpoint endpoint, {
    String? accountId,
  }) async {
    if (!endpoint.supportsExecution) {
      throw const TmdbV4ApiException(
        'This endpoint cannot be executed from the demo interface.',
      );
    }

    try {
      final result = await _service.execute(
        endpoint,
        accountId: accountId,
      );
      if (result == null) {
        return 'No content returned.';
      }
      if (result is String) {
        return result;
      }

      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(result);
    } on TmdbV4ApiException {
      rethrow;
    } catch (error) {
      throw TmdbV4ApiException('Failed to execute endpoint: $error');
    }
  }
}
