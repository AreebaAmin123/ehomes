import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../../models/product/product_model.dart';
import '../../../services/product_service.dart';
import '../../../Utils/constants/my_sharePrefs.dart';

class BrandProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final MySharedPrefs _prefs = MySharedPrefs();
  final Map<String, List<ProductModel>> _brandProducts = {};
  final Set<String> _loadingBrands = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Map<String, List<ProductModel>> get brandProducts => _brandProducts;
  bool isLoadingBrand(String brandName) => _loadingBrands.contains(brandName);

  // Add request tracking
  final Map<String, DateTime> _lastBrandProductsFetch = {};
  static const Duration _minFetchInterval = Duration(seconds: 30);

  bool _shouldRefetch(String brandName) {
    final lastFetch = _lastBrandProductsFetch[brandName];
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch) > _minFetchInterval;
  }

  Future<List<ProductModel>> getBrandProducts(String brandName) async {
    if (!_shouldRefetch(brandName)) {
      debugPrint(
          'Skipping brand products fetch for $brandName - too soon since last fetch');
      return _brandProducts[brandName] ?? [];
    }

    if (_loadingBrands.contains(brandName)) {
      debugPrint('Brand products fetch already in progress for $brandName');
      return _brandProducts[brandName] ?? [];
    }

    try {
      _loadingBrands.add(brandName);
      _isLoading = true;
      notifyListeners();

      debugPrint('Fetching products for brand: $brandName...');
      _lastBrandProductsFetch[brandName] = DateTime.now();

      // Try to get cached data first
      final cachedData = await _prefs.getBrandProductsData(brandName);
      if (cachedData != null) {
        final response = jsonDecode(cachedData);
        if (response['success'] == true && response['products'] != null) {
          final products = (response['products'] as List)
              .map((product) => ProductModel.fromJson(product))
              .toList();
          _brandProducts[brandName] = products;
          debugPrint(
              'Brand products loaded from cache (${products.length} products)');
          notifyListeners();
          return products;
        }
      }

      // If no cache or cache invalid, fetch from API
      debugPrint('Fetching brand products from API...');
      final products = await _productService.fetchProducts();
      final brandProducts =
          products.where((p) => p.brandName == brandName).toList();

      if (brandProducts.isNotEmpty) {
        _brandProducts[brandName] = brandProducts;
        // Cache the response
        await _prefs.saveBrandProductsData(
          brandName,
          jsonEncode({
            'success': true,
            'products': brandProducts.map((p) => p.toJson()).toList(),
          }),
        );
        debugPrint(
            'Brand products fetched from API and cached (${brandProducts.length} products)');
        notifyListeners();
        return brandProducts;
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching brand products: $e');
      return [];
    } finally {
      _loadingBrands.remove(brandName);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBrandProducts(String brandName) async {
    _brandProducts.remove(brandName);
    _lastBrandProductsFetch.remove(brandName);
    await getBrandProducts(brandName);
  }

  void reset() {
    _brandProducts.clear();
    _loadingBrands.clear();
    _isLoading = false;
    _lastBrandProductsFetch.clear();
    notifyListeners();
  }

  Future<void> clearCache() async {
    await _prefs.clearBrandProductsCache();
    reset();
  }
}
