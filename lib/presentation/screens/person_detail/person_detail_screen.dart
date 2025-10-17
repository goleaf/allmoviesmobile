import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/person_model.dart';
import '../../../data/tmdb_repository.dart';

class PersonDetailScreen extends StatefulWidget {
  static const routeName = '/person-detail';

  final int personId;
  final String? initialName;

  const PersonDetailScreen({
    super.key,
    required this.personId,
    this.initialName,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Future<Person> _personFuture;

  @override
  void initState() {
    super.initState();
    final repository = context.read<TmdbRepository>();
    _personFuture = repository.fetchPersonDetails(widget.personId);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: FutureBuilder<Person>(
        future: _personFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(widget.initialName ?? loc.t('person.title')),
                ),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(widget.initialName ?? loc.t('person.title')),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        loc.t('errors.load_failed'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final person = snapshot.data!;
          final profileUrl = _buildProfileUrl(person.profilePath);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                title: Text(person.name),
                flexibleSpace: FlexibleSpaceBar(
                  background: profileUrl != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: profileUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 80),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    person.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (person.knownForDepartment != null &&
                                      person.knownForDepartment!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        person.knownForDepartment!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                person.name,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBiographySection(context, loc, person),
                      const SizedBox(height: 24),
                      _buildPersonalInfoSection(context, loc, person),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBiographySection(
    BuildContext context,
    AppLocalizations loc,
    Person person,
  ) {
    if (person.biography == null || person.biography!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('person.biography'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          person.biography!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(
    BuildContext context,
    AppLocalizations loc,
    Person person,
  ) {
    final entries = <MapEntry<String, String>>[];

    if (person.birthday != null && person.birthday!.isNotEmpty) {
      entries.add(MapEntry(loc.t('person.birthday'), person.birthday!));
    }

    if (person.placeOfBirth != null && person.placeOfBirth!.isNotEmpty) {
      entries
          .add(MapEntry(loc.t('person.place_of_birth'), person.placeOfBirth!));
    }

    if (person.alsoKnownAs.isNotEmpty) {
      entries.add(
        MapEntry(
          loc.t('person.also_known_as'),
          person.alsoKnownAs.join(', '),
        ),
      );
    }

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('person.title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(entry.value),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _buildProfileUrl(String? profilePath) {
    if (profilePath == null || profilePath.isEmpty) {
      return null;
    }
    return 'https://image.tmdb.org/t/p/w780$profilePath';
  }
}
