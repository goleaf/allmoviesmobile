import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allmoviesmobile/data/models/video_model.dart';
import 'package:allmoviesmobile/presentation/screens/video_player/video_player_factory.dart';
import 'package:allmoviesmobile/presentation/screens/video_player/video_player_screen.dart';

void main() {
  setUp(() {
    VideoPlayerAdapterFactory.debugDisableVimeoInlinePlayback = true;
  });

  tearDown(() {
    VideoPlayerAdapterFactory.debugDisableVimeoInlinePlayback = false;
  });

  testWidgets('falls back to external launcher for Vimeo videos', (tester) async {
    const video = Video(
      key: '123456789',
      site: 'Vimeo',
      type: 'Trailer',
      name: 'Vimeo Sample',
      official: true,
      publishedAt: '2024-01-01T00:00:00Z',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: VideoPlayerScreen(
          args: VideoPlayerScreenArgs(
            videos: [video],
            title: 'Sample Video',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Vimeo videos open in the browser.'), findsOneWidget);
    expect(find.text('Open Vimeo'), findsOneWidget);
  });
}
