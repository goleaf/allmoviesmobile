import 'movie.dart';
import 'movie_detailed_model.dart';
import 'tv_detailed_model.dart';

extension MovieDetailedMapper on MovieDetailed {
  Movie toMovieSummary() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      mediaType: 'movie',
      releaseDate: releaseDate,
      runtime: runtime,
      voteAverage: voteAverage,
      voteCount: voteCount,
      popularity: popularity,
      originalLanguage: null,
      originalTitle: originalTitle,
      adult: false,
      genreIds: genres.map((genre) => genre.id).toList(),
      status: status,
    );
  }
}

extension TVDetailedMapper on TVDetailed {
  Movie toMovieSummaryFromTv() {
    final runtime = episodeRunTime.isNotEmpty ? episodeRunTime.first : null;
    return Movie(
      id: id,
      title: name,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      mediaType: 'tv',
      releaseDate: firstAirDate,
      runtime: runtime,
      voteAverage: voteAverage,
      voteCount: voteCount,
      popularity: popularity,
      originalLanguage: null,
      originalTitle: originalName,
      adult: false,
      genreIds: genres.map((genre) => genre.id).toList(),
      status: status,
    );
  }
}
