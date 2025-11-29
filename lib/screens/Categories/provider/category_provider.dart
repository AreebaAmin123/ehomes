import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../models/category/categories_model.dart';
import '../../../services/category_service.dart';
import '../../../Utils/constants/my_sharePrefs.dart';
import '../../../services/product_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  final MySharedPrefs _prefs = MySharedPrefs();

  String _selectedCategory = '';
  final Map<String, bool> _expandedStates = {};
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  /// **📌 Getters**
  String get selectedCategory => _selectedCategory;

  List<CategoryModel> get categories => _categories;

  bool get isLoading => _isLoading;

  /// **🔹 Select Category**
  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// **🔹 Toggle Expand State**
  void toggleExpanded(String subfield) {
    _expandedStates[subfield] = !(_expandedStates[subfield] ?? false);
    notifyListeners();
  }

  bool isExpanded(String subfield) {
    return _expandedStates[subfield] ?? false;
  }

  /// **📌 Fetch Categories from API with caching**
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to get cached data first
      final cachedData = await _prefs.getCategoriesData();
      if (cachedData != null) {
        final response = jsonDecode(cachedData);
        if (response['success'] == true) {
          _categories = (response['categories'] as List<dynamic>)
              .map((e) => CategoryModel.fromJson(e))
              .toList();

          // Load products for each category
          await _loadProductsForCategories();

          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first.name;
          }
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // If no cache or cache invalid, fetch from API
      final response = await _categoryService.getCategories();
      if (response != null && response['success'] == true) {
        _categories = (response['categories'] as List<dynamic>)
            .map((e) => CategoryModel.fromJson(e))
            .toList();

        // Load products for each category
        await _loadProductsForCategories();

        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first.name;
        }

        // Cache the response
        await _prefs.saveCategoriesData(jsonEncode(response));
      } else {
        _categories = [];
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      _categories = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load products for each category
  Future<void> _loadProductsForCategories() async {
    final updatedCategories = <CategoryModel>[];
    final allProducts = await _productService.fetchProducts();

    for (var category in _categories) {
      try {
        // Filter products for this category
        final categoryProducts = allProducts.where((product) {
          // Check if product's categoryId matches
          final matchesCategoryId = product.categoryId == category.id;

          // Check if product's categories list contains this category
          final matchesCategoriesList = product.categories.any((catId) {
            try {
              final parsedId = int.tryParse(catId);
              return parsedId == category.id;
            } catch (e) {
              debugPrint('Error parsing category ID: $catId');
              return false;
            }
          });

          final matches = matchesCategoryId || matchesCategoriesList;
          if (matches) {
            debugPrint(
                'Product ${product.productName} matches category ${category.name}');
            debugPrint('- categoryId match: $matchesCategoryId');
            debugPrint('- categories list match: $matchesCategoriesList');
          }

          return matches;
        }).toList();

        debugPrint(
            'Category ${category.name} has ${categoryProducts.length} products');
        if (categoryProducts.isNotEmpty) {
          debugPrint('First product: ${categoryProducts.first.productName}');
        }

        final updatedCategory = CategoryModel(
          id: category.id,
          name: category.name,
          icon: category.icon,
          parentId: category.parentId,
          subcategories: category.subcategories,
          products: categoryProducts,
        );
        updatedCategories.add(updatedCategory);
      } catch (e) {
        debugPrint("Error loading products for category ${category.name}: $e");
        updatedCategories.add(category);
      }
    }

    _categories = updatedCategories;
    notifyListeners();
  }

  /// Clear categories cache
  Future<void> clearCache() async {
    await _prefs.clearCategoriesCache();
  }
}
