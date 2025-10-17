import 'package:flutter/foundation.dart';

import 'paginated_response.dart';
import 'movie.dart';

@immutable
class TmdbListDetails {
  const TmdbListDetails({
    required this.id,
    required this.name,
    this.description,
    this.posterPath,
    this.backdropPath,
    this.createdBy,
    this.language,
    this.country,
    this.favoriteCount = 0,
    this.itemCount = 0,
    this.sortBy,
    this.public,
    required this.entries,
  });

  factory TmdbListDetails.fromJson(Map<String, dynamic> json) {
    final entries = PaginatedResponse<Movie>.fromJson(
      json,
      (item) => Movie.fromJson(item),
    );

    return TmdbListDetails(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim(),
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      createdBy: json['created_by'] as String?,
      language: json['iso_639_1'] as String?,
      country: json['iso_3166_1'] as String?,
      favoriteCount: json['favorite_count'] is int
          ? json['favorite_count'] as int
          : int.tryParse('${json['favorite_count']}') ?? 0,
      itemCount: json['item_count'] is int
          ? json['item_count'] as int
          : int.tryParse('${json['item_count']}') ?? entries.totalResults,
      sortBy: json['sort_by'] as String?,
      public: json['public'] as bool?,
      entries: entries,
    );
  }

  final int id;
  final String name;
  final String? description;
  final String? posterPath;
  final String? backdropPath;
  final String? createdBy;
  final String? language;
  final String? country;
  final int favoriteCount;
  final int itemCount;
  final String? sortBy;
  final bool? public;
  final PaginatedResponse<Movie> entries;
}
