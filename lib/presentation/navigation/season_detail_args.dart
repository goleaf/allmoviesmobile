import '../../data/models/episode_model.dart';

class SeasonDetailArgs {
  final int tvId;
  final int seasonNumber;

  const SeasonDetailArgs({required this.tvId, required this.seasonNumber});
}

class EpisodeDetailArgs {
  final int tvId;
  final Episode episode;

  const EpisodeDetailArgs({required this.tvId, required this.episode});
}
