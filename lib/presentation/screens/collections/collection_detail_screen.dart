import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/deep_link_handler.dart';
import '../../../data/models/collection_detail_view.dart';
import '../../../data/services/api_config.dart';
import '../../../providers/collection_details_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../widgets/media_image.dart';
import '../../widgets/share_link_sheet.dart';
import '../../../core/navigation/deep_link_parser.dart';

class CollectionDetailScreen extends StatelessWidget {
  static const routeName = '/collection-detail';

  final int collectionId;
  final String? initialName;
  final String? initialPosterPath;
  final String? initialBackdropPath;

  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
    this.initialName,
    this.initialPosterPath,
    this.initialBackdropPath,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CollectionDetailsProvider()..loadCollection(collectionId),
      child: _CollectionDetailView(
        collectionId: collectionId,
        initialName: initialName,
        initialPosterPath: initialPosterPath,
        initialBackdropPath: initialBackdropPath,
      ),
    );
  }
}

class _CollectionDetailView extends StatefulWidget {
  const _CollectionDetailView({
    required this.collectionId,
    this.initialName,
    this.initialPosterPath,
    this.initialBackdropPath,
  });

  final int collectionId;
  final String? initialName;
  final String? initialPosterPath;
  final String? initialBackdropPath;

  @override
  State<_CollectionDetailView> createState() => _CollectionDetailViewState();
}

enum _PartsSortMode { order, releaseDate }

class _CollectionDetailViewState extends State<_CollectionDetailView> {
  _PartsSortMode _sortMode = _PartsSortMode.order;

  List<Widget> _buildShareActions(BuildContext context, String name) {
    final loc = AppLocalizations.of(context);
    final displayName = name.isEmpty
        ? '${loc.t('collection.title')} #${widget.collectionId}'
        : name;
    return [
      IconButton(
        icon: const Icon(Icons.share),
        tooltip: loc.movie['share'] ?? loc.t('movie.share'),
        onPressed: () {
          showShareLinkSheet(
            context,
            title: displayName,
            link: DeepLinkBuilder.collection(widget.collectionId),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionDetailsProvider>();
    final loc = AppLocalizations.of(context);
    final data = provider.collection;

    if (provider.isLoading && data == null) {
      return FullscreenModalScaffold(
        title: const Text(''),
        actions: _buildShareActions(context, widget.initialName ?? ''),
        body: const LoadingIndicator(),
      );
    }

    if (provider.errorMessage != null && data == null) {
      return FullscreenModalScaffold(
        title: Text(loc.t('collection.title')),
        actions: _buildShareActions(context, widget.initialName ?? ''),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.t('errors.load_failed'),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<CollectionDetailsProvider>()
                      .loadCollection(widget.collectionId),
                  icon: const Icon(Icons.refresh),
                  label: Text(loc.t('common.retry')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final backdropPath = data?.backdropPath ?? widget.initialBackdropPath;
    final posterPath = data?.posterPath ?? widget.initialPosterPath;
    final displayName =
        data?.name ?? widget.initialName ?? loc.t('collection.title');
    final overview = data?.overview;

    return FullscreenModalScaffold(
      includeDefaultSliverAppBar: false,
      actions: _buildShareActions(context, displayName),
      sliverScrollWrapper: (scroll) => RefreshIndicator(
        onRefresh: () => context
            .read<CollectionDetailsProvider>()
            .loadCollection(widget.collectionId),
        child: scroll,
      ),
      slivers: [
        _buildAppBar(context, backdropPath, displayName, widget.collectionId),
        if (provider.isLoading && data != null)
          const SliverToBoxAdapter(child: LinearProgressIndicator()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  context,
                  loc,
                  widget.collectionId,
                  posterPath,
                  displayName,
                  data?.totalRevenue,
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: loc.t('collection.overview')),
                const SizedBox(height: 8),
                Text(
                  (overview != null && overview.trim().isNotEmpty)
                      ? overview
                      : loc.t('collection.no_overview'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (data != null && data.parts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _SectionTitle(text: loc.t('collection.parts')),
                      ),
                      const SizedBox(width: 12),
                      _buildSortToggle(context, loc),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPartsList(context, loc, _sortedParts(data.parts)),
                  const SizedBox(height: 24),
                  _SectionTitle(text: loc.t('collection.release_timeline')),
                  const SizedBox(height: 12),
                  _buildTimeline(context, loc, _sortedParts(data.parts)),
                ],
                if (data != null && data.images.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionTitle(text: loc.t('collection.images')),
                  const SizedBox(height: 12),
                  _buildImagesGallery(context, data.images),
                ],
                if (data != null && data.translations.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionTitle(text: loc.t('collection.translations')),
                  const SizedBox(height: 12),
                  _buildTranslations(context, loc, data.translations),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<CollectionPartItem> _sortedParts(List<CollectionPartItem> parts) {
    final list = List<CollectionPartItem>.from(parts);
    if (_sortMode == _PartsSortMode.order) {
      list.sort((a, b) {
        if (a.order != null && b.order != null && a.order != b.order) {
          return a.order!.compareTo(b.order!);
        }
        final dateA = a.releaseDateTime;
        final dateB = b.releaseDateTime;
        if (dateA != null && dateB != null) {
          return dateA.compareTo(dateB);
        }
        if (dateA != null) return -1;
        if (dateB != null) return 1;
        return a.title.compareTo(b.title);
      });
      return list;
    }
    list.sort((a, b) {
      final dateA = a.releaseDateTime;
      final dateB = b.releaseDateTime;
      if (dateA != null && dateB != null) {
        return dateA.compareTo(dateB);
      }
      if (dateA != null) return -1;
      if (dateB != null) return 1;
      return a.title.compareTo(b.title);
    });
    return list;
  }

  Widget _buildSortToggle(BuildContext context, AppLocalizations loc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          loc.t('collection.sort_label'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        DropdownButton<_PartsSortMode>(
          value: _sortMode,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _sortMode = value);
          },
          items: [
            DropdownMenuItem(
              value: _PartsSortMode.order,
              child: Text(loc.t('collection.sort_order')),
            ),
            DropdownMenuItem(
              value: _PartsSortMode.releaseDate,
              child: Text(loc.t('collection.sort_release_date')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    int collectionId,
    String? backdropPath,
    String title,
    int collectionId,
  ) {
    final backdropUrl = backdropPath;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 240,
      title: Text(title),
      actions: [
        IconButton(
          tooltip: 'Share',
          icon: const Icon(Icons.share),
          onPressed: () {
            showDeepLinkShareSheet(
              context,
              title: title,
              deepLink: DeepLinkHandler.buildCollectionUri(
                collectionId,
                universal: true,
              ),
              fallbackUrl: 'https://www.themoviedb.org/collection/$collectionId',
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: (backdropUrl != null && backdropUrl.isNotEmpty)
            ? Stack(
                fit: StackFit.expand,
                children: [
                  MediaImage(
                    path: backdropPath,
                    type: MediaImageType.backdrop,
                    size: MediaImageSize.w1280,
                    fit: BoxFit.cover,
                    placeholder: Container(color: Colors.grey[300]),
                    errorWidget: Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.photo, size: 64),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.collections_bookmark, size: 72),
              ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations loc,
    int collectionId,
    String? posterPath,
    String title,
    num? totalRevenue,
  ) {
    final posterUrl = posterPath;
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final currencyFormatter = NumberFormat.simpleCurrency(locale: localeName);
    final revenueText = (totalRevenue != null && totalRevenue > 0)
        ? currencyFormatter.format(totalRevenue)
        : loc.t('common.not_available');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'collection-poster-$collectionId',
          flightShuttleBuilder: (context, animation, direction, from, to) {
            return FadeTransition(
              opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
              child: to.widget,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (posterUrl != null && posterUrl.isNotEmpty)
                ? MediaImage(
                    path: posterPath,
                    type: MediaImageType.poster,
                    size: MediaImageSize.w500,
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      width: 120,
                      height: 180,
                      color: Colors.grey[300],
                    ),
                    errorWidget: Container(
                      width: 120,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.movie, size: 48),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.t('collection.total_revenue'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                revenueText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartsList(
    BuildContext context,
    AppLocalizations loc,
    List<CollectionPartItem> parts,
  ) {
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final currencyFormatter = NumberFormat.simpleCurrency(locale: localeName);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final part = parts[index];
        final posterUrl = part.posterPath;
        final releaseText = part.formattedReleaseDate(localeName);
        final rating = part.voteAverage;
        final revenueText = (part.revenue != null && part.revenue! > 0)
            ? currencyFormatter.format(part.revenue)
            : null;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.4),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (posterUrl != null && posterUrl.isNotEmpty)
                    ? MediaImage(
                        path: part.posterPath,
                        type: MediaImageType.poster,
                        size: MediaImageSize.w342,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey[300],
                        ),
                        errorWidget: Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie_filter),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (releaseText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        releaseText,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (rating != null && rating > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(rating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                    if (revenueText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${loc.t('collection.revenue_label')}: $revenueText',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (part.overview != null &&
                        part.overview!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        part.overview!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    AppLocalizations loc,
    List<CollectionPartItem> parts,
  ) {
    final localeName = Localizations.localeOf(context).toLanguageTag();
    return SizedBox(
      height: 140,
      child: parts.isEmpty
          ? Center(child: Text(loc.t('collection.no_timeline_data')))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: parts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final part = parts[index];
                final releaseDate = part.releaseDateTime;
                final releaseLabel = releaseDate != null
                    ? DateFormat.y(localeName).format(releaseDate)
                    : loc.t('collection.unknown_release_date');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      releaseLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 2,
                            height: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.movie,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: Text(
                        part.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildImagesGallery(
    BuildContext context,
    List<CollectionImageItem> images,
  ) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final image = images[index];
          final imageUrl = image.filePath;

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MediaImage(
              path: imageUrl,
              type: image.type == 'poster'
                  ? MediaImageType.poster
                  : MediaImageType.backdrop,
              size: image.type == 'poster'
                  ? MediaImageSize.w342
                  : MediaImageSize.w780,
              width: image.type == 'poster' ? 120 : 240,
              height: 180,
              fit: BoxFit.cover,
              placeholder: Container(
                width: image.type == 'poster' ? 120 : 240,
                height: 180,
                color: Colors.grey[300],
              ),
              errorWidget: Container(
                width: image.type == 'poster' ? 120 : 240,
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTranslations(
    BuildContext context,
    AppLocalizations loc,
    List<CollectionTranslationItem> translations,
  ) {
    return Column(
      children: translations
          .map(
            (translation) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  '${translation.englishName} (${translation.iso6391.toUpperCase()})',
                ),
                subtitle: Text(
                  translation.title.isNotEmpty
                      ? translation.title
                      : loc.t('collection.no_translation_title'),
                ),
                children: [
                  if (translation.overview != null &&
                      translation.overview!.trim().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('collection.translation_overview'),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          translation.overview!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    )
                  else
                    Text(loc.t('collection.no_translation_overview')),
                  if (translation.homepage != null &&
                      translation.homepage!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${loc.t('collection.translation_homepage')}: ${translation.homepage}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
