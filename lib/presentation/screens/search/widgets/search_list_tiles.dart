import 'package:flutter/material.dart';

import '../../../../data/models/company_model.dart';
import '../../../../data/models/search_result_model.dart';
import '../../movie_detail/movie_detail_screen.dart';
import '../../../widgets/media_image.dart';
import '../../../../core/config/app_config.dart';

class SearchResultListTile extends StatelessWidget {
  const SearchResultListTile({
    required this.result,
    this.showDivider = true,
  });

  final SearchResult result;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final title = (result.title ?? result.name ?? '').trim();
    final overview = (result.overview ?? '').trim();
    final mediaLabel = switch (result.mediaType) {
      MediaType.movie => 'Movie',
      MediaType.tv => 'TV Show',
      MediaType.person => 'Person',
    };

    final tile = ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: ResultThumbnail(imageUrl: _posterImage),
      title: Text(title.isEmpty ? 'Untitled $mediaLabel' : title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mediaLabel),
          if (overview.isNotEmpty)
            Text(
              overview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      onTap: result.mediaType == MediaType.movie
          ? () {
              Navigator.pushNamed(
                context,
                MovieDetailScreen.routeName,
                arguments: result.id,
              );
            }
          : null,
    );

    if (!showDivider) {
      return tile;
    }

    return Column(
      children: [
        tile,
        const Divider(height: 0),
      ],
    );
  }

  String? get _posterImage {
    if (result.posterPath != null && result.posterPath!.isNotEmpty) {
      return AppConfig.tmdbImageBaseUrl + '/w185' + (result.posterPath!.startsWith('/') ? '' : '/') + result.posterPath!;
    }
    if (result.profilePath != null && result.profilePath!.isNotEmpty) {
      return AppConfig.tmdbImageBaseUrl + '/w185' + (result.profilePath!.startsWith('/') ? '' : '/') + result.profilePath!;
    }
    return null;
  }
}

class CompanyResultTile extends StatelessWidget {
  const CompanyResultTile({
    required this.company,
    this.showDivider = true,
  });

  final Company company;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: ResultThumbnail(
        imageUrl: _logoUrl,
        isCircular: true,
        fallbackLabel: company.name.isNotEmpty ? company.name[0].toUpperCase() : 'C',
      ),
      title: Text(company.name),
      subtitle: Text(
        company.originCountry?.isNotEmpty == true ? company.originCountry! : 'Company',
      ),
    );

    if (!showDivider) {
      return tile;
    }

    return Column(
      children: [
        tile,
        const Divider(height: 0),
      ],
    );
  }

  String? get _logoUrl {
    if (company.logoPath != null && company.logoPath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w185${company.logoPath}';
    }
    return null;
  }
}

class ResultThumbnail extends StatelessWidget {
  const ResultThumbnail({
    required this.imageUrl,
    this.isCircular = false,
    this.fallbackLabel,
  });

  final String? imageUrl;
  final bool isCircular;
  final String? fallbackLabel;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        (fallbackLabel ?? '?').toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      ),
    );

    if (imageUrl == null) {
      return placeholder;
    }

    final image = ClipRRect(
      borderRadius: isCircular ? null : BorderRadius.circular(8),
      child: MediaImage(
        path: imageUrl,
        type: isCircular ? MediaImageType.profile : MediaImageType.poster,
        size: MediaImageSize.w185,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorWidget: placeholder,
      ),
    );

    if (isCircular) {
      return ClipOval(child: image);
    }

    return image;
  }
}
