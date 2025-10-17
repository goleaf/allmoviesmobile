import 'package:flutter/material.dart';

import '../../core/utils/media_image_helper.dart';
import 'media_image.dart';

/// A reusable dialog that renders a zoomable TMDB image.
class ZoomableImageDialog extends StatelessWidget {
  const ZoomableImageDialog({
    super.key,
    required this.imagePath,
    required this.type,
    this.backgroundColor = Colors.black,
    this.closeIconColor = Colors.white,
  });

  /// The remote path of the image to display.
  final String? imagePath;

  /// The TMDB media image type used for URL resolution.
  final MediaImageType type;

  /// Dialog background color.
  final Color backgroundColor;

  /// Color used for the close icon button.
  final Color closeIconColor;

  /// Displays the dialog for the provided [imagePath] and [type].
  static Future<void> show(
    BuildContext context, {
    required String? imagePath,
    required MediaImageType type,
    Color backgroundColor = Colors.black,
    Color closeIconColor = Colors.white,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ZoomableImageDialog(
        imagePath: imagePath,
        type: type,
        backgroundColor: backgroundColor,
        closeIconColor: closeIconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 6,
              child: Center(
                child: MediaImage(
                  path: imagePath,
                  type: type,
                  size: MediaImageSize.original,
                  fit: BoxFit.contain,
                  placeholder: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: Icon(
                    Icons.broken_image,
                    color: closeIconColor,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: closeIconColor),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ),
        ],
      ),
    );
  }
}
