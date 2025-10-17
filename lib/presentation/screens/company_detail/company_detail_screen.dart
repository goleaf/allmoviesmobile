import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/company_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../widgets/media_image.dart';
import '../../widgets/share_link_sheet.dart';
import '../../../core/navigation/deep_link_parser.dart';

class CompanyDetailScreen extends StatefulWidget {
  static const routeName = '/company-detail';

  final Company initialCompany;

  const CompanyDetailScreen({super.key, required this.initialCompany});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late Future<Company> _companyFuture;

  @override
  void initState() {
    super.initState();
    _companyFuture = _loadCompany();
  }

  Future<Company> _loadCompany({bool forceRefresh = false}) {
    return context.read<TmdbRepository>().fetchCompanyDetails(
      widget.initialCompany.id,
    );
  }

  Future<void> _refreshCompany() async {
    final future = _loadCompany(forceRefresh: true);
    setState(() {
      _companyFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FullscreenModalScaffold(
      title: Text(widget.initialCompany.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: loc.movie['share'] ?? loc.t('movie.share'),
          onPressed: () {
            showShareLinkSheet(
              context,
              title: widget.initialCompany.name,
              link: DeepLinkBuilder.company(widget.initialCompany.id),
            );
          },
        ),
      ],
      body: FutureBuilder<Company>(
        future: _companyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load company details.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshCompany,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final company = snapshot.data ?? widget.initialCompany;
          final isRefreshing =
              snapshot.connectionState == ConnectionState.waiting;

          return _CompanyDetailBody(
            company: company,
            loc: loc,
            onRefresh: _refreshCompany,
            isRefreshing: isRefreshing,
          );
        },
      ),
    );
  }
}

class _CompanyDetailBody extends StatelessWidget {
  const _CompanyDetailBody({
    required this.company,
    required this.loc,
    required this.onRefresh,
    required this.isRefreshing,
  });

  final Company company;
  final AppLocalizations loc;
  final Future<void> Function() onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoPath = company.logoPath;
    final description = (company.description?.trim().isNotEmpty ?? false)
        ? company.description!.trim()
        : 'No description available.';
    final producedMovies = _extractTitles(company.producedMovies);
    final producedSeries = _extractTitles(company.producedSeries);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (isRefreshing) const LinearProgressIndicator(minHeight: 2),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: (logoPath != null && logoPath.isNotEmpty)
                  ? MediaImage(
                      path: logoPath,
                      type: MediaImageType.logo,
                      size: MediaImageSize.w185,
                      fit: BoxFit.contain,
                      placeholder: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: Icon(
                        Icons.business_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.business_outlined,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            company.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: loc.company['origin_country'] ?? 'Origin Country',
            value: company.originCountry?.isNotEmpty == true
                ? company.originCountry!
                : '—',
          ),
          _InfoRow(
            label: loc.company['headquarters'] ?? 'Headquarters',
            value: company.headquarters?.isNotEmpty == true
                ? company.headquarters!
                : '—',
          ),
          _InfoRow(
            label: loc.company['homepage'] ?? 'Homepage',
            value: company.homepage?.isNotEmpty == true
                ? company.homepage!
                : '—',
          ),
          const SizedBox(height: 24),
          Text(
            loc.company['description'] ?? 'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          if (producedMovies.isNotEmpty)
            _ProducedList(
              title: loc.company['produced_movies'] ?? 'Produced Movies',
              items: producedMovies,
            ),
          if (producedMovies.isNotEmpty && producedSeries.isNotEmpty)
            const SizedBox(height: 16),
          if (producedSeries.isNotEmpty)
            _ProducedList(
              title: loc.company['produced_series'] ?? 'Produced Series',
              items: producedSeries,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<String> _extractTitles(List<dynamic> items) {
    final results = <String>[];
    final seen = <String>{};

    for (final item in items) {
      String? title;
      if (item is Map<String, dynamic>) {
        final raw = item['title'] ?? item['name'];
        if (raw is String) {
          title = raw.trim();
        }
      } else if (item is String) {
        title = item.trim();
      } else {
        title = item?.toString().trim();
      }

      if (title != null && title.isNotEmpty && seen.add(title)) {
        results.add(title);
      }

      if (results.length >= 12) {
        break;
      }
    }

    return results;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ProducedList extends StatelessWidget {
  const _ProducedList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('• $item', style: theme.textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
