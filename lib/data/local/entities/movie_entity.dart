import 'package:hive/hive.dart';

import '../../models/movie.dart';

const int movieEntityTypeId = 1;

class MovieEntity extends HiveObject {
  MovieEntity({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.mediaType,
    this.releaseDate,
    this.runtime,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.originalLanguage,
    this.originalTitle,
    this.adult = false,
    this.genreIds,
    this.status,
  });

  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? mediaType;
  final String? releaseDate;
  final int? runtime;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;
  final String? originalLanguage;
  final String? originalTitle;
  final bool adult;
  final List<int>? genreIds;
  final String? status;

  factory MovieEntity.fromMovie(Movie movie) {
    return MovieEntity(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      mediaType: movie.mediaType,
      releaseDate: movie.releaseDate,
      runtime: movie.runtime,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      popularity: movie.popularity,
      originalLanguage: movie.originalLanguage,
      originalTitle: movie.originalTitle,
      adult: movie.adult,
      genreIds: movie.genreIds,
      status: movie.status,
    );
  }

  Movie toMovie() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      mediaType: mediaType,
      releaseDate: releaseDate,
      runtime: runtime,
      voteAverage: voteAverage,
      voteCount: voteCount,
      popularity: popularity,
      originalLanguage: originalLanguage,
      originalTitle: originalTitle,
      adult: adult,
      genreIds: genreIds,
      status: status,
    );
  }
}

class MovieEntityAdapter extends TypeAdapter<MovieEntity> {
  @override
  final int typeId = movieEntityTypeId;

  @override
  MovieEntity read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0, count = reader.readByte(); i < count; i++) reader.readByte(): reader.read(),
    };
    return MovieEntity(
      id: fields[0] as int,
      title: fields[1] as String,
      overview: fields[2] as String?,
      posterPath: fields[3] as String?,
      backdropPath: fields[4] as String?,
      mediaType: fields[5] as String?,
      releaseDate: fields[6] as String?,
      runtime: fields[7] as int?,
      voteAverage: fields[8] as double?,
      voteCount: fields[9] as int?,
      popularity: fields[10] as double?,
      originalLanguage: fields[11] as String?,
      originalTitle: fields[12] as String?,
      adult: fields[13] as bool? ?? false,
      genreIds: (fields[14] as List?)?.cast<int>(),
      status: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieEntity obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.overview)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.backdropPath)
      ..writeByte(5)
      ..write(obj.mediaType)
      ..writeByte(6)
      ..write(obj.releaseDate)
      ..writeByte(7)
      ..write(obj.runtime)
      ..writeByte(8)
      ..write(obj.voteAverage)
      ..writeByte(9)
      ..write(obj.voteCount)
      ..writeByte(10)
      ..write(obj.popularity)
      ..writeByte(11)
      ..write(obj.originalLanguage)
      ..writeByte(12)
      ..write(obj.originalTitle)
      ..writeByte(13)
      ..write(obj.adult)
      ..writeByte(14)
      ..write(obj.genreIds)
      ..writeByte(15)
      ..write(obj.status);
  }
}
