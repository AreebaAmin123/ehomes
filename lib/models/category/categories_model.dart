import '../product/product_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final int? parentId;
  final List<CategoryModel> subcategories;
  final List<ProductModel> products;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.parentId,
    this.subcategories = const [],
    this.products = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['category_name'] ?? 'Unknown',
      icon: json['category_icon'] ?? 'assets/app_logo/ehomes logo green.png',
      parentId: json['parent_id'],
      subcategories: (json['subcategories'] as List?)
              ?.map((child) => CategoryModel.fromJson(child))
              .toList() ??
          [],
      products: (json['products'] as List?)
              ?.map((prod) => ProductModel.fromJson(prod))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': name,
      'category_icon': icon,
      'parent_id': parentId,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
      'products': products.map((p) => p.toJson()).toList(),
    };
  }

  /// ✅ Helper function to fix the image URL
  static String _fixImageUrl(String imageUrl) {
    const String baseUrl = "https://ehomes.pk/admin_panel/uploads/";
    // if (imageUrl.isEmpty) {
    //   return "https://ehomes.pk/admin_panel/uploads/default-placeholder.png";
    // }
    return imageUrl.startsWith("http") ? imageUrl : "$baseUrl$imageUrl";
  }

  /// ✅ Getter for fixed category icon URL
  String get fixedIcon => _fixImageUrl(icon);

  /// ✅ Getter for subcategories
  List<CategoryModel> get subCategories => subcategories;

  /// ✅ Getter to check if category has products
  bool get hasProducts => products.isNotEmpty;

  /// ✅ Getter to check if category has subcategories
  bool get hasSubCategories => subcategories.isNotEmpty;

  /// ✅ Getter to check if category is a leaf node (no subcategories)
  bool get isLeaf => subcategories.isEmpty;

  /// ✅ Getter to check if category is a root node (no parent)
  bool get isRoot => parentId == null;
}
