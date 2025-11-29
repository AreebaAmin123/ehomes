import 'client/api_client.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

/// 🔹 **Notification Service**
/// Handles sending push notifications using the custom API
class NotificationService {
  final ApiClient _apiClient = ApiClient();
  final String _notificationEndpoint = '/SendNotification.php';

  /// 🔹 **Send Global Notification**
  /// Sends a notification to all users subscribed to the 'global' topic
  Future<NotificationResponse> sendGlobalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint("Sending global notification - Title: $title, Body: $body");

      final Map<String, dynamic> payload = {
        "topic": "global",
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          ...?additionalData,
        }
      };

      debugPrint("Notification payload: $payload");
      final response = await _apiClient.post(_notificationEndpoint, payload);
      debugPrint("Send notification response: $response");

      if (response != null) {
        if (response.containsKey('name')) {
          return NotificationResponse(
            success: true,
            message: 'Notification sent successfully',
            name: response['name'],
            data: response,
          );
        } else {
          return NotificationResponse.error(
              'Failed to send notification: Invalid response format');
        }
      } else {
        return NotificationResponse.error('API returned null response');
      }
    } catch (e) {
      debugPrint("Error sending global notification: $e");
      return NotificationResponse.error(
          'Error sending notification: ${e.toString()}');
    }
  }

  /// 🔹 **Send Targeted Notification**
  /// Sends a notification to a specific topic
  Future<NotificationResponse> sendTargetedNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint(
          "Sending targeted notification to topic: $topic - Title: $title, Body: $body");

      final Map<String, dynamic> payload = {
        "topic": topic,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          ...?additionalData,
        }
      };

      debugPrint("Notification payload: $payload");
      final response = await _apiClient.post(_notificationEndpoint, payload);
      debugPrint("Send notification response: $response");

      if (response != null) {
        if (response.containsKey('name')) {
          return NotificationResponse(
            success: true,
            message: 'Notification sent successfully',
            name: response['name'],
            data: response,
          );
        } else {
          return NotificationResponse.error(
              'Failed to send notification: Invalid response format');
        }
      } else {
        return NotificationResponse.error('API returned null response');
      }
    } catch (e) {
      debugPrint("Error sending targeted notification: $e");
      return NotificationResponse.error(
          'Error sending notification: ${e.toString()}');
    }
  }

  /// 🔹 **Send User Notification**
  /// Sends a notification to a specific user by their device token
  Future<NotificationResponse> sendUserNotification({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint(
          "Sending user notification to device: $deviceToken - Title: $title, Body: $body");

      final Map<String, dynamic> payload = {
        "to": deviceToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          ...?additionalData,
        }
      };

      debugPrint("Notification payload: $payload");
      final response = await _apiClient.post(_notificationEndpoint, payload);
      debugPrint("Send notification response: $response");

      if (response != null) {
        if (response.containsKey('name')) {
          return NotificationResponse(
            success: true,
            message: 'Notification sent successfully',
            name: response['name'],
            data: response,
          );
        } else {
          return NotificationResponse.error(
              'Failed to send notification: Invalid response format');
        }
      } else {
        return NotificationResponse.error('API returned null response');
      }
    } catch (e) {
      debugPrint("Error sending user notification: $e");
      return NotificationResponse.error(
          'Error sending notification: ${e.toString()}');
    }
  }
}
