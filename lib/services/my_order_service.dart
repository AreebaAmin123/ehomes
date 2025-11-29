import 'package:e_Home_app/models/my_order_model.dart';
import 'package:e_Home_app/models/track_order_model.dart';
import 'package:e_Home_app/services/client/api_client.dart';
import 'package:flutter/foundation.dart';

class MyOrderServices {
  final ApiClient _apiClient = ApiClient();

  /// My order with user id
  Future<MyOrderModel> myOrder(int userId) async {
    try {
      final response =
          await _apiClient.post('/get_user_orders.php', {"user_id": userId});

      debugPrint("Full API Response: ${response.toString()}");

      if (response != null) {
        return MyOrderModel.fromJson(response);
      } else {
        throw Exception("API returned null response");
      }
    } catch (e) {
      debugPrint("Error in my order api : $e");
      rethrow;
    }
  }
}
