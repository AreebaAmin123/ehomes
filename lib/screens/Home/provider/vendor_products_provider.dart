import 'package:flutter/material.dart';
import '../../../models/home screen/vendor/vendor_product_model.dart';
import '../../../models/product/product_model.dart';
import 'vendor_provider.dart';
import 'package:flutter/foundation.dart';

class VendorProductsProvider extends ChangeNotifier {
  final VendorProvider _vendorProvider;

  VendorProductsProvider(this._vendorProvider);

  bool _isLoadingMore = false;
  String? _selectedVendorId;

  // Getters
  bool get isLoadingMore => _isLoadingMore;
  List<VendorProductModel> get products => _vendorProvider.vendorProducts;
  bool get isLoading => _vendorProvider.isLoadingProducts;
  String? get error => _vendorProvider.productsError;
  bool get hasMoreProducts => _vendorProvider.hasMoreProducts;
  int get currentPage => _vendorProvider.currentPage;

  void setLoadingMore(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }

  Future<void> loadInitialProducts(String vendorId) async {
    _selectedVendorId = vendorId;
    await _vendorProvider.fetchVendorProducts(
      vendorId,
      page: 1,
      pageSize: 20,
    );
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !hasMoreProducts || _selectedVendorId == null) return;

    setLoadingMore(true);

    await _vendorProvider.fetchVendorProducts(
      _selectedVendorId!,
      page: currentPage + 1,
      pageSize: 20,
    );

    setLoadingMore(false);
  }

  Future<void> refreshProducts() async {
    if (_selectedVendorId == null) return;
    await _vendorProvider.refreshVendorProducts(
      _selectedVendorId!,
      pageSize: 20,
    );
  }

  // Compute-intensive task moved to isolate
  Future<ProductModel> convertToProductModel(VendorProductModel product) async {
    return compute(_productConverter, product);
  }

  static ProductModel _productConverter(VendorProductModel product) {
    return ProductModel(
      productId: product.productId,
      vendorId: product.vendorId,
      productName: product.productName,
      brandName: product.brandName,
      price: product.price.toInt(),
      discountPrice: product.discountPrice.toInt(),
      description: product.description,
      stock: product.stock,
      categories: product.categories,
      images: product.images,
      variations: [],
      tags: product.tags
          .map((tag) => TagModel(
                tagId: tag.tagId,
                tagName: tag.tagName,
              ))
          .toList(),
    );
  }
}
