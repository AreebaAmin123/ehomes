import 'package:flutter/material.dart';

class ProductCardData {
  final int productId;
  final String imageUrl;
  final String title;
  final int price;
  final int? discountPrice;
  final List<String>? tags; // e.g. ["Best Seller", "New"]
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onTap;
  final String? vendorName;
  final int stock;

  ProductCardData({
    required this.productId,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.stock,
    this.discountPrice,
    this.tags,
    this.badgeText,
    this.badgeColor,
    this.onTap,
    this.vendorName,
  });
}
