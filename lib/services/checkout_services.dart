import 'package:e_Home_app/models/check%20out/check_out_model.dart';
import '../models/check out/state_model.dart';
import 'client/api_client.dart';

class CheckoutServices {
  final ApiClient _apiClient = ApiClient();

  Future<CheckOutModel> checkout({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    String? zip,
    required String orderNotes,
    required int discount,
    required String couponCode,
    required int? couponAmount,
    required String paymentMethod,
    required int shippingCharge,
    required int slotId,
  }) async {
    final data = {
      "user_id": userId,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "address": address,
      "city": city,
      "state": state,
      if (zip != null && zip.isNotEmpty) "zip": zip,
      "order_notes": orderNotes,
      "discount": discount,
      "coupon_code": couponCode,
      "coupon_amount": couponAmount,
      "payment_method": paymentMethod,
      "shipping_charge": shippingCharge,
      "slot_id": slotId,
    };

    try {
      final response = await _apiClient.post('/checkout.php', data);
      if (response != null && response['success'] == true) {
        return CheckOutModel.fromJson(response);
      } else {
        if (response != null) {
          return CheckOutModel.fromJson(response);
        } else {
          return CheckOutModel(
            success: false,
            message: 'No response from API',
            orderId: '',
            vendorId: 0,
            totalAmount: 0,
          );
        }
      }
    } catch (e) {
      print("Checkout API Error: $e");
      rethrow;
    }
  }

  /// Fetch States with shipment charges
  Future<StateModel> getStates() async {
    try {
      final response = await _apiClient.get('/shipping_charges.php');

      if (response != null && response['shipping_charges'] != null) {
        return StateModel.fromJson(response);
      } else {
        return StateModel(shippingCharges: []);
      }
    } catch (e) {
      throw Exception("Error fetching shipping charges: $e");
    }
  }

  /// get discount from code which is posted on the email of user
  Future<Map<String, dynamic>?> getCouponDiscount(String couponCode) async {
    return await _apiClient
        .get('/coupons.php', queryParams: {"code": couponCode});
  }
}
