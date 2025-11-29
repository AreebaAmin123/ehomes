// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../models/product/product_model.dart';
import '../../../services/product_service.dart';
import '../../../Utils/cache/cache_manager.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final CacheManager _cache = CacheManager();
  final Map<String, List<ProductModel>> _products = {};
  final Set<String> _loadingCategories = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProductModel? _productModel;
  ProductModel? get productModel => _productModel;

  Map<String, List<ProductModel>> get subcategoryProducts => _products;

  bool isLoadingCategory(String categoryId) =>
      _loadingCategories.contains(categoryId);

  String _getCacheKey(String categoryId) => 'products_cache_$categoryId';

  ProductService get productService => _productService;

  /// Get products with caching
  Future<List<ProductModel>> fetchProducts(String categoryId) async {
    final cacheKey = _getCacheKey(categoryId);

    // Check for concurrent requests and debounce
    if (_loadingCategories.contains(categoryId) ||
        !_cache.shouldAllowNewRequest(cacheKey)) {
      debugPrint('🔄 Skipping request for category: $categoryId (debounced)');
      return _products[categoryId] ?? [];
    }

    // Try to get from cache first
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);
    if (cachedData != null) {
      final products =
          cachedData.map((json) => ProductModel.fromJson(json)).toList();
      _products[categoryId] = products;
      debugPrint('📦 Using cached products for category: $categoryId');
      notifyListeners();
      return products;
    }

    try {
      debugPrint('🔄 Fetching products for category: $categoryId');
      _loadingCategories.add(categoryId);
      _cache.updateRequestTime(cacheKey);
      notifyListeners();

      final products = await _productService.fetchProducts();
      debugPrint('📦 Total products fetched: ${products.length}');

      List<ProductModel> categoryProducts;
      if (categoryId == "1") {
        categoryProducts = products;
        debugPrint('✅ Storing all products for default category');
      } else {
        categoryProducts = products.where((product) {
          final targetId = int.tryParse(categoryId);
          if (targetId == null) return false;

          // Check both categoryId and categories list
          final matchesCategoryId = product.categoryId == targetId;
          final matchesCategoriesList = product.categories.any((cat) {
            // Try to parse the category ID from the string
            final catId = int.tryParse(cat);
            if (catId != null) {
              return catId == targetId;
            }
            // If parsing fails, try to extract ID from category object
            try {
              final catMap = jsonDecode(cat);
              if (catMap is Map) {
                final id = catMap['id'] ?? catMap['category_id'];
                return id == targetId;
              }
            } catch (e) {
              // If parsing fails, just compare strings
              return cat == categoryId;
            }
            return false;
          });

          if (matchesCategoryId || matchesCategoriesList) {
            debugPrint(
                '✅ Found matching product: ${product.productName} (Category ID: ${product.categoryId}, Categories: ${product.categories})');
            return true;
          }
          return false;
        }).toList();
      }

      _products[categoryId] = categoryProducts;

      // Save to cache
      await _cache.set(
        cacheKey,
        categoryProducts.map((p) => p.toJson()).toList(),
      );

      _loadingCategories.remove(categoryId);
      notifyListeners();
      return categoryProducts;
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      _loadingCategories.remove(categoryId);
      notifyListeners();
      rethrow;
    }
  }

  /// Get cached products without fetching
  List<ProductModel> getProducts(String categoryId) {
    final products = _products[categoryId] ?? [];
    debugPrint('📦 Getting ${products.length} products from cache');
    return products;
  }

  /// Force refresh products
  Future<void> forceRefreshProducts(String categoryId) async {
    final cacheKey = _getCacheKey(categoryId);
    _products.remove(categoryId);
    await _cache.clear(cacheKey);
    await fetchProducts(categoryId);
  }

  /// Clear products cache for a specific subcategory
  Future<void> clearSubcategoryCache(String categoryId) async {
    final cacheKey = _getCacheKey(categoryId);
    _products.remove(categoryId);
    await _cache.clear(cacheKey);
    notifyListeners();
  }

  /// Search for a specific product
  Future<void> searchProducts(int productId) async {
    // First check in cached products
    for (final products in _products.values) {
      final product = products.firstWhere(
        (p) => p.productId == productId,
        orElse: () => ProductModel(
          productId: 0,
          vendorId: null,
          productName: '',
          brandName: '',
          price: 0,
          discountPrice: 0,
          description: '',
          stock: 0,
          categories: [],
          images: [],
          variations: [],
          tags: [],
        ),
      );

      if (product.productId != 0) {
        _productModel = product;
        notifyListeners();
        return;
      }
    }

    // If not found in cache, fetch from API
    try {
      final response = await _productService.fetchProducts();
      if (response.isNotEmpty) {
        _productModel = response.firstWhere(
          (product) => product.productId == productId,
          orElse: () => ProductModel(
            productId: 0,
            vendorId: null,
            productName: '',
            brandName: '',
            price: 0,
            discountPrice: 0,
            description: '',
            stock: 0,
            categories: [],
            images: [],
            variations: [],
            tags: [],
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all products cache
  Future<void> clearAllCache() async {
    debugPrint('🗑️ Clearing all product cache');
    _products.clear();
    await _cache.clearAll();
    notifyListeners();
  }

  ProductModel? getProductById(int productId) {
    for (final products in _products.values) {
      final product = products.firstWhere(
        (p) => p.productId == productId,
        orElse: () => ProductModel(
          productId: 0,
          vendorId: null,
          productName: '',
          brandName: '',
          price: 0,
          discountPrice: 0,
          description: '',
          stock: 0,
          categories: [],
          images: [],
          variations: [],
          tags: [],
        ),
      );
      if (product.productId != 0) {
        return product;
      }
    }
    return null;
  }
}
