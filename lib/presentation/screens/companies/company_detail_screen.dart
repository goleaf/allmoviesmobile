import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/company_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../widgets/media_image.dart';

class CompanyDetailScreen extends StatefulWidget {
  const CompanyDetailScreen({super.key, required this.company});

  final Company company;

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late final TmdbRepository _repository;
  late Future<Company> _future;

  @override
  void initState() {
    super.initState();
    _repository = Provider.of<TmdbRepository>(context, listen: false);
    _future = _repository.fetchCompanyDetails(widget.company.id);
  }

  Future<void> _refresh() async {
    final future = _repository.fetchCompanyDetails(widget.company.id);
    setState(() {
      _future = future;
    });
    await future;
  }

  Future<void> _openHomepage(String url, AppLocalizations loc) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.errors['load_failed'] ?? 'Unable to open link.'),
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.errors['load_failed'] ?? 'Unable to open link.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: FutureBuilder<Company>(
        future: _future,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (snapshot.hasError && !snapshot.hasData) {
            return _CompanyDetailErrorView(
              company: widget.company,
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _future = _repository.fetchCompanyDetails(widget.company.id);
                });
              },
            );
          }

          final company = snapshot.data ?? widget.company;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _CompanyDetailAppBar(
                  company: company,
                  isLoading: isLoading && !snapshot.hasData,
                  onRefreshPressed: () {
                    setState(() {
                    _future = _repository.fetchCompanyDetails(
                      widget.company.id,
                    );
                    });
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CompanyDescriptionSection(company: company),
                        const SizedBox(height: 24),
                        _CompanyInfoSection(
                          company: company,
                          onOpenHomepage: (url) => _openHomepage(url, loc),
                        ),
                        const SizedBox(height: 24),
                        _AlternativeNamesSection(company: company),
                        const SizedBox(height: 24),
                        _ProducedTitlesSection(
                          title:
                              loc.company['produced_movies'] ??
                              'Produced Movies',
                          emptyMessage:
                              loc.company['no_produced_movies'] ??
                              'No produced movies available.',
                          titles: _parseProducedTitles(
                            company.producedMovies,
                            isSeries: false,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _ProducedTitlesSection(
                          title:
                              loc.company['produced_series'] ??
                              'Produced Series',
                          emptyMessage:
                              loc.company['no_produced_series'] ??
                              'No produced TV shows available.',
                          titles: _parseProducedTitles(
                            company.producedSeries,
                            isSeries: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _LogoGallerySection(company: company),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompanyDetailAppBar extends StatelessWidget {
  const _CompanyDetailAppBar({
    required this.company,
    required this.isLoading,
    required this.onRefreshPressed,
  });

  final Company company;
  final bool isLoading;
  final VoidCallback onRefreshPressed;

  @override
  Widget build(BuildContext context) {
    final logoPath = company.logoPath;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 220,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefreshPressed,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(company.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: (logoPath != null && logoPath.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: MediaImage(
                        path: logoPath,
                        type: MediaImageType.logo,
                        size: MediaImageSize.w300,
                        fit: BoxFit.contain,
                        placeholder: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: const Icon(Icons.business, size: 96),
                      ),
                    )
                  : const Center(child: Icon(Icons.business, size: 96)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isLoading ? 1 : 0,
                  child: const LinearProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyDescriptionSection extends StatelessWidget {
  const _CompanyDescriptionSection({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final description = company.description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.company['description'] ?? 'Description',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              (description != null && description.isNotEmpty)
                  ? description
                  : loc.company['no_description'] ??
                        'No description available.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyInfoSection extends StatelessWidget {
  const _CompanyInfoSection({
    required this.company,
    required this.onOpenHomepage,
  });

  final Company company;
  final ValueChanged<String> onOpenHomepage;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String _displayOrFallback(String? value) {
      if (value == null || value.trim().isEmpty) {
        return loc.common['not_available'] ?? 'N/A';
      }
      return value.trim();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.company['title'] ?? 'Company',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.location_city,
                  label: loc.company['headquarters'] ?? 'Headquarters',
                  value: _displayOrFallback(company.headquarters),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.flag,
                  label: loc.company['origin_country'] ?? 'Origin Country',
                  value: _displayOrFallback(company.originCountry),
                ),
                const SizedBox(height: 12),
                _ParentCompanyRow(parentCompany: company.parentCompany),
                const SizedBox(height: 12),
                _HomepageRow(
                  homepage: company.homepage,
                  onOpenHomepage: onOpenHomepage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParentCompanyRow extends StatelessWidget {
  const _ParentCompanyRow({required this.parentCompany});

  final ParentCompany? parentCompany;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (parentCompany == null) {
      return _InfoRow(
        icon: Icons.account_tree,
        label: loc.company['parent_company'] ?? 'Parent Company',
        value: loc.common['not_available'] ?? 'N/A',
      );
    }

    final parent = parentCompany!;
    final subtitleParts = <String>[];
    if (parent.originCountry != null && parent.originCountry!.isNotEmpty) {
      subtitleParts.add(parent.originCountry!);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.account_tree, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.company['parent_company'] ?? 'Parent Company',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(parent.name, style: theme.textTheme.bodyMedium),
              if (subtitleParts.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitleParts.join(' • '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HomepageRow extends StatelessWidget {
  const _HomepageRow({required this.homepage, required this.onOpenHomepage});

  final String? homepage;
  final ValueChanged<String> onOpenHomepage;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (homepage == null || homepage!.isEmpty) {
      return _InfoRow(
        icon: Icons.link,
        label: loc.company['homepage'] ?? 'Homepage',
        value: loc.common['not_available'] ?? 'N/A',
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.link, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.company['homepage'] ?? 'Homepage',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => onOpenHomepage(homepage!),
                child: Text(
                  homepage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlternativeNamesSection extends StatelessWidget {
  const _AlternativeNamesSection({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.company['alternative_names'] ?? 'Alternative Names',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (company.alternativeNames.isEmpty)
          Text(
            loc.company['no_alternative_names'] ??
                'No alternative names available.',
            style: theme.textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: company.alternativeNames
                .map((name) => Chip(label: Text(name)))
                .toList(growable: false),
          ),
      ],
    );
  }
}

class _LogoGallerySection extends StatelessWidget {
  const _LogoGallerySection({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.company['logo_gallery'] ?? 'Logo Gallery',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (company.logoGallery.isEmpty)
          Text(
            loc.company['no_logo_gallery'] ?? 'No logos available.',
            style: theme.textTheme.bodyMedium,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 720 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 16 / 9,
            ),
            itemCount: company.logoGallery.length,
            itemBuilder: (context, index) {
              final logo = company.logoGallery[index];
              final path = logo.filePath;

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: (path.isNotEmpty)
                      ? MediaImage(
                          path: path,
                          type: MediaImageType.logo,
                          size: MediaImageSize.w300,
                          fit: BoxFit.contain,
                          placeholder: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.broken_image),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ProducedTitlesSection extends StatefulWidget {
  const _ProducedTitlesSection({
    required this.title,
    required this.emptyMessage,
    required this.titles,
  });

  final String title;
  final String emptyMessage;
  final List<_ProducedTitle> titles;

  @override
  State<_ProducedTitlesSection> createState() => _ProducedTitlesSectionState();
}

enum _ProducedSortOption { newest, rating, alphabetical }

class _ProducedTitlesSectionState extends State<_ProducedTitlesSection> {
  _ProducedSortOption _sortOption = _ProducedSortOption.newest;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (widget.titles.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.emptyMessage, style: theme.textTheme.bodyMedium),
        ],
      );
    }

    final filteredTitles = widget.titles
        .where((title) {
          if (_query.isEmpty) return true;
          return title.title.toLowerCase().contains(_query.toLowerCase());
        })
        .toList(growable: false);

    filteredTitles.sort((a, b) {
      switch (_sortOption) {
        case _ProducedSortOption.newest:
          final dateA = a.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA);
        case _ProducedSortOption.rating:
          final ratingA = a.rating ?? -1;
          final ratingB = b.rating ?? -1;
          return ratingB.compareTo(ratingA);
        case _ProducedSortOption.alphabetical:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<_ProducedSortOption>(
              value: _sortOption,
              underline: const SizedBox.shrink(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _sortOption = value);
              },
              items: [
                DropdownMenuItem(
                  value: _ProducedSortOption.newest,
                  child: Text(
                    loc.company['sort_release_date'] ?? 'Release Date',
                  ),
                ),
                DropdownMenuItem(
                  value: _ProducedSortOption.rating,
                  child: Text(loc.company['sort_rating'] ?? 'Rating'),
                ),
                DropdownMenuItem(
                  value: _ProducedSortOption.alphabetical,
                  child: Text(loc.company['sort_title'] ?? 'Title'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: loc.company['filter_placeholder'] ?? 'Filter titles...',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredTitles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final title = filteredTitles[index];
            final posterUrl = MediaImageHelper.buildUrl(
              title.posterPath,
              type: MediaImageType.poster,
              size: MediaImageSize.w185,
            );
            final subtitleParts = <String>[];
            if (title.releaseDate != null) {
              subtitleParts.add(title.formattedYear);
            }
            if (title.rating != null && title.rating! > 0) {
              subtitleParts.add('${title.rating!.toStringAsFixed(1)} ★');
            }

            return Card(
              child: ListTile(
                leading: (posterUrl != null && posterUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MediaImage(
                          path: title.posterPath,
                          type: MediaImageType.poster,
                          size: MediaImageSize.w185,
                          width: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.movie_creation_outlined),
                      ),
                title: Text(title.title),
                subtitle: subtitleParts.isNotEmpty
                    ? Text(subtitleParts.join(' • '))
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CompanyDetailErrorView extends StatelessWidget {
  const _CompanyDetailErrorView({
    required this.company,
    required this.error,
    required this.onRetry,
  });

  final Company company;
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        AppBar(
          title: Text(company.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    loc.errors['load_failed'] ?? 'Failed to load data',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.common['retry'] ?? 'Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProducedTitle {
  _ProducedTitle({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
  });

  final int? id;
  final String title;
  final String? posterPath;
  final DateTime? releaseDate;
  final double? rating;

  String get formattedYear => releaseDate?.year.toString() ?? '';
}

List<_ProducedTitle> _parseProducedTitles(
  List<dynamic> items, {
  required bool isSeries,
}) {
  return items
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final title = _extractTitle(item, isSeries: isSeries);
        if (title == null || title.isEmpty) {
          return null;
        }

        final dateString = isSeries
            ? (item['first_air_date'] as String?)
            : (item['release_date'] as String?);
        final releaseDate = (dateString != null && dateString.isNotEmpty)
            ? DateTime.tryParse(dateString)
            : null;

        double? rating;
        final voteAverage = item['vote_average'];
        if (voteAverage is num) {
          rating = voteAverage.toDouble();
        }

        final posterPath =
            (item['poster_path'] ?? item['backdrop_path']) as String?;

        return _ProducedTitle(
          id: item['id'] as int?,
          title: title,
          posterPath: posterPath,
          releaseDate: releaseDate,
          rating: rating,
        );
      })
      .whereType<_ProducedTitle>()
      .toList(growable: false);
}

String? _extractTitle(Map<String, dynamic> json, {required bool isSeries}) {
  final possibleKeys = isSeries
      ? ['name', 'original_name', 'title']
      : ['title', 'name', 'original_title'];
  for (final key in possibleKeys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
