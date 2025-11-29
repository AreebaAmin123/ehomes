import 'package:flutter/foundation.dart';
import '../models/feedback_model.dart';
import 'client/api_client.dart';

class FeedbackService {
  final ApiClient _apiClient = ApiClient();

  Future<List<FeedbackModel>> fetchFeedback() async {
    try {
      final response = await _apiClient.get(
        'https://ehomes.pk/API/chat/get_feedback.php',
      );
      debugPrint("Get Feedback Response: \\${response.toString()}");
      if (response != null &&
          response['success'] == true &&
          response['feedback'] != null) {
        return (response['feedback'] as List)
            .map((item) => FeedbackModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching feedback: \\${e.toString()}");
      return [];
    }
  }

  Future<Map<String, dynamic>?> submitFeedback({
    required int userId,
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await _apiClient.post(
        'https://ehomes.pk/API/chat/submit_feedback.php',
        {
          'user_id': userId.toString(),
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        },
      );
      debugPrint("Submit Feedback Response: \\${response.toString()}");
      return response;
    } catch (e) {
      debugPrint("Error submitting feedback: \\${e.toString()}");
      return {'success': false, 'message': 'Failed to submit feedback'};
    }
  }
}
