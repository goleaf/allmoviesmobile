import 'external_ids_model.dart';
import 'image_model.dart';
import '../../core/utils/media_image_helper.dart';

class PersonDetail {
  PersonDetail({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.knownForDepartment,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.gender,
    List<String>? alsoKnownAs,
    this.popularity,
    this.externalIds,
    List<ImageModel>? profiles,
    List<PersonTaggedImage>? taggedImages,
    PersonCredits? combinedCredits,
    PersonCredits? movieCredits,
    PersonCredits? tvCredits,
    List<PersonTranslation>? translations,
  })  : alsoKnownAs = alsoKnownAs ?? const <String>[],
        profiles = profiles ?? const <ImageModel>[],
        taggedImages = taggedImages ?? const <PersonTaggedImage>[],
        combinedCredits = combinedCredits ?? const PersonCredits(),
        movieCredits = movieCredits ?? const PersonCredits(),
        tvCredits = tvCredits ?? const PersonCredits(),
        translations = translations ?? const <PersonTranslation>[];

  final int id;
  final String name;
  final String? profilePath;
  final String? biography;
  final String? knownForDepartment;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final int? gender;
  final List<String> alsoKnownAs;
  final double? popularity;
  final ExternalIds? externalIds;
  final List<ImageModel> profiles;
  final List<PersonTaggedImage> taggedImages;
  final PersonCredits combinedCredits;
  final PersonCredits movieCredits;
  final PersonCredits tvCredits;
  final List<PersonTranslation> translations;

  factory PersonDetail.fromJson(Map<String, dynamic> json) {
    final alsoKnownAs = (json['also_known_as'] as List?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    final imagesJson = json['images'] as Map<String, dynamic>?;
    final profiles = (imagesJson?['profiles'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(ImageModel.fromJson)
            .toList() ??
        const <ImageModel>[];
    final taggedJson = json['tagged_images'] as Map<String, dynamic>?;
    final taggedImages = (taggedJson?['results'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(PersonTaggedImage.fromJson)
            .toList() ??
        const <PersonTaggedImage>[];
    final combined = json['combined_credits'] as Map<String, dynamic>?;
    final movie = json['movie_credits'] as Map<String, dynamic>?;
    final tv = json['tv_credits'] as Map<String, dynamic>?;
    final translationsJson = json['translations'] as Map<String, dynamic>?;
    final translations = (translationsJson?['translations'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(PersonTranslation.fromJson)
            .toList() ??
        const <PersonTranslation>[];

    return PersonDetail(
      id: json['id'] as int,
      name: (json['name'] as String?)?.trim() ?? '',
      profilePath: json['profile_path'] as String?,
      biography: (json['biography'] as String?)?.trim(),
      knownForDepartment: (json['known_for_department'] as String?)?.trim(),
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: (json['place_of_birth'] as String?)?.trim(),
      gender: json['gender'] as int?,
      alsoKnownAs: alsoKnownAs,
      popularity: (json['popularity'] as num?)?.toDouble(),
      externalIds: json['external_ids'] == null
          ? null
          : ExternalIds.fromJson(
              (json['external_ids'] as Map<String, dynamic>),
            ),
      profiles: profiles,
      taggedImages: taggedImages,
      combinedCredits: combined == null
          ? const PersonCredits()
          : PersonCredits.fromJson(combined),
      movieCredits:
          movie == null ? const PersonCredits() : PersonCredits.fromJson(movie),
      tvCredits: tv == null ? const PersonCredits() : PersonCredits.fromJson(tv),
      translations: translations,
    );
  }

  String? get profileUrl => MediaImageHelper.buildUrl(
        profilePath,
        type: MediaImageType.profile,
        size: MediaImageSize.w500,
      );
}

class PersonCredits {
  const PersonCredits({
    List<PersonCredit>? cast,
    List<PersonCredit>? crew,
  })  : cast = cast ?? const <PersonCredit>[],
        crew = crew ?? const <PersonCredit>[];

  factory PersonCredits.fromJson(Map<String, dynamic> json) {
    final cast = (json['cast'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(PersonCredit.fromJson)
            .toList() ??
        const <PersonCredit>[];
    final crew = (json['crew'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(PersonCredit.fromJson)
            .toList() ??
        const <PersonCredit>[];
    return PersonCredits(cast: cast, crew: crew);
  }

  final List<PersonCredit> cast;
  final List<PersonCredit> crew;
}

class PersonCredit {
  const PersonCredit({
    required this.id,
    this.creditId,
    this.mediaType,
    this.title,
    this.name,
    this.character,
    this.job,
    this.department,
    this.releaseDate,
    this.firstAirDate,
    this.episodeCount,
    this.posterPath,
    this.backdropPath,
    this.popularity,
    this.voteAverage,
    this.voteCount,
    this.order,
  });

  factory PersonCredit.fromJson(Map<String, dynamic> json) {
    return PersonCredit(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      creditId: json['credit_id'] as String?,
      mediaType: json['media_type'] as String?,
      title: (json['title'] as String?)?.trim(),
      name: (json['name'] as String?)?.trim(),
      character: (json['character'] as String?)?.trim(),
      job: (json['job'] as String?)?.trim(),
      department: (json['department'] as String?)?.trim(),
      releaseDate: json['release_date'] as String?,
      firstAirDate: json['first_air_date'] as String?,
      episodeCount: json['episode_count'] as int?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      order: json['order'] as int?,
    );
  }

  final int id;
  final String? creditId;
  final String? mediaType;
  final String? title;
  final String? name;
  final String? character;
  final String? job;
  final String? department;
  final String? releaseDate;
  final String? firstAirDate;
  final int? episodeCount;
  final String? posterPath;
  final String? backdropPath;
  final double? popularity;
  final double? voteAverage;
  final int? voteCount;
  final int? order;

  String get displayTitle {
    final resolved = (title ?? name ?? '').trim();
    return resolved.isEmpty ? 'Untitled' : resolved;
  }

  String? get posterUrl => MediaImageHelper.buildUrl(
        posterPath,
        type: MediaImageType.poster,
        size: MediaImageSize.w342,
      );

  DateTime? get parsedDate {
    final raw = (releaseDate?.isNotEmpty ?? false) == true
        ? releaseDate
        : firstAirDate;
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  String? get releaseYear => parsedDate?.year.toString();
}

class PersonTaggedImage {
  PersonTaggedImage({
    required this.filePath,
    required this.aspectRatio,
    required this.height,
    required this.width,
    this.voteAverage,
    this.voteCount,
    this.mediaType,
    this.media,
  });

  factory PersonTaggedImage.fromJson(Map<String, dynamic> json) {
    return PersonTaggedImage(
      filePath: json['file_path'] as String,
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble() ?? 1,
      height: json['height'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      mediaType: json['media_type'] as String?,
      media: json['media'] is Map<String, dynamic>
          ? PersonTaggedMedia.fromJson(json['media'] as Map<String, dynamic>)
          : null,
    );
  }

  final String filePath;
  final double aspectRatio;
  final int height;
  final int width;
  final double? voteAverage;
  final int? voteCount;
  final String? mediaType;
  final PersonTaggedMedia? media;
}

class PersonTaggedMedia {
  PersonTaggedMedia({
    required this.id,
    this.title,
    this.name,
    this.character,
    this.job,
    this.mediaType,
    this.releaseDate,
    this.firstAirDate,
    this.posterPath,
  });

  factory PersonTaggedMedia.fromJson(Map<String, dynamic> json) {
    return PersonTaggedMedia(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] as String?)?.trim(),
      name: (json['name'] as String?)?.trim(),
      character: (json['character'] as String?)?.trim(),
      job: (json['job'] as String?)?.trim(),
      mediaType: json['media_type'] as String?,
      releaseDate: json['release_date'] as String?,
      firstAirDate: json['first_air_date'] as String?,
      posterPath: json['poster_path'] as String?,
    );
  }

  final int id;
  final String? title;
  final String? name;
  final String? character;
  final String? job;
  final String? mediaType;
  final String? releaseDate;
  final String? firstAirDate;
  final String? posterPath;
}

class PersonTranslation {
  PersonTranslation({
    this.iso31661,
    this.iso6391,
    this.name,
    this.englishName,
    this.biography,
  });

  factory PersonTranslation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return PersonTranslation(
      iso31661: json['iso_3166_1'] as String?,
      iso6391: json['iso_639_1'] as String?,
      name: json['name'] as String?,
      englishName: json['english_name'] as String?,
      biography: data == null ? null : data['biography'] as String?,
    );
  }

  final String? iso31661;
  final String? iso6391;
  final String? name;
  final String? englishName;
  final String? biography;
}

extension PersonTranslationListX on List<PersonTranslation> {
  List<PersonTranslation> get withUniqueLocales {
    final seen = <String>{};
    final result = <PersonTranslation>[];
    for (final translation in this) {
      final key = '${translation.iso31661 ?? ''}-${translation.iso6391 ?? ''}';
      if (seen.add(key)) {
        result.add(translation);
      }
    }
    return result;
  }
}

extension PersonTaggedMediaX on PersonTaggedMedia {
  String? get titleOrName {
    final value = (title ?? name ?? '').trim();
    return value.isEmpty ? null : value;
  }
}

