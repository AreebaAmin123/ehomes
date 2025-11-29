// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';

import '../models/wish_list_model.dart';
import 'client/api_client.dart';

/// 🔹 **WishList Service**
class WishListService {
  final ApiClient _apiClient = ApiClient();

  /// **Fetch Wishlist Items**
  Future<WishListModel?> getWishList(int userId) async {
    final response = await _apiClient.get('/wishlist.php', queryParams: {
      "user_id": userId,
    });

    print("API Response: $response");

    if (response != null) {
      print("Wishlist found for user: $userId");
      return WishListModel.fromJson(response);
    } else {
      print(" No wishlist found or invalid response.");
      return null;
    }
  }

  /// **Add Product to Wishlist**
  Future<Map<String, dynamic>?> postWishList({
    required int userId,
    required int productId,
    int? variationId,
    int quantity = 1,
    num? discountPrice,
    required num price,
    required num totalPrice,
  }) async {
    print("Sending request to add product: $productId for user: $userId");

    final payload = {
      "user_id": userId.toString(),
      "product_id": productId.toString(),
      "variation_id": variationId?.toString() ?? '',
      "quantity": quantity.toString(),
      "discount_price": discountPrice?.toString() ?? '',
      "price": price.toString(),
      "total_price": totalPrice.toString(),
    };

    final response = await _apiClient.post('/wishlist.php', payload);

    debugPrint("Full API Response: \\${response.toString()}");
    return response;
  }

  /// **Remove Product from Wishlist**
  Future<Map<String, dynamic>?> deleteWishList(int wishlistId) async {
    final response = await _apiClient.delete(
      '/wishlist.php',
      data: {
        "id": wishlistId.toString(),
      },
    );
    return response;
  }
}
