import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/models/video_model.dart';

class VideoPlayerScreenArgs {
  const VideoPlayerScreenArgs({
    required this.videos,
    this.initialVideoKey,
    this.title,
    this.autoPlay = false,
  });

  final List<Video> videos;
  final String? initialVideoKey;
  final String? title;
  final bool autoPlay;
}

class VideoPlayerScreen extends StatefulWidget {
  static const routeName = '/video-player';

  const VideoPlayerScreen({
    super.key,
    this.args,
  });

  final VideoPlayerScreenArgs? args;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerScreenArgs? _resolvedArgs;
  List<Video> _videos = const [];
  Video? _selectedVideo;
  String? _selectedType;
  bool _autoPlay = false;
  bool _initialized = false;
  bool _isFullScreen = false;
  bool _requestedQualityLevels = false;
  bool _qualityOptionsLoading = false;
  bool _qualityOptionsUnavailable = false;

  YoutubePlayerController? _ytController;
  List<String> _availableQualities = const [];
  String? _selectedQuality;

  @override
  void dispose() {
    _disposeYoutubeController();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    _resolvedArgs = widget.args ??
        (ModalRoute.of(context)?.settings.arguments as VideoPlayerScreenArgs?);
    final args = _resolvedArgs;
    if (args == null || args.videos.isEmpty) {
      return;
    }
    _videos = List<Video>.from(args.videos);
    _autoPlay = args.autoPlay;
    final initialVideo = _resolveInitialVideo(args);
    _selectVideo(initialVideo, notify: false);
  }

  Video _resolveInitialVideo(VideoPlayerScreenArgs args) {
    if (args.initialVideoKey != null) {
      for (final video in args.videos) {
        if (video.key == args.initialVideoKey) {
          return video;
        }
      }
    }
    return args.videos.first;
  }

  bool get _hasVideos => _videos.isNotEmpty;

  bool _isYoutube(Video video) => video.site.toLowerCase() == 'youtube';

  void _resetQualityState() {
    _requestedQualityLevels = false;
    _availableQualities = const [];
    _selectedQuality = null;
    _qualityOptionsLoading = false;
    _qualityOptionsUnavailable = false;
  }

  void _selectVideo(Video video, {bool notify = true}) {
    void updateSelection() {
      final isYoutubeVideo = _isYoutube(video);
      if (!isYoutubeVideo) {
        _disposeYoutubeController();
      }
      _selectedVideo = video;
      _selectedType = video.type;
      if (isYoutubeVideo) {
        if (_ytController == null) {
          _initializeYoutubeController(video);
        } else {
          _resetQualityState();
          if (_autoPlay) {
            _ytController!.load(video.key);
          } else {
            _ytController!.cue(video.key);
          }
        }
      }
    }

    if (notify) {
      setState(updateSelection);
    } else {
      updateSelection();
    }
  }

  void _initializeYoutubeController(Video video) {
    _disposeYoutubeController();
    _resetQualityState();
    _isFullScreen = false;

    final controller = YoutubePlayerController(
      initialVideoId: video.key,
      flags: YoutubePlayerFlags(
        autoPlay: _autoPlay,
        controlsVisibleAtStart: true,
        enableCaption: true,
      ),
    );

    controller.addListener(_handleYoutubeUpdates);
    _ytController = controller;
  }

  void _disposeYoutubeController() {
    final controller = _ytController;
    if (controller != null) {
      controller.removeListener(_handleYoutubeUpdates);
      controller.dispose();
    }
    _ytController = null;
    _resetQualityState();
    _isFullScreen = false;
  }

  Future<void> _handleQualityChange(String quality) async {
    final controller = _ytController;
    final webController = controller?.value.webViewController;
    if (controller == null || webController == null) {
      return;
    }

    final normalized = quality == 'auto' ? 'default' : quality;
    try {
      await webController.evaluateJavascript(
        source: 'setPlaybackQuality("$normalized")',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedQuality = quality;
      });
    } catch (error) {
      debugPrint('Failed to set playback quality: $error');
    }
  }

  Future<void> _loadYoutubeQualities() async {
    final controller = _ytController;
    final webController = controller?.value.webViewController;
    if (controller == null || webController == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _qualityOptionsLoading = true;
        _qualityOptionsUnavailable = false;
      });
    }

    try {
      final result = await webController.evaluateJavascript(
        source: 'JSON.stringify(getAvailableQualityLevels())',
      );
      if (!mounted) {
        return;
      }
      if (_ytController != controller) {
        return;
      }
      final qualities = _parseQualityLevels(result);
      final normalizedQualities = _normalizeQualityList(qualities);
      setState(() {
        _qualityOptionsLoading = false;
        if (normalizedQualities.isEmpty) {
          _availableQualities = const [];
          _qualityOptionsUnavailable = true;
          final normalizedCurrent =
              _normalizeQualityValue(controller.value.playbackQuality);
          if (normalizedCurrent != null) {
            _selectedQuality = normalizedCurrent;
          }
        } else if (!listEquals(normalizedQualities, _availableQualities)) {
          _availableQualities = normalizedQualities;
          _qualityOptionsUnavailable = false;
          if (_selectedQuality == null ||
              !_availableQualities.contains(_selectedQuality)) {
            _selectedQuality = _availableQualities.first;
          }
        } else {
          _qualityOptionsUnavailable = false;
        }
      });
    } catch (error) {
      debugPrint('Failed to load quality levels: $error');
      if (!mounted) {
        return;
      }
      if (_ytController != controller) {
        return;
      }
      setState(() {
        _qualityOptionsLoading = false;
        _qualityOptionsUnavailable = true;
      });
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
        // Ignore malformed results.
      }
    }
    return const [];
  }

  String? _normalizeQualityValue(String? quality) {
    if (quality == null || quality.isEmpty) {
      return null;
    }
    return quality == 'default' ? 'auto' : quality;
  }

  List<String> _normalizeQualityList(Iterable<String> qualities) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final quality in qualities) {
      final normalizedQuality = _normalizeQualityValue(quality);
      if (normalizedQuality != null && seen.add(normalizedQuality)) {
        normalized.add(normalizedQuality);
      }
    }
    return normalized;
  }

  List<String> _extractQualitiesFromValue(YoutubePlayerValue value) {
    final dynamic dynamicValue = value;
    final potentialLists = <dynamic>[];

    void safeAdd(dynamic Function() accessor) {
      try {
        final result = accessor();
        if (result != null) {
          potentialLists.add(result);
        }
      } catch (_) {
        // Ignore missing properties or API incompatibilities.
      }
    }

    safeAdd(() => dynamicValue.availableQualities);
    safeAdd(() => dynamicValue.availableQualityLevels);
    safeAdd(() => dynamicValue.metaData?.availableQualities);
    safeAdd(() => dynamicValue.metaData?.availableQualityLevels);
    safeAdd(() => dynamicValue.metadata?.availableQualities);
    safeAdd(() => dynamicValue.metadata?.availableQualityLevels);
    for (final potential in potentialLists) {
      if (potential is List) {
        final normalized = _normalizeQualityList(potential.whereType<String>());
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    }
    return const [];
  }

  void _handleYoutubeUpdates() {
    final controller = _ytController;
    if (controller == null || !mounted) {
      return;
    }
    final value = controller.value;
    if (value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = value.isFullScreen;
      });
    }
    final trackedQualities = _extractQualitiesFromValue(value);
    if (trackedQualities.isNotEmpty &&
        !listEquals(trackedQualities, _availableQualities)) {
      setState(() {
        _availableQualities = trackedQualities;
        _qualityOptionsLoading = false;
        _qualityOptionsUnavailable = false;
        if (_selectedQuality == null ||
            !_availableQualities.contains(_selectedQuality)) {
          _selectedQuality = _availableQualities.first;
        }
      });
    }
    final currentQuality = _normalizeQualityValue(value.playbackQuality);
    if (currentQuality != null && currentQuality != _selectedQuality) {
      final knownQualities =
          _availableQualities.isEmpty ? trackedQualities : _availableQualities;
      if (knownQualities.contains(currentQuality) || knownQualities.isEmpty) {
        setState(() {
          _selectedQuality = currentQuality;
        });
      }
    }
    if (value.isReady && !_requestedQualityLevels) {
      _requestedQualityLevels = true;
      _loadYoutubeQualities();
    }
  }

  Future<void> _toggleAutoPlay(bool value) async {
    setState(() {
      _autoPlay = value;
    });
    final controller = _ytController;
    if (controller == null) {
      return;
    }
    if (value) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  Iterable<String> get _availableTypes sync* {
    final seen = <String>{};
    for (final video in _videos) {
      if (seen.add(video.type)) {
        yield video.type;
      }
    }
  }

  void _onTypeSelected(String type) {
    if (_selectedType == type) {
      return;
    }
    for (final video in _videos) {
      if (video.type == type) {
        _selectVideo(video);
        return;
      }
    }
  }

  List<Video> get _videosForCurrentType {
    if (_selectedType == null) {
      return _videos;
    }
    final filtered =
        _videos.where((video) => video.type == _selectedType).toList();
    if (filtered.isEmpty) {
      return _videos;
    }
    return filtered;
  }

  String _formatPublishedDate(Video video) {
    final publishedAt = video.publishedAt;
    if (publishedAt.isEmpty) {
      return 'Unknown date';
    }
    final parsed = DateTime.tryParse(publishedAt);
    if (parsed == null) {
      return publishedAt;
    }
    return DateFormat.yMMMd().format(parsed.toLocal());
  }

  String _qualityLabel(String quality) {
    const labels = {
      'auto': 'Auto',
      'default': 'Auto',
      'highres': '2160p',
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
    return labels[quality] ?? quality.toUpperCase();
  }

  /// Builds the toolbar that hosts playback customization controls such as the
  /// YouTube quality picker and the autoplay toggle shown beneath the player
  /// when the video is not in fullscreen mode.
  Widget _buildPlaybackOptions({required bool showQualitySelector}) {
    final qualityOptions = <String>[..._availableQualities];
    if (showQualitySelector && qualityOptions.isNotEmpty) {
      if (!qualityOptions.contains('auto')) {
        qualityOptions.insert(0, 'auto');
      }
    }

    final currentQuality = showQualitySelector && qualityOptions.isNotEmpty
        ? (_selectedQuality != null &&
                qualityOptions.contains(_selectedQuality!)
            ? _selectedQuality!
            : qualityOptions.first)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (showQualitySelector)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.high_quality_outlined, size: 20),
                const SizedBox(width: 8),
                if (_qualityOptionsLoading)
                  const Text('Loading quality options...')
                else if (_qualityOptionsUnavailable)
                  Text(
                    'Quality selection unavailable',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).disabledColor),
                  )
                else if (qualityOptions.isEmpty)
                  const Text('Quality options unavailable')
                else
                  DropdownButton<String>(
                    value: currentQuality,
                    onChanged: (value) {
                      if (value != null) {
                        _handleQualityChange(value);
                      }
                    },
                    items: [
                      for (final quality in qualityOptions)
                        DropdownMenuItem<String>(
                          value: quality,
                          child: Text(_qualityLabel(quality)),
                        ),
                    ],
                  ),
              ],
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Autoplay'),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: _autoPlay,
                onChanged: (value) => _toggleAutoPlay(value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = _availableTypes.toList();
    if (types.length <= 1) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final type in types)
            ChoiceChip(
              label: Text(type),
              selected: _selectedType == type,
              onSelected: (selected) {
                if (selected) {
                  _onTypeSelected(type);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    final videos = _videosForCurrentType;
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: videos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final video = videos[index];
          final isSelected = _selectedVideo?.key == video.key;
          final published = _formatPublishedDate(video);
          return Material(
            color: isSelected
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.35)
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _selectVideo(video),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.play_circle_fill
                          : Icons.play_circle_outline,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${video.type} • ${video.site}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Published $published',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoSummary(Video video) {
    final published = _formatPublishedDate(video);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${video.type} • ${video.site} • $published',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Uri? _videoUri(Video video) {
    final key = video.key;
    switch (video.site.toLowerCase()) {
      case 'youtube':
        return Uri.parse('https://www.youtube.com/watch?v=$key');
      case 'vimeo':
        return Uri.parse('https://vimeo.com/$key');
      case 'dailymotion':
        return Uri.parse('https://www.dailymotion.com/video/$key');
      default:
        return null;
    }
  }

  Future<void> _launchExternal(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open ${uri.toString()}'),
        ),
      );
    }
  }

  Widget _buildExternalVideoPlaceholder(Video video) {
    final uri = _videoUri(video);
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.slideshow_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${video.site} videos open in the browser.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: uri == null ? null : () => _launchExternal(uri),
              icon: const Icon(Icons.open_in_new),
              label: Text(uri == null
                  ? 'No compatible link available'
                  : 'Open ${video.site}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaffold({
    required Video video,
    required Widget playerSection,
    required bool showQualitySelector,
  }) {
    final title = _resolvedArgs?.title ?? video.name;
    return Scaffold(
      appBar: _isFullScreen ? null : AppBar(title: Text(title)),
      body: SafeArea(
        child: !_hasVideos
            ? const Center(child: Text('No videos available.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  playerSection,
                  _buildVideoSummary(video),
                  _buildPlaybackOptions(
                    showQualitySelector: showQualitySelector,
                  ),
                  _buildTypeSelector(),
                  _buildVideoList(),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final video = _selectedVideo;
    if (!_hasVideos || video == null) {
      final title = _resolvedArgs?.title ?? 'Video Player';
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('No videos available.')),
      );
    }

    if (_isYoutube(video) && _ytController != null) {
      return YoutubePlayerBuilder(
        onEnterFullScreen: () => setState(() => _isFullScreen = true),
        onExitFullScreen: () => setState(() => _isFullScreen = false),
        player: YoutubePlayer(
          controller: _ytController!,
          progressIndicatorColor: Theme.of(context).colorScheme.primary,
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) {
          return _buildScaffold(
            video: video,
            showQualitySelector: true,
            playerSection: AspectRatio(
              aspectRatio: 16 / 9,
              child: player,
            ),
          );
        },
      );
    }

    return _buildScaffold(
      video: video,
      showQualitySelector: false,
      playerSection: AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildExternalVideoPlaceholder(video),
      ),
    );
  }
}


