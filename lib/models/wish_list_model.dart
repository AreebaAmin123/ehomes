class WishListModel {
  List<Wishlist>? wishlist;

  WishListModel({this.wishlist});

  WishListModel.fromJson(Map<String, dynamic> json) {
    if (json['wishlist'] != null) {
      wishlist = <Wishlist>[];
      json['wishlist'].forEach((v) {
        wishlist!.add(Wishlist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (wishlist != null) {
      data['wishlist'] = wishlist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Wishlist {
  int? id;
  int? userId;
  int? productId;
  int? variationId;
  int? quantity;
  String? discountPrice;
  String? price;
  String? totalPrice;

  Wishlist({
    this.id,
    this.userId,
    this.productId,
    this.variationId,
    this.quantity,
    this.discountPrice,
    this.price,
    this.totalPrice,
  });

  Wishlist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    variationId = json['variation_id'];
    quantity = json['quantity'] is int
        ? json['quantity']
        : int.tryParse(json['quantity']?.toString() ?? '');
    discountPrice = json['discount_price']?.toString();
    price = json['price']?.toString();
    totalPrice = json['total_price']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['user_id'] = userId;
    data['product_id'] = productId;
    data['variation_id'] = variationId;
    data['quantity'] = quantity;
    data['discount_price'] = discountPrice;
    data['price'] = price;
    data['total_price'] = totalPrice;
    return data;
  }
}
