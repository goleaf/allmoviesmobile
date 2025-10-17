import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../widgets/media_section_screen.dart';

class SeriesScreen extends StatelessWidget {
  static const routeName = AppRoutes.series;

  const SeriesScreen({super.key});

  static const List<MediaItem> _series = [
    MediaItem(title: 'Galactic Frontier', subtitle: 'Season 3 • Sci-Fi', icon: Icons.tv_outlined),
    MediaItem(title: 'Harbor Lights', subtitle: 'Season 1 • Drama', icon: Icons.live_tv_outlined),
    MediaItem(title: 'Codebreakers', subtitle: 'Season 2 • Thriller', icon: Icons.tv_rounded),
    MediaItem(title: 'Atlas Rising', subtitle: 'Limited Series • Documentary', icon: Icons.tv),
    MediaItem(title: 'Neon Alley', subtitle: 'Season 4 • Action', icon: Icons.slow_motion_video_outlined),
    MediaItem(title: 'The Archivist', subtitle: 'Season 1 • Mystery', icon: Icons.tv_off_outlined),
    MediaItem(title: 'Second Sun', subtitle: 'Season 2 • Drama', icon: Icons.tv_sharp),
    MediaItem(title: 'Canvas', subtitle: 'Season 1 • Anthology', icon: Icons.tv),
  ];

  @override
  Widget build(BuildContext context) {
    return const MediaSectionScreen(
      title: 'Series',
      titleIcon: Icons.tv_outlined,
      items: _series,
      currentRoute: routeName,
      childAspectRatio: 0.75,
    );
  }
}
