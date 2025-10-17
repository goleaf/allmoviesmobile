import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/media_image_helper.dart';
import '../../data/models/image_model.dart';
import 'zoomable_image.dart';

/// Fullscreen gallery that presents TMDB media images with zoom support.
///
/// The widget expects `ImageModel` instances produced by endpoints like
/// `/3/movie/{id}/images` or `/3/tv/{id}/images`, whose JSON payload includes
/// `file_path` entries. Those paths are passed to the [ZoomableImage] widget
/// to build original-sized assets while a blurred backdrop uses medium-sized
/// variants.
class ImageGallery extends StatefulWidget {
  const ImageGallery({
    super.key,
    required this.images,
    required this.mediaType,
    this.initialIndex = 0,
    this.heroTagBuilder,
    this.onClose,
  }) : assert(images.length > 0);

  /// Images to display in the gallery.
  final List<ImageModel> images;

  /// TMDB media type for resolving CDN URLs.
  final MediaImageType mediaType;

  /// Initial index to display when the gallery opens.
  final int initialIndex;

  /// Optional builder that returns a Hero tag per image index.
  final Object? Function(int index, ImageModel image)? heroTagBuilder;

  /// Callback invoked when the gallery is dismissed.
  final VoidCallback? onClose;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = widget.images[_currentIndex];
    final backgroundUrl = MediaImageHelper.buildPreviewUrl(
      image.filePath,
      type: widget.mediaType,
      size: MediaImageSize.w780,
    );

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(child: _buildBlurredBackdrop(backgroundUrl)),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _handleClose,
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      ),
                      const Spacer(),
                      Text(
                        '${_currentIndex + 1} / ${widget.images.length}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final img = widget.images[index];
                    final heroTag = widget.heroTagBuilder?.call(index, img);
                    return Center(
                      child: ZoomableImage(
                        imagePath: img.filePath,
                        type: widget.mediaType,
                        heroTag: heroTag,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
          _EdgeGradientOverlay(position: EdgeGradientPosition.top),
          _EdgeGradientOverlay(position: EdgeGradientPosition.bottom),
        ],
      ),
    );
  }

  Widget _buildBlurredBackdrop(String? url) {
    if (url == null) {
      return Container(color: Colors.black);
    }

    final imageProvider = CachedNetworkImageProvider(url, cacheKey: 'gallery::$url');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ImageFiltered(
        key: ValueKey(url),
        imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35),
                BlendMode.darken,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleClose() {
    widget.onClose?.call();
    Navigator.of(context).maybePop();
  }
}

enum EdgeGradientPosition { top, bottom }

class _EdgeGradientOverlay extends StatelessWidget {
  const _EdgeGradientOverlay({required this.position});

  final EdgeGradientPosition position;

  @override
  Widget build(BuildContext context) {
    final begin = position == EdgeGradientPosition.top
        ? Alignment.topCenter
        : Alignment.bottomCenter;
    final end = position == EdgeGradientPosition.top
        ? Alignment.bottomCenter
        : Alignment.topCenter;

    return Positioned(
      top: position == EdgeGradientPosition.top ? 0 : null,
      bottom: position == EdgeGradientPosition.bottom ? 0 : null,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
