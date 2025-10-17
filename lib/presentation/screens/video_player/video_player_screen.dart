import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  static const routeName = '/video-player';

  const VideoPlayerScreen({
    super.key,
    required this.videoKey,
    required this.title,
    this.site = 'YouTube',
    this.autoPlay = false,
    this.qualitySources,
  });

  final String videoKey;
  final String title;
  final String site; // e.g., YouTube
  final bool autoPlay;
  final Map<String, String>? qualitySources;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _ytController;
  VideoPlayerController? _nativeController;
  Future<void>? _nativeInitializeFuture;
  bool _isFullScreen = false;
  bool _autoPlay = false;
  String? _selectedQuality;

  static const Map<String, String> _youTubeQualityLabels = {
    'auto': 'Auto',
    'highres': '4320p',
    'hd2880': '2880p',
    'hd2160': '2160p',
    'hd1440': '1440p',
    'hd1080': '1080p',
    'hd720': '720p',
    'large': '480p',
    'medium': '360p',
    'small': '240p',
    'tiny': '144p',
  };

  void _handleYouTubeUpdates() {
    final controller = _ytController;
    if (controller == null) {
      return;
    }
    final quality = controller.value.playbackQuality;
    if (quality != null && quality != _selectedQuality) {
      setState(() {
        _selectedQuality = quality;
      });
    }
  }

  bool get _isYouTube => widget.site.toLowerCase() == 'youtube';

  Future<void> _initializeNativeController(
    String url, {
    Duration? startAt,
    bool? play,
  }) async {
    _nativeController?.removeListener(_onNativeControllerUpdate);
    await _nativeController?.dispose();
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    setState(() {
      _nativeController = controller;
      _nativeInitializeFuture = controller.initialize().then((_) async {
        if (startAt != null) {
          await controller.seekTo(startAt);
        }
        final shouldPlay = play ?? _autoPlay;
        if (shouldPlay) {
          await controller.play();
        }
        setState(() {});
      });
    });
    controller.addListener(_onNativeControllerUpdate);
  }

  void _onNativeControllerUpdate() {
    final controller = _nativeController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final isPlaying = controller.value.isPlaying;
    if (!isPlaying && _autoPlay) {
      // Ensure auto-play preference is respected if playback stops unexpectedly.
      controller.play();
    }
  }

  @override
  void initState() {
    super.initState();
    _autoPlay = widget.autoPlay;
    if (_isYouTube) {
      _ytController = YoutubePlayerController(
        initialVideoId: widget.videoKey,
        flags: YoutubePlayerFlags(
          autoPlay: _autoPlay,
          enableCaption: true,
          controlsVisibleAtStart: true,
        ),
      );
      _selectedQuality = 'auto';
      _ytController!.addListener(_handleYouTubeUpdates);
    } else {
      final qualitySources = widget.qualitySources;
      if (qualitySources != null && qualitySources.isNotEmpty) {
        final first = qualitySources.entries.first;
        _selectedQuality = first.key;
        unawaited(
          _initializeNativeController(
            first.value,
            play: _autoPlay,
          ),
        );
      } else {
        _selectedQuality = null;
        unawaited(
          _initializeNativeController(
            widget.videoKey,
            play: _autoPlay,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ytController?..removeListener(_handleYouTubeUpdates);
    _ytController?.dispose();
    _nativeController?..removeListener(_onNativeControllerUpdate);
    _nativeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isYouTube) {
      return _buildYouTubePlayer(context);
    }

    return _buildNativePlayer(context);
  }

  Widget _buildYouTubePlayer(BuildContext context) {
    if (_ytController == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Unsupported video provider')),
      );
    }

    final controller = _ytController!;
    final qualityOptions = _youTubeQualityLabels.keys.toList();
    final currentQuality = _selectedQuality ?? controller.value.playbackQuality ?? 'auto';

    return YoutubePlayerBuilder(
      onEnterFullScreen: () => setState(() => _isFullScreen = true),
      onExitFullScreen: () => setState(() => _isFullScreen = false),
      player: YoutubePlayer(
        controller: controller,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => controller.value.isPlaying
                                ? controller.pause()
                                : controller.play(),
                            icon: Icon(controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow),
                            label: Text(controller.value.isPlaying
                                ? 'Pause'
                                : 'Play'),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            tooltip: 'Fullscreen',
                            onPressed: controller.toggleFullScreenMode,
                            icon: const Icon(Icons.fullscreen),
                          ),
                          const Spacer(),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: qualityOptions.contains(currentQuality)
                                  ? currentQuality
                                  : 'auto',
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() => _selectedQuality = value);
                                // ignore: avoid_dynamic_calls
                                try {
                                  (controller as dynamic).setPlaybackQuality(value);
                                } catch (error) {
                                  debugPrint(
                                    'Playback quality selection not supported: $error',
                                  );
                                }
                              },
                              items: qualityOptions
                                  .map(
                                    (quality) => DropdownMenuItem<String>(
                                      value: quality,
                                      child: Text(
                                        _youTubeQualityLabels[quality] ?? quality,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              icon: const Icon(Icons.high_quality),
                              hint: const Text('Quality'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Autoplay'),
                          Switch(
                            value: _autoPlay,
                            onChanged: (value) {
                              setState(() => _autoPlay = value);
                              if (value && !controller.value.isPlaying) {
                                controller.play();
                              }
                              if (!value && controller.value.isPlaying) {
                                controller.pause();
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

  Widget _buildNativePlayer(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<void>(
        future: _nativeInitializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final controller = _nativeController;
          if (controller == null || !controller.value.isInitialized) {
            return const Center(child: Text('Unable to load video'));
          }

          final aspectRatio = controller.value.aspectRatio == 0
              ? 16 / 9
              : controller.value.aspectRatio;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: aspectRatio,
                child: VideoPlayer(controller),
              ),
              VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        });
                      },
                      icon: Icon(controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow),
                      label: Text(controller.value.isPlaying ? 'Pause' : 'Play'),
                    ),
                    const SizedBox(width: 12),
                    if ((widget.qualitySources?.length ?? 0) > 1)
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedQuality ?? widget.qualitySources!.keys.first,
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            _switchNativeQuality(value);
                          },
                          items: widget.qualitySources!.entries
                              .map(
                                (entry) => DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.key),
                                ),
                              )
                              .toList(),
                          icon: const Icon(Icons.high_quality),
                          hint: const Text('Quality'),
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        const Text('Autoplay'),
                        Switch(
                          value: _autoPlay,
                          onChanged: (value) {
                            setState(() => _autoPlay = value);
                            if (!value && controller.value.isPlaying) {
                              controller.pause();
                            }
                            if (value && !controller.value.isPlaying) {
                              controller.play();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _switchNativeQuality(String quality) async {
    final sources = widget.qualitySources;
    if (sources == null) {
      return;
    }
    final url = sources[quality];
    if (url == null) {
      return;
    }
    final controller = _nativeController;
    final wasPlaying = controller?.value.isPlaying ?? false;
    final position = controller?.value.position ?? Duration.zero;
    setState(() => _selectedQuality = quality);
    await _initializeNativeController(
      url,
      startAt: position,
      play: wasPlaying || _autoPlay,
    );
  }
}


