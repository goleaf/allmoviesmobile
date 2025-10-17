import 'package:flutter/material.dart';

import '../../../data/models/saved_media_item.dart';
import '../media_image.dart';

/// Card showing items from the continue watching provider.
class HomeContinueWatchingCard extends StatelessWidget {
  const HomeContinueWatchingCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final SavedMediaItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 220,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: MediaImage(
                  path: item.backdropPath ?? item.posterPath,
                  type: MediaImageType.backdrop,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              _buildSubtitle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progressValue,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[item.type.displayLabel];
    if (item.releaseYear != null) {
      parts.add(item.releaseYear!);
    }
    if (item.voteAverageRounded != null) {
      parts.add(item.voteAverageRounded!.toStringAsFixed(1));
    }
    return parts.join(' • ');
  }

  double get _progressValue {
    final int? total = item.totalRuntimeEstimate;
    if (total == null || total == 0) {
      return 0.35; // Provide a pleasant default progress.
    }
    final int watched = item.watchedAt != null ? total : total ~/ 2;
    final double ratio = watched / total;
    return ratio.clamp(0.1, 0.95).toDouble();
  }
}
