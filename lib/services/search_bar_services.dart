import '../models/cart/get_cart_model.dart';
import '../models/search_model.dart';
import 'client/api_client.dart';
import 'package:flutter/foundation.dart';

class SearchBarServices {
  final ApiClient _apiClient = ApiClient();

  SearchModel? _searchModel;
  SearchModel? get searchModel => _searchModel;

  /// Searching Items
  Future<SearchModel?> searchQuery(String query) async {
    try {
      final response = await _apiClient.get(
        '/search_products.php',
        queryParams: {"query": query},
      );

      debugPrint('Search API raw response: $response');

      if (response != null && response["products"] != null) {
        // Process each product to ensure image_url is set correctly
        for (var product in response["products"]) {
          // If image_url is already provided, use it
          if (product['image_url'] != null &&
              product['image_url'].toString().isNotEmpty) {
            if (!product['image_url'].toString().startsWith('http')) {
              product['image_url'] =
                  'https://ehomes.pk/Vendor_Panel/uploads/${product['image_url']}';
            }
          }
          // If no image_url but images array exists, use first image
          else if (product['images'] != null && product['images'].isNotEmpty) {
            String imageUrl = product['images'][0];
            if (!imageUrl.startsWith('http')) {
              imageUrl = 'https://ehomes.pk/Vendor_Panel/uploads/$imageUrl';
            }
            product['image_url'] = imageUrl;
          }
          // If neither exists, set empty string
          else {
            product['image_url'] = '';
          }
        }

        debugPrint('Search API processed response: $response');
        _searchModel = SearchModel.fromJson(response);
        debugPrint(
            'Parsed search model products: ${_searchModel?.products?.length}');
        if (_searchModel?.products?.isNotEmpty == true) {
          debugPrint(
              'First product image URL: ${_searchModel?.products?.first.imageUrl}');
        }
        return _searchModel;
      } else {
        debugPrint('Search API returned null or no products');
        return null;
      }
    } catch (e) {
      debugPrint('Search API error: $e');
      throw Exception("Error fetching search results: $e");
    }
  }
}
