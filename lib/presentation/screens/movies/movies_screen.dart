import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../widgets/media_section_screen.dart';

class MoviesScreen extends StatelessWidget {
  static const routeName = AppRoutes.movies;

  const MoviesScreen({super.key});

  static const List<MediaItem> _movies = [
    MediaItem(title: 'Infinite Horizon', subtitle: '2024 • Sci-Fi', icon: Icons.movie_creation_outlined),
    MediaItem(title: 'Shadow Lines', subtitle: '2023 • Thriller', icon: Icons.movie_filter_outlined),
    MediaItem(title: 'Celestial Dreams', subtitle: '2022 • Fantasy', icon: Icons.local_movies_outlined),
    MediaItem(title: 'Neon Pulse', subtitle: '2024 • Action', icon: Icons.slideshow_outlined),
    MediaItem(title: 'Echoes of Time', subtitle: '2021 • Drama', icon: Icons.theaters_outlined),
    MediaItem(title: 'Midnight Run', subtitle: '2022 • Adventure', icon: Icons.movie_outlined),
    MediaItem(title: 'Chromatic', subtitle: '2020 • Documentary', icon: Icons.ondemand_video_outlined),
    MediaItem(title: 'Silver Lining', subtitle: '2023 • Romance', icon: Icons.local_activity_outlined),
    MediaItem(title: 'Quantum Drift', subtitle: '2024 • Sci-Fi', icon: Icons.movie_creation_outlined),
    MediaItem(title: 'Blue Notes', subtitle: '2019 • Musical', icon: Icons.music_video_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return const MediaSectionScreen(
      title: 'Movies',
      titleIcon: Icons.movie_outlined,
      items: _movies,
      currentRoute: routeName,
      childAspectRatio: 0.65,
    );
  }
}
