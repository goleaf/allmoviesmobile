import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/person_detail_model.dart';
import '../../providers/person_detail_provider.dart';

class PersonCombinedTimeline extends StatelessWidget {
  const PersonCombinedTimeline({
    super.key,
    required this.title,
    required this.emptyLabel,
    required this.entries,
    this.careerStats = const <PersonCareerTimelineBucket>[],
  });

  final String title;
  final String emptyLabel;
  final List<PersonCombinedTimelineEntry> entries;
  final List<PersonCareerTimelineBucket> careerStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          _TimelineEmptyState(message: emptyLabel)
        else
          Column(
            children: [
              if (careerStats.isNotEmpty) ...[
                _CareerTimelineChart(stats: careerStats),
                const SizedBox(height: 16),
              ],
              for (var i = 0; i < entries.length; i++)
                _TimelineYearTile(
                  entry: entries[i],
                  isLast: i == entries.length - 1,
                ),
            ],
          ),
      ],
    );
  }
}

class _TimelineEmptyState extends StatelessWidget {
  const _TimelineEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }
}

class _TimelineYearTile extends StatelessWidget {
  const _TimelineYearTile({
    required this.entry,
    required this.isLast,
  });

  final PersonCombinedTimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final yearLabel = entry.hasKnownYear ? entry.year : loc.t('common.unknown');
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: theme.colorScheme.primary.withOpacity(0.4),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  yearLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...entry.groups.map(
                  (group) => _TimelineMediaGroup(group: group),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineMediaGroup extends StatelessWidget {
  const _TimelineMediaGroup({required this.group});

  final PersonCombinedTimelineMediaGroup group;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mediaLabel = _labelForMediaType(group.mediaType, loc);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mediaLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...group.credits.map(
            (credit) => _TimelineCreditTile(credit: credit),
          ),
        ],
      ),
    );
  }

  String _labelForMediaType(String type, AppLocalizations loc) {
    final normalized = type.trim().toLowerCase();
    if (normalized.isEmpty ||
        normalized == PersonCombinedTimelineEntry.unknownMediaType) {
      return loc.t('common.unknown');
    }
    if (normalized == 'tv') {
      return 'TV';
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

class _TimelineCreditTile extends StatelessWidget {
  const _TimelineCreditTile({required this.credit});

  final PersonCredit credit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = _roleLabel();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            credit.displayTitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (role != null) ...[
            const SizedBox(height: 4),
            Text(
              role,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _roleLabel() {
    final character = credit.character?.trim();
    if (character != null && character.isNotEmpty) {
      return character;
    }
    final job = credit.job?.trim();
    if (job != null && job.isNotEmpty) {
      return job;
    }
    final department = credit.department?.trim();
    if (department != null && department.isNotEmpty) {
      return department;
    }
    return null;
  }
}

class _CareerTimelineChart extends StatelessWidget {
  const _CareerTimelineChart({required this.stats});

  final List<PersonCareerTimelineBucket> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final maxTotal = stats.map((stat) => stat.total).fold<int>(0, (a, b) => a > b ? a : b);

    if (maxTotal == 0) {
      return const SizedBox.shrink();
    }

    const chartHeight = 160.0;
    const barWidth = 28.0;

    final actingLabel = loc.t('people.departments.acting');
    final crewLabel = loc.t('people.departments.crew');
    final actingColor = theme.colorScheme.primary;
    final crewColor = theme.colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: chartHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 8),
                for (final stat in stats)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _CareerTimelineBar(
                      stat: stat,
                      maxTotal: maxTotal,
                      actingColor: actingColor,
                      crewColor: crewColor,
                      barWidth: barWidth,
                      chartHeight: chartHeight,
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _TimelineLegendEntry(label: actingLabel, color: actingColor),
            _TimelineLegendEntry(label: crewLabel, color: crewColor),
          ],
        ),
      ],
    );
  }
}

class _TimelineLegendEntry extends StatelessWidget {
  const _TimelineLegendEntry({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _CareerTimelineBar extends StatelessWidget {
  const _CareerTimelineBar({
    required this.stat,
    required this.maxTotal,
    required this.actingColor,
    required this.crewColor,
    required this.barWidth,
    required this.chartHeight,
  });

  final PersonCareerTimelineBucket stat;
  final int maxTotal;
  final Color actingColor;
  final Color crewColor;
  final double barWidth;
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final total = stat.total;

    if (maxTotal <= 0) {
      return SizedBox(width: barWidth);
    }

    final totalFraction = total <= 0 ? 0.0 : total / maxTotal;
    final totalHeight = chartHeight * totalFraction;
    final actingHeight = total == 0
        ? 0.0
        : totalHeight * (stat.actingCredits / total);
    final crewHeight = total == 0
        ? 0.0
        : totalHeight * (stat.crewCredits / total);
    final yearLabel = stat.hasKnownYear
        ? stat.year
        : loc.t('common.unknown');

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (total > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$total',
              style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: barWidth,
              height: chartHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            if (total > 0)
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: barWidth,
                    height: totalHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (stat.crewCredits > 0)
                          Container(
                            height: crewHeight,
                            color: crewColor.withOpacity(0.85),
                          ),
                        if (stat.actingCredits > 0)
                          Container(
                            height: actingHeight,
                            color: actingColor.withOpacity(0.9),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: barWidth + 12,
          child: Text(
            yearLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
