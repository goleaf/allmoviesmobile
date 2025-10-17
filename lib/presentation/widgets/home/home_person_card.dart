import 'package:flutter/material.dart';

import '../../../data/models/person_model.dart';
import '../media_image.dart';

/// Small card for popular people carousel entries.
class HomePersonCard extends StatelessWidget {
  const HomePersonCard({
    super.key,
    required this.person,
    this.onTap,
  });

  final Person person;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 120,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.primaryContainer,
              child: ClipOval(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: MediaImage(
                    path: person.profilePath,
                    type: MediaImageType.profile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              person.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall,
            ),
            if ((person.knownForDepartment ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                person.knownForDepartment!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
