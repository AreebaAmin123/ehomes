import 'client/api_client.dart';
import '../models/product/product_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// 🔹 **Product Service**
class ProductService {
  final ApiClient _apiClient = ApiClient();

  /// ✅ **Fetch Products from API**
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _apiClient.get('/get_products.php');

      if (response != null &&
          response['success'] == true &&
          response['products'] != null) {
        List<dynamic> productList = response['products'];

        // Fix image URLs in the response
        for (var product in productList) {
          if (product['images'] != null) {
            product['images'] = (product['images'] as List).map((img) {
              String imageUrl = img.toString();

              // Skip if already a full URL
              if (imageUrl.startsWith('http')) {
                return imageUrl;
              }

              // Clean the URL
              imageUrl = imageUrl.trim();

              // Remove any leading/trailing slashes
              imageUrl = imageUrl.replaceAll(RegExp(r'^/+|/+$'), '');

              // Handle webp/jpg extension issues
              if (imageUrl.contains('.webp/')) {
                imageUrl = imageUrl.split('.webp/')[0] + '.webp';
              } else if (imageUrl.contains('.jpg/')) {
                imageUrl = imageUrl.split('.jpg/')[0] + '.jpg';
              } else if (imageUrl.contains('.png/')) {
                imageUrl = imageUrl.split('.png/')[0] + '.png';
              }

              // Add extension if missing
              if (!imageUrl.contains('.')) {
                imageUrl = '$imageUrl.jpg';
              }

              // Determine the correct base URL
              if (imageUrl.contains('admin_panel/uploads')) {
                return 'https://ehomes.pk/admin_panel/uploads/$imageUrl';
              } else if (imageUrl.contains('admin_panel/upload_banner')) {
                return 'https://ehomes.pk/admin_panel/upload_banner/$imageUrl';
              } else if (imageUrl.contains('Vendor_Panel/upload_promotion')) {
                return 'https://ehomes.pk/Vendor_Panel/upload_promotion/$imageUrl';
              } else {
                return 'https://ehomes.pk/Vendor_Panel/uploads/$imageUrl';
              }
            }).toList();
          }

          // Ensure categories is a list
          if (product['categories'] != null) {
            if (product['categories'] is String) {
              try {
                // Try to parse as JSON
                final categories = jsonDecode(product['categories']);
                if (categories is List) {
                  product['categories'] = categories;
                } else {
                  product['categories'] = [product['categories']];
                }
              } catch (e) {
                // If parsing fails, wrap in a list
                product['categories'] = [product['categories']];
              }
            } else if (product['categories'] is! List) {
              product['categories'] = [];
            }
          } else {
            product['categories'] = [];
          }
        }

        return productList.map((json) => ProductModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("❌ Error fetching products: $e");
    }

    return [];
  }
}
