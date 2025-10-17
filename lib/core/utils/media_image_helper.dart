import '../config/app_config.dart';

/// Descriptor for TMDB media image categories.
enum MediaImageType { poster, backdrop, profile, still, logo }

/// Supported TMDB CDN sizes.
enum MediaImageSize {
  w45,
  w92,
  w154,
  w185,
  w300,
  w342,
  w500,
  w780,
  w1280,
  h632,
  original,
}

extension MediaImageSizeX on MediaImageSize {
  String get value {
    switch (this) {
      case MediaImageSize.w45:
        return 'w45';
      case MediaImageSize.w92:
        return 'w92';
      case MediaImageSize.w154:
        return 'w154';
      case MediaImageSize.w185:
        return 'w185';
      case MediaImageSize.w300:
        return 'w300';
      case MediaImageSize.w342:
        return 'w342';
      case MediaImageSize.w500:
        return 'w500';
      case MediaImageSize.w780:
        return 'w780';
      case MediaImageSize.w1280:
        return 'w1280';
      case MediaImageSize.h632:
        return 'h632';
      case MediaImageSize.original:
        return 'original';
    }
  }
}

class MediaImageHelper {
  MediaImageHelper._();

  static const Map<MediaImageType, List<MediaImageSize>> _supportedSizes = {
    MediaImageType.poster: [
      MediaImageSize.w92,
      MediaImageSize.w154,
      MediaImageSize.w185,
      MediaImageSize.w342,
      MediaImageSize.w500,
      MediaImageSize.w780,
      MediaImageSize.original,
    ],
    MediaImageType.backdrop: [
      MediaImageSize.w300,
      MediaImageSize.w780,
      MediaImageSize.w1280,
      MediaImageSize.original,
    ],
    MediaImageType.profile: [
      MediaImageSize.w45,
      MediaImageSize.w185,
      MediaImageSize.h632,
      MediaImageSize.original,
    ],
    MediaImageType.still: [
      MediaImageSize.w92,
      MediaImageSize.w185,
      MediaImageSize.w300,
      MediaImageSize.original,
    ],
    MediaImageType.logo: [
      MediaImageSize.w45,
      MediaImageSize.w92,
      MediaImageSize.w154,
      MediaImageSize.w185,
      MediaImageSize.w300,
      MediaImageSize.w500,
      MediaImageSize.original,
    ],
  };

  static const Map<MediaImageType, MediaImageSize> _defaultSizes = {
    MediaImageType.poster: MediaImageSize.w500,
    MediaImageType.backdrop: MediaImageSize.w780,
    MediaImageType.profile: MediaImageSize.w185,
    MediaImageType.still: MediaImageSize.w300,
    MediaImageType.logo: MediaImageSize.w185,
  };

  static const Map<MediaImageType, MediaImageSize> _previewSizes = {
    MediaImageType.poster: MediaImageSize.w154,
    MediaImageType.backdrop: MediaImageSize.w300,
    MediaImageType.profile: MediaImageSize.w45,
    MediaImageType.still: MediaImageSize.w92,
    MediaImageType.logo: MediaImageSize.w92,
  };

  /// Build the full CDN URL.
  static String? buildUrl(
    String? path, {
    MediaImageType type = MediaImageType.poster,
    MediaImageSize? size,
  }) {
    final sanitized = _sanitizePath(path);
    if (sanitized == null) {
      return null;
    }
    final resolvedSize = _resolveSize(
      type,
      size ?? _defaultSizes[type] ?? MediaImageSize.original,
    );
    return '${AppConfig.tmdbImageBaseUrl}/${resolvedSize.value}$sanitized';
  }

  /// Build a low-resolution thumbnail URL for progressive loading.
  static String? buildPreviewUrl(
    String? path, {
    MediaImageType type = MediaImageType.poster,
    MediaImageSize? size,
  }) {
    final sanitized = _sanitizePath(path);
    if (sanitized == null) {
      return null;
    }
    final resolvedSize = _resolveSize(
      type,
      size ?? _previewSizes[type] ?? MediaImageSize.w92,
    );
    return '${AppConfig.tmdbImageBaseUrl}/${resolvedSize.value}$sanitized';
  }

  static MediaImageSize _resolveSize(MediaImageType type, MediaImageSize size) {
    final supported = _supportedSizes[type];
    if (supported != null && supported.contains(size)) {
      return size;
    }
    return _defaultSizes[type] ?? MediaImageSize.original;
  }

  static String? _sanitizePath(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    return path.startsWith('/') ? path : '/$path';
  }
}
