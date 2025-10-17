import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';

typedef GalleryLoader = Future<MediaImages> Function(
  int id, {
  bool forceRefresh,
});

class StubTmdbRepository extends TmdbRepository {
  StubTmdbRepository({this.movieLoader, this.tvLoader}) : super(apiKey: 'test');

  final GalleryLoader? movieLoader;
  final GalleryLoader? tvLoader;

  @override
  Future<MediaImages> fetchMovieImages(
    int movieId, {
    bool forceRefresh = false,
  }) {
    final loader = movieLoader;
    if (loader != null) {
      return loader(movieId, forceRefresh: forceRefresh);
    }
    return Future.value(MediaImages.empty());
  }

  @override
  Future<MediaImages> fetchTvImages(
    int tvId, {
    bool forceRefresh = false,
  }) {
    final loader = tvLoader;
    if (loader != null) {
      return loader(tvId, forceRefresh: forceRefresh);
    }
    return Future.value(MediaImages.empty());
  }
}
