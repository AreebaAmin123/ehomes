import 'package:flutter/material.dart';
import '../../../../models/feedback_model.dart';
import '../../../../services/feedback_service.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();
  List<FeedbackModel> _feedbackList = [];
  bool _isLoading = false;
  String? _error;
  bool _isSubmitting = false;
  String? _submitResult;

  List<FeedbackModel> get feedbackList => _feedbackList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;
  String? get submitResult => _submitResult;

  Future<void> fetchFeedback() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _feedbackList = await _feedbackService.fetchFeedback();
    } catch (e) {
      _error = 'Failed to load feedback';
      _feedbackList = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitFeedback({
    required int userId,
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    _isSubmitting = true;
    _submitResult = null;
    notifyListeners();
    try {
      final response = await _feedbackService.submitFeedback(
        userId: userId,
        name: name,
        email: email,
        subject: subject,
        message: message,
      );
      if (response != null && response['success'] == true) {
        _submitResult =
            response['message'] ?? 'Feedback submitted successfully';
        await fetchFeedback(); // Optionally refresh list
        return true;
      } else {
        _submitResult = response?['message'] ?? 'Failed to submit feedback.';
        return false;
      }
    } catch (e) {
      _submitResult = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
