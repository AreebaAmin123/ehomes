class GetCartModel {
  bool? success;
  List<CartModel>? cart;

  GetCartModel({this.success, this.cart});

  GetCartModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['cart'] != null) {
      cart = <CartModel>[];
      json['cart'].forEach((v) {
        cart!.add(new CartModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.cart != null) {
      data['cart'] = this.cart!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CartModel {
  int? id;
  String? userId;
  int? productId;
  int? variationId;
  int? quantity;
  String? discountPrice;
  String? price;
  String? totalPrice;
  String? productName;
  String? variationName;
  String? variationValue;
  String? imageUrl;

  CartModel({
    this.id,
    this.userId,
    this.productId,
    this.variationId,
    this.quantity,
    this.discountPrice,
    this.price,
    this.totalPrice,
    this.productName,
    this.variationName,
    this.variationValue,
    this.imageUrl,
  });

  CartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    variationId = json['variation_id'];
    quantity = json['quantity'];
    discountPrice = json['discount_price'];
    price = json['price'];
    totalPrice = json['total_price'];
    productName = json['product_name'];
    variationName = json['variation_name'];
    variationValue = json['variation_value'];
    imageUrl = _resolveImageUrl(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['product_id'] = this.productId;
    data['variation_id'] = this.variationId;
    data['quantity'] = this.quantity;
    data['discount_price'] = this.discountPrice;
    data['price'] = this.price;
    data['total_price'] = this.totalPrice;
    data['product_name'] = this.productName;
    data['variation_name'] = this.variationName;
    data['variation_value'] = this.variationValue;
    data['image_url'] = this.imageUrl;
    return data;
  }

  /// Helper function to fix or resolve the image URL
  static String _resolveImageUrl(Map<String, dynamic> json) {
    String? imageUrl = json['image_url'];
    if (imageUrl == null || imageUrl.isEmpty) {
      // Try to resolve from product images if available (for future extensibility)
      if (json['product'] != null && json['product'] is Map<String, dynamic>) {
        final product = json['product'] as Map<String, dynamic>;
        if (product['images'] != null &&
            product['images'] is List &&
            product['images'].isNotEmpty) {
          final firstImage = product['images'][0].toString();
          if (firstImage.startsWith('http')) {
            return firstImage;
          } else {
            return 'https://ehomes.pk/Vendor_Panel/uploads/$firstImage';
          }
        }
      }
      // Fallback to placeholder
      return 'https://via.placeholder.com/300x400?text=No+Image';
    }

    // Extract the filename from the old klik.pk URL if present
    if (imageUrl.contains('klik.pk')) {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final filename = pathSegments.last;
        imageUrl = 'https://ehomes.pk/Vendor_Panel/uploads/$filename';
      }
    }
    if (imageUrl.toLowerCase().endsWith('.webp')) {
      imageUrl = imageUrl.substring(0, imageUrl.length - 5) + '.jpg';
    }
    if (!imageUrl.startsWith('http')) {
      imageUrl = 'https://ehomes.pk/Vendor_Panel/uploads/$imageUrl';
    }
    return imageUrl;
  }

  String get effectivePrice {
    final hasValidDiscount = discountPrice != null &&
        discountPrice != '' &&
        discountPrice != '0' &&
        discountPrice != '0.0' &&
        price != null &&
        price != '' &&
        price != '0' &&
        price != '0.0' &&
        double.tryParse(discountPrice!) != null &&
        double.tryParse(price!) != null &&
        double.parse(discountPrice!) > 0 &&
        double.parse(discountPrice!) < double.parse(price!);
    if (hasValidDiscount) {
      return discountPrice!;
    }
    if (price != null && price != '' && price != '0' && price != '0.0') {
      return price!;
    }
    // If both are missing or zero, return 'N/A' to avoid showing 0
    return 'N/A';
  }
}
