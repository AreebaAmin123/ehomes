import '../models/home screen/slider_model.dart';
import '../models/home screen/tag_model.dart';
import '../models/home screen/tag_product_model.dart';
import '../models/home screen/exclusive_product_model.dart';
import 'client/api_client.dart';
import 'package:flutter/foundation.dart';

class HomeServices {
  final ApiClient _apiClient = ApiClient();

  Future<SliderModel> getSlider() async {
    try {
      final response = await _apiClient.get('/get_slider.php');

      if (response != null && response['success'] == true) {
        // Fix slider image URLs
        if (response['sliders'] != null) {
          for (var slider in response['sliders']) {
            if (slider['slider_image'] != null) {
              String imageUrl = slider['slider_image'];
              // Clean up the URL
              imageUrl = imageUrl.trim().replaceAll(RegExp(r'^/+|/+$'), '');

              debugPrint('Original slider image URL: $imageUrl');

              // Handle different URL formats
              if (!imageUrl.startsWith('http')) {
                // Extract just the filename, removing any path
                final filename = imageUrl.split('/').last;

                // Try different path combinations
                final possiblePaths = [
                  'uploads/slider',
                  'upload_banner',
                  'uploads/banners',
                  'uploads'
                ];

                // Start with the most specific path
                slider['slider_image'] =
                    'https://ehomes.pk/Vendor_Panel/${possiblePaths[0]}/$filename';
                debugPrint(
                    'Using primary slider path: ${slider['slider_image']}');
              }

              // Replace old domain if present
              if (imageUrl.contains('klik.pk')) {
                slider['slider_image'] =
                    imageUrl.replaceAll('klik.pk/klik_store_test', 'ehomes.pk');
              }
            }
          }
        }
        return SliderModel.fromJson(response);
      } else {
        return SliderModel(success: false, sliders: []);
      }
    } catch (e) {
      debugPrint("Error fetching slider data: $e");
      throw Exception("Error fetching slider data: $e");
    }
  }

  Future<TagModel> getTags() async {
    try {
      final response = await _apiClient.get('/get_tags.php');

      if (response != null && response['success'] == true) {
        TagModel tagModel = TagModel.fromJson(response);
        return tagModel;
      } else {
        return TagModel(success: false, tags: []);
      }
    } catch (e) {
      throw Exception("Error fetching tag data: $e");
    }
  }

  /// get product based on tag id
  Future<TagProductModel> getProduct() async {
    try {
      final response = await _apiClient.get('/get_products.php');

      if (response != null && response['success'] == true) {
        TagProductModel tagProductModel = TagProductModel.fromJson(response);
        return tagProductModel;
      } else {
        return TagProductModel(success: false, products: []);
      }
    } catch (e) {
      throw Exception("Error fetching tag data: $e");
    }
  }

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // If URL doesn't start with http/https, assume it's relative and add domain
    if (!url.startsWith('http')) {
      return 'https://ehomes.pk/Vendor_Panel/uploads/$url';
    }

    // Handle old klik.pk URLs
    if (url.contains('klik.pk')) {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final filename = pathSegments.last;
        return 'https://ehomes.pk/Vendor_Panel/uploads/$filename';
      }
    }

    // Handle WebP images
    if (url.toLowerCase().endsWith('.webp')) {
      url = url.substring(0, url.length - 5) + '.jpg';
    }

    return url;
  }

  // /// get Categories that will displayed on home screen
  // Future<HomeCategoryModel> getCategory() async {
  //   try {
  //     final response = await _apiClient.get('/get_categories.php');
  //
  //     if (response != null && response['success'] == true) {
  //       // Fix category image URLs
  //       if (response['categories'] != null) {
  //         for (var category in response['categories']) {
  //           if (category['category_icon'] != null) {
  //             category['category_icon'] =
  //                 _fixImageUrl(category['category_icon']);
  //           }
  //
  //           // Fix subcategories image URLs
  //           if (category['subcategories'] != null) {
  //             for (var subCategory in category['subcategories']) {
  //               if (subCategory['category_icon'] != null) {
  //                 subCategory['category_icon'] =
  //                     _fixImageUrl(subCategory['category_icon']);
  //               }
  //
  //               // Fix sub-subcategories image URLs
  //               if (subCategory['subcategories'] != null) {
  //                 for (var subSubCategory in subCategory['subcategories']) {
  //                   if (subSubCategory['category_icon'] != null) {
  //                     subSubCategory['category_icon'] =
  //                         _fixImageUrl(subSubCategory['category_icon']);
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       }
  //       return HomeCategoryModel.fromJson(response);
  //     } else {
  //       return HomeCategoryModel(success: false, categories: []);
  //     }
  //   } catch (e) {
  //     throw Exception("Error fetching category data: $e");
  //   }
  // }

  Future<List<ExclusiveProductModel>> getExclusiveProducts() async {
    try {
      final response = await _apiClient.get('/get_exclusive_products.php');
      if (response != null &&
          response['success'] == true &&
          response['products'] != null) {
        return (response['products'] as List)
            .map((e) => ExclusiveProductModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching exclusive products: $e');
    }
  }
}
