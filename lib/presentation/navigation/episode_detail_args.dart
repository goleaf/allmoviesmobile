import '../../data/models/episode_model.dart';

/// Strongly typed navigation arguments for [EpisodeDetailScreen].
class EpisodeDetailArgs {
  const EpisodeDetailArgs({required this.tvId, required this.episode});

  /// TMDB television series identifier that owns the episode.
  final int tvId;

  /// Episode payload fetched from `GET /3/tv/{tv_id}/season/{season_number}/episode/{episode_number}`.
  final Episode episode;
}
