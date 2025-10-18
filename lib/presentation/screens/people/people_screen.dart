import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/person_model.dart';
import '../../../providers/people_provider.dart';
import '../../../data/models/person_detail_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/media_image.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/virtualized_list_view.dart';

class PeopleScreen extends StatefulWidget {
  static const routeName = '/people';

  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen>
    with SingleTickerProviderStateMixin {
  late final LocalStorageService _storageService;
  late final TabController _tabController;
  final Map<PeopleSection, ScrollController> _controllers = {};
  final Map<PeopleSection, VoidCallback> _listeners = {};
  final Map<PeopleSection, Timer?> _debouncers = {};
  late final List<PeopleSection> _sections;

  @override
  void initState() {
    super.initState();
    _storageService = context.read<LocalStorageService>();
    _sections = PeopleSection.values;
    final initialIndex = _storageService
        .getPeopleTabIndex()
        .clamp(0, _sections.length - 1);
    _tabController = TabController(
      length: _sections.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      unawaited(_storageService.setPeopleTabIndex(_tabController.index));
    });

    for (final section in _sections) {
      final offset = _storageService.getPeopleScrollOffset(section.name);
      final controller = ScrollController(
        initialScrollOffset: offset ?? 0,
      );
      void listener() {
        _debouncers[section]?.cancel();
        _debouncers[section] = Timer(const Duration(milliseconds: 350), () {
          unawaited(
            _storageService.setPeopleScrollOffset(
              section.name,
              controller.offset,
            ),
          );
        });
      }

      controller.addListener(listener);
      _controllers[section] = controller;
      _listeners[section] = listener;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PeopleProvider>();
      provider.refresh();

      final savedDepartment =
          _storageService.getPeopleDepartmentFilter();
      if (savedDepartment == null || savedDepartment.isEmpty) {
        return;
      }

      unawaited(
        provider.initialized.then((_) {
          if (!mounted) {
            return;
          }
          if (provider.availableDepartments.contains(savedDepartment)) {
            provider.selectDepartment(savedDepartment);
          } else {
            unawaited(
              _storageService.setPeopleDepartmentFilter(null),
            );
          }
        }),
      );
    });
  }

  Future<void> _refreshAll(BuildContext context) {
    return context.read<PeopleProvider>().refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('person.people')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (final section in _sections)
              Tab(
                text: _labelForSection(section, AppLocalizations.of(context)),
              ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Client-side department filter applied to TMDB `/trending/person` and
          // `/person/popular` results that are cached by the provider.
          const _PeopleDepartmentSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final section in _sections)
                  _PeopleSectionView(
                    section: section,
                    onRefreshAll: _refreshAll,
                    controller: _controllers[section],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final section in _sections) {
      _debouncers[section]?.cancel();
      final controller = _controllers[section];
      final listener = _listeners[section];
      if (controller != null && listener != null) {
        controller.removeListener(listener);
        unawaited(
          _storageService.setPeopleScrollOffset(
            section.name,
            controller.offset,
          ),
        );
        controller.dispose();
      }
    }
    super.dispose();
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
    this.controller,
  });

  final PeopleSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;
  final ScrollController? controller;

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
            controller: controller,
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
    this.controller,
  });

  final List<Person> people;
  final ValueChanged<Person> onPersonSelected;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
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

    return VirtualizedSeparatedListView(
      controller: controller,
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
      cacheExtent: 640,
      addAutomaticKeepAlives: true,
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

/// Chip-based selector that filters people lists by their known-for
/// department. The widget listens to [PeopleProvider] updates so that it can
/// show a localized department name for every available option and persists
/// the current selection via [LocalStorageService].
class _PeopleDepartmentSelector extends StatelessWidget {
  const _PeopleDepartmentSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer<PeopleProvider>(
      builder: (context, provider, _) {
        final loc = AppLocalizations.of(context);
        final departments = provider.availableDepartments;

        if (departments.isEmpty) {
          return const SizedBox.shrink();
        }

        final storage = context.read<LocalStorageService>();
        final selectedDepartment = provider.selectedDepartment;
        final departmentEntries = departments
            .map(
              (department) => MapEntry(
                department,
                _localizedDepartmentLabel(loc, department),
              ),
            )
            .toList()
          ..sort(
            (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()),
          );

        Widget buildChip(String? value, String label) {
          final isSelected = value == null
              ? selectedDepartment == null
              : selectedDepartment == value;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (isSelectedTap) {
              final newValue = isSelectedTap ? value : null;
              if (provider.selectedDepartment == newValue) {
                return;
              }
              provider.selectDepartment(newValue);
              unawaited(storage.setPeopleDepartmentFilter(newValue));
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: loc.t('people.departments.label'),
              border: const OutlineInputBorder(),
            ),
            isEmpty: selectedDepartment == null,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                buildChip(null, loc.t('people.departments.all')),
                for (final entry in departmentEntries)
                  buildChip(entry.key, entry.value),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _localizedDepartmentLabel(
    AppLocalizations loc,
    String department,
  ) {
    final sanitized = department
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+'), '')
        .replaceAll(RegExp(r'_+$'), '');

    final key = 'people.departments.$sanitized';
    final localized = loc.t(key);
    if (localized == key) {
      return department;
    }
    return localized;
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
