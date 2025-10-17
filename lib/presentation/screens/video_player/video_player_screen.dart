import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'video_player_factory.dart';

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
  List<String> _availableQualities = const [];
  String? _selectedQuality;
  VideoPlayerAdapter? _adapter;
  VideoPlayerMetadata? _metadata;
  VoidCallback? _fullScreenListener;
  VoidCallback? _qualityListener;
  VoidCallback? _selectedQualityListener;

  @override
  void dispose() {
    _removeAdapterListeners();
    _adapter?.dispose();
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
    unawaited(_selectVideo(initialVideo, notify: false));
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

  Future<void> _selectVideo(Video video, {bool notify = true}) async {
    await _activateAdapter(video);
    void updateSelection() {
      _selectedVideo = video;
      _selectedType = video.type;
    }

    if (!mounted) {
      return;
    }

    if (notify) {
      setState(updateSelection);
    } else {
      updateSelection();
    }
  }

  Future<void> _activateAdapter(Video video) async {
    _removeAdapterListeners();
    final previousAdapter = _adapter;
    _adapter = null;
    previousAdapter?.dispose();

    final adapter = VideoPlayerAdapterFactory.create(
      video,
      autoPlay: _autoPlay,
      fallbackBuilder: ({required Video video, Uri? uri}) =>
          _buildExternalVideoPlaceholder(video, uri: uri),
    );
    await adapter.initialize();
    if (!mounted) {
      adapter.dispose();
      return;
    }

    setState(() {
      _adapter = adapter;
      _metadata = adapter.metadata;
      _isFullScreen = adapter.isFullScreen.value;
      _availableQualities = adapter.availableQualities.value;
      _selectedQuality = adapter.selectedQuality.value;
    });

    _fullScreenListener = () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isFullScreen = adapter.isFullScreen.value;
      });
    };
    adapter.isFullScreen.addListener(_fullScreenListener!);

    _qualityListener = () {
      if (!mounted) {
        return;
      }
      setState(() {
        _availableQualities = adapter.availableQualities.value;
        if (_selectedQuality != null &&
            !_availableQualities.contains(_selectedQuality)) {
          _selectedQuality =
              _availableQualities.isEmpty ? null : _availableQualities.first;
        }
      });
    };
    adapter.availableQualities.addListener(_qualityListener!);

    _selectedQualityListener = () {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedQuality = adapter.selectedQuality.value;
      });
    };
    adapter.selectedQuality.addListener(_selectedQualityListener!);
  }

  void _removeAdapterListeners() {
    final adapter = _adapter;
    if (adapter != null) {
      if (_fullScreenListener != null) {
        adapter.isFullScreen.removeListener(_fullScreenListener!);
      }
      if (_qualityListener != null) {
        adapter.availableQualities.removeListener(_qualityListener!);
      }
      if (_selectedQualityListener != null) {
        adapter.selectedQuality.removeListener(_selectedQualityListener!);
      }
    }
    _fullScreenListener = null;
    _qualityListener = null;
    _selectedQualityListener = null;
  }

  Future<void> _handleQualityChange(String quality) async {
    final adapter = _adapter;
    if (adapter == null) {
      return;
    }
    await adapter.handleQualityChange(quality);
  }

  Future<void> _toggleAutoPlay(bool value) async {
    setState(() {
      _autoPlay = value;
    });
    final adapter = _adapter;
    if (adapter == null) {
      return;
    }
    await adapter.handleAutoPlayChange(value);
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
        unawaited(_selectVideo(video));
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

  Widget _buildPlaybackOptions({
    required bool showQualitySelector,
    required bool allowAutoPlayToggle,
  }) {
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
                onChanged:
                    allowAutoPlayToggle ? (value) => _toggleAutoPlay(value) : null,
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
              onTap: () => unawaited(_selectVideo(video)),
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

  Widget _buildExternalVideoPlaceholder(Video video, {Uri? uri}) {
    final effectiveUri = uri ?? _videoUri(video);
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
              onPressed: effectiveUri == null
                  ? null
                  : () => _launchExternal(effectiveUri),
              icon: const Icon(Icons.open_in_new),
              label: Text(effectiveUri == null
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
    required bool allowAutoPlayToggle,
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
                  allowAutoPlayToggle: allowAutoPlayToggle,
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
    final adapter = _adapter;
    final metadata = _metadata;
    if (!_hasVideos || video == null || adapter == null || metadata == null) {
      final title = _resolvedArgs?.title ?? 'Video Player';
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('No videos available.')),
      );
    }

    return _buildScaffold(
      video: video,
      showQualitySelector: metadata.supportsQualitySelection,
      allowAutoPlayToggle: metadata.supportsAutoplay,
      playerSection: AspectRatio(
        aspectRatio: adapter.aspectRatio,
        child: adapter.buildPlayer(context),
      ),
    );
  }
}


