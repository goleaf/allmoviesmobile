import 'dart:collection';

import 'package:flutter/foundation.dart';

@immutable
class TvDiscoverFilters {
  const TvDiscoverFilters({
    this.page = 1,
    this.sortBy = TvSortOption.popularityDesc,
    this.airDateGte,
    this.airDateLte,
    this.firstAirDateGte,
    this.firstAirDateLte,
    this.firstAirDateYear,
    this.withGenres = const <int>[],
    this.withNetworks = const <int>[],
    this.withCompanies = const <int>[],
    this.withKeywords = const <int>[],
    this.withOriginalLanguage,
    this.withRuntimeGte,
    this.withRuntimeLte,
    this.voteAverageGte,
    this.voteAverageLte,
    this.voteCountGte,
    this.withWatchProviders = const <int>[],
    this.watchRegion,
    this.monetizationTypes = const <MonetizationType>{},
    this.includeNullFirstAirDates = false,
    this.screenedTheatrically,
    this.timezone,
    this.statuses = const <TvStatus>{},
    this.types = const <TvShowType>{},
  });

  static const Object _sentinel = Object();

  final int page;
  final TvSortOption sortBy;
  final DateTime? airDateGte;
  final DateTime? airDateLte;
  final DateTime? firstAirDateGte;
  final DateTime? firstAirDateLte;
  final int? firstAirDateYear;
  final List<int> withGenres;
  final List<int> withNetworks;
  final List<int> withCompanies;
  final List<int> withKeywords;
  final String? withOriginalLanguage;
  final int? withRuntimeGte;
  final int? withRuntimeLte;
  final double? voteAverageGte;
  final double? voteAverageLte;
  final int? voteCountGte;
  final List<int> withWatchProviders;
  final String? watchRegion;
  final Set<MonetizationType> monetizationTypes;
  final bool includeNullFirstAirDates;
  final bool? screenedTheatrically;
  final String? timezone;
  final Set<TvStatus> statuses;
  final Set<TvShowType> types;

  TvDiscoverFilters copyWith({
    int? page,
    TvSortOption? sortBy,
    DateTime? airDateGte,
    DateTime? airDateLte,
    DateTime? firstAirDateGte,
    DateTime? firstAirDateLte,
    int? firstAirDateYear,
    List<int>? withGenres,
    List<int>? withNetworks,
    List<int>? withCompanies,
    List<int>? withKeywords,
    String? withOriginalLanguage,
    int? withRuntimeGte,
    int? withRuntimeLte,
    double? voteAverageGte,
    double? voteAverageLte,
    int? voteCountGte,
    List<int>? withWatchProviders,
    String? watchRegion,
    Set<MonetizationType>? monetizationTypes,
    bool? includeNullFirstAirDates,
    Object? screenedTheatrically = _sentinel,
    Object? timezone = _sentinel,
    Set<TvStatus>? statuses,
    Set<TvShowType>? types,
  }) {
    return TvDiscoverFilters(
      page: page ?? this.page,
      sortBy: sortBy ?? this.sortBy,
      airDateGte: airDateGte ?? this.airDateGte,
      airDateLte: airDateLte ?? this.airDateLte,
      firstAirDateGte: firstAirDateGte ?? this.firstAirDateGte,
      firstAirDateLte: firstAirDateLte ?? this.firstAirDateLte,
      firstAirDateYear: firstAirDateYear ?? this.firstAirDateYear,
      withGenres: withGenres ?? this.withGenres,
      withNetworks: withNetworks ?? this.withNetworks,
      withCompanies: withCompanies ?? this.withCompanies,
      withKeywords: withKeywords ?? this.withKeywords,
      withOriginalLanguage: withOriginalLanguage ?? this.withOriginalLanguage,
      withRuntimeGte: withRuntimeGte ?? this.withRuntimeGte,
      withRuntimeLte: withRuntimeLte ?? this.withRuntimeLte,
      voteAverageGte: voteAverageGte ?? this.voteAverageGte,
      voteAverageLte: voteAverageLte ?? this.voteAverageLte,
      voteCountGte: voteCountGte ?? this.voteCountGte,
      withWatchProviders: withWatchProviders ?? this.withWatchProviders,
      watchRegion: watchRegion ?? this.watchRegion,
      monetizationTypes: monetizationTypes ?? this.monetizationTypes,
      includeNullFirstAirDates:
          includeNullFirstAirDates ?? this.includeNullFirstAirDates,
      screenedTheatrically: screenedTheatrically == _sentinel
          ? this.screenedTheatrically
          : screenedTheatrically as bool?,
      timezone: timezone == _sentinel ? this.timezone : timezone as String?,
      statuses: statuses ?? this.statuses,
      types: types ?? this.types,
    );
  }

  Map<String, String> toQueryParameters({bool includePage = false}) {
    final params = <String, String>{'sort_by': sortBy.value};

    if (includePage) {
      params['page'] = '$page';
    }

    void addDate(String key, DateTime? value) {
      if (value == null) return;
      params[key] = _formatDate(value);
    }

    addDate('air_date.gte', airDateGte);
    addDate('air_date.lte', airDateLte);
    addDate('first_air_date.gte', firstAirDateGte);
    addDate('first_air_date.lte', firstAirDateLte);

    if (firstAirDateYear != null) {
      params['first_air_date_year'] = '$firstAirDateYear';
    }

    void addIntList(String key, List<int> values, {String separator = ','}) {
      if (values.isEmpty) return;
      final deduplicated = LinkedHashSet<int>.from(values);
      params[key] = deduplicated.join(separator);
    }

    addIntList('with_genres', withGenres);
    addIntList('with_networks', withNetworks, separator: '|');
    addIntList('with_companies', withCompanies, separator: '|');
    addIntList('with_keywords', withKeywords, separator: '|');
    addIntList('with_watch_providers', withWatchProviders, separator: '|');

    if (withOriginalLanguage != null &&
        withOriginalLanguage!.trim().isNotEmpty) {
      params['with_original_language'] = withOriginalLanguage!.trim();
    }

    if (withRuntimeGte != null) {
      params['with_runtime.gte'] = '$withRuntimeGte';
    }

    if (withRuntimeLte != null) {
      params['with_runtime.lte'] = '$withRuntimeLte';
    }

    if (voteAverageGte != null) {
      params['vote_average.gte'] = _formatDouble(voteAverageGte!);
    }

    if (voteAverageLte != null) {
      params['vote_average.lte'] = _formatDouble(voteAverageLte!);
    }

    if (voteCountGte != null) {
      params['vote_count.gte'] = '$voteCountGte';
    }

    if (watchRegion != null && watchRegion!.trim().isNotEmpty) {
      params['watch_region'] = watchRegion!.trim();
    }

    if (monetizationTypes.isNotEmpty) {
      final values = monetizationTypes.toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      params['with_watch_monetization_types'] = values
          .map((type) => type.value)
          .join('|');
    }

    if (includeNullFirstAirDates) {
      params['include_null_first_air_dates'] = 'true';
    }

    if (screenedTheatrically != null) {
      params['screened_theatrically'] = screenedTheatrically.toString();
    }

    if (timezone != null && timezone!.trim().isNotEmpty) {
      params['timezone'] = timezone!.trim();
    }

    if (statuses.isNotEmpty) {
      final codes = statuses.toList()..sort((a, b) => a.code.compareTo(b.code));
      params['with_status'] = codes.map((status) => status.code).join('|');
    }

    if (types.isNotEmpty) {
      final codes = types.toList()..sort((a, b) => a.code.compareTo(b.code));
      params['with_type'] = codes.map((type) => type.code).join('|');
    }

    return params;
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _formatDouble(double value) {
    final asString = value.toString();
    if (asString.contains('.') && asString.endsWith('0')) {
      return value
          .toStringAsFixed(1)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return asString;
  }
}

enum TvSortOption {
  popularityDesc('popularity.desc'),
  popularityAsc('popularity.asc'),
  firstAirDateDesc('first_air_date.desc'),
  firstAirDateAsc('first_air_date.asc'),
  voteAverageDesc('vote_average.desc'),
  voteAverageAsc('vote_average.asc');

  const TvSortOption(this.value);

  final String value;
}

enum MonetizationType {
  flatrate('flatrate'),
  free('free'),
  ads('ads'),
  rent('rent'),
  buy('buy');

  const MonetizationType(this.value);

  final String value;
}

enum TvStatus {
  returningSeries(0),
  planned(1),
  inProduction(2),
  ended(3),
  canceled(4),
  pilot(5);

  const TvStatus(this.code);

  final int code;
}

enum TvShowType {
  scripted(0),
  reality(1),
  documentary(2),
  news(3),
  talkShow(4),
  animation(5),
  miniseries(6);

  const TvShowType(this.code);

  final int code;
}
