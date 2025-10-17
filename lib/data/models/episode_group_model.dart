import 'package:collection/collection.dart';

import 'network_model.dart';

class EpisodeGroup {
  const EpisodeGroup({
    required this.id,
    required this.name,
    this.description,
    this.episodeCount,
    this.groupCount,
    this.network,
    required this.type,
    this.groups = const <EpisodeGroupNode>[],
  });

  factory EpisodeGroup.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['groups'];
    return EpisodeGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      episodeCount: (json['episode_count'] as num?)?.toInt(),
      groupCount: (json['group_count'] as num?)?.toInt(),
      network: json['network'] is Map<String, dynamic>
          ? Network.fromJson(json['network'] as Map<String, dynamic>)
          : null,
      type: (json['type'] as num?)?.toInt() ?? 0,
      groups: rawGroups is List
          ? rawGroups
              .whereType<Map<String, dynamic>>()
              .map(EpisodeGroupNode.fromJson)
              .toList()
          : const <EpisodeGroupNode>[],
    );
  }

  final String id;
  final String name;
  final String? description;
  final int? episodeCount;
  final int? groupCount;
  final Network? network;
  final int type;
  final List<EpisodeGroupNode> groups;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'episode_count': episodeCount,
        'group_count': groupCount,
        'network': network?.toJson(),
        'type': type,
        'groups': groups.map((group) => group.toJson()).toList(),
      };

  static const _listEquality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpisodeGroup &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.episodeCount == episodeCount &&
        other.groupCount == groupCount &&
        other.network == network &&
        other.type == type &&
        _listEquality.equals(other.groups, groups);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        episodeCount,
        groupCount,
        network,
        type,
        _listEquality.hash(groups),
      );
}

class EpisodeGroupNode {
  const EpisodeGroupNode({
    required this.id,
    required this.name,
    this.order,
    this.lockOrder,
    this.overview,
    this.episodes = const <EpisodeGroupEpisode>[],
  });

  factory EpisodeGroupNode.fromJson(Map<String, dynamic> json) {
    final rawEpisodes = json['episodes'];
    return EpisodeGroupNode(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      order: (json['order'] as num?)?.toInt(),
      lockOrder: (json['lock_order'] as num?)?.toInt(),
      overview: json['overview'] as String?,
      episodes: rawEpisodes is List
          ? rawEpisodes
              .whereType<Map<String, dynamic>>()
              .map(EpisodeGroupEpisode.fromJson)
              .toList()
          : const <EpisodeGroupEpisode>[],
    );
  }

  final String id;
  final String name;
  final int? order;
  final int? lockOrder;
  final String? overview;
  final List<EpisodeGroupEpisode> episodes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'order': order,
        'lock_order': lockOrder,
        'overview': overview,
        'episodes': episodes.map((episode) => episode.toJson()).toList(),
      };

  static const _listEquality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpisodeGroupNode &&
        other.id == id &&
        other.name == name &&
        other.order == order &&
        other.lockOrder == lockOrder &&
        other.overview == overview &&
        _listEquality.equals(other.episodes, episodes);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        order,
        lockOrder,
        overview,
        _listEquality.hash(episodes),
      );
}

class EpisodeGroupEpisode {
  const EpisodeGroupEpisode({
    required this.id,
    required this.name,
    required this.episodeNumber,
    required this.seasonNumber,
    this.airDate,
    this.overview,
    this.productionCode,
    this.stillPath,
    this.voteAverage,
    this.voteCount,
    this.order,
  });

  factory EpisodeGroupEpisode.fromJson(Map<String, dynamic> json) {
    return EpisodeGroupEpisode(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      episodeNumber: (json['episode_number'] as num?)?.toInt() ?? 0,
      seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
      airDate: json['air_date'] as String?,
      overview: json['overview'] as String?,
      productionCode: json['production_code'] as String?,
      stillPath: json['still_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
      order: (json['order'] as num?)?.toInt(),
    );
  }

  final int id;
  final String name;
  final int episodeNumber;
  final int seasonNumber;
  final String? airDate;
  final String? overview;
  final String? productionCode;
  final String? stillPath;
  final double? voteAverage;
  final int? voteCount;
  final int? order;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'episode_number': episodeNumber,
        'season_number': seasonNumber,
        'air_date': airDate,
        'overview': overview,
        'production_code': productionCode,
        'still_path': stillPath,
        'vote_average': voteAverage,
        'vote_count': voteCount,
        'order': order,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpisodeGroupEpisode &&
        other.id == id &&
        other.name == name &&
        other.episodeNumber == episodeNumber &&
        other.seasonNumber == seasonNumber &&
        other.airDate == airDate &&
        other.overview == overview &&
        other.productionCode == productionCode &&
        other.stillPath == stillPath &&
        other.voteAverage == voteAverage &&
        other.voteCount == voteCount &&
        other.order == order;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        episodeNumber,
        seasonNumber,
        airDate,
        overview,
        productionCode,
        stillPath,
        voteAverage,
        voteCount,
        order,
      );
}
