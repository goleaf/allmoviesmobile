import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/movie_detailed_model.dart';
import '../../core/utils/media_image_helper.dart';
import 'media_image.dart';
import 'loading_indicator.dart';
import '../../data/tmdb_repository.dart';
import 'loading_indicator.dart';

class SavedMovieCard extends StatefulWidget {
  const SavedMovieCard({
    super.key,
    required this.movieId,
    required this.removeIcon,
    required this.removeColor,
    required this.onRemove,
    this.removeTooltip,
  });

  final int movieId;
  final IconData removeIcon;
  final Color removeColor;
  final Future<void> Function() onRemove;
  final String? removeTooltip;

  @override
  State<SavedMovieCard> createState() => _SavedMovieCardState();
}

class _SavedMovieCardState extends State<SavedMovieCard> {
  late Future<MovieDetailed> _movieFuture;

  @override
  void initState() {
    super.initState();
    _movieFuture = _fetchMovieDetails();
  }

  Future<MovieDetailed> _fetchMovieDetails({bool forceRefresh = false}) {
    final repository = context.read<TmdbRepository>();
    return repository.fetchMovieDetails(
      widget.movieId,
      forceRefresh: forceRefresh,
    );
  }

  void _retryLoad() {
    setState(() {
      _movieFuture = _fetchMovieDetails(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FutureBuilder<MovieDetailed>(
      future: _movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _LoadingCard();
        }

        if (snapshot.hasError) {
          return _ErrorCard(
            message: loc.t('errors.load_failed'),
            retryLabel: loc.t('common.retry'),
            onRetry: _retryLoad,
          );
        }

        final movie = snapshot.data;
        if (movie == null) {
          return _ErrorCard(
            message: loc.t('errors.load_failed'),
            retryLabel: loc.t('common.retry'),
            onRetry: _retryLoad,
          );
        }

        return _MovieContent(
          movie: movie,
          removeIcon: widget.removeIcon,
          removeColor: widget.removeColor,
          removeTooltip: widget.removeTooltip,
          onRemove: widget.onRemove,
        );
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => ShimmerLoading(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: const ShimmerLoading(
                width: double.infinity,
                height: 12,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 36,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

class _MovieContent extends StatelessWidget {
  const _MovieContent({
    required this.movie,
    required this.removeIcon,
    required this.removeColor,
    required this.onRemove,
    this.removeTooltip,
  });

  final MovieDetailed movie;
  final IconData removeIcon;
  final Color removeColor;
  final Future<void> Function() onRemove;
  final String? removeTooltip;

  @override
  Widget build(BuildContext context) {
    final posterPath = movie.posterPath;
    final releaseYear = (movie.releaseDate ?? '').isNotEmpty
        ? movie.releaseDate!.split('-').first
        : null;
    final voteAverage = movie.voteAverage;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (posterPath != null && posterPath.isNotEmpty)
                    ? MediaImage(
                        path: posterPath,
                        type: MediaImageType.poster,
                        size: MediaImageSize.w342,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (voteAverage > 0) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            voteAverage.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                        ] else
                          const Spacer(),
                        if (releaseYear != null)
                          Text(
                            releaseYear,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _ActionIcon(
              icon: removeIcon,
              color: removeColor,
              tooltip: removeTooltip,
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final Color color;
  final Future<void> Function() onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.black.withOpacity(0.6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          await onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}
