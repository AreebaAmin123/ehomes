import '../models/delivery_slot_model.dart';
import 'client/api_client.dart';
import 'package:flutter/foundation.dart';

class DeliverySlotService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 **Fetch Delivery Slots**
  Future<DeliverySlotModel> getDeliverySlots(List<String> categoryIds) async {
    try {
      final categoryIdsString = categoryIds.join(',');
      debugPrint('📤 Fetching delivery slots...');
      debugPrint('📝 Category IDs: $categoryIdsString');
      debugPrint(
          '🔗 API Endpoint: /get_slots.php?category_ids=$categoryIdsString');

      final response = await _apiClient.get(
        '/get_slots.php',
        queryParams: {
          "category_ids": categoryIdsString,
        },
      );

      debugPrint('📥 Raw API Response: $response');

      if (response != null) {
        // Handle both success and failure cases from API
        if (response['success'] == true) {
          debugPrint('✅ API returned success: true');
          return DeliverySlotModel.fromJson(response);
        } else {
          final message = response['message'] ?? 'Unknown error';
          debugPrint('❌ API returned success: false - $message');
          return DeliverySlotModel(success: false, slots: []);
        }
      } else {
        debugPrint('❌ API response is null');
        return DeliverySlotModel(success: false, slots: []);
      }
    } catch (e) {
      debugPrint('❌ Error fetching delivery slots: $e');
      throw Exception("Error fetching delivery slots: $e");
    }
  }
}
