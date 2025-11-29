import 'package:flutter/foundation.dart';
import '../models/home screen/vendor/vendor_response.dart';
import '../models/home screen/vendor/vendor_products_response.dart';
import 'client/api_client.dart';

/// 🔹 **Vendor Service**
/// Handles all vendor-related API operations including fetching vendors and their products
class VendorService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 **Fetch Vendors**
  /// Fetches all vendors with their complete store information
  Future<VendorResponse> fetchVendors() async {
    try {
      debugPrint('Fetching vendors from API');
      final response = await _apiClient.get('/vendors_stores.php');

      if (response != null && response['success'] == true) {
        debugPrint('Successfully fetched vendors');
        return VendorResponse.fromJson(response);
      } else {
        final errorMessage = response?['message'] ?? 'Unknown error occurred';
        debugPrint('Failed to fetch vendors: $errorMessage');
        throw Exception('Failed to load vendors: $errorMessage');
      }
    } catch (e) {
      debugPrint('Error fetching vendors: $e');
      throw Exception('Failed to fetch vendors: $e');
    }
  }

  /// 🔹 **Get Vendor Products**
  /// Fetches all products for a specific vendor with pagination support
  Future<VendorProductsResponse> getVendorProducts(
    String vendorId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      debugPrint(
          'Fetching products for vendor: $vendorId (page: $page, pageSize: $pageSize)');
      final response = await _apiClient.get(
        '/get_vendor_products.php',
        queryParams: {
          'vendor_id': vendorId,
          'page': page.toString(),
          'page_size': pageSize.toString(),
        },
      );

      if (response != null) {
        debugPrint('Raw API Response Data: $response');
        return VendorProductsResponse.fromJson(response);
      } else {
        debugPrint('Failed to fetch vendor products: Invalid response');
        throw Exception('Failed to fetch vendor products: Invalid response');
      }
    } catch (e) {
      debugPrint('Error fetching vendor products: $e');
      throw Exception('Failed to fetch vendor products: $e');
    }
  }
}
