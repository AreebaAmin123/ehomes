import 'vendor_model.dart';

class VendorResponse {
  final bool success;
  final int count;
  final List<VendorModel> vendors;

  const VendorResponse({
    required this.success,
    required this.count,
    required this.vendors,
  });

  factory VendorResponse.fromJson(Map<String, dynamic> json) {
    return VendorResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      vendors: (json['vendors'] as List<dynamic>?)
              ?.map((vendor) => VendorModel.fromJson(vendor))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'vendors': vendors.map((vendor) => vendor.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'VendorResponse(success: $success, count: $count, vendors: $vendors)';
  }
}
