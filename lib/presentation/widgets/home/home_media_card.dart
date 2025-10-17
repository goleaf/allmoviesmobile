import 'package:flutter/material.dart';

import '../../../data/models/movie.dart';
import '../media_image.dart';

/// Poster style card used for both movie and TV entries in the home screen.
class HomeMediaCard extends StatelessWidget {
  const HomeMediaCard({
    super.key,
    required this.media,
    this.onTap,
  });

  final Movie media;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 140,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: MediaImage(
                  path: media.posterPath,
                  type: MediaImageType.poster,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              media.title,
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
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if ((media.mediaType ?? '').isNotEmpty) {
      parts.add(media.mediaLabel);
    }
    if (media.releaseYear != null) {
      parts.add(media.releaseYear!);
    }
    if (media.voteAverage != null && media.voteAverage! > 0) {
      parts.add(media.voteAverage!.toStringAsFixed(1));
    }
    return parts.join(' • ');
  }
}
