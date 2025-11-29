import 'package:flutter/foundation.dart';

class PromotionProductModel {
  final int productId;
  final String productName;

  PromotionProductModel({required this.productId, required this.productName});

  factory PromotionProductModel.fromJson(Map<String, dynamic> json) {
    debugPrint('PromotionProductModel.fromJson input: $json');
    return PromotionProductModel(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id'].toString()) ?? 0,
      productName: json['product_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
      };
}

class PromotionModel {
  final int id;
  final String title;
  final String description;
  final String discountPercentage;
  final String discountAmount;
  final String startDate;
  final String endDate;
  final int vendorId;
  final String image;
  final List<PromotionProductModel> products;

  PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.discountAmount,
    required this.startDate,
    required this.endDate,
    required this.vendorId,
    required this.image,
    required this.products,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    debugPrint('PromotionModel.fromJson input: $json');
    return PromotionModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: json['discount_percentage']?.toString() ?? '0.00',
      discountAmount: json['discount_amount']?.toString() ?? '0.00',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      vendorId: json['vendor_id'] is int
          ? json['vendor_id']
          : int.tryParse(json['vendor_id'].toString()) ?? 0,
      image: json['image'] ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) =>
                  PromotionProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'discount_percentage': discountPercentage,
        'discount_amount': discountAmount,
        'start_date': startDate,
        'end_date': endDate,
        'vendor_id': vendorId,
        'image': image,
        'products': products.map((p) => p.toJson()).toList(),
      };
}
