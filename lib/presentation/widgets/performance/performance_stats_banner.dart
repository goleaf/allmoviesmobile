import 'package:flutter/material.dart';

import '../../../core/diagnostics/performance_profiler.dart';

class PerformanceStatsBanner extends StatelessWidget {
  const PerformanceStatsBanner({super.key, required this.statsListenable});

  final ValueListenable<FrameTimingsStats?> statsListenable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: colorScheme.shadow.withOpacity(0.25),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ValueListenableBuilder<FrameTimingsStats?>(
              valueListenable: statsListenable,
              builder: (context, stats, _) {
                if (stats == null) {
                  return const _BannerRow(
                    title: 'Profiler warming up…',
                    subtitle: 'Collecting frame timings',
                    statusColor: Colors.orange,
                  );
                }

                final buildMs =
                    (stats.averageBuildTime.inMicroseconds / 1000).toStringAsFixed(1);
                final rasterMs =
                    (stats.averageRasterTime.inMicroseconds / 1000).toStringAsFixed(1);
                final fps = stats.estimatedFps.toStringAsFixed(1);

                final bool healthy = stats.isWithinBudget;
                final Color statusColor = healthy ? Colors.green : Colors.redAccent;
                final String title = healthy
                    ? 'Smooth frame timings'
                    : 'Frame timings over budget';
                final String subtitle =
                    'Build: ${buildMs}ms · Raster: ${rasterMs}ms · FPS: $fps';

                return _BannerRow(
                  title: title,
                  subtitle: subtitle,
                  statusColor: statusColor,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerRow extends StatelessWidget {
  const _BannerRow({
    required this.title,
    required this.subtitle,
    required this.statusColor,
  });

  final String title;
  final String subtitle;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 12, color: statusColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
