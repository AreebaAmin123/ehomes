class PopupModel {
  final bool success;
  final List<PopupBanner> banners;

  PopupModel({required this.success, required this.banners});

  factory PopupModel.fromJson(Map<String, dynamic> json) {
    return PopupModel(
      success: json['success'] ?? false,
      banners: (json['banners'] as List<dynamic>?)
              ?.map((e) => PopupBanner.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'banners': banners.map((e) => e.toJson()).toList(),
    };
  }
}

class PopupBanner {
  final String imageUrl;
  final int productId;
  final String productName;

  PopupBanner({
    required this.imageUrl,
    required this.productId,
    required this.productName,
  });

  factory PopupBanner.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = json['image_url'] ?? '';
    // Fix double escaped backslashes in the URL
    String fixedImageUrl = rawImageUrl.replaceAll(r'\\', r'\');

    return PopupBanner(
      imageUrl: fixedImageUrl,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'product_id': productId,
      'product_name': productName,
    };
  }
}
