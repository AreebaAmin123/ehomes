import 'package:e_Home_app/models/product/variation_model.dart';

class ProductModel {
  final int productId;
  final int? vendorId;
  final String productName;
  final String brandName;
  final int price;
  final int discountPrice;
  final String description;
  final int stock;
  final List<String> categories;
  final List<String> images;
  final List<VariationModel> variations;
  final List<TagModel> tags;
  final int categoryId;
  final int brandId;
  final double rating;

  ProductModel({
    required this.productId,
    this.vendorId,
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
    this.categoryId = 0,
    this.brandId = 0,
    this.rating = 0.0,
  });

  static String _fixImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) {
      return 'https://via.placeholder.com/300x400?text=No+Image';
    }

    // If it's already a full URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // For any other case, return placeholder
    return 'https://via.placeholder.com/300x400?text=No+Image';
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id'].toString()) ?? 0,
      vendorId: json['vendor_id'] is int
          ? json['vendor_id']
          : int.tryParse(json['vendor_id'].toString()),
      productName: json['product_name']?.toString() ?? '',
      brandName: json['brand_name']?.toString() ?? '',
      price: _parseInt(json['price']),
      discountPrice: _parseInt(json['discount_price']),
      description: json['description']?.toString() ?? '',
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock'].toString()) ?? 0,
      categories: (json['categories'] as List<dynamic>?)?.map((e) {
            if (e is Map<String, dynamic>) {
              return e['id']?.toString() ??
                  e['category_id']?.toString() ??
                  e['category_name']?.toString() ??
                  '';
            }
            return e.toString();
          }).toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => _fixImageUrl(img.toString()))
              .toList() ??
          [],
      variations: (json['variations'] as List<dynamic>?)
              ?.map((variation) =>
                  VariationModel.fromJson(variation as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => TagModel.fromJson(tag as Map<String, dynamic>))
              .toList() ??
          [],
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id'].toString()) ?? 0,
      brandId: json['brand_id'] is int
          ? json['brand_id']
          : int.tryParse(json['brand_id'].toString()) ?? 0,
      rating: json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating'].toString()) ?? 0.0,
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
      'variations': variations.map((v) => v.toJson()).toList(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'category_id': categoryId,
      'brand_id': brandId,
      'rating': rating,
    };
  }

  /// Calculates the discount percentage
  double get discountPercentage {
    // Return 0 if:
    // 1. Price is 0 or negative (invalid price)
    // 2. Discount price is 0 (no discount)
    // 3. Discount price is greater than or equal to price (invalid discount)
    if (price <= 0 || discountPrice <= 0 || discountPrice >= price) {
      return 0.0;
    }
    return ((price - discountPrice) / price) * 100;
  }
}

class TagModel {
  final int tagId;
  final String tagName;

  TagModel({
    required this.tagId,
    required this.tagName,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    if (json is Map<String, dynamic>) {
      return TagModel(
        tagId: json['tag_id'] is int
            ? json['tag_id']
            : int.tryParse(json['tag_id'].toString()) ?? 0,
        tagName: json['tag_name']?.toString() ?? '',
      );
    }
    // Handle case where json might be a string
    return TagModel(
      tagId: 0,
      tagName: json.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_id': tagId,
      'tag_name': tagName,
    };
  }
}
