import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/person_model.dart';
import '../../../providers/people_provider.dart';
import '../../../data/models/person_detail_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/media_image.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../../core/localization/app_localizations.dart';

class PeopleScreen extends StatefulWidget {
  static const routeName = '/people';

  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final LocalStorageService _storageService;
  late final Map<PeopleSection, ScrollController> _scrollControllers;
  late final Map<PeopleSection, VoidCallback> _scrollListeners;
  late final Map<PeopleSection, double> _lastPersistedOffsets;

  @override
  void initState() {
    super.initState();
    _storageService = context.read<LocalStorageService>();
    final sections = PeopleSection.values;
    final initialTabIndex = _storageService.getPeopleTabIndex().clamp(
      0,
      sections.length - 1,
    );
    _tabController = TabController(
      length: sections.length,
      vsync: this,
      initialIndex: initialTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      unawaited(_storageService.setPeopleTabIndex(_tabController.index));
    });

    final storedOffsets = <PeopleSection, double?>{
      for (final section in sections)
        section: _storageService.getPeopleScrollOffset(section.name),
    };

    _scrollControllers = {
      for (final section in sections)
        section: ScrollController(
          initialScrollOffset: ((storedOffsets[section] ?? 0.0)
                  .clamp(0.0, double.maxFinite))
              .toDouble(),
        ),
    };
    _lastPersistedOffsets = {
      for (final section in sections)
        section: (storedOffsets[section] ?? -1).toDouble(),
    };
    _scrollListeners = {
      for (final section in sections)
        section: () {
          final controller = _scrollControllers[section]!;
          if (!controller.hasClients) {
            return;
          }
          final offset = controller.offset;
          final previous = _lastPersistedOffsets[section] ?? -1;
          if ((previous - offset).abs() < 24) {
            return;
          }
          _lastPersistedOffsets[section] = offset;
          unawaited(
            _storageService.setPeopleScrollOffset(section.name, offset),
          );
        },
    };

    for (final entry in _scrollListeners.entries) {
      _scrollControllers[entry.key]!.addListener(entry.value);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeopleProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final entry in _scrollListeners.entries) {
      final controller = _scrollControllers[entry.key]!;
      controller.removeListener(entry.value);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshAll(BuildContext context) {
    return context.read<PeopleProvider>().refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final sections = PeopleSection.values;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('person.people')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (final section in sections)
              Tab(
                text: _labelForSection(section, AppLocalizations.of(context)),
              ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final section in sections)
            _PeopleSectionView(
              section: section,
              onRefreshAll: _refreshAll,
              scrollController: _scrollControllers[section]!,
            ),
        ],
      ),
    );
  }

  String _labelForSection(PeopleSection section, AppLocalizations l) {
    switch (section) {
      case PeopleSection.trending:
        return l.t('home.trending');
      case PeopleSection.popular:
        return l.t('home.popular');
    }
  }
}

class _PeopleSectionView extends StatelessWidget {
  const _PeopleSectionView({
    required this.section,
    required this.onRefreshAll,
    required this.scrollController,
  });

  final PeopleSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Consumer<PeopleProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && state.items.isEmpty) {
          return _ErrorView(
            message: state.errorMessage!,
            onRetry: () => onRefreshAll(context),
          );
        }

        return RefreshIndicator(
          onRefresh: () => onRefreshAll(context),
          child: _PeopleList(
            people: state.items,
            onPersonSelected: (person) async {
              try {
                final PersonDetail details = await provider.loadDetails(
                  person.id,
                );
                // ignore: use_build_context_synchronously
                if (context.mounted) {
                  _showPersonDetails(context, details.id);
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load details: $error')),
                  );
                }
              }
            },
            controller: scrollController,
          ),
        );
      },
    );
  }

  void _showPersonDetails(BuildContext context, int personId) {
    Navigator.pushNamed(context, '/person', arguments: personId);
  }
}

class _PeopleList extends StatelessWidget {
  const _PeopleList({
    required this.people,
    required this.onPersonSelected,
    required this.controller,
  });

  final List<Person> people;
  final ValueChanged<Person> onPersonSelected;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.person_outline,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppLocalizations.of(context).t('search.no_results'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: people.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final person = people[index];
        return _PersonCard(
          person: person,
          onTap: () => onPersonSelected(person),
        );
      },
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person, required this.onTap});

  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileUrl = person.profilePath;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: MediaImage(
                  path: profileUrl,
                  type: MediaImageType.profile,
                  size: MediaImageSize.w185,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if ((person.knownForDepartment ?? '').isNotEmpty)
                      Text(
                        person.knownForDepartment!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 4),
                    if (person.popularity != null)
                      Text(
                        '${AppLocalizations.of(context).person['popularity'] ?? 'Popularity'} ${person.popularity!.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_right),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed inline bottom sheet; detail now uses dedicated screen via routing

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).t('common.retry')),
          ),
        ),
      ],
    );
  }
}
