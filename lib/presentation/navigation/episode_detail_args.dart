import '../../data/models/episode_model.dart';

class EpisodeDetailArgs {
  final int tvId;
  final Episode episode;

  const EpisodeDetailArgs({
    required this.tvId,
    required this.episode,
  });
}
