import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? voteCount;
  final double size;
  final bool showLabel;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.voteCount,
    this.size = 16,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: size,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.875,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showLabel && voteCount != null) ...[
          Text(
            ' / 10',
            style: TextStyle(
              fontSize: size * 0.75,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($voteCount)',
            style: TextStyle(
              fontSize: size * 0.75,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

class RatingStars extends StatelessWidget {
  final double rating; // 0-10
  final double size;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    final normalizedRating = rating / 2; // Convert 10-point scale to 5-star scale
    final fullStars = normalizedRating.floor();
    final hasHalfStar = (normalizedRating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: starColor, size: size);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: starColor, size: size);
        } else {
          return Icon(Icons.star_border, color: starColor, size: size);
        }
      }),
    );
  }
}

