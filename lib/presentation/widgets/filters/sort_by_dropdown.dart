import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/discover_filters_model.dart';

class SortByDropdown extends StatelessWidget {
  const SortByDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.mediaType = 'movie',
  });

  final SortBy value;
  final ValueChanged<SortBy?> onChanged;
  final String mediaType;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    
    final items = <DropdownMenuItem<SortBy>>[];

    // Common sort options
    items.add(DropdownMenuItem(
      value: SortBy.popularityDesc,
      child: Text(l.t('discover.sort.popularityDesc')),
    ));
    items.add(DropdownMenuItem(
      value: SortBy.popularityAsc,
      child: Text(l.t('discover.sort.popularityAsc')),
    ));
    items.add(DropdownMenuItem(
      value: SortBy.ratingDesc,
      child: Text(l.t('discover.sort.ratingDesc')),
    ));
    items.add(DropdownMenuItem(
      value: SortBy.ratingAsc,
      child: Text(l.t('discover.sort.ratingAsc')),
    ));

    if (mediaType == 'movie') {
      items.add(DropdownMenuItem(
        value: SortBy.revenueDesc,
        child: Text(l.t('discover.sort.revenueDesc')),
      ));
      items.add(DropdownMenuItem(
        value: SortBy.revenueAsc,
        child: Text(l.t('discover.sort.revenueAsc')),
      ));
      items.add(DropdownMenuItem(
        value: SortBy.releaseDateDesc,
        child: Text(l.t('discover.sort.releaseDateDesc')),
      ));
      items.add(DropdownMenuItem(
        value: SortBy.releaseDateAsc,
        child: Text(l.t('discover.sort.releaseDateAsc')),
      ));
      items.add(DropdownMenuItem(
        value: SortBy.titleAsc,
        child: Text(l.t('discover.sort.titleAsc')),
      ));
      items.add(DropdownMenuItem(
        value: SortBy.titleDesc,
        child: Text(l.t('discover.sort.titleDesc')),
      ));
    } else if (mediaType == 'tv') {
      items.add(DropdownMenuItem(
        value: SortBy.firstAirDateDesc,
        child: Text(l.t('discover.sort.releaseDateDesc')), // Reusing string key for "Release Date" as "First Air Date"
      ));
      items.add(DropdownMenuItem(
        value: SortBy.firstAirDateAsc,
        child: Text(l.t('discover.sort.releaseDateAsc')),
      ));
      // TV shows usually don't have revenue sort in standard discover, but if they did:
      // items.add(...) 
      // Name sort for TV
      items.add(DropdownMenuItem(
        value: SortBy.nameAsc,
        child: Text(l.t('discover.sort.titleAsc')), // Reusing "Title A-Z"
      ));
      items.add(DropdownMenuItem(
        value: SortBy.nameDesc,
        child: Text(l.t('discover.sort.titleDesc')),
      ));
    }

    return DropdownButtonFormField<SortBy>(
      value: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
