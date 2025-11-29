class SearchModel {
  final String query;
  List<Products>? products;
  final List<Brand>? brands;
  final List<Category>? categories;

  SearchModel({
    required this.query,
    this.products,
    this.brands,
    this.categories,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      query: json['query'] as String? ?? '',
      products: json['products'] != null
          ? List<Products>.from(
              json['products'].map((x) => Products.fromJson(x)))
          : null,
      brands: json['brands'] != null
          ? List<Brand>.from(json['brands'].map((x) => Brand.fromJson(x)))
          : null,
      categories: json['categories'] != null
          ? List<Category>.from(
              json['categories'].map((x) => Category.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'products': products?.map((x) => x.toJson()).toList(),
      'brands': brands?.map((x) => x.toJson()).toList(),
      'categories': categories?.map((x) => x.toJson()).toList(),
    };
  }
}

class Products {
  final int? productId;
  final String? productName;
  final String? brandName;
  final double? price;
  final double? discountPrice;
  final String? imageUrl;
  final String? categoryName;
  final String? subCategoryName;

  Products({
    this.productId,
    this.productName,
    this.brandName,
    this.price,
    this.discountPrice,
    this.imageUrl,
    this.categoryName,
    this.subCategoryName,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      productId: json['product_id'],
      productName: json['product_name'],
      brandName: json['brand_name'],
      price: json['price']?.toDouble(),
      discountPrice: json['discount_price']?.toDouble(),
      imageUrl: json['image_url'],
      categoryName: json['category_name'],
      subCategoryName: json['sub_category_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'brand_name': brandName,
      'price': price,
      'discount_price': discountPrice,
      'image_url': imageUrl,
      'category_name': categoryName,
      'sub_category_name': subCategoryName,
    };
  }
}

class Brand {
  int? brandId;
  String? brandName;
  String? imageUrl;

  Brand({this.brandId, this.brandName, this.imageUrl});

  Brand.fromJson(Map<String, dynamic> json) {
    brandId = json['brand_id'];
    brandName = json['brand_name'];
    imageUrl = json['image_url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['brand_id'] = brandId;
    data['brand_name'] = brandName;
    data['image_url'] = imageUrl;
    return data;
  }
}

class Category {
  int? categoryId;
  String? categoryName;
  String? imageUrl;

  Category({this.categoryId, this.categoryName, this.imageUrl});

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    imageUrl = json['image_url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['image_url'] = imageUrl;
    return data;
  }
}
