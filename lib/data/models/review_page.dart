import 'review_model.dart';

/// Paginated response of reviews from TMDB.
class ReviewPage {
  const ReviewPage({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.reviews,
  });

  factory ReviewPage.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    final reviews = results is List
        ? results
              .whereType<Map<String, dynamic>>()
              .map(Review.fromJson)
              .toList(growable: false)
        : const <Review>[];

    return ReviewPage(
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalResults: (json['total_results'] as num?)?.toInt() ?? reviews.length,
      reviews: reviews,
    );
  }

  final int page;
  final int totalPages;
  final int totalResults;
  final List<Review> reviews;

  bool get hasMore => page < totalPages;
}
