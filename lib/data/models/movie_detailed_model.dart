import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import 'alternative_title_model.dart';
import 'certification_model.dart';
import 'collection_model.dart';
import 'company_model.dart';
import 'country_model.dart';
import 'credit_model.dart';
import 'external_ids_model.dart';
import 'genre_model.dart';
import 'image_model.dart';
import 'keyword_model.dart';
import 'language_model.dart';
import 'movie_ref_model.dart';
import 'review_model.dart';
import 'translation_model.dart';
import 'video_model.dart';
import 'watch_provider_model.dart';

part 'movie_detailed_model.freezed.dart';
part 'movie_detailed_model.g.dart';

/// Comprehensive movie model with all details
@freezed
class MovieDetailed with _$MovieDetailed {
  const factory MovieDetailed({
    required int id,
    required String title,
    @JsonKey(name: 'original_title') required String originalTitle,
    @JsonKey(name: 'original_language') String? originalLanguage,
    @JsonKey(name: 'vote_average') required double voteAverage,
    @JsonKey(name: 'vote_count') required int voteCount,
    String? overview,
    String? tagline,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? runtime,
    @Default([]) List<Genre> genres,
    @JsonKey(name: 'production_companies')
    @Default([])
    List<Company> productionCompanies,
    @JsonKey(name: 'production_countries')
    @Default([])
    List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages')
    @Default([])
    List<Language> spokenLanguages,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'belongs_to_collection') Collection? collection,
    double? popularity,
    String? status,
    String? homepage,
    @JsonKey(name: 'external_ids')
    @Default(ExternalIds())
    ExternalIds externalIds,
    int? budget,
    int? revenue,
    @Default([]) List<Cast> cast,
    @Default([]) List<Crew> crew,
    @Default([]) List<Keyword> keywords,
    @Default([]) List<Review> reviews,
    @JsonKey(name: 'release_dates')
    @Default([])
    List<ReleaseDatesResult> releaseDates,
    @JsonKey(
      name: 'watchProviders',
      fromJson: MovieDetailed._watchProvidersFromJson,
      toJson: MovieDetailed._watchProvidersToJson,
    )
    @Default({})
    Map<String, WatchProviderResults> watchProviders,
    @JsonKey(name: 'alternative_titles')
    @Default([])
    List<AlternativeTitle> alternativeTitles,
    @Default([]) List<Translation> translations,
    @Default([]) List<Video> videos,
    @JsonKey(name: 'imageBackdrops')
    @Default([])
    List<ImageModel> imageBackdrops,
    @JsonKey(name: 'imagePosters') @Default([]) List<ImageModel> imagePosters,
    @JsonKey(name: 'imageProfiles') @Default([]) List<ImageModel> imageProfiles,
    @Default([]) List<ImageModel> images,
    @Default([]) List<MovieRef> recommendations,
    @Default([]) List<MovieRef> similar,
    @Default([]) List<Keyword> keywords,
  }) = _MovieDetailed;

  factory MovieDetailed.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailedFromJson(json);

  static Map<String, WatchProviderResults> _watchProvidersFromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return const {};
    }

    final mapped = <String, WatchProviderResults>{};
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        mapped[key] = WatchProviderResults.fromJson(value);
      }
    });
    return mapped;
  }

  static Map<String, dynamic> _watchProvidersToJson(
    Map<String, WatchProviderResults> providers,
  ) {
    final mapped = <String, dynamic>{};
    providers.forEach((key, value) {
      mapped[key] = value.toJson();
    });
    return mapped;
  }
}

extension MovieDetailedX on MovieDetailed {
  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;

  String? get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : null;

  String? get releaseYear => releaseDate != null && releaseDate!.isNotEmpty
      ? releaseDate!.split('-').first
      : null;

  String? get formattedRuntime {
    if (runtime == null || runtime == 0) {
      return null;
    }
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours == 0) {
      return '$minutes min';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  String formatCurrency(int? value) {
    if (value == null || value == 0) {
      return '—';
    }
    final formatter = NumberFormat.compactCurrency(symbol: r'$');
    return formatter.format(value);
  }

  String get formattedReleaseDate {
    if (releaseDate == null || releaseDate!.isEmpty) {
      return '';
    }
    final parsed = DateTime.tryParse(releaseDate!);
    if (parsed == null) {
      return releaseDate!;
    }
    return DateFormat.yMMMMd().format(parsed);
  }

  List<String> get genreNames => genres.map((genre) => genre.name).toList();

  String get genreLabel => genreNames.join(', ');

  bool get hasCollection => collection != null;

  bool get hasWatchProviders => watchProviders.values.any(
    (provider) =>
        provider.buy.isNotEmpty ||
        provider.rent.isNotEmpty ||
        provider.flatrate.isNotEmpty ||
        provider.ads.isNotEmpty ||
        provider.free.isNotEmpty,
  );
}
