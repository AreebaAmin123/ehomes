import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../models/home screen/vendor/vendor_model.dart';
import '../../../models/home screen/vendor/vendor_product_model.dart';
import '../../../services/vendor_service.dart';
import '../../../Utils/constants/my_sharePrefs.dart';
import 'package:flutter/foundation.dart';

class VendorProvider extends ChangeNotifier {
  final VendorService _vendorService = VendorService();
  final MySharedPrefs _prefs = MySharedPrefs();

  // Vendors state
  List<VendorModel> _vendors = [];
  bool _isLoading = false;
  String? _error;

  // Vendor products state
  List<VendorProductModel> _vendorProducts = [];
  bool _isLoadingProducts = false;
  String? _productsError;
  String? _currentVendorId;
  int _currentPage = 1;
  bool _hasMoreProducts = true;
  int _totalProducts = 0;

  // Vendors getters
  List<VendorModel> get vendors => _vendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Vendor products getters
  List<VendorProductModel> get vendorProducts => _vendorProducts;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get productsError => _productsError;
  String? get currentVendorId => _currentVendorId;
  int get currentPage => _currentPage;
  bool get hasMoreProducts => _hasMoreProducts;
  int get totalProducts => _totalProducts;

  /// Fetch vendors with caching and compute isolation
  Future<void> fetchVendors() async {
    if (_isLoading) {
      debugPrint('Vendors fetch already in progress');
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Try to get cached data first
      final cachedData = await _prefs.getVendorsData();
      if (cachedData != null) {
        final response = await compute(_parseVendorsJson, cachedData);
        if (response['success'] == true) {
          _vendors = (response['vendors'] as List)
              .map((vendor) => VendorModel.fromJson(vendor))
              .toList();
          _isLoading = false;
          notifyListeners();
          debugPrint('Vendors loaded from cache (${_vendors.length} vendors)');
          return;
        }
      }

      // If no cache or cache invalid, fetch from API
      final response = await _vendorService.fetchVendors();
      _vendors = await compute(_parseVendorResponse, response);

      // Cache the response
      await _prefs.saveVendorsData(jsonEncode({
        'success': true,
        'vendors': _vendors.map((vendor) => vendor.toJson()).toList(),
      }));

      debugPrint('Vendors fetched from API and cached (${_vendors.length} vendors)');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching vendors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Static methods for compute isolation
  static Map<String, dynamic> _parseVendorsJson(String jsonStr) {
    return jsonDecode(jsonStr);
  }

  static List<VendorModel> _parseVendorResponse(dynamic response) {
    return response.vendors;
  }

  Future<void> fetchVendorProducts(
    String vendorId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (_isLoadingProducts) return;

    try {
      _isLoadingProducts = true;
      _productsError = null;
      _currentVendorId = vendorId;
      notifyListeners();

      // For first page, try to get cached data
      if (page == 1) {
        final cachedData = await _prefs.getVendorProductsData(vendorId);
        if (cachedData != null) {
          final response = jsonDecode(cachedData);
          if (response['success'] == true) {
            _vendorProducts = (response['products'] as List)
                .map((product) => VendorProductModel.fromJson(product))
                .toList();
            _totalProducts = response['total_products'] ?? 0;
            _hasMoreProducts = _vendorProducts.length < _totalProducts;
            _currentPage = 1;
            _productsError = null;
            _isLoadingProducts = false;
            notifyListeners();
            debugPrint(
                'Vendor products loaded from cache (${_vendorProducts.length} products)');
            return;
          }
        }
      }

      // If no cache, cache invalid, or loading more pages
      final response = await _vendorService.getVendorProducts(
        vendorId,
        page: page,
        pageSize: pageSize,
      );

      if (response.success) {
        if (page == 1) {
          _vendorProducts = response.products;
          // Cache first page
          await _prefs.saveVendorProductsData(
            vendorId,
            jsonEncode({
              'success': true,
              'products':
                  _vendorProducts.map((product) => product.toJson()).toList(),
              'total_products': response.count,
            }),
          );
        } else {
          _vendorProducts.addAll(response.products);
        }

        _totalProducts = response.count;
        _hasMoreProducts = _vendorProducts.length < _totalProducts;
        _currentPage = page;
        _productsError = null;

        debugPrint(
            'Vendor products fetched from API (${response.products.length} products, page $page)');
      } else {
        _productsError = 'Failed to fetch products';
        if (page == 1) _vendorProducts = [];
      }

      _isLoadingProducts = false;
      notifyListeners();
    } catch (e) {
      _productsError = e.toString();
      if (page == 1) _vendorProducts = [];
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> refreshVendorProducts(String vendorId,
      {int pageSize = 20}) async {
    _currentPage = 1;
    _hasMoreProducts = true;
    _vendorProducts = [];
    await fetchVendorProducts(vendorId, page: 1, pageSize: pageSize);
  }

  void reset() {
    _vendors = [];
    _isLoading = false;
    _error = null;
    _vendorProducts = [];
    _isLoadingProducts = false;
    _productsError = null;
    _currentVendorId = null;
    _currentPage = 1;
    _hasMoreProducts = true;
    _totalProducts = 0;
    notifyListeners();
  }

  /// Clear vendor cache
  Future<void> clearCache() async {
    await _prefs.clearVendorCache();
    debugPrint('Vendor cache cleared');
  }
}
