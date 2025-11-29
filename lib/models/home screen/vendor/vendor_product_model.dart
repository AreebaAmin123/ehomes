import 'dart:convert';

class VendorProductModel {
  final int productId;
  final int vendorId;
  final String productName;
  final String brandName;
  final double price;
  final double discountPrice;
  final String description;
  final int stock;
  final List<String> categories;
  final List<String> images;
  final List<dynamic> variations;
  final List<ProductTag> tags;

  VendorProductModel({
    required this.productId,
    required this.vendorId,
    required this.productName,
    required this.brandName,
    required this.price,
    required this.discountPrice,
    required this.description,
    required this.stock,
    required this.categories,
    required this.images,
    required this.variations,
    required this.tags,
  });

  static String _processImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300x400?text=No+Image';
    }

    // Clean the URL
    var cleanUrl = url.trim();

    // If it's already a full URL, validate and return
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      // Handle old klik.pk URLs
      if (cleanUrl.contains('klik.pk')) {
        final uri = Uri.parse(cleanUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final filename = pathSegments.last;
          return 'https://ehomes.pk/Vendor_Panel/uploads/$filename';
        }
      }
      return cleanUrl;
    }

    // Remove any leading/trailing slashes
    cleanUrl = cleanUrl.replaceAll(RegExp(r'^/+|/+$'), '');

    // Split path into components
    final components = cleanUrl.split('/');

    // Extract filename (last component)
    String filename = components.last;

    // Add extension if missing
    if (!filename.contains('.')) {
      filename = '$filename.jpg';
    }

    // Construct proper path
    return 'https://ehomes.pk/Vendor_Panel/uploads/$filename';
  }

  static bool _isValidImageUrl(String url) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  factory VendorProductModel.fromJson(Map<String, dynamic> json) {
    // Process image URLs
    final rawImages = List<String>.from(json['images'] ?? []);
    final processedImages =
        rawImages.map((url) => _processImageUrl(url)).toList();

    // Process categories
    final List<String> processedCategories =
        (json['categories'] as List<dynamic>?)?.map((e) {
              if (e is Map<String, dynamic>) {
                return e['category_name']?.toString() ?? '';
              }
              return e.toString();
            }).toList() ??
            [];

    return VendorProductModel(
      productId: json['product_id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      productName: json['product_name'] ?? '',
      brandName: json['brand_name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discountPrice:
          double.tryParse(json['discount_price']?.toString() ?? '0') ?? 0.0,
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      categories: processedCategories,
      images: processedImages,
      variations: List<dynamic>.from(json['variations'] ?? []),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => ProductTag.fromJson(tag))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'vendor_id': vendorId,
      'product_name': productName,
      'brand_name': brandName,
      'price': price,
      'discount_price': discountPrice,
      'description': description,
      'stock': stock,
      'categories': categories,
      'images': images,
      'variations': variations,
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }
}

class ProductTag {
  final int tagId;
  final String tagName;

  ProductTag({
    required this.tagId,
    required this.tagName,
  });

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      tagId: json['tag_id'] ?? 0,
      tagName: json['tag_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_id': tagId,
      'tag_name': tagName,
    };
  }
}
