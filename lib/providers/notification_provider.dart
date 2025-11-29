import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

/// 🔹 **Notification Provider**
/// Manages notification state and operations using Provider pattern
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  String? _error;
  NotificationResponse? _lastResponse;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  NotificationResponse? get lastResponse => _lastResponse;

  /// 🔹 **Send Global Notification**
  Future<bool> sendGlobalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _notificationService.sendGlobalNotification(
        title: title,
        body: body,
        additionalData: additionalData,
      );

      _lastResponse = response;

      if (response.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// 🔹 **Send Targeted Notification**
  Future<bool> sendTargetedNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _notificationService.sendTargetedNotification(
        topic: topic,
        title: title,
        body: body,
        additionalData: additionalData,
      );

      _lastResponse = response;

      if (response.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// 🔹 **Send User Notification**
  Future<bool> sendUserNotification({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _notificationService.sendUserNotification(
        deviceToken: deviceToken,
        title: title,
        body: body,
        additionalData: additionalData,
      );

      _lastResponse = response;

      if (response.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
