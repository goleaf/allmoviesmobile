import 'package:flutter/material.dart';
import '../data/models/media_item.dart';

class MoviesProvider extends ChangeNotifier {
  final List<MediaItem> _movies = const [
    MediaItem(
      title: 'Inception',
      subtitle: '2010 • Sci-Fi',
      overview: 'A thief enters dreams to steal secrets and plant new ideas.',
      rating: 8.8,
    ),
    MediaItem(
      title: 'Dune: Part Two',
      subtitle: '2024 • Adventure',
      overview: 'Paul Atreides unites the Fremen in a fight against House Harkonnen.',
      rating: 8.6,
    ),
    MediaItem(
      title: 'Spider-Man: Across the Spider-Verse',
      subtitle: '2023 • Animation',
      overview: 'Miles Morales catapults across the multiverse to face a new villain.',
      rating: 8.7,
    ),
    MediaItem(
      title: 'The Batman',
      subtitle: '2022 • Action',
      overview: 'Bruce Wayne faces a serial killer leaving riddles across Gotham.',
      rating: 7.9,
    ),
    MediaItem(
      title: 'Oppenheimer',
      subtitle: '2023 • Drama',
      overview: 'The story of J. Robert Oppenheimer and the creation of the atomic bomb.',
      rating: 8.4,
    ),
  ];

  List<MediaItem> get movies => List.unmodifiable(_movies);
}
