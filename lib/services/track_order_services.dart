import 'package:e_Home_app/models/track_order_model.dart';
import 'package:e_Home_app/services/client/api_client.dart';
import 'package:flutter/foundation.dart';

class TrackOrderServices {
  final ApiClient _apiClient = ApiClient();

  /// Track order using Order ID
  Future<TrackOrderModel> trackOrder(String orderId) async {
    try {
      final response = await _apiClient.post('/track_order.php', {
        "order_id": orderId,
      });

      debugPrint("Full API Response: ${response.toString()}");

      if (response != null) {
        return TrackOrderModel.fromJson(response);
      } else {
        throw Exception("API returned null response");
      }
    } catch (e) {
      debugPrint("Error in postTrackOrder: $e");
      rethrow;
    }
  }
}
