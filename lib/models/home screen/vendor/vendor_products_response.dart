import 'vendor_product_model.dart';

class VendorProductsResponse {
  final bool success;
  final int vendorId;
  final int count;
  final List<VendorProductModel> products;

  VendorProductsResponse({
    required this.success,
    required this.vendorId,
    required this.count,
    required this.products,
  });

  factory VendorProductsResponse.fromJson(Map<String, dynamic> json) {
    return VendorProductsResponse(
      success: json['success'] ?? false,
      vendorId: int.tryParse(json['vendor_id']?.toString() ?? '') ?? 0,
      count: int.tryParse(json['count']?.toString() ?? '') ?? 0,
      products: (json['products'] as List<dynamic>?)
              ?.map((product) => VendorProductModel.fromJson(product))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'vendor_id': vendorId,
      'count': count,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}
