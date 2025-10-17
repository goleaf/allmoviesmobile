import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/person_detail_model.dart';
import '../../../data/models/person_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/person_detail_provider.dart';
import '../../widgets/media_image.dart';
import '../../../core/utils/media_image_helper.dart';

class PersonDetailScreen extends StatelessWidget {
  static const routeName = '/person-detail';

  const PersonDetailScreen({
    super.key,
    required this.personId,
    this.initialPerson,
  });

  final int personId;
  final Person? initialPerson;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return ChangeNotifierProvider(
      create: (_) => PersonDetailProvider(
        repository,
        personId,
        seedPerson: initialPerson,
      )..load(),
      builder: (context, _) => const _PersonDetailView(),
    );
  }
}

class _PersonDetailView extends StatelessWidget {
  const _PersonDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonDetailProvider>();
    final loc = AppLocalizations.of(context);
    final detail = provider.detail;
    final summary = provider.summary;

    if (provider.isLoading && summary == null && detail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (summary == null && detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.errorMessage ?? loc.t('errors.generic'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<PersonDetailProvider>().load(forceRefresh: true),
                  child: Text(loc.t('common.retry')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final name = detail?.name ?? summary?.name ?? '';
    final department = detail?.knownForDepartment ?? summary?.knownForDepartment;
    final popularity = detail?.popularity ?? summary?.popularity;
    final profileUrl = detail?.profileUrl ?? summary?.profileUrl;

    if (detail == null) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            _PersonAppBar(
              name: name,
              department: department,
              popularity: popularity,
              profileUrl: profileUrl,
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<PersonDetailProvider>().load(forceRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _PersonAppBar(
              name: name,
              department: department,
              popularity: popularity,
              profileUrl: profileUrl,
            ),
            SliverToBoxAdapter(
              child: _PersonDetailBody(detail: detail),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonAppBar extends StatelessWidget {
  const _PersonAppBar({
    required this.name,
    this.department,
    this.popularity,
    this.profileUrl,
  });

  final String name;
  final String? department;
  final double? popularity;
  final String? profileUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedProfileUrl = profileUrl;
    final loc = AppLocalizations.of(context);

    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
        title: Text(name),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (resolvedProfileUrl != null)
              MediaImage(
                path: resolvedProfileUrl,
                type: MediaImageType.profile,
                size: MediaImageSize.h632,
                fit: BoxFit.cover,
              )
            else
              _FallbackProfile(name: name),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            if (department != null && department!.isNotEmpty)
                Chip(
                  label: Text(
                        department!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      backgroundColor: Colors.black45,
                    ),
                  if (popularity != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${loc.t('person.popularity')}: ${popularity!.toStringAsFixed(1)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackProfile extends StatelessWidget {
  const _FallbackProfile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: 64,
        backgroundColor: Colors.grey.shade500,
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _PersonDetailBody extends StatelessWidget {
  const _PersonDetailBody({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _SectionPadding(child: _BiographySection(detail: detail)),
      _SectionPadding(child: _PersonalInfoSection(detail: detail)),
      _SectionPadding(child: _KnownForSection(detail: detail)),
      _SectionPadding(child: _CombinedCreditsSection(detail: detail)),
      _SectionPadding(
        child: _TimelineSection(
          titleKey: 'person.movie_actor_timeline',
          credits: detail.movieCredits.cast,
          emptyKey: 'person.no_movie_actor_credits',
        ),
      ),
      _SectionPadding(
        child: _CrewByDepartmentSection(
          titleKey: 'person.movie_crew_departments',
          credits: detail.movieCredits.crew,
          emptyKey: 'person.no_movie_crew_credits',
        ),
      ),
      _SectionPadding(
        child: _TimelineSection(
          titleKey: 'person.tv_actor_timeline',
          credits: detail.tvCredits.cast,
          emptyKey: 'person.no_tv_actor_credits',
        ),
      ),
      _SectionPadding(
        child: _CrewByDepartmentSection(
          titleKey: 'person.tv_crew_departments',
          credits: detail.tvCredits.crew,
          emptyKey: 'person.no_tv_crew_credits',
        ),
      ),
      _SectionPadding(child: _ImageGallerySection(detail: detail)),
      _SectionPadding(child: _TaggedImagesSection(detail: detail)),
      _SectionPadding(child: _ExternalLinksSection(detail: detail)),
      _SectionPadding(child: _TranslationsSection(detail: detail)),
      const SizedBox(height: 32),
    ];

    return Column(children: sections);
  }
}

class _SectionPadding extends StatelessWidget {
  const _SectionPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}

class _BiographySection extends StatefulWidget {
  const _BiographySection({required this.detail});

  final PersonDetail detail;

  @override
  State<_BiographySection> createState() => _BiographySectionState();
}

class _BiographySectionState extends State<_BiographySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final biography = widget.detail.biography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('person.biography'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (biography == null || biography.isEmpty)
          Text(
            loc.t('person.no_biography'),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCrossFade(
                firstChild: Text(
                  biography,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                secondChild: Text(
                  biography,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              if (biography.length > 320)
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  label: Text(_expanded
                      ? loc.t('person.show_less')
                      : loc.t('person.read_more')),
                ),
            ],
          ),
      ],
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  const _PersonalInfoSection({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMMd();
    final birthday = _parseDate(detail.birthday);
    final deathday = _parseDate(detail.deathday);
    final age = _calculateAge(birthday, deathday: deathday);
    final genderLabel = _genderLabel(detail.gender, loc);

    final rows = <MapEntry<String, String>>[];
    if (birthday != null) {
      rows.add(MapEntry(
        loc.t('person.birthday'),
        dateFormat.format(birthday),
      ));
    }
    if (deathday != null) {
      rows.add(MapEntry(
        loc.t('person.deathday'),
        dateFormat.format(deathday),
      ));
    }
    if (age != null) {
      rows.add(MapEntry(loc.t('person.age'), age.toString()));
    }
    if ((detail.placeOfBirth ?? '').isNotEmpty) {
      rows.add(MapEntry(loc.t('person.place_of_birth'), detail.placeOfBirth!));
    }
    if (genderLabel.isNotEmpty) {
      rows.add(MapEntry(loc.t('person.gender'), genderLabel));
    }
    if ((detail.knownForDepartment ?? '').isNotEmpty) {
      rows.add(MapEntry(
        loc.t('person.known_for_department'),
        detail.knownForDepartment!,
      ));
    }
    if (detail.alsoKnownAs.isNotEmpty) {
      rows.add(MapEntry(
        loc.t('person.also_known_as'),
        detail.alsoKnownAs.join(', '),
      ));
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: loc.t('person.personal_info'),
      child: Column(
        children: rows
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        entry.key,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _KnownForSection extends StatelessWidget {
  const _KnownForSection({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final credits = <PersonCredit>{};

    credits.addAll(detail.combinedCredits.cast);
    credits.addAll(detail.combinedCredits.crew);

    final sorted = credits
        .toList()
      ..sort(
        (a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0),
      );
    final topCredits = sorted.take(10).toList();

    if (topCredits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('person.known_for'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topCredits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final credit = topCredits[index];
              return _KnownForCard(credit: credit);
            },
          ),
        ),
      ],
    );
  }
}

class _KnownForCard extends StatelessWidget {
  const _KnownForCard({required this.credit});

  final PersonCredit credit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = credit.posterUrl;

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            credit.displayTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (credit.mediaType != null)
            Text(
              credit.mediaType!.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}

class _CombinedCreditsSection extends StatelessWidget {
  const _CombinedCreditsSection({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final combined = detail.combinedCredits;
    final cast = combined.cast ?? const [];
    final crew = combined.crew ?? const [];
    if (cast.isEmpty && crew.isEmpty) {
      return const SizedBox.shrink();
    }

    final combinedCredits = [...cast, ...crew];
    combinedCredits.sort(
      (a, b) => (b.releaseYear ?? '').compareTo(a.releaseYear ?? ''),
    );

    return _SectionCard(
      title: loc.t('person.combined_credits'),
      child: Column(
        children: combinedCredits.take(12).map((credit) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    credit.releaseYear ?? '—',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credit.displayTitle,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if ((credit.mediaType ?? '').isNotEmpty)
                            _InfoChip(label: credit.mediaType!.toUpperCase()),
                          if ((credit.character ?? '').isNotEmpty)
                            _InfoChip(label: credit.character!),
                          if ((credit.job ?? '').isNotEmpty)
                            _InfoChip(label: credit.job!),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.titleKey,
    required this.credits,
    required this.emptyKey,
  });

  final String titleKey;
  final List<PersonCredit> credits;
  final String emptyKey;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final sorted = credits
        .where((credit) => credit.parsedDate != null)
        .toList()
      ..sort((a, b) => b.parsedDate!.compareTo(a.parsedDate!));

    if (sorted.isEmpty) {
      return _SectionCard(
        title: loc.t(titleKey),
        child: Text(
          loc.t(emptyKey),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey.shade600),
        ),
      );
    }

    return _SectionCard(
      title: loc.t(titleKey),
      child: Column(
        children: sorted.take(15).map((credit) {
          return _TimelineTile(credit: credit);
        }).toList(),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.credit});

  final PersonCredit credit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 36,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credit.releaseYear ?? '—',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  credit.displayTitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if ((credit.character ?? '').isNotEmpty)
                  Text(
                    credit.character!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else if ((credit.job ?? '').isNotEmpty)
                  Text(
                    credit.job!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CrewByDepartmentSection extends StatelessWidget {
  const _CrewByDepartmentSection({
    required this.titleKey,
    required this.credits,
    required this.emptyKey,
  });

  final String titleKey;
  final List<PersonCredit> credits;
  final String emptyKey;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (credits.isEmpty) {
      return _SectionCard(
        title: loc.t(titleKey),
        child: Text(
          loc.t(emptyKey),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey.shade600),
        ),
      );
    }

    final grouped = <String, List<PersonCredit>>{};
    for (final credit in credits) {
      final key = (credit.department ?? loc.t('person.other_department'));
      grouped.putIfAbsent(key, () => <PersonCredit>[]).add(credit);
    }

    final sortedDepartments = grouped.keys.toList()
      ..sort();

    return _SectionCard(
      title: loc.t(titleKey),
      child: Column(
        children: sortedDepartments.map((department) {
          final departmentCredits = grouped[department]!;
          departmentCredits.sort((a, b) =>
              (b.parsedDate ?? DateTime(1900)).compareTo(a.parsedDate ?? DateTime(1900)));
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...departmentCredits.take(10).map(
                  (credit) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            credit.releaseYear ?? '—',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            credit.displayTitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if ((credit.job ?? '').isNotEmpty)
                          Text(
                            credit.job!,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ImageGallerySection extends StatelessWidget {
  const _ImageGallerySection({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final images = detail.profiles;

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: loc.t('person.image_gallery'),
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final image = images[index];
            final imageUrl = image.filePath;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: image.aspectRatio,
                  child: MediaImage(
                    path: imageUrl,
                    type: MediaImageType.profile,
                    size: MediaImageSize.w300,
                    fit: BoxFit.cover,
                  ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TaggedImagesSection extends StatelessWidget {
  const _TaggedImagesSection({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final tagged = detail.taggedImages;
    if (tagged.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: loc.t('person.tagged_images'),
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tagged.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final image = tagged[index];
            final imageUrl = image.filePath;
            final mediaTitle = image.media?.titleOrName;
            return SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: image.aspectRatio,
                      child: MediaImage(
                        path: imageUrl,
                        type: MediaImageType.profile,
                        size: MediaImageSize.w300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (mediaTitle != null && mediaTitle.isNotEmpty)
                    Text(
                      mediaTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if ((image.media?.character ?? '').isNotEmpty)
                    Text(
                      image.media!.character!,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExternalLinksSection extends StatelessWidget {
  const _ExternalLinksSection({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final ids = detail.externalIds;
    if (ids == null) {
      return const SizedBox.shrink();
    }

    final links = <_ExternalLink>[];
    if ((ids.imdbId ?? '').isNotEmpty) {
      links.add(
        _ExternalLink(
          label: 'IMDb',
          icon: Icons.movie_creation_outlined,
          url: 'https://www.imdb.com/name/${ids.imdbId}',
        ),
      );
    }
    if ((ids.facebookId ?? '').isNotEmpty) {
      links.add(
        _ExternalLink(
          label: 'Facebook',
          icon: Icons.facebook,
          url: 'https://www.facebook.com/${ids.facebookId}',
        ),
      );
    }
    if ((ids.twitterId ?? '').isNotEmpty) {
      links.add(
        _ExternalLink(
          label: 'Twitter',
          icon: Icons.alternate_email,
          url: 'https://twitter.com/${ids.twitterId}',
        ),
      );
    }
    if ((ids.instagramId ?? '').isNotEmpty) {
      links.add(
        _ExternalLink(
          label: 'Instagram',
          icon: Icons.camera_alt_outlined,
          url: 'https://www.instagram.com/${ids.instagramId}',
        ),
      );
    }

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: loc.t('person.external_links'),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: links
            .map(
              (link) => OutlinedButton.icon(
                onPressed: () => _openLink(link.url),
                icon: Icon(link.icon),
                label: Text(link.label),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ExternalLink {
  const _ExternalLink({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;
}

class _TranslationsSection extends StatelessWidget {
  const _TranslationsSection({required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final translations = detail.translations.withUniqueLocales;
    if (translations.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: loc.t('person.translations'),
      child: Column(
        children: translations.map((translation) {
          final parts = <String>[];
          if ((translation.englishName ?? '').isNotEmpty) parts.add(translation.englishName!);
          if ((translation.iso31661 ?? '').isNotEmpty) parts.add(translation.iso31661!);
          final localeLabel = parts.join(' • ');

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if ((translation.biography ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      translation.biography!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
    );
  }
}

Future<void> _openLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

int? _calculateAge(DateTime? birthday, {DateTime? deathday}) {
  if (birthday == null) {
    return null;
  }

  final endDate = deathday ?? DateTime.now();
  var age = endDate.year - birthday.year;
  final hasNotHadBirthdayYet = (endDate.month < birthday.month) ||
      (endDate.month == birthday.month && endDate.day < birthday.day);

  if (hasNotHadBirthdayYet) {
    age -= 1;
  }

  return age;
}

String _genderLabel(int? gender, AppLocalizations loc) {
  switch (gender) {
    case 1:
      return loc.t('person.gender_female');
    case 2:
      return loc.t('person.gender_male');
    case 3:
      return loc.t('person.gender_non_binary');
    default:
      return '';
  }
}

