import 'package:flutter/material.dart';

import '../../widgets/media_section_screen.dart';

class VideosScreen extends StatelessWidget {
  static const routeName = '/videos';

  const VideosScreen({super.key});

  static const List<MediaItem> _videoItems = [
    MediaItem(
      title: 'Trailers',
      subtitle: 'Official previews from studios and distributors.',
      icon: Icons.play_circle_outline,
    ),
    MediaItem(
      title: 'Teasers',
      subtitle: 'First-look snippets to build anticipation.',
      icon: Icons.movie_filter_outlined,
    ),
    MediaItem(
      title: 'Promos',
      subtitle: 'Broadcast promos and exclusive campaign cuts.',
      icon: Icons.campaign_outlined,
    ),
    MediaItem(
      title: 'Clips',
      subtitle: 'Hand-picked scene highlights and memorable moments.',
      icon: Icons.video_collection_outlined,
    ),
    MediaItem(
      title: 'Featurettes',
      subtitle: 'Deep dives with cast and crew commentary.',
      icon: Icons.recent_actors_outlined,
    ),
    MediaItem(
      title: 'Behind the Scenes',
      subtitle: 'On-set footage showcasing the production process.',
      icon: Icons.theaters_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const MediaSectionScreen(
      title: 'Videos',
      titleIcon: Icons.slow_motion_video_outlined,
      items: _videoItems,
      currentRoute: routeName,
      childAspectRatio: 0.75,
    );
  }
}
