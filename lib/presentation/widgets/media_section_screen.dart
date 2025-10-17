import 'package:flutter/material.dart';

import 'app_drawer.dart';
import 'section_navigation_actions.dart';
import '../../core/localization/app_localizations.dart';

class MediaItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const MediaItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class MediaSectionScreen extends StatefulWidget {
  final String title;
  final IconData titleIcon;
  final List<MediaItem> items;
  final String currentRoute;
  final double childAspectRatio;

  const MediaSectionScreen({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.items,
    required this.currentRoute,
    this.childAspectRatio = 0.7,
  });

  @override
  State<MediaSectionScreen> createState() => _MediaSectionScreenState();
}

class _MediaSectionScreenState extends State<MediaSectionScreen> {
  late final TextEditingController _searchController;
  late final List<int> _visibleItemIndices;
  late final List<String> _normalizedTitles;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _visibleItemIndices = List<int>.generate(
      widget.items.length,
      (index) => index,
    );
    _normalizedTitles = widget.items
        .map((item) => item.title.toLowerCase())
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      setState(() {
        _visibleItemIndices = List<int>.generate(
          widget.items.length,
          (index) => index,
        );
      });
      return;
    }

    final matches = <int>[];
    for (var i = 0; i < _normalizedTitles.length; i++) {
      if (_normalizedTitles[i].contains(normalizedQuery)) {
        matches.add(i);
      }
    }

    setState(() {
      _visibleItemIndices = matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRoute = widget.currentRoute;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.titleIcon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        actions: [SectionNavigationActions(currentRoute: currentRoute)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    '${AppLocalizations.of(context).t('search.title')} ${widget.title.toLowerCase()}',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged: _handleSearch,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _visibleItemIndices.isEmpty
            ? Center(
                child: Text(
                  AppLocalizations.of(context).t('search.no_results'),
                  style: theme.textTheme.titleMedium,
                ),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: widget.childAspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _visibleItemIndices.length,
                itemBuilder: (context, index) {
                  final item = widget.items[_visibleItemIndices[index]];
                  return _MediaCard(item: item);
                },
              ),
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  final MediaItem item;

  const _MediaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              child: Icon(
                item.icon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
