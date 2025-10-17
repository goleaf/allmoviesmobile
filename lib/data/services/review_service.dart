import '../models/review_model.dart';
import '../models/review_page.dart';
import 'tmdb_comprehensive_service.dart';

enum ReviewMediaType {
  movie,
  tv,
}

/// Facade around the TMDB comprehensive service for working with reviews.
class ReviewService {
  ReviewService({
    TmdbComprehensiveService? tmdbService,
  }) : _tmdbService = tmdbService ?? TmdbComprehensiveService();

  final TmdbComprehensiveService _tmdbService;

  Future<ReviewPage> fetchReviews({
    required int mediaId,
    ReviewMediaType mediaType = ReviewMediaType.movie,
    int page = 1,
  }) async {
    final response = mediaType == ReviewMediaType.movie
        ? await _tmdbService.getMovieReviews(mediaId, page: page)
        : await _tmdbService.getTVShowReviews(mediaId, page: page);

    return ReviewPage.fromJson(response);
  }

  Future<Review> fetchReviewDetails(String reviewId) async {
    final response = await _tmdbService.getReviewDetails(reviewId);
    return Review.fromJson(response);
  }
}
