import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/review_model.dart';
import 'client/api_client.dart';
import 'package:http/http.dart';

/// 🔹 **Review Service**
class ReviewService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 **Fetch reviews for a product**
  Future<List<ReviewModel>> getReviews(int productId) async {
    try {
      final response = await _apiClient.get(
        '/get_reviews.php',
        queryParams: {'product_id': productId.toString()},
      );

      debugPrint("Get Reviews Response: ${response.toString()}");

      if (response != null && response['reviews'] != null) {
        return (response['reviews'] as List)
            .map((review) => ReviewModel.fromJson(review))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      return [];
    }
  }

  /// 🔹 **Submit a new review**
  Future<Map<String, dynamic>?> submitReview({
    required int productId,
    required int categoryId,
    required String name,
    required String email,
    required int rating,
    required String review,
  }) async {
    try {
      // Validate category_id
      if (categoryId <= 0) {
        debugPrint(
            "Warning: Invalid category_id ($categoryId). Using default category 9.");
        categoryId = 9; // Use default category if none provided
      }

      // Create the data map with the correct field names
      final Map<String, dynamic> data = {
        'product_id': productId.toString(),
        'category_id': categoryId.toString(),
        'name': name,
        'email': email,
        'rating': rating,
        'review': review,
      };

      // Convert to JSON string and back to ensure proper formatting
      final jsonString = jsonEncode(data);
      debugPrint("Submitting review with JSON data: $jsonString");

      // Send the request with the JSON-encoded string
      final response = await _apiClient.post(
        '/product_review.php',
        jsonDecode(jsonString),
      );

      debugPrint("Submit Review Response: ${response.toString()}");
      return response;
    } catch (e) {
      debugPrint("Error submitting review: $e");
      return {'error': 'Failed to submit review'};
    }
  }
}
