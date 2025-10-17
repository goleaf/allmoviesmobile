import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/media_image_helper.dart';
import '../../data/models/image_model.dart';
import 'zoomable_image.dart';
import 'media_image.dart';

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
  bool _showChrome = true;

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

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(child: _buildBlurredBackdrop(image)),
          Column(
            children: [
              _GalleryTopBar(
                isVisible: _showChrome,
                currentIndex: _currentIndex,
                total: widget.images.length,
                onClose: _handleClose,
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
                        onInteractionStart: _handleInteractionStart,
                        onInteractionEnd: _handleInteractionEnd,
                      ),
                    );
                  },
                ),
              ),
              if (widget.images.length > 1)
                _ThumbnailStrip(
                  images: widget.images,
                  mediaType: widget.mediaType,
                  currentIndex: _currentIndex,
                  onTap: _jumpToIndex,
                ),
              const SizedBox(height: 24),
            ],
          ),
          _EdgeGradientOverlay(position: EdgeGradientPosition.top),
          _EdgeGradientOverlay(position: EdgeGradientPosition.bottom),
        ],
      ),
    );
  }

  Widget _buildBlurredBackdrop(ImageModel image) {
    final path = image.filePath;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: (path == null || path.isEmpty)
          ? const DecoratedBox(
              key: ValueKey('gallery::empty'),
              decoration: BoxDecoration(color: Colors.black),
            )
          : MediaImage(
              key: ValueKey(path),
              path: path,
              type: widget.mediaType,
              size: MediaImageSize.w780,
              previewSize: MediaImageSize.w300,
              fit: BoxFit.cover,
              enableBlur: true,
              blurSigmaX: 24,
              blurSigmaY: 24,
              enableProgress: false,
              placeholder: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black),
              ),
              errorWidget: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black),
              ),
              overlay: MediaImageOverlay(
                colorResolver: (_, __) => Colors.black.withOpacity(0.35),
              ),
            ),
    );
  }

  void _handleClose() {
    widget.onClose?.call();
    Navigator.of(context).maybePop();
  }

  void _jumpToIndex(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _handleInteractionStart() {
    if (!_showChrome) {
      return;
    }
    setState(() => _showChrome = false);
  }

  void _handleInteractionEnd() {
    if (_showChrome) {
      return;
    }
    setState(() => _showChrome = true);
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

class _GalleryTopBar extends StatelessWidget {
  const _GalleryTopBar({
    required this.isVisible,
    required this.currentIndex,
    required this.total,
    required this.onClose,
  });

  final bool isVisible;
  final int currentIndex;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 180),
      offset: isVisible ? Offset.zero : const Offset(0, -0.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isVisible ? 1 : 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
                const Spacer(),
                Text(
                  '${currentIndex + 1} / $total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({
    required this.images,
    required this.mediaType,
    required this.currentIndex,
    required this.onTap,
  });

  final List<ImageModel> images;
  final MediaImageType mediaType;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final image = images[index];
          final url = MediaImageHelper.buildPreviewUrl(
            image.filePath,
            type: mediaType,
            size: MediaImageSize.w154,
          );

          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                border: Border.all(
                  color: index == currentIndex
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white24,
                  width: index == currentIndex ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: image.aspectRatio > 0 ? image.aspectRatio : 1.5,
                  child: CachedNetworkImage(
                    imageUrl: url ?? '',
                    fit: BoxFit.cover,
                    memCacheHeight: 200,
                    placeholder: (context, _) => Container(
                      color: Colors.white12,
                    ),
                    errorWidget: (context, _, __) => Container(
                      color: Colors.white12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: images.length,
      ),
    );
  }
}
