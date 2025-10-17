import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/media_image_helper.dart';
import '../../data/services/compressed_image_cache_manager.dart';
import '../../data/services/network_quality_service.dart';

class MediaImage extends StatefulWidget {
  const MediaImage({
    super.key,
    required this.path,
    this.type = MediaImageType.poster,
    this.size,
    this.previewSize,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enableProgress = true,
    this.fadeInDuration = const Duration(milliseconds: 450),
    this.crossFadeDuration = const Duration(milliseconds: 280),
    this.overlay = const MediaImageOverlay.none(),
    this.enableBlur = false,
    this.blurSigmaX = 18,
    this.blurSigmaY = 18,
  });

  final String? path;
  final MediaImageType type;
  final MediaImageSize? size;
  final MediaImageSize? previewSize;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableProgress;
  final Duration fadeInDuration;
  final Duration crossFadeDuration;
  final MediaImageOverlay overlay;
  final bool enableBlur;
  final double blurSigmaX;
  final double blurSigmaY;

  @override
  State<MediaImage> createState() => _MediaImageState();
}

class _MediaImageState extends State<MediaImage> {
  bool _isHighResReady = false;
  double? _progress;
  String? _lastPath;

  @override
  void initState() {
    super.initState();
    _lastPath = widget.path;
    if (widget.path != null && widget.path!.isNotEmpty) {
      _progress = 0;
    }
  }

  @override
  void didUpdateWidget(MediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.path != _lastPath) {
      _lastPath = widget.path;
      _isHighResReady = false;
      if (widget.path != null && widget.path!.isNotEmpty) {
        _progress = 0;
      } else {
        _progress = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size ??
        MediaImageHelper.resolvePreferredSize(
          context,
          type: widget.type,
          fallback: null,
          networkQuality:
              Provider.maybeOf<NetworkQualityNotifier>(context)?.quality,
        );
    final highResUrl = MediaImageHelper.buildUrl(
      widget.path,
      type: widget.type,
      size: effectiveSize,
    );
    final previewUrl = MediaImageHelper.buildPreviewUrl(
      widget.path,
      type: widget.type,
      size: widget.previewSize,
    );

    final placeholder =
        widget.placeholder ??
        _DefaultPlaceholder(
          width: widget.width,
          height: widget.height,
          type: widget.type,
        );

    final errorWidget =
        widget.errorWidget ??
        _DefaultError(
          width: widget.width,
          height: widget.height,
          type: widget.type,
        );

    if (highResUrl == null) {
      return _wrapWithSize(_withSemantics(placeholder));
    }

    final preview = _buildPreviewLayer(previewUrl, placeholder);
    final image = _buildHighResLayer(highResUrl, errorWidget);
    final progressIndicator =
        (_progress != null && widget.enableProgress && !_isHighResReady)
        ? _buildProgressOverlay()
        : const SizedBox.shrink();

    final overlayLayer = _buildOverlay(context);

    final imageLayers = <Widget>[
      if (preview != null) preview,
      image,
    ];

    Widget content = Stack(
      fit: StackFit.expand,
      children: imageLayers,
    );

    if (widget.enableBlur) {
      content = ClipRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: widget.blurSigmaX,
            sigmaY: widget.blurSigmaY,
          ),
          child: content,
        ),
      );
    }

    final stackChildren = <Widget>[
      content,
      if (overlayLayer != null) overlayLayer,
      progressIndicator,
    ];

    final stack = Stack(
      fit: StackFit.expand,
      children: stackChildren,
    );

    final imageContent = ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: stack,
    );

    return _wrapWithSize(_withSemantics(imageContent));
  }

  Widget? _buildPreviewLayer(String? previewUrl, Widget placeholder) {
    if (previewUrl == null) {
      return AnimatedOpacity(
        opacity: _isHighResReady ? 0 : 1,
        duration: widget.crossFadeDuration,
        child: placeholder,
      );
    }

    final imageProvider = CachedNetworkImageProvider(
      previewUrl,
      cacheKey: 'preview::$previewUrl',
      cacheManager: CompressedImageCacheManager.instance,
    );

    return AnimatedOpacity(
      opacity: _isHighResReady ? 0 : 1,
      duration: widget.crossFadeDuration,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: widget.fit),
          ),
        ),
      ),
    );
  }

  Widget _buildHighResLayer(String url, Widget errorWidget) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: CompressedImageCacheManager.instance,
      fit: widget.fit,
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: Duration.zero,
      // Avoid providing both placeholder and progressIndicatorBuilder to OctoImage
      placeholder: null,
      progressIndicatorBuilder: (context, _, downloadProgress) {
        _updateProgress(downloadProgress.progress);
        return const SizedBox.shrink();
      },
      errorWidget: (context, _, __) {
        _markReady();
        return errorWidget;
      },
      imageBuilder: (context, imageProvider) {
        _markReady();
        return AnimatedOpacity(
          opacity: 1,
          duration: widget.crossFadeDuration,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: widget.fit),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          alignment: Alignment.center,
          color: Colors.black.withOpacity(0.08),
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3, value: _progress),
          ),
        ),
      ),
    );
  }

  Widget _wrapWithSize(Widget child) {
    if (widget.width == null && widget.height == null) {
      return child;
    }
    return SizedBox(width: widget.width, height: widget.height, child: child);
  }

  Widget _withSemantics(Widget child) {
    if (widget.excludeFromSemantics) {
      return ExcludeSemantics(child: child);
    }
    final label = widget.semanticLabel;
    if (label != null && label.isNotEmpty) {
      return Semantics(
        label: label,
        image: true,
        child: child,
      );
    }
    return child;
  }

  void _updateProgress(double? value) {
    if (!mounted) return;
    final nextValue = value == null ? null : value.clamp(0.0, 1.0);
    if (_progress == nextValue) return;
    // Defer setState to next frame to avoid setState during build from image progress callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _progress = nextValue;
      });
    });
  }

  void _markReady() {
    if (!mounted || _isHighResReady) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isHighResReady = true;
        _progress = 1;
      });
    });
  }

  Widget? _buildOverlay(BuildContext context) {
    if (widget.overlay.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedGradients =
        widget.overlay.resolveGradients(theme, colorScheme);
    final resolvedColor = widget.overlay.resolveColor(theme, colorScheme);

    final overlayLayers = <Widget>[];

    if (resolvedColor != null) {
      overlayLayers.add(
        DecoratedBox(
          decoration: BoxDecoration(color: resolvedColor),
        ),
      );
    }

    for (final gradient in resolvedGradients) {
      overlayLayers.add(
        DecoratedBox(
          decoration: BoxDecoration(gradient: gradient),
        ),
      );
    }

    if (overlayLayers.isEmpty) {
      return null;
    }

    Widget overlayWidget;
    if (overlayLayers.length == 1) {
      overlayWidget = overlayLayers.single;
    } else {
      overlayWidget = Stack(
        fit: StackFit.expand,
        children: overlayLayers,
      );
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: widget.overlay.padding,
          child: overlayWidget,
        ),
      ),
    );
  }
}

typedef MediaImageGradientResolver = Gradient Function(
  ThemeData theme,
  ColorScheme colorScheme,
);

typedef MediaImageColorResolver = Color? Function(
  ThemeData theme,
  ColorScheme colorScheme,
);

class MediaImageOverlay {
  const MediaImageOverlay({
    this.gradientResolvers = const <MediaImageGradientResolver>[],
    this.colorResolver,
    this.padding = EdgeInsets.zero,
  });

  const MediaImageOverlay.none()
      : gradientResolvers = const <MediaImageGradientResolver>[],
        colorResolver = null,
        padding = EdgeInsets.zero;

  factory MediaImageOverlay.legible({
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double bottomOpacityLight = 0.78,
    double bottomOpacityDark = 0.62,
    double topOpacityLight = 0.38,
    double topOpacityDark = 0.28,
    MediaImageColorResolver? baseColorResolver,
  }) {
    Color _resolveBaseColor(ThemeData theme, ColorScheme scheme) {
      final Color? resolved = baseColorResolver?.call(theme, scheme);
      if (resolved != null) {
        return resolved;
      }
      final scrim = scheme.scrim;
      if (scrim.opacity == 0) {
        return Colors.black;
      }
      if (scrim.opacity < 1) {
        return scrim.withOpacity(1);
      }
      return scrim;
    }

    final gradientResolvers = <MediaImageGradientResolver>[
      (theme, scheme) {
        final baseColor = _resolveBaseColor(theme, scheme);
        final isDark = theme.brightness == Brightness.dark;
        final opacity = (isDark ? bottomOpacityDark : bottomOpacityLight)
            .clamp(0.0, 1.0)
            .toDouble();
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            baseColor.withOpacity(opacity),
            baseColor.withOpacity(0),
          ],
        );
      },
    ];

    final hasTopOverlay = topOpacityLight > 0 || topOpacityDark > 0;
    if (hasTopOverlay) {
      gradientResolvers.add((theme, scheme) {
        final baseColor = _resolveBaseColor(theme, scheme);
        final isDark = theme.brightness == Brightness.dark;
        final opacity = (isDark ? topOpacityDark : topOpacityLight)
            .clamp(0.0, 1.0)
            .toDouble();
        if (opacity <= 0) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.transparent],
          );
        }
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            baseColor.withOpacity(opacity),
            baseColor.withOpacity(0),
          ],
        );
      });
    }

    return MediaImageOverlay(
      gradientResolvers: gradientResolvers,
      padding: padding,
    );
  }

  final List<MediaImageGradientResolver> gradientResolvers;
  final MediaImageColorResolver? colorResolver;
  final EdgeInsetsGeometry padding;

  bool get isEmpty => gradientResolvers.isEmpty && colorResolver == null;

  List<Gradient> resolveGradients(ThemeData theme, ColorScheme colorScheme) {
    return [
      for (final resolver in gradientResolvers) resolver(theme, colorScheme),
    ];
  }

  Color? resolveColor(ThemeData theme, ColorScheme colorScheme) {
    return colorResolver?.call(theme, colorScheme);
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  const _DefaultPlaceholder({required this.type, this.width, this.height});

  final MediaImageType type;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: _placeholderColor(type),
      alignment: Alignment.center,
      child: Icon(_iconForType(type), color: Colors.white70),
    );
  }
}

class _DefaultError extends StatelessWidget {
  const _DefaultError({required this.type, this.width, this.height});

  final MediaImageType type;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade400,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade100),
    );
  }
}

IconData _iconForType(MediaImageType type) {
  switch (type) {
    case MediaImageType.poster:
      return Icons.movie_outlined;
    case MediaImageType.backdrop:
      return Icons.landscape_outlined;
    case MediaImageType.profile:
      return Icons.person_outline;
    case MediaImageType.still:
      return Icons.photo_outlined;
    case MediaImageType.logo:
      return Icons.branding_watermark_outlined;
  }
}

Color _placeholderColor(MediaImageType type) {
  switch (type) {
    case MediaImageType.poster:
      return Colors.blueGrey.shade300;
    case MediaImageType.backdrop:
      return Colors.indigo.shade300;
    case MediaImageType.profile:
      return Colors.teal.shade300;
    case MediaImageType.still:
      return Colors.deepPurple.shade300;
    case MediaImageType.logo:
      return Colors.orange.shade300;
  }
}
