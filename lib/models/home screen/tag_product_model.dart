class TagProductModel {
  bool? success;
  List<Products>? products;

  TagProductModel({this.success, this.products});

  TagProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  int? productId;
  int? vendorId;
  String? productName;
  String? brandName;
  String? price;
  String? discountPrice;
  String? description;
  int? stock;
  List<String>? categories;
  List<String>? images;
  List<Variations>? variations;
  List<Tags>? tags;

  Products({
    this.productId,
    this.vendorId,
    this.productName,
    this.brandName,
    this.price,
    this.discountPrice,
    this.description,
    this.stock,
    this.categories,
    this.images,
    this.variations,
    this.tags,
  });

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    vendorId = json['vendor_id'];
    productName = json['product_name'];
    brandName = json['brand_name'];
    price = json['price']?.toString();
    discountPrice = json['discount_price']?.toString();
    description = json['description'];
    stock = json['stock'];
    categories = (json['categories'] as List<dynamic>?)?.map((e) {
          if (e is Map<String, dynamic>) {
            return e['category_name']?.toString() ?? '';
          }
          return e.toString();
        }).toList() ??
        [];
    images =
        (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    if (json['variations'] != null) {
      variations = <Variations>[];
      json['variations'].forEach((v) {
        variations!.add(Variations.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(Tags.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['vendor_id'] = vendorId;
    data['product_name'] = productName;
    data['brand_name'] = brandName;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['description'] = description;
    data['stock'] = stock;
    data['categories'] = categories;
    data['images'] = images;
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variations {
  int? variationId;
  String? variationName;
  String? variationValue;
  String? price;
  int? stock;
  String? imageUrl;

  Variations({
    this.variationId,
    this.variationName,
    this.variationValue,
    this.price,
    this.stock,
    this.imageUrl,
  });

  Variations.fromJson(Map<String, dynamic> json) {
    variationId = json['variation_id'] is int
        ? json['variation_id']
        : int.tryParse(json['variation_id'].toString());
    variationName = json['variation_name']?.toString();
    variationValue = json['variation_value']?.toString();
    price = json['price']?.toString();
    stock = json['stock'] is int
        ? json['stock']
        : int.tryParse(json['stock'].toString());
    imageUrl = json['image_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variation_id'] = variationId;
    data['variation_name'] = variationName;
    data['variation_value'] = variationValue;
    data['price'] = price;
    data['stock'] = stock;
    data['image_url'] = imageUrl;
    return data;
  }
}

class Tags {
  int? tagId;
  String? tagName;

  Tags({
    this.tagId,
    this.tagName,
  });

  Tags.fromJson(Map<String, dynamic> json) {
    tagId = json['tag_id'] is int
        ? json['tag_id']
        : int.tryParse(json['tag_id'].toString());
    tagName = json['tag_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tag_id'] = tagId;
    data['tag_name'] = tagName;
    return data;
  }
}
