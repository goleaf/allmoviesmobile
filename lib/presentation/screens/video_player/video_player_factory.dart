import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/models/video_model.dart';

/// Metadata describing the interactive capabilities of a given player.
///
/// The information allows the rest of the UI to remain provider agnostic
/// when deciding which controls to render.
class VideoPlayerMetadata {
  const VideoPlayerMetadata({
    required this.providerId,
    required this.displayName,
    required this.supportsFullscreen,
    required this.supportsPlayPause,
    required this.supportsAutoplay,
    required this.supportsQualitySelection,
    required this.supportsCaptions,
  });

  /// Identifier describing the backing provider (e.g. `youtube`).
  final String providerId;

  /// User facing name of the provider.
  final String displayName;

  final bool supportsFullscreen;
  final bool supportsPlayPause;
  final bool supportsAutoplay;
  final bool supportsQualitySelection;
  final bool supportsCaptions;
}

/// Base contract for player adapters.
///
/// Implementations bridge a [Video] object into a self-contained widget while
/// exposing reactive state for the hosting screen.
abstract class VideoPlayerAdapter {
  VideoPlayerMetadata get metadata;

  /// Tracks whether the underlying widget is currently fullscreen.
  ValueNotifier<bool> get isFullScreen;

  /// Exposes the known playback quality levels.
  ValueNotifier<List<String>> get availableQualities;

  /// Reflects the currently selected quality if any.
  ValueNotifier<String?> get selectedQuality;

  /// Preferred display aspect ratio.
  double get aspectRatio;

  /// Returns the widget that renders the actual video surface.
  Widget buildPlayer(BuildContext context);

  /// Initializes the adapter.
  Future<void> initialize();

  /// Responds to the autoplay toggle.
  Future<void> handleAutoPlayChange(bool autoPlay);

  /// Requests the provider to change quality, if supported.
  Future<void> handleQualityChange(String quality);

  /// Cleans up any platform resources.
  void dispose();
}

/// Convenience layer that orchestrates the appropriate adapter for a [Video].
class VideoPlayerAdapterFactory {
  VideoPlayerAdapterFactory._();

  /// When `true` the Vimeo adapter will force the inline player even on
  /// platforms that are typically unsupported (for example in widget tests).
  /// This is primarily useful for integration tests.
  static bool debugForceVimeoInlinePlayback = false;

  /// When `true` the Vimeo adapter will always fall back to the external
  /// launcher placeholder.
  static bool debugDisableVimeoInlinePlayback = false;

  /// When `true` the Chewie adapter (local streams) will be skipped entirely
  /// and the app will fall back to the external launcher placeholder. This
  /// keeps unit tests deterministic.
  static bool debugDisableChewie = false;

  /// Builds the correct adapter for [video].
  static VideoPlayerAdapter create(
    Video video, {
    required bool autoPlay,
    required Widget Function({required Video video, Uri? uri})
        fallbackBuilder,
  }) {
    final normalizedSite = video.site.toLowerCase();
    if (normalizedSite == 'youtube') {
      return YoutubeVideoPlayerAdapter(video: video, autoPlay: autoPlay);
    }

    if (normalizedSite == 'vimeo') {
      final allowInlinePlayback = !debugDisableVimeoInlinePlayback &&
          (debugForceVimeoInlinePlayback ||
              _isVimeoSupportedPlatform(defaultTargetPlatform));
      if (allowInlinePlayback) {
        return VimeoVideoPlayerAdapter(video: video, autoPlay: autoPlay);
      }
      return ExternalVideoPlaceholderAdapter(
        video: video,
        metadata: const VideoPlayerMetadata(
          providerId: 'vimeo',
          displayName: 'Vimeo',
          supportsFullscreen: false,
          supportsPlayPause: false,
          supportsAutoplay: false,
          supportsQualitySelection: false,
          supportsCaptions: false,
        ),
        builder: fallbackBuilder,
      );
    }

    if (normalizedSite == 'local' || normalizedSite == 'trailers') {
      if (debugDisableChewie) {
        return ExternalVideoPlaceholderAdapter(
          video: video,
          metadata: const VideoPlayerMetadata(
            providerId: 'local',
            displayName: 'Local',
            supportsFullscreen: false,
            supportsPlayPause: false,
            supportsAutoplay: false,
            supportsQualitySelection: false,
            supportsCaptions: false,
          ),
          builder: fallbackBuilder,
        );
      }
      return LocalStreamVideoPlayerAdapter(video: video, autoPlay: autoPlay);
    }

    return ExternalVideoPlaceholderAdapter(
      video: video,
      metadata: VideoPlayerMetadata(
        providerId: normalizedSite,
        displayName: video.site,
        supportsFullscreen: false,
        supportsPlayPause: false,
        supportsAutoplay: false,
        supportsQualitySelection: false,
        supportsCaptions: false,
      ),
      builder: fallbackBuilder,
    );
  }

  static bool _isVimeoSupportedPlatform(TargetPlatform platform) {
    if (kIsWeb) {
      return false;
    }
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }
}

class YoutubeVideoPlayerAdapter implements VideoPlayerAdapter {
  YoutubeVideoPlayerAdapter({
    required this.video,
    required this.autoPlay,
  });

  final Video video;
  final bool autoPlay;

  YoutubePlayerController? _controller;
  bool _requestedQualityLevels = false;

  @override
  final ValueNotifier<bool> isFullScreen = ValueNotifier<bool>(false);

  @override
  final ValueNotifier<List<String>> availableQualities =
      ValueNotifier<List<String>>(<String>[]);

  @override
  final ValueNotifier<String?> selectedQuality = ValueNotifier<String?>(null);

  @override
  double get aspectRatio => 16 / 9;

  @override
  VideoPlayerMetadata get metadata => const VideoPlayerMetadata(
        providerId: 'youtube',
        displayName: 'YouTube',
        supportsFullscreen: true,
        supportsPlayPause: true,
        supportsAutoplay: true,
        supportsQualitySelection: true,
        supportsCaptions: true,
      );

  YoutubePlayerController? get controller => _controller;

  @override
  Future<void> initialize() async {
    dispose();
    _requestedQualityLevels = false;
    availableQualities.value = const [];
    selectedQuality.value = null;
    isFullScreen.value = false;

    final flags = YoutubePlayerFlags(
      autoPlay: autoPlay,
      controlsVisibleAtStart: true,
      enableCaption: true,
    );

    final newController = YoutubePlayerController(
      initialVideoId: video.key,
      flags: flags,
    );
    newController.addListener(_handleUpdates);
    _controller = newController;
  }

  @override
  Widget buildPlayer(BuildContext context) {
    final activeController = controller;
    if (activeController == null) {
      return const SizedBox.shrink();
    }
    return YoutubePlayerBuilder(
      onEnterFullScreen: () => isFullScreen.value = true,
      onExitFullScreen: () => isFullScreen.value = false,
      player: YoutubePlayer(
        controller: activeController,
        progressIndicatorColor: Theme.of(context).colorScheme.primary,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) => player,
    );
  }

  @override
  Future<void> handleAutoPlayChange(bool value) async {
    final activeController = controller;
    if (activeController == null) {
      return;
    }
    if (value) {
      activeController.play();
    } else {
      activeController.pause();
    }
  }

  @override
  Future<void> handleQualityChange(String quality) async {
    final activeController = controller;
    final webController = activeController?.value.webViewController;
    if (activeController == null || webController == null) {
      return;
    }

    final normalized = quality == 'auto' ? 'default' : quality;
    try {
      await webController.evaluateJavascript(
        source: 'setPlaybackQuality("$normalized")',
      );
      selectedQuality.value = quality;
    } catch (error) {
      debugPrint('Failed to set playback quality: $error');
    }
  }

  void _handleUpdates() {
    final activeController = controller;
    if (activeController == null) {
      return;
    }
    final value = activeController.value;
    if (value.isFullScreen != isFullScreen.value) {
      isFullScreen.value = value.isFullScreen;
    }
    final playbackQuality = value.playbackQuality;
    if (playbackQuality != null && playbackQuality != selectedQuality.value) {
      final qualities = availableQualities.value;
      if (qualities.contains(playbackQuality) || qualities.isEmpty) {
        selectedQuality.value = playbackQuality;
      }
    }

    if (value.isReady && !_requestedQualityLevels) {
      _requestedQualityLevels = true;
      _loadQualities(activeController);
    }
  }

  Future<void> _loadQualities(YoutubePlayerController controller) async {
    final webController = controller.value.webViewController;
    if (webController == null) {
      return;
    }
    try {
      final result = await webController.evaluateJavascript(
        source: 'JSON.stringify(getAvailableQualityLevels())',
      );
      final qualities = _parseQualityLevels(result);
      if (qualities.isEmpty) {
        return;
      }
      if (!listEquals(qualities, availableQualities.value)) {
        availableQualities.value = qualities;
        final current = selectedQuality.value;
        if (current == null || !qualities.contains(current)) {
          selectedQuality.value = qualities.first;
        }
      }
    } catch (error) {
      debugPrint('Failed to load quality levels: $error');
    }
  }

  List<String> _parseQualityLevels(dynamic result) {
    if (result == null) {
      return const [];
    }
    if (result is List) {
      return result.whereType<String>().toList();
    }
    if (result is String) {
      try {
        final decoded = jsonDecode(result);
        if (decoded is List) {
          return decoded.whereType<String>().toList();
        }
      } catch (_) {
        // Ignore malformed responses.
      }
    }
    return const [];
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleUpdates);
    _controller?.dispose();
    _controller = null;
    _requestedQualityLevels = false;
    availableQualities.value = const [];
    selectedQuality.value = null;
    isFullScreen.value = false;
  }
}

class VimeoVideoPlayerAdapter implements VideoPlayerAdapter {
  VimeoVideoPlayerAdapter({
    required this.video,
    required this.autoPlay,
  });

  final Video video;
  final bool autoPlay;
  final ValueNotifier<bool> _autoPlayNotifier = ValueNotifier<bool>(false);

  @override
  final ValueNotifier<bool> isFullScreen = ValueNotifier<bool>(false);

  @override
  final ValueNotifier<List<String>> availableQualities =
      ValueNotifier<List<String>>(<String>[]);

  @override
  final ValueNotifier<String?> selectedQuality = ValueNotifier<String?>(null);

  @override
  double get aspectRatio => 16 / 9;

  @override
  VideoPlayerMetadata get metadata => const VideoPlayerMetadata(
        providerId: 'vimeo',
        displayName: 'Vimeo',
        supportsFullscreen: true,
        supportsPlayPause: true,
        supportsAutoplay: true,
        supportsQualitySelection: false,
        supportsCaptions: true,
      );

  @override
  Future<void> initialize() async {
    isFullScreen.value = false;
    _autoPlayNotifier.value = autoPlay;
  }

  @override
  Widget buildPlayer(BuildContext context) {
    return _VimeoInlinePlayer(
      videoId: video.key,
      autoPlayNotifier: _autoPlayNotifier,
      onFullScreenChanged: (isFullscreen) => isFullScreen.value = isFullscreen,
    );
  }

  @override
  Future<void> handleAutoPlayChange(bool autoPlay) async {
    if (_autoPlayNotifier.value != autoPlay) {
      _autoPlayNotifier.value = autoPlay;
    }
  }

  @override
  Future<void> handleQualityChange(String quality) async {
    // Vimeo player does not currently expose quality controls through the
    // public JavaScript API without additional plumbing. Left intentionally
    // empty until the provider adds support.
  }

  @override
  void dispose() {
    isFullScreen.value = false;
    _autoPlayNotifier.dispose();
  }
}

class LocalStreamVideoPlayerAdapter implements VideoPlayerAdapter {
  LocalStreamVideoPlayerAdapter({
    required this.video,
    required this.autoPlay,
  });

  final Video video;
  final bool autoPlay;

  ChewieController? _chewieController;
  VideoPlayerController? _videoController;
  VoidCallback? _chewieListener;

  @override
  final ValueNotifier<bool> isFullScreen = ValueNotifier<bool>(false);

  @override
  final ValueNotifier<List<String>> availableQualities =
      ValueNotifier<List<String>>(<String>[]);

  @override
  final ValueNotifier<String?> selectedQuality = ValueNotifier<String?>(null);

  @override
  double get aspectRatio => 16 / 9;

  @override
  VideoPlayerMetadata get metadata => const VideoPlayerMetadata(
        providerId: 'local',
        displayName: 'Local Stream',
        supportsFullscreen: true,
        supportsPlayPause: true,
        supportsAutoplay: true,
        supportsQualitySelection: false,
        supportsCaptions: false,
      );

  ChewieController? get controller => _chewieController;

  @override
  Future<void> initialize() async {
    dispose();
    isFullScreen.value = false;
    final uri = Uri.tryParse(video.key);
    if (uri == null) {
      return;
    }

    final videoController = uri.scheme.isEmpty
        ? VideoPlayerController.asset(video.key)
        : VideoPlayerController.networkUrl(uri);
    _videoController = videoController;
    try {
      await videoController.initialize();
      final chewie = ChewieController(
        videoPlayerController: videoController,
        autoPlay: autoPlay,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: false,
      );
      _chewieListener = _handleChewieUpdates;
      chewie.addListener(_chewieListener!);
      _chewieController = chewie;
    } catch (error) {
      debugPrint('Failed to initialize local video controller: $error');
    }
  }

  @override
  Widget buildPlayer(BuildContext context) {
    final chewie = controller;
    if (chewie == null) {
      return const Center(
        child: Text('Video preview unavailable for this source.'),
      );
    }
    return Chewie(
      controller: chewie,
    );
  }

  @override
  Future<void> handleAutoPlayChange(bool value) async {
    final videoController = _videoController;
    if (videoController == null) {
      return;
    }
    if (!videoController.value.isInitialized) {
      return;
    }
    if (value) {
      await videoController.play();
    } else {
      await videoController.pause();
    }
  }

  @override
  Future<void> handleQualityChange(String quality) async {
    // Local trailers do not currently expose multiple qualities.
  }

  @override
  void dispose() {
    final chewie = _chewieController;
    if (chewie != null && _chewieListener != null) {
      chewie.removeListener(_chewieListener!);
    }
    _chewieListener = null;
    chewie?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
    isFullScreen.value = false;
  }

  void _handleChewieUpdates() {
    final controller = _chewieController;
    if (controller == null) {
      return;
    }
    final fullscreen = controller.isFullScreen;
    if (isFullScreen.value != fullscreen) {
      isFullScreen.value = fullscreen;
    }
  }
}

class ExternalVideoPlaceholderAdapter implements VideoPlayerAdapter {
  ExternalVideoPlaceholderAdapter({
    required this.video,
    required this.metadata,
    required this.builder,
  });

  final Video video;
  @override
  final VideoPlayerMetadata metadata;
  final Widget Function({required Video video, Uri? uri}) builder;

  @override
  final ValueNotifier<bool> isFullScreen = ValueNotifier<bool>(false);

  @override
  final ValueNotifier<List<String>> availableQualities =
      ValueNotifier<List<String>>(<String>[]);

  @override
  final ValueNotifier<String?> selectedQuality = ValueNotifier<String?>(null);

  @override
  double get aspectRatio => 16 / 9;

  @override
  Future<void> initialize() async {}

  @override
  Widget buildPlayer(BuildContext context) {
    return builder(video: video, uri: _videoUri(video));
  }

  Uri? _videoUri(Video video) {
    final uri = Uri.tryParse(video.key);
    if (uri == null || (!uri.hasScheme && !uri.hasAuthority)) {
      return null;
    }
    return uri;
  }

  @override
  Future<void> handleAutoPlayChange(bool autoPlay) async {}

  @override
  Future<void> handleQualityChange(String quality) async {}

  @override
  void dispose() {}
}

class _VimeoInlinePlayer extends StatefulWidget {
  const _VimeoInlinePlayer({
    required this.videoId,
    required this.autoPlayNotifier,
    required this.onFullScreenChanged,
  });

  final String videoId;
  final ValueNotifier<bool> autoPlayNotifier;
  final ValueChanged<bool> onFullScreenChanged;

  @override
  State<_VimeoInlinePlayer> createState() => _VimeoInlinePlayerState();
}

class _VimeoInlinePlayerState extends State<_VimeoInlinePlayer> {
  bool _isFullScreen = false;
  late bool _autoPlay;
  late VoidCallback _autoPlayListener;
  InAppWebViewController? _webController;

  void _toggleFullscreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    widget.onFullScreenChanged(_isFullScreen);
  }

  @override
  void initState() {
    super.initState();
    _autoPlay = widget.autoPlayNotifier.value;
    _autoPlayListener = () {
      final nextValue = widget.autoPlayNotifier.value;
      if (_autoPlay != nextValue) {
        setState(() {
          _autoPlay = nextValue;
        });
        _syncAutoPlay(nextValue);
      }
    };
    widget.autoPlayNotifier.addListener(_autoPlayListener);
  }

  @override
  void didUpdateWidget(covariant _VimeoInlinePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlayNotifier != widget.autoPlayNotifier) {
      oldWidget.autoPlayNotifier.removeListener(_autoPlayListener);
      _autoPlay = widget.autoPlayNotifier.value;
      widget.autoPlayNotifier.addListener(_autoPlayListener);
      _syncAutoPlay(_autoPlay);
    }
  }

  @override
  void dispose() {
    widget.autoPlayNotifier.removeListener(_autoPlayListener);
    _webController = null;
    super.dispose();
  }

  void _handleWebViewReady(InAppWebViewController controller) {
    _webController = controller;
    _syncAutoPlay(_autoPlay);
  }

  void _syncAutoPlay(bool shouldPlay) {
    final controller = _webController;
    if (controller == null) {
      return;
    }
    final command = shouldPlay ? 'play' : 'pause';
    unawaited(
      controller.evaluateJavascript(source: 'player.$command();').catchError(
            (error) => debugPrint('Failed to toggle Vimeo playback: $error'),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = VimeoVideoPlayer(
      key: ValueKey('${widget.videoId}_${_autoPlay ? 'autoplay' : 'paused'}'),
      videoId: widget.videoId,
      isAutoPlay: _autoPlay,
      showControls: true,
      onReady: () => widget.onFullScreenChanged(_isFullScreen),
      onInAppWebViewCreated: _handleWebViewReady,
    );

    return Stack(
      children: [
        Positioned.fill(child: player),
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton.small(
            heroTag: 'vimeo_fullscreen_${widget.videoId}',
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            onPressed: _toggleFullscreen,
            child: Icon(
              _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
          ),
        ),
      ],
    );
  }
}

