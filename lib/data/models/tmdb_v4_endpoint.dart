import 'package:equatable/equatable.dart';

enum TmdbV4HttpMethod { get, post, delete }

extension TmdbV4HttpMethodExtension on TmdbV4HttpMethod {
  String get name => switch (this) {
    TmdbV4HttpMethod.get => 'GET',
    TmdbV4HttpMethod.post => 'POST',
    TmdbV4HttpMethod.delete => 'DELETE',
  };
}

class TmdbV4Endpoint extends Equatable {
  const TmdbV4Endpoint({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.path,
    this.method = TmdbV4HttpMethod.get,
    this.sampleQuery,
    this.sampleBody,
    this.supportsExecution = true,
    this.notes,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String path;
  final TmdbV4HttpMethod method;
  final Map<String, dynamic>? sampleQuery;
  final Map<String, dynamic>? sampleBody;
  final bool supportsExecution;
  final String? notes;

  Uri buildUri({Map<String, dynamic>? overrideQuery}) {
    final effectiveQuery = <String, dynamic>{
      if (sampleQuery != null) ...sampleQuery!,
      if (overrideQuery != null) ...overrideQuery,
    };

    final filtered = effectiveQuery.map(
      (key, value) => MapEntry(key, value?.toString()),
    );

    return Uri.https(
      'api.themoviedb.org',
      '/4$path',
      filtered.isEmpty ? null : filtered,
    );
  }

  @override
  List<Object?> get props => [id, title, path, method, category];
}

class TmdbV4EndpointGroup extends Equatable {
  const TmdbV4EndpointGroup({
    required this.name,
    required this.description,
    required this.endpoints,
  });

  final String name;
  final String description;
  final List<TmdbV4Endpoint> endpoints;

  @override
  List<Object?> get props => [name, description, endpoints];
}
