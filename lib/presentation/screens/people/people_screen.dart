import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../widgets/media_section_screen.dart';

class PeopleScreen extends StatelessWidget {
  static const routeName = AppRoutes.people;

  const PeopleScreen({super.key});

  static const List<MediaItem> _people = [
    MediaItem(title: 'Ava Reynolds', subtitle: 'Actor • Known for "Neon Pulse"', icon: Icons.person_outline),
    MediaItem(title: 'Luca Martinez', subtitle: 'Director • "Shadow Lines"', icon: Icons.person_pin_outlined),
    MediaItem(title: 'Mei Chen', subtitle: 'Producer • "Celestial Dreams"', icon: Icons.person_search_outlined),
    MediaItem(title: 'Noah Patel', subtitle: 'Composer • "Blue Notes"', icon: Icons.person_outline),
    MediaItem(title: 'Sofia Dubois', subtitle: 'Actor • "Echoes of Time"', icon: Icons.person_outline),
    MediaItem(title: 'Elias Novak', subtitle: 'Writer • "Quantum Drift"', icon: Icons.person_outline),
    MediaItem(title: 'Harper Singh', subtitle: 'Cinematographer', icon: Icons.person_outline),
    MediaItem(title: 'Leo Fernandez', subtitle: 'Actor • "Midnight Run"', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return const MediaSectionScreen(
      title: 'People',
      titleIcon: Icons.person_search_outlined,
      items: _people,
      currentRoute: routeName,
      childAspectRatio: 0.9,
    );
  }
}
