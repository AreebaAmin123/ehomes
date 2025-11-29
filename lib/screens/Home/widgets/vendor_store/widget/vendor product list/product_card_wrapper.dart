import 'package:flutter/material.dart';
import '../../../../../../global widgets/product card/product_card.dart';
import '../../../../../../global widgets/product card/product_card_data.dart';
import '../../../../../../models/home screen/vendor/vendor_product_model.dart';

class ProductCardWrapper extends StatelessWidget {
  final VendorProductModel product;
  final String vendorName;
  final Future<void> Function(VendorProductModel) onProductSelected;

  const ProductCardWrapper({
    super.key,
    required this.product,
    required this.vendorName,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      data: ProductCardData(
        productId: product.productId,
        imageUrl: product.images.isNotEmpty
            ? product.images.first
            : 'https://via.placeholder.com/300x400?text=No+Image',
        title: product.productName,
        price: product.price.toInt(),
        stock: product.stock,
        discountPrice: product.discountPrice.toInt(),
        tags: product.tags.map((tag) => tag.tagName).toList(),
        vendorName: vendorName,
        onTap: () => onProductSelected(product),
      ),
    );
  }
}
