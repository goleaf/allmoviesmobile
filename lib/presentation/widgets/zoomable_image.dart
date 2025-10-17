import 'package:flutter/material.dart';

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

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  late final TransformationController _controller;
  AnimationController? _animationController;
  Animation<Matrix4>? _zoomAnimation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _controller.dispose();
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

    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController: _controller,
          clipBehavior: Clip.none,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          onInteractionStart: (_) => widget.onInteractionStart?.call(),
          onInteractionEnd: (_) => widget.onInteractionEnd?.call(),
          child: image,
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    widget.onInteractionStart?.call();
    final position = _doubleTapDetails?.localPosition;
    final currentMatrix = _controller.value;
    final isZoomed = !_isIdentityMatrix(currentMatrix);

    _animationController?.dispose();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    final targetMatrix = isZoomed
        ? Matrix4.identity()
        : _zoomMatrix(position ?? Offset.zero, widget.maxScale);

    _zoomAnimation = Matrix4Tween(begin: currentMatrix, end: targetMatrix)
        .animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ))
      ..addListener(() {
        _controller.value = _zoomAnimation!.value;
      });

    _animationController!
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          widget.onInteractionEnd?.call();
        }
      })
      ..forward();
  }

  Matrix4 _zoomMatrix(Offset focalPoint, double scale) {
    final translation = Matrix4.identity()
      ..translate(-focalPoint.dx * (scale - 1), -focalPoint.dy * (scale - 1));
    return translation..scale(scale);
  }

  bool _isIdentityMatrix(Matrix4 matrix) {
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 4; column++) {
        final expected = row == column ? 1.0 : 0.0;
        if ((matrix.storage[row * 4 + column] - expected).abs() > 0.01) {
          return false;
        }
      }
    }
    return true;
  }
}
