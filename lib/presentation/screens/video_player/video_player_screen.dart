import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  static const routeName = '/video-player';

  const VideoPlayerScreen({
    super.key,
    required this.videoKey,
    required this.title,
    this.site = 'YouTube',
    this.autoPlay = false,
  });

  final String videoKey;
  final String title;
  final String site; // e.g., YouTube
  final bool autoPlay;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _ytController;
  bool _isFullScreen = false;
  bool _autoPlay = false;

  @override
  void initState() {
    super.initState();
    _autoPlay = widget.autoPlay;
    if (widget.site.toLowerCase() == 'youtube') {
      _ytController = YoutubePlayerController(
        initialVideoId: widget.videoKey,
        flags: YoutubePlayerFlags(
          autoPlay: _autoPlay,
          enableCaption: true,
          controlsVisibleAtStart: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ytController == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Unsupported video provider')),
      );
    }

    return YoutubePlayerBuilder(
      onEnterFullScreen: () => setState(() => _isFullScreen = true),
      onExitFullScreen: () => setState(() => _isFullScreen = false),
      player: YoutubePlayer(
        controller: _ytController!,
        progressIndicatorColor: Theme.of(context).colorScheme.primary,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: _isFullScreen ? null : AppBar(title: Text(widget.title)),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: player),
              if (!_isFullScreen)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _ytController!.value.isPlaying
                            ? _ytController!.pause()
                            : _ytController!.play(),
                        icon: Icon(_ytController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                        label: Text(_ytController!.value.isPlaying
                            ? 'Pause'
                            : 'Play'),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Fullscreen',
                        onPressed: () => _ytController!.toggleFullScreenMode(),
                        icon: const Icon(Icons.fullscreen),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Text('Autoplay'),
                          Switch(
                            value: _autoPlay,
                            onChanged: (value) {
                              setState(() => _autoPlay = value);
                              // Apply by playing immediately when toggled on
                              if (value && !_ytController!.value.isPlaying) {
                                _ytController!.play();
                              }
                              if (!value && _ytController!.value.isPlaying) {
                                _ytController!.pause();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}


