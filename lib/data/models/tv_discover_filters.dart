import 'dart:collection';
import 'dart:convert';

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'page': page,
      'sortBy': sortBy.value,
      'airDateGte': _encodeDate(airDateGte),
      'airDateLte': _encodeDate(airDateLte),
      'firstAirDateGte': _encodeDate(firstAirDateGte),
      'firstAirDateLte': _encodeDate(firstAirDateLte),
      'firstAirDateYear': firstAirDateYear,
      'withGenres': withGenres,
      'withNetworks': withNetworks,
      'withCompanies': withCompanies,
      'withKeywords': withKeywords,
      'withOriginalLanguage': withOriginalLanguage,
      'withRuntimeGte': withRuntimeGte,
      'withRuntimeLte': withRuntimeLte,
      'voteAverageGte': voteAverageGte,
      'voteAverageLte': voteAverageLte,
      'voteCountGte': voteCountGte,
      'withWatchProviders': withWatchProviders,
      'watchRegion': watchRegion,
      'monetizationTypes':
          monetizationTypes.map((type) => type.value).toList(growable: false),
      'includeNullFirstAirDates': includeNullFirstAirDates,
      'screenedTheatrically': screenedTheatrically,
      'timezone': timezone,
      'statuses': statuses.map((status) => status.code).toList(growable: false),
      'types': types.map((type) => type.code).toList(growable: false),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static TvDiscoverFilters fromJson(Map<String, dynamic> json) {
    return TvDiscoverFilters(
      page: json['page'] as int? ?? 1,
      sortBy: _parseSort(json['sortBy']) ?? TvSortOption.popularityDesc,
      airDateGte: _decodeDate(json['airDateGte']),
      airDateLte: _decodeDate(json['airDateLte']),
      firstAirDateGte: _decodeDate(json['firstAirDateGte']),
      firstAirDateLte: _decodeDate(json['firstAirDateLte']),
      firstAirDateYear: json['firstAirDateYear'] as int?,
      withGenres: _parseIntList(json['withGenres']),
      withNetworks: _parseIntList(json['withNetworks']),
      withCompanies: _parseIntList(json['withCompanies']),
      withKeywords: _parseIntList(json['withKeywords']),
      withOriginalLanguage: _parseString(json['withOriginalLanguage']),
      withRuntimeGte: json['withRuntimeGte'] as int?,
      withRuntimeLte: json['withRuntimeLte'] as int?,
      voteAverageGte: _parseDouble(json['voteAverageGte']),
      voteAverageLte: _parseDouble(json['voteAverageLte']),
      voteCountGte: json['voteCountGte'] as int?,
      withWatchProviders: _parseIntList(json['withWatchProviders']),
      watchRegion: _parseString(json['watchRegion']),
      monetizationTypes:
          _parseMonetizationList(json['monetizationTypes']).toSet(),
      includeNullFirstAirDates:
          json['includeNullFirstAirDates'] as bool? ?? false,
      screenedTheatrically: json['screenedTheatrically'] as bool?,
      timezone: _parseString(json['timezone']),
      statuses: _parseStatusList(json['statuses']).toSet(),
      types: _parseTypeList(json['types']).toSet(),
    );
  }

  static TvDiscoverFilters fromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return fromJson(decoded);
    }
    throw const FormatException('Invalid TV discover filters payload');
  }

  static TvDiscoverFilters fromQueryParameters(Map<String, String> params) {
    return TvDiscoverFilters(
      sortBy: _parseSort(params['sort_by']) ?? TvSortOption.popularityDesc,
      airDateGte: _parseDate(params['air_date.gte']),
      airDateLte: _parseDate(params['air_date.lte']),
      firstAirDateGte: _parseDate(params['first_air_date.gte']),
      firstAirDateLte: _parseDate(params['first_air_date.lte']),
      firstAirDateYear: _tryParseInt(params['first_air_date_year']),
      withGenres: _parseDelimitedInts(params['with_genres'], ','),
      withNetworks: _parseDelimitedInts(params['with_networks'], '|'),
      withCompanies: _parseDelimitedInts(params['with_companies'], '|'),
      withKeywords: _parseDelimitedInts(params['with_keywords'], '|'),
      withOriginalLanguage: _normalizeString(params['with_original_language']),
      withRuntimeGte: _tryParseInt(params['with_runtime.gte']),
      withRuntimeLte: _tryParseInt(params['with_runtime.lte']),
      voteAverageGte: _tryParseDouble(params['vote_average.gte']),
      voteAverageLte: _tryParseDouble(params['vote_average.lte']),
      voteCountGte: _tryParseInt(params['vote_count.gte']),
      withWatchProviders:
          _parseDelimitedInts(params['with_watch_providers'], '|'),
      watchRegion: _normalizeString(params['watch_region']),
      monetizationTypes:
          _parseMonetizationFromString(params['with_watch_monetization_types']),
      includeNullFirstAirDates:
          params['include_null_first_air_dates'] == 'true',
      screenedTheatrically: _parseNullableBool(params['screened_theatrically']),
      timezone: _normalizeString(params['timezone']),
      statuses: _parseStatusCodes(params['with_status']),
      types: _parseTypeCodes(params['with_type']),
    );
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

  static String? _encodeDate(DateTime? value) => value?.toIso8601String();

  static DateTime? _decodeDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static String? _parseString(Object? raw) {
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  static String? _normalizeString(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<int> _parseIntList(Object? raw) {
    if (raw is List) {
      return raw.whereType<num>().map((value) => value.toInt()).toList();
    }
    return const <int>[];
  }

  static List<int> _parseDelimitedInts(String? raw, String separator) {
    if (raw == null || raw.isEmpty) {
      return const <int>[];
    }
    final pattern = separator == '|'
        ? RegExp('[,|]')
        : RegExp(RegExp.escape(separator));
    return raw
        .split(pattern)
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toList(growable: false);
  }

  static double? _parseDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  static double? _tryParseDouble(String? raw) {
    if (raw == null) return null;
    return double.tryParse(raw);
  }

  static int? _tryParseInt(String? raw) {
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  static bool? _parseNullableBool(String? raw) {
    if (raw == null) return null;
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    return null;
  }

  static TvSortOption? _parseSort(Object? raw) {
    if (raw is String) {
      return TvSortOption.values.firstWhere(
        (option) => option.value == raw,
        orElse: () => TvSortOption.popularityDesc,
      );
    }
    return null;
  }

  static Set<MonetizationType> _parseMonetizationFromString(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const <MonetizationType>{};
    }
    final tokens = raw.split('|').map((value) => value.trim()).where(
          (value) => value.isNotEmpty,
        );
    return tokens
        .map((token) => MonetizationType.values.firstWhere(
              (type) => type.value == token,
              orElse: () => MonetizationType.flatrate,
            ))
        .toSet();
  }

  static List<MonetizationType> _parseMonetizationList(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<String>()
          .map((value) => MonetizationType.values.firstWhere(
                (type) => type.value == value,
                orElse: () => MonetizationType.flatrate,
              ))
          .toList(growable: false);
    }
    return const <MonetizationType>[];
  }

  static Set<TvStatus> _parseStatusCodes(String? raw) {
    if (raw == null || raw.isEmpty) return const <TvStatus>{};
    final tokens = raw.split(RegExp('[,|]')).map((value) => value.trim());
    final results = <TvStatus>{};
    for (final token in tokens) {
      if (token.isEmpty) continue;
      final asInt = int.tryParse(token);
      if (asInt != null) {
        final match = TvStatus.values.firstWhere(
          (status) => status.code == asInt,
          orElse: () => TvStatus.returningSeries,
        );
        results.add(match);
        continue;
      }
      final fallback = _statusByName[token.toLowerCase()];
      if (fallback != null) {
        results.add(fallback);
      }
    }
    return results;
  }

  static List<TvStatus> _parseStatusList(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<num>()
          .map((value) => value.toInt())
          .map((code) => TvStatus.values.firstWhere(
                (status) => status.code == code,
                orElse: () => TvStatus.returningSeries,
              ))
          .toList(growable: false);
    }
    return const <TvStatus>[];
  }

  static Set<TvShowType> _parseTypeCodes(String? raw) {
    if (raw == null || raw.isEmpty) return const <TvShowType>{};
    final tokens = raw.split(RegExp('[,|]')).map((value) => value.trim());
    final results = <TvShowType>{};
    for (final token in tokens) {
      if (token.isEmpty) continue;
      final asInt = int.tryParse(token);
      if (asInt != null) {
        final match = TvShowType.values.firstWhere(
          (type) => type.code == asInt,
          orElse: () => TvShowType.scripted,
        );
        results.add(match);
        continue;
      }
      final fallback = _typeByName[token.toLowerCase()];
      if (fallback != null) {
        results.add(fallback);
      }
    }
    return results;
  }

  static List<TvShowType> _parseTypeList(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<num>()
          .map((value) => value.toInt())
          .map((code) => TvShowType.values.firstWhere(
                (type) => type.code == code,
                orElse: () => TvShowType.scripted,
              ))
          .toList(growable: false);
    }
    return const <TvShowType>[];
  }

  static const Map<String, TvStatus> _statusByName = {
    'returning series': TvStatus.returningSeries,
    'planned': TvStatus.planned,
    'in production': TvStatus.inProduction,
    'ended': TvStatus.ended,
    'canceled': TvStatus.canceled,
    'cancelled': TvStatus.canceled,
    'pilot': TvStatus.pilot,
  };

  static const Map<String, TvShowType> _typeByName = {
    'scripted': TvShowType.scripted,
    'reality': TvShowType.reality,
    'documentary': TvShowType.documentary,
    'news': TvShowType.news,
    'talk show': TvShowType.talkShow,
    'talk-show': TvShowType.talkShow,
    'animation': TvShowType.animation,
    'miniseries': TvShowType.miniseries,
  };
}

@immutable
class TvDiscoverFilterPreset {
  const TvDiscoverFilterPreset({
    required this.name,
    required this.filters,
  });

  final String name;
  final TvDiscoverFilters filters;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'filters': filters.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory TvDiscoverFilterPreset.fromJson(Map<String, dynamic> json) {
    final rawFilters = json['filters'];
    final filters = rawFilters is Map<String, dynamic>
        ? TvDiscoverFilters.fromJson(rawFilters)
        : TvDiscoverFilters.fromQueryParameters(
            (rawFilters is Map)
                ? rawFilters.map((key, value) => MapEntry('$key', '$value'))
                : const <String, String>{},
          );
    final rawName = json['name'];
    final trimmedName = rawName is String ? rawName.trim() : null;
    return TvDiscoverFilterPreset(
      name: trimmedName ?? 'Preset',
      filters: filters,
    );
  }

  static TvDiscoverFilterPreset? fromJsonString(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return TvDiscoverFilterPreset.fromJson(decoded);
      }
    } catch (_) {
      // ignore malformed entries
    }
    return null;
  }

  TvDiscoverFilterPreset copyWith({
    String? name,
    TvDiscoverFilters? filters,
  }) {
    return TvDiscoverFilterPreset(
      name: name ?? this.name,
      filters: filters ?? this.filters,
    );
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
