import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/models/review_model.dart';
import '../data/services/review_service.dart';

enum ReviewSortOption {
  newest,
  highestRated,
}

enum ReviewRatingFilter {
  all(null, 'All ratings'),
  ninePlus(9, '9+'),
  eightPlus(8, '8+'),
  sevenPlus(7, '7+'),
  sixPlus(6, '6+'),
  fivePlus(5, '5+');

  const ReviewRatingFilter(this.minRating, this.label);

  final double? minRating;
  final String label;
}

enum ReviewVote {
  helpful,
  notHelpful,
}

class ReviewHelpfulState {
  const ReviewHelpfulState({
    required this.helpfulCount,
    required this.totalVotes,
    this.userVote,
  });

  final int helpfulCount;
  final int totalVotes;
  final ReviewVote? userVote;

  double get helpfulRatio =>
      totalVotes == 0 ? 0 : helpfulCount / totalVotes;

  ReviewHelpfulState copyWith({
    int? helpfulCount,
    int? totalVotes,
    ReviewVote? userVote,
  }) {
    return ReviewHelpfulState(
      helpfulCount: helpfulCount ?? this.helpfulCount,
      totalVotes: totalVotes ?? this.totalVotes,
      userVote: userVote,
    );
  }
}

class ReviewListProvider extends ChangeNotifier {
  ReviewListProvider({
    required this.mediaId,
    this.mediaType = ReviewMediaType.movie,
    ReviewService? reviewService,
  }) : _reviewService = reviewService ?? ReviewService();

  final int mediaId;
  final ReviewMediaType mediaType;
  final ReviewService _reviewService;

  final Map<String, ReviewHelpfulState> _helpfulStates = {};
  final Set<String> _reportedReviewIds = {};

  List<Review> _reviews = const [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasLoadedInitial = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 1;
  ReviewSortOption _sortOption = ReviewSortOption.newest;
  ReviewRatingFilter _ratingFilter = ReviewRatingFilter.all;

  List<Review> get _sortedReviews {
    final reviews = List<Review>.from(_reviews);
    reviews.sort((a, b) {
      switch (_sortOption) {
        case ReviewSortOption.newest:
          final aDate = _reviewDate(a);
          final bDate = _reviewDate(b);
          return bDate.compareTo(aDate);
        case ReviewSortOption.highestRated:
          final aRating = a.authorDetails.rating ?? -1;
          final bRating = b.authorDetails.rating ?? -1;
          if (bRating.compareTo(aRating) != 0) {
            return bRating.compareTo(aRating);
          }
          return _reviewDate(b).compareTo(_reviewDate(a));
      }
    });
    return reviews;
  }

  List<Review> get visibleReviews {
    final filtered = _sortedReviews.where((review) {
      final threshold = _ratingFilter.minRating;
      if (threshold == null) {
        return true;
      }
      final rating = review.authorDetails.rating;
      if (rating == null) {
        return false;
      }
      return rating >= threshold;
    }).toList(growable: false);

    return filtered;
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasLoadedInitial => _hasLoadedInitial;
  String? get errorMessage => _errorMessage;
  ReviewSortOption get sortOption => _sortOption;
  ReviewRatingFilter get ratingFilter => _ratingFilter;
  int get totalReviews => _reviews.length;
  bool get canLoadMore =>
      !_isLoadingMore &&
      !_isLoading &&
      _currentPage < _totalPages;

  ReviewHelpfulState helpfulStateFor(String reviewId) {
    return _helpfulStates[reviewId] ??
        const ReviewHelpfulState(helpfulCount: 0, totalVotes: 0);
  }

  bool isReported(String reviewId) => _reportedReviewIds.contains(reviewId);

  Future<void> loadInitial() async {
    if (_isLoading || _isLoadingMore) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _reviewService.fetchReviews(
        mediaId: mediaId,
        mediaType: mediaType,
        page: 1,
      );

      _reviews = page.reviews;
      _currentPage = page.page;
      _totalPages = page.totalPages;
      _hasLoadedInitial = true;
      _seedHelpfulStates(_reviews);
    } catch (error) {
      _errorMessage = 'Failed to load reviews: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!canLoadMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final page = await _reviewService.fetchReviews(
        mediaId: mediaId,
        mediaType: mediaType,
        page: nextPage,
      );

      _reviews = [
        ..._reviews,
        ...page.reviews.where(
          (review) => !_reviews.any((existing) => existing.id == review.id),
        ),
      ];
      _currentPage = page.page;
      _totalPages = page.totalPages;
      _seedHelpfulStates(page.reviews);
    } catch (error) {
      _errorMessage = 'Failed to load more reviews: $error';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<Review?> refreshReview(String reviewId) async {
    try {
      final review = await _reviewService.fetchReviewDetails(reviewId);
      final idx = _reviews.indexWhere((item) => item.id == reviewId);
      if (idx != -1) {
        _reviews = List<Review>.from(_reviews)
          ..removeAt(idx)
          ..insert(idx, review);
      } else {
        _reviews = List<Review>.from(_reviews)..insert(0, review);
      }
      _seedHelpfulStates([review]);
      notifyListeners();
      return review;
    } catch (error) {
      _errorMessage = 'Failed to refresh review: $error';
      notifyListeners();
      return null;
    }
  }

  void setSortOption(ReviewSortOption option) {
    if (_sortOption == option) {
      return;
    }
    _sortOption = option;
    notifyListeners();
  }

  void setRatingFilter(ReviewRatingFilter filter) {
    if (_ratingFilter == filter) {
      return;
    }
    _ratingFilter = filter;
    notifyListeners();
  }

  void reportReview(String reviewId) {
    if (_reportedReviewIds.contains(reviewId)) {
      return;
    }
    _reportedReviewIds.add(reviewId);
    notifyListeners();
  }

  void vote(String reviewId, ReviewVote vote) {
    final current = helpfulStateFor(reviewId);

    var helpfulCount = current.helpfulCount;
    var totalVotes = current.totalVotes;
    ReviewVote? userVote = current.userVote;

    if (userVote == vote) {
      switch (vote) {
        case ReviewVote.helpful:
          helpfulCount = max(0, helpfulCount - 1);
          totalVotes = max(0, totalVotes - 1);
          break;
        case ReviewVote.notHelpful:
          totalVotes = max(0, totalVotes - 1);
          break;
      }
      userVote = null;
    } else {
      if (userVote != null) {
        switch (userVote) {
          case ReviewVote.helpful:
            helpfulCount = max(0, helpfulCount - 1);
            totalVotes = max(0, totalVotes - 1);
            break;
          case ReviewVote.notHelpful:
            totalVotes = max(0, totalVotes - 1);
            break;
        }
      }

      switch (vote) {
        case ReviewVote.helpful:
          helpfulCount += 1;
          totalVotes += 1;
          break;
        case ReviewVote.notHelpful:
          totalVotes += 1;
          break;
      }
      userVote = vote;
    }

    _helpfulStates[reviewId] = ReviewHelpfulState(
      helpfulCount: helpfulCount,
      totalVotes: totalVotes,
      userVote: userVote,
    );

    notifyListeners();
  }

  DateTime _reviewDate(Review review) {
    final updatedAt = review.updatedAt;
    if (updatedAt != null && updatedAt.isNotEmpty) {
      final parsed = DateTime.tryParse(updatedAt);
      if (parsed != null) {
        return parsed;
      }
    }
    final created = DateTime.tryParse(review.createdAt);
    return created ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _seedHelpfulStates(List<Review> reviews) {
    for (final review in reviews) {
      if (_helpfulStates.containsKey(review.id)) {
        continue;
      }
      final seed = review.id.codeUnits.fold<int>(
        0,
        (value, unit) => (value + unit) & 0x7fffffff,
      );
      final baseTotal = 18 + (seed % 40); // 18-57 votes
      final rating = review.authorDetails.rating ?? 6.0;
      final normalized = (rating / 10).clamp(0.0, 1.0);
      final helpful = max(0, min(baseTotal, (baseTotal * normalized).round()));

      _helpfulStates[review.id] = ReviewHelpfulState(
        helpfulCount: helpful,
        totalVotes: baseTotal,
        userVote: null,
      );
    }
  }
}
