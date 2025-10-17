import 'package:intl/intl.dart';

/// Lightweight representation of a collection part used in the collection
/// details screen.
class CollectionPartItem {
  CollectionPartItem({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.order,
    this.revenue,
  });

  factory CollectionPartItem.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?) ?? (json['name'] as String?) ?? '';
    return CollectionPartItem(
      id: (json['id'] as num).toInt(),
      title: title,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] is num)
          ? (json['vote_average'] as num).toDouble()
          : null,
      order: (json['order'] is num) ? (json['order'] as num).toInt() : null,
    );
  }

  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? order;
  final num? revenue;

  DateTime? get releaseDateTime {
    if (releaseDate == null || releaseDate!.isEmpty) {
      return null;
    }
    try {
      return DateTime.tryParse(releaseDate!);
    } catch (_) {
      return null;
    }
  }

  String formattedReleaseDate(String locale) {
    final date = releaseDateTime;
    if (date == null) return '';
    return DateFormat.yMMMMd(locale).format(date);
  }

  CollectionPartItem copyWith({num? revenue}) {
    return CollectionPartItem(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      order: order,
      revenue: revenue ?? this.revenue,
    );
  }
}

/// Representation of a single collection image (poster or backdrop).
class CollectionImageItem {
  CollectionImageItem({
    required this.filePath,
    required this.width,
    required this.height,
    required this.type,
    this.voteAverage,
    this.voteCount,
  });

  factory CollectionImageItem.fromJson(
    Map<String, dynamic> json, {
    required String type,
  }) {
    return CollectionImageItem(
      filePath: json['file_path'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      type: type,
      voteAverage:
          (json['vote_average'] is num) ? (json['vote_average'] as num).toDouble() : null,
      voteCount: (json['vote_count'] is num) ? (json['vote_count'] as num).toInt() : null,
    );
  }

  final String filePath;
  final int width;
  final int height;
  final String type;
  final double? voteAverage;
  final int? voteCount;
}

/// Representation of an available translation for the collection.
class CollectionTranslationItem {
  CollectionTranslationItem({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.englishName,
    required this.title,
    this.overview,
    this.homepage,
  });

  factory CollectionTranslationItem.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return CollectionTranslationItem(
      iso6391: json['iso_639_1'] as String? ?? '',
      iso31661: json['iso_3166_1'] as String? ?? '',
      name: json['name'] as String? ?? '',
      englishName: json['english_name'] as String? ?? '',
      title: data['title'] as String? ?? data['name'] as String? ?? '',
      overview: data['overview'] as String?,
      homepage: data['homepage'] as String?,
    );
  }

  final String iso6391;
  final String iso31661;
  final String name;
  final String englishName;
  final String title;
  final String? overview;
  final String? homepage;
}

/// Aggregated view data for the collection details screen.
class CollectionDetailViewData {
  CollectionDetailViewData({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.parts = const [],
    this.images = const [],
    this.translations = const [],
    this.totalRevenue = 0,
  });

  factory CollectionDetailViewData.fromResponses({
    required Map<String, dynamic> details,
    required Map<String, dynamic> images,
    required Map<String, dynamic> translations,
  }) {
    final parts = (details['parts'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CollectionPartItem.fromJson)
        .toList();

    parts.sort((a, b) {
      if (a.order != null && b.order != null && a.order != b.order) {
        return a.order!.compareTo(b.order!);
      }
      final dateA = a.releaseDateTime;
      final dateB = b.releaseDateTime;
      if (dateA != null && dateB != null) {
        return dateA.compareTo(dateB);
      }
      if (dateA != null) return -1;
      if (dateB != null) return 1;
      return a.title.compareTo(b.title);
    });

    final posterImages = (images['posters'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => CollectionImageItem.fromJson(e, type: 'poster'));
    final backdropImages = (images['backdrops'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => CollectionImageItem.fromJson(e, type: 'backdrop'));

    final translationItems = (translations['translations'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CollectionTranslationItem.fromJson)
        .toList();

    return CollectionDetailViewData(
      id: (details['id'] as num).toInt(),
      name: details['name'] as String? ?? '',
      overview: details['overview'] as String?,
      posterPath: details['poster_path'] as String?,
      backdropPath: details['backdrop_path'] as String?,
      parts: parts,
      images: [...posterImages, ...backdropImages],
      translations: translationItems,
    );
  }

  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final List<CollectionPartItem> parts;
  final List<CollectionImageItem> images;
  final List<CollectionTranslationItem> translations;
  final num totalRevenue;

  CollectionDetailViewData copyWith({
    List<CollectionPartItem>? parts,
    List<CollectionImageItem>? images,
    List<CollectionTranslationItem>? translations,
    num? totalRevenue,
  }) {
    return CollectionDetailViewData(
      id: id,
      name: name,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      parts: parts ?? this.parts,
      images: images ?? this.images,
      translations: translations ?? this.translations,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }
}
