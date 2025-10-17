import 'package:flutter/material.dart';

import '../../../data/models/collection_model.dart';
import '../media_image.dart';

/// Card displayed in the featured collections carousel.
class HomeCollectionCard extends StatelessWidget {
  const HomeCollectionCard({
    super.key,
    required this.collection,
    this.onTap,
  });

  final CollectionDetails collection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                  path: collection.backdropPath ?? collection.posterPath,
                  type: MediaImageType.backdrop,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              collection.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall,
            ),
            if ((collection.overview ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                collection.overview!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
