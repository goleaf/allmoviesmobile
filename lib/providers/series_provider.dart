import 'package:flutter/material.dart';
import '../data/models/media_item.dart';

class SeriesProvider extends ChangeNotifier {
  final List<MediaItem> _series = const [
    MediaItem(
      title: 'The Last of Us',
      subtitle: '2023 • Drama',
      overview: 'Joel and Ellie traverse a post-pandemic United States.',
      rating: 8.9,
    ),
    MediaItem(
      title: 'Succession',
      subtitle: '2018 • Drama',
      overview: 'The Roy family fights for control of their media empire.',
      rating: 8.8,
    ),
    MediaItem(
      title: 'The Bear',
      subtitle: '2022 • Comedy-Drama',
      overview: 'A chef returns home to run his family sandwich shop.',
      rating: 8.5,
    ),
    MediaItem(
      title: 'Arcane',
      subtitle: '2021 • Animation',
      overview: 'Sisters Vi and Jinx clash amid unrest in Piltover and Zaun.',
      rating: 9.0,
    ),
    MediaItem(
      title: 'Severance',
      subtitle: '2022 • Sci-Fi',
      overview: 'Office workers separate their memories between work and personal life.',
      rating: 8.4,
    ),
  ];

  List<MediaItem> get series => List.unmodifiable(_series);
}
