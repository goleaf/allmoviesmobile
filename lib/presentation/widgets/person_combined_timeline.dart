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
  });

  final String title;
  final String emptyLabel;
  final List<PersonCombinedTimelineEntry> entries;

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
