import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/utils/media_image_helper.dart';
import 'media_image.dart';

/// Displays a TMDB image with pinch/zoom interactions.
///
/// The widget is primarily used for assets fetched from the TMDB image CDN
/// via endpoints such as `/3/movie/{id}/images` and `/3/tv/{id}/images`.
/// The JSON response for those endpoints contains `file_path` values that
/// are forwarded to [MediaImage] to resolve the image URLs.
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

  /// Minimum zoom level supported by [InteractiveViewer].
  final double minScale;

  /// Maximum zoom level supported by [InteractiveViewer].
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
  late final PhotoViewController _photoViewController;
  late final PhotoViewScaleStateController _scaleStateController;
  StreamSubscription<PhotoViewControllerValue>? _controllerSubscription;
  PhotoViewControllerValue? _lastControllerValue;
  PhotoViewScaleState? _lastScaleState;
  bool _isInteracting = false;
  bool _isControllerCoolingDown = false;
  Timer? _cooldownTimer;
  Timer? _doubleTapTimer;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _scaleStateController = PhotoViewScaleStateController();
    _lastScaleState = PhotoViewScaleState.initial;
    _controllerSubscription =
        _photoViewController.outputStateStream.listen(_handleControllerValue);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _doubleTapTimer?.cancel();
    _controllerSubscription?.cancel();
    _photoViewController.dispose();
    _scaleStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget image = MediaImage(
      path: widget.imagePath,
      type: widget.type,
      size: MediaImageSize.original,
      fit: BoxFit.contain,
      placeholder: const Center(child: CircularProgressIndicator()),
      errorWidget: const Center(
        child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.white70),
      ),
      enableProgress: false,
    );

    final heroAttributes = widget.heroTag == null
        ? null
        : PhotoViewHeroAttributes(tag: widget.heroTag!);

    return Padding(
      padding: widget.padding,
      child: PhotoView.customChild(
        controller: _photoViewController,
        scaleStateController: _scaleStateController,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        initialScale: widget.minScale,
        basePosition: Alignment.center,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        heroAttributes: heroAttributes,
        scaleStateChangedCallback: _handleScaleStateChange,
        onScaleEnd: _handleScaleEnd,
        onTapUp: (_, __, ___) => widget.onTap?.call(),
        child: image,
      ),
    );
  }

  void _handleControllerValue(PhotoViewControllerValue value) {
    if (_lastControllerValue == null) {
      _lastControllerValue = value;
      return;
    }

    if (_isControllerCoolingDown) {
      _lastControllerValue = value;
      return;
    }

    if (!_isInteracting && value != _lastControllerValue) {
      _notifyInteractionStart();
    }

    _lastControllerValue = value;
  }

  void _handleScaleStateChange(PhotoViewScaleState state) {
    final previous = _lastScaleState;
    _lastScaleState = state;

    if (previous == null) {
      return;
    }

    final startedFromInitial = previous == PhotoViewScaleState.initial &&
        state != PhotoViewScaleState.initial;

    final isDoubleTapTarget = state == PhotoViewScaleState.covering ||
        state == PhotoViewScaleState.originalSize;

    if (startedFromInitial && isDoubleTapTarget) {
      final didStart = _notifyInteractionStart();
      if (!didStart) {
        return;
      }
      _doubleTapTimer?.cancel();
      _doubleTapTimer = Timer(const Duration(milliseconds: 260), () {
        _finishInteraction();
      });
      return;
    }

    if (state == PhotoViewScaleState.initial) {
      _doubleTapTimer?.cancel();
      _finishInteraction();
    }
  }

  void _handleScaleEnd(
    BuildContext context,
    ScaleEndDetails details,
    PhotoViewControllerValue controllerValue,
  ) {
    _doubleTapTimer?.cancel();
    _finishInteraction();
  }

  bool _notifyInteractionStart() {
    if (_isInteracting) {
      return false;
    }
    _cooldownTimer?.cancel();
    _isControllerCoolingDown = false;
    _isInteracting = true;
    widget.onInteractionStart?.call();
    return true;
  }

  void _finishInteraction() {
    if (!_isInteracting) {
      return;
    }
    _isInteracting = false;
    widget.onInteractionEnd?.call();
    _startCooldown();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _isControllerCoolingDown = true;
    _cooldownTimer = Timer(const Duration(milliseconds: 180), () {
      _isControllerCoolingDown = false;
    });
  }
}
