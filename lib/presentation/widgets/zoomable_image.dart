import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/utils/media_image_helper.dart';
import '../../data/services/compressed_image_cache_manager.dart';

/// Displays a TMDB image with pinch/zoom interactions.
///
/// The widget is primarily used for assets fetched from the TMDB image CDN
/// via endpoints such as `/3/movie/{id}/images` and `/3/tv/{id}/images`.
/// The JSON response for those endpoints contains `file_path` values that
/// are converted to CDN URLs with [MediaImageHelper] and rendered with
/// `photo_view` for smooth zooming.
class ZoomableImage extends StatefulWidget {
  const ZoomableImage({
    super.key,
    required this.imagePath,
    required this.type,
    this.heroTag,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.padding = const EdgeInsets.all(12),
    this.onInteractionStart,
    this.onInteractionEnd,
    this.onTap,
  })  : assert(minScale > 0),
        assert(maxScale >= minScale);

  /// Raw TMDB image path (e.g. `/kqjL17yufvn9OVLyXYpvtyrFfak.jpg`).
  final String? imagePath;

  /// Category of the TMDB image (poster, backdrop, still...)
  final MediaImageType type;

  /// Optional hero tag to enable Hero transitions from thumbnails.
  final Object? heroTag;

  /// Minimum zoom level supported by the underlying [PhotoView].
  final double minScale;

  /// Maximum zoom level supported by [PhotoView].
  final double maxScale;

  /// Padding applied around the zoomable content.
  final EdgeInsets padding;

  /// Callback triggered when a user begins a gesture interaction.
  final VoidCallback? onInteractionStart;

  /// Callback triggered when the gesture interaction ends.
  final VoidCallback? onInteractionEnd;

  /// Callback triggered when the user performs a single tap.
  final VoidCallback? onTap;

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  PhotoViewScaleState? _lastScaleState = PhotoViewScaleState.initial;
  bool _isInteracting = false;
  Timer? _interactionEndTimer;
  int _activePointers = 0;

  @override
  void dispose() {
    _interactionEndTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = MediaImageHelper.buildUrl(
      widget.imagePath,
      type: widget.type,
      size: MediaImageSize.original,
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildFallbackPlaceholder();
    }

    final imageProvider = CachedNetworkImageProvider(
      imageUrl,
      cacheManager: CompressedImageCacheManager.instance,
    );

    final heroAttributes = widget.heroTag != null
        ? PhotoViewHeroAttributes(
            tag: widget.heroTag!,
            transitionOnUserGestures: true,
          )
        : null;

    return Padding(
      padding: widget.padding,
      child: Listener(
        onPointerDown: (_) => _handlePointerDown(),
        onPointerUp: (_) => _handlePointerUp(),
        onPointerCancel: (_) => _handlePointerUp(),
        child: PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration:
              const BoxDecoration(color: Colors.transparent),
          minScale: PhotoViewComputedScale.contained * widget.minScale,
          maxScale: PhotoViewComputedScale.contained * widget.maxScale,
          initialScale: PhotoViewComputedScale.contained * widget.minScale,
          heroAttributes: heroAttributes,
          loadingBuilder: _buildLoadingIndicator,
          errorBuilder: _buildErrorIndicator,
          onTapUp: (_, __, ___) => widget.onTap?.call(),
          onScaleEnd: _handleScaleEnd,
          scaleStateChangedCallback: _handleScaleStateChanged,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Widget _buildFallbackPlaceholder() {
    return Padding(
      padding: widget.padding,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, ImageChunkEvent? event) {
    final total = event?.expectedTotalBytes;
    final loaded = event?.cumulativeBytesLoaded ?? 0;
    final progress = total != null && total > 0 ? loaded / total : null;

    return Center(
      child: SizedBox(
        width: 42,
        height: 42,
        child: CircularProgressIndicator(value: progress),
      ),
    );
  }

  Widget _buildErrorIndicator(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: 48,
        color: Colors.white70,
      ),
    );
  }

  void _handleScaleStateChanged(PhotoViewScaleState state) {
    if (_lastScaleState == state) {
      return;
    }

    if (state == PhotoViewScaleState.initial) {
      _cancelInteractionEndTimer();
      _notifyInteractionEnd();
    } else if (_lastScaleState == PhotoViewScaleState.initial ||
        _lastScaleState == null) {
      _notifyInteractionStart();
    }

    if (state != PhotoViewScaleState.initial && _activePointers == 0) {
      _scheduleInteractionEndDebounce();
    }

    _lastScaleState = state;
  }

  void _handleScaleEnd(
    BuildContext context,
    ScaleEndDetails details,
    PhotoViewControllerValue controllerValue,
  ) {
    _cancelInteractionEndTimer();
    _notifyInteractionEnd();
  }

  void _handlePointerDown() {
    _activePointers++;
    _cancelInteractionEndTimer();
    if (_lastScaleState != PhotoViewScaleState.initial) {
      _notifyInteractionStart();
    }
  }

  void _handlePointerUp() {
    if (_activePointers > 0) {
      _activePointers--;
    }

    if (_activePointers == 0 && _lastScaleState != PhotoViewScaleState.initial) {
      _scheduleInteractionEndDebounce();
    }
  }

  void _scheduleInteractionEndDebounce() {
    _cancelInteractionEndTimer();
    _interactionEndTimer = Timer(
      const Duration(milliseconds: 240),
      () {
        if (_activePointers == 0) {
          _notifyInteractionEnd();
        }
      },
    );
  }

  void _cancelInteractionEndTimer() {
    _interactionEndTimer?.cancel();
    _interactionEndTimer = null;
  }

  void _notifyInteractionStart() {
    if (_isInteracting) {
      return;
    }
    _isInteracting = true;
    widget.onInteractionStart?.call();
  }

  void _notifyInteractionEnd() {
    if (!_isInteracting) {
      return;
    }
    _isInteracting = false;
    widget.onInteractionEnd?.call();
  }
}
