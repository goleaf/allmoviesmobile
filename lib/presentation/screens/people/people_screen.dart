import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/person_model.dart';
import '../../../providers/people_provider.dart';
import '../../../data/models/person_detail_model.dart';
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

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeopleProvider>().refresh();
    });
  }

  Future<void> _refreshAll(BuildContext context) {
    return context.read<PeopleProvider>().refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final sections = PeopleSection.values;

    return DefaultTabController(
      length: sections.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).t('person.people')),
          bottom: TabBar(
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
          children: [
            for (final section in sections)
              _PeopleSectionView(section: section, onRefreshAll: _refreshAll),
          ],
        ),
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
  const _PeopleSectionView({required this.section, required this.onRefreshAll});

  final PeopleSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;

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

        return Column(
          children: [
            const _PeopleDepartmentSelector(),
            Expanded(
              child: RefreshIndicator(
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
                          SnackBar(
                            content:
                                Text('Failed to load details: $error'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPersonDetails(BuildContext context, int personId) {
    Navigator.pushNamed(context, '/person', arguments: personId);
  }
}

class _PeopleList extends StatelessWidget {
  const _PeopleList({required this.people, required this.onPersonSelected});

  final List<Person> people;
  final ValueChanged<Person> onPersonSelected;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return ListView(
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

    return ListView.separated(
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

class _PeopleDepartmentSelector extends StatelessWidget {
  const _PeopleDepartmentSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer<PeopleProvider>(
      builder: (context, provider, _) {
        final loc = AppLocalizations.of(context);
        final departments = provider.availableDepartments;
        final dropdownItems = <DropdownMenuItem<String?>>[
          DropdownMenuItem<String?>(
            value: null,
            child: Text(loc.t('people.departments.all')),
          ),
          for (final department in departments)
            DropdownMenuItem<String?>(
              value: department,
              child: Text(_localizedDepartmentLabel(loc, department)),
            ),
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: loc.t('people.departments.label'),
              border: const OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                key: const Key('peopleDepartmentDropdown'),
                isExpanded: true,
                value: provider.selectedDepartment,
                items: dropdownItems,
                onChanged: provider.selectDepartment,
              ),
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
