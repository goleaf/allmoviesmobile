import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../providers/accessibility_provider.dart';
import '../../providers/favorites_provider.dart';
import 'media_image.dart';

/// {@template movie_card}
/// Displays concise movie metadata sourced from TMDB list endpoints such as
/// `GET /3/movie/popular` and `GET /3/trending/movie/{time_window}`. The widget
/// is optimized for accessibility with semantics, focus indicators, and
/// keyboard navigation hints.
/// {@endtemplate}
class MovieCard extends StatefulWidget {
  const MovieCard({
    super.key,
    required this.id,
    required this.title,
    this.posterPath,
    this.voteAverage,
    this.releaseDate,
    this.showingLabel,
    this.onTap,
  });

  final int id;
  final String title;
  final String? posterPath;
  final double? voteAverage;
  final String? releaseDate;
  final String? showingLabel;
  final VoidCallback? onTap;

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isFocused = false;
  bool _isHovered = false;

  /// Builds the accessible card structure that surfaces TMDB list metadata in
  /// a keyboard and screen-reader friendly layout.
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();
    final accessibility = context.watch<AccessibilityProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.id);
    final releaseYear = (widget.releaseDate != null &&
            widget.releaseDate!.isNotEmpty &&
            widget.releaseDate!.length >= 4)
        ? widget.releaseDate!.substring(0, 4)
        : loc.t('common.unknown');
    final ratingLabel = widget.voteAverage != null
        ? widget.voteAverage!.toStringAsFixed(1)
        : loc.t('common.not_available');
    final showingLabel = widget.showingLabel ?? '';

    final semanticsLabel = '${widget.title}. '
        '${loc.t('movie.rating')}: $ratingLabel. '
        '${loc.t('movie.release_date')}: $releaseYear.'
        '${showingLabel.isNotEmpty ? ' $showingLabel.' : ''}';
    final semanticsHint = accessibility.keyboardNavigationHints
        ? loc.t('common.open_details_keyboard_hint')
        : loc.t('common.view_details_action');
    final focusBorderColor = Theme.of(context).colorScheme.secondary;
    final showFocus = accessibility.showFocusIndicators && _isFocused;

    return Semantics(
      container: true,
      button: true,
      enabled: widget.onTap != null,
      label: semanticsLabel,
      hint: semanticsHint,
      child: FocusableActionDetector(
        onShowFocusHighlight: (value) {
          if (value != _isFocused) {
            setState(() => _isFocused = value);
          }
        },
        onShowHoverHighlight: (value) {
          if (value != _isHovered) {
            setState(() => _isHovered = value);
          }
        },
        mouseCursor:
            widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: showFocus ? focusBorderColor : Colors.transparent,
              width: showFocus ? 3 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: focusBorderColor.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: widget.onTap,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPoster(context, loc)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (widget.voteAverage != null) ...[
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ratingLabel,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  releaseYear,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            if (showingLabel.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                showingLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Semantics(
                      button: true,
                      label: isFavorite
                          ? loc.t('movie.remove_from_favorites')
                          : loc.t('movie.add_to_favorites'),
                      hint: loc.t('common.toggle_favorite_hint'),
                      child: Tooltip(
                        message: isFavorite
                            ? loc.t('movie.remove_from_favorites')
                            : loc.t('movie.add_to_favorites'),
                        child: IconButton(
                          iconSize: 20,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            favoritesProvider.toggleFavorite(widget.id);
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the poster image widget with semantic metadata for screen readers.
  Widget _buildPoster(BuildContext context, AppLocalizations loc) {
    if (widget.posterPath == null || widget.posterPath!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.movie, size: 48, color: Colors.grey),
        ),
      );
    }

    final semanticLabel =
        '${loc.t('common.poster_semantics_prefix')} ${widget.title}';

    return MediaImage(
      path: widget.posterPath,
      type: MediaImageType.poster,
      size: MediaImageSize.w342,
      fit: BoxFit.cover,
      semanticLabel: semanticLabel,
      placeholder: Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      ),
    );
  }
}
