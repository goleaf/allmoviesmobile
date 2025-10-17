import 'package:flutter/foundation.dart';

@immutable
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final resultsRaw = json['results'];

    return PaginatedResponse<T>(
      page: json['page'] is int
          ? json['page'] as int
          : int.tryParse('${json['page']}') ?? 1,
      totalPages: json['total_pages'] is int
          ? json['total_pages'] as int
          : int.tryParse('${json['total_pages']}') ?? 1,
      totalResults: json['total_results'] is int
          ? json['total_results'] as int
          : int.tryParse('${json['total_results']}') ??
                (resultsRaw is List ? resultsRaw.length : 0),
      results: resultsRaw is List
          ? resultsRaw
                .whereType<Map<String, dynamic>>()
                .map(mapper)
                .toList(growable: false)
          : const [],
    );
  }

  final int page;
  final int totalPages;
  final int totalResults;
  final List<T> results;

  bool get hasMore => page < totalPages;
}
