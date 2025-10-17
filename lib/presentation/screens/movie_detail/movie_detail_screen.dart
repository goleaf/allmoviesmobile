import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/movie.dart';

class MovieDetailScreen extends StatelessWidget {
  static const routeName = '/movie-detail';

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainInfo(context),
                if (movie.overview != null && movie.overview!.isNotEmpty)
                  _buildOverview(context),
                _buildMetadata(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final backdropUrl = movie.backdropUrl ?? movie.posterUrl;
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          movie.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 4.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: backdropUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image, size: 64),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.movie, size: 64),
              ),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPoster(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movie.releaseYear != null)
                  Text(
                    movie.releaseYear!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                const SizedBox(height: 8),
                Text(
                  movie.mediaLabel,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _buildRatingInfo(context),
                const SizedBox(height: 16),
                if (movie.genres.isNotEmpty) _buildGenres(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(BuildContext context) {
    final posterUrl = movie.posterUrl;
    
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: posterUrl != null
            ? CachedNetworkImage(
                imageUrl: posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image),
                ),
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.movie_outlined, size: 48),
              ),
      ),
    );
  }

  Widget _buildRatingInfo(BuildContext context) {
    if (movie.voteAverage == null || movie.voteAverage! <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              movie.voteAverage!.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              ' / 10',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        if (movie.voteCount != null && movie.voteCount! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              movie.formattedVoteCount,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildGenres(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: movie.genres.take(5).map((genre) {
        return Chip(
          label: Text(genre),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 12,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildOverview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            movie.overview!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    final metadata = <MapEntry<String, String>>[];

    if (movie.originalTitle != null && movie.originalTitle != movie.title) {
      metadata.add(MapEntry('Original Title', movie.originalTitle!));
    }

    if (movie.originalLanguage != null) {
      metadata.add(MapEntry(
        'Original Language',
        movie.originalLanguage!.toUpperCase(),
      ));
    }

    if (movie.popularity != null) {
      metadata.add(MapEntry(
        'Popularity',
        movie.formattedPopularity,
      ));
    }

    if (metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...metadata.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
            );
          }),
        ],
      ),
    );
  }
}

