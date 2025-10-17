import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Cache manager that performs lightweight compression before persisting files.
class CompressedImageCacheManager extends CacheManager {
  CompressedImageCacheManager._()
      : super(
          Config(
            'compressedImageCache',
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 200,
          ),
        );

  static final CompressedImageCacheManager instance =
      CompressedImageCacheManager._();

  static const int _compressionThresholdBytes = 400 * 1024; // 400 KB

  @override
  Future<FileInfo> putFile(
    String url,
    Uint8List fileBytes, {
    String? key,
    String? fileExtension,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String? fileServiceKey,
  }) async {
    final shouldCompress = fileBytes.length > _compressionThresholdBytes;
    Uint8List effectiveBytes = fileBytes;

    if (shouldCompress) {
      final compressed = await FlutterImageCompress.compressWithList(
        fileBytes,
        minWidth: 1280,
        minHeight: 720,
        quality: 80,
      );
      if (compressed.isNotEmpty && compressed.length < fileBytes.length) {
        effectiveBytes = Uint8List.fromList(compressed);
      }
    }

    return super.putFile(
      url,
      effectiveBytes,
      key: key,
      fileExtension: fileExtension,
      eTag: eTag,
      maxAge: maxAge,
      fileServiceKey: fileServiceKey,
    );
  }
}
