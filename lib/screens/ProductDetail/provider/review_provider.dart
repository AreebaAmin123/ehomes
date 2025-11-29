import 'package:flutter/material.dart';
import '../../../models/review_model.dart';
import '../../../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch reviews for a product
  Future<void> fetchReviews(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.getReviews(productId);
    } catch (e) {
      _error = 'Failed to load reviews';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Submit a new review
  Future<bool> submitReview({
    required int productId,
    required int categoryId,
    required String name,
    required String email,
    required int rating,
    required String review,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _reviewService.submitReview(
        productId: productId,
        categoryId: categoryId,
        name: name,
        email: email,
        rating: rating,
        review: review,
      );

      // Check if response contains a success message or true value
      if (response != null &&
          (response['success'] == true ||
              (response['success'] is String &&
                  !response['success']
                      .toString()
                      .toLowerCase()
                      .contains('error')))) {
        // First fetch the latest reviews to ensure we have the current state
        await fetchReviews(productId);
        return true;
      } else {
        _error = response?['error'] ??
            response?['message'] ??
            'Failed to submit review';
        debugPrint("Review submission error: $_error");
        return false;
      }
    } catch (e) {
      _error = 'Failed to submit review';
      debugPrint("Review submission exception: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculate average rating
  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    double total = _reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
  }

  /// Get rating breakdown
  Map<int, int> get ratingBreakdown {
    Map<int, int> breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in _reviews) {
      breakdown[review.rating] = (breakdown[review.rating] ?? 0) + 1;
    }
    return breakdown;
  }

  /// Group reviews by user_id
  Map<int, List<ReviewModel>> get groupedReviewsByUser {
    final Map<int, List<ReviewModel>> grouped = {};
    int counter = 0;
    Map<String, int> emailToId =
        {}; // Map to maintain consistent IDs for emails

    for (final review in _reviews) {
      // Use email as the unique identifier for users
      if (!emailToId.containsKey(review.email)) {
        emailToId[review.email] = counter++;
      }
      int userId = emailToId[review.email]!;

      grouped.putIfAbsent(userId, () => []).add(review);
    }

    // Sort reviews in each group by date
    for (final list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }
}
