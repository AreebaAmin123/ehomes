// ignore_for_file: avoid_print, prefer_const_declarations, prefer_final_fields, collection_methods_unrelated_type

import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_Home_app/services/cart_service.dart';
import 'package:e_Home_app/models/cart/get_cart_model.dart';
import 'package:e_Home_app/Utils/constants/my_sharePrefs.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../Categories/provider/product_provider.dart';
import '../../../models/product/product_model.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartServices = CartService();
  final MySharedPrefs _prefs = MySharedPrefs();
  final Map<int, bool> _cart = {};
  Map<int, bool> get cart => _cart;

  bool isLoading = false;
  bool _isAddingToCart = false;
  bool get isAddingToCart => _isAddingToCart;
  GetCartModel? _cartModel;
  GetCartModel? get cartModel => _cartModel;
  bool _isInitialized = false;

  static const String _cartCacheKey = 'cart_data';
  static const Duration _cartCacheValidity = Duration(hours: 24);

  /// Get total number of items in cart
  int get cartItemCount {
    if (_cartModel?.cart == null) return 0;
    return _cartModel!.cart!.length;
  }

  /// Initialize cart data
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    final authProvider = Provider.of<EmailAuthProvider>(context, listen: false);
    try {
      await authProvider.loadUserSession();
      if (authProvider.isLoggedIn) {
        // Try to load from cache first
        final cachedCart = await _loadCartFromCache();
        if (cachedCart != null) {
          _cartModel = cachedCart;
          _updateCartMapFromModel();
          notifyListeners();
        }
        // Always fetch fresh data from API
        await getCart(context);
      }
    } catch (e) {
      print('Error initializing cart: $e');
    } finally {
      _isInitialized = true;
    }
  }

  /// Load cart data from cache
  Future<GetCartModel?> _loadCartFromCache() async {
    try {
      final cartData = await _prefs.getString(_cartCacheKey);
      if (cartData != null) {
        final cartJson = jsonDecode(cartData);
        final timestamp = cartJson['timestamp'] as int?;

        // Check if cache is still valid
        if (timestamp != null &&
            DateTime.now().millisecondsSinceEpoch - timestamp <
                _cartCacheValidity.inMilliseconds) {
          return GetCartModel.fromJson(cartJson['data']);
        }
      }
    } catch (e) {
      print('Error loading cart from cache: $e');
    }
    return null;
  }

  /// Save cart data to cache
  Future<void> _saveCartToCache() async {
    if (_cartModel == null) return;

    try {
      final cartData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': _cartModel!.toJson(),
      };
      await _prefs.setString(_cartCacheKey, jsonEncode(cartData));
    } catch (e) {
      print('Error saving cart to cache: $e');
    }
  }

  /// Update cart map from model
  void _updateCartMapFromModel() {
    _cart.clear();
    if (_cartModel?.cart != null) {
      for (var item in _cartModel!.cart!) {
        if (item.productId != null) {
          _cart[item.productId!] = true;
        }
      }
    }
  }

  /// Calculate total cart price using compute
  Future<double> calculateTotalPrice() async {
    if (_cartModel == null || _cartModel!.cart == null) return 0.0;

    return compute(_calculateTotal, _cartModel!.cart!);
  }

  /// Static method for compute
  static double _calculateTotal(List<dynamic> items) {
    double total = 0.0;
    for (var item in items) {
      final price = double.tryParse(item.effectivePrice) ?? 0.0;
      final quantity = item.quantity ?? 1;
      total += price * quantity;
    }
    return total;
  }

  double get totalCartPrice {
    if (_cartModel == null || _cartModel!.cart == null) return 0.0;

    double total = 0.0;
    for (var item in _cartModel!.cart!) {
      if (inCart(item.productId!)) {
        final price = double.tryParse(item.effectivePrice) ?? 0.0;
        final quantity = item.quantity ?? 1;
        total += price * quantity;
      }
    }
    return total;
  }

  void updateQuantity(int index, int newQuantity, int productId) {
    cartModel!.cart![index].quantity = newQuantity;
    notifyListeners();
    updateCart(productId, newQuantity);
  }

  void updateCart(int productId, int quantity) async {
    if (_cartModel != null && _cartModel!.cart != null) {
      try {
        int? cartId;
        for (var item in _cartModel!.cart!) {
          if (item.productId == productId) {
            cartId = item.id!;
            break;
          }
        }

        if (cartId != null) {
          await _cartServices.updateCart(cartId, quantity);
          await _saveCartToCache(); // Update cache after successful API call
        }
      } catch (e) {
        print("Error updating cart item: $e");
        rethrow;
      }
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setAddingToCart(bool value) {
    _isAddingToCart = value;
    notifyListeners();
  }

  Future<void> deleteCart(int productId) async {
    if (_cartModel != null && _cartModel!.cart != null) {
      try {
        int? cartId;
        int? itemIndex;

        for (int i = 0; i < _cartModel!.cart!.length; i++) {
          if (_cartModel!.cart![i].productId == productId) {
            cartId = _cartModel!.cart![i].id!;
            itemIndex = i;
            break;
          }
        }

        if (cartId != null) {
          await _cartServices.deleteCart(cartId);

          if (itemIndex != null) {
            _cartModel!.cart!.removeAt(itemIndex);
          }

          _cart.remove(productId);
          await _saveCartToCache(); // Update cache after successful deletion
          notifyListeners();

          print('Cart item removed successfully.');
        } else {
          print('Product not found in cart.');
        }
      } catch (e) {
        print('Error deleting cart item: $e');
        rethrow;
      }
    }
  }

  bool inCart(int productId) {
    return _cart[productId] ?? false;
  }

  void addToCart(int productId) {
    _cart[productId] = true;
    print("Updated cart: $_cart");
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cart.remove(productId);
    notifyListeners();
  }

  Future<void> postAddedCart(
    BuildContext context,
    int productId,
    int? variationId,
    int quantity,
    double price,
    double totalPrice,
  ) async {
    setAddingToCart(true);
    try {
      final provider = Provider.of<EmailAuthProvider>(context, listen: false);
      await provider.loadUserSession();
      final userId = provider.user!.id;

      final response = await _cartServices.addToCart(
        userId: userId,
        productId: productId,
        variationId: variationId,
        quantity: quantity,
        price: price,
        totalPrice: totalPrice,
      );
      print("API Response: ${response.toString()}");

      if (response != null && response['success'] != null) {
        addToCart(productId);
        await getCart(context);
        await _patchCartImagesFromProductCache(context);
      } else {
        String errorMessage = response!['message'] ?? 'Unknown error';
        print("Failed to add item to cart. Response: $errorMessage");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to cart: $errorMessage'),
          ),
        );
      }
    } finally {
      setAddingToCart(false);
    }
  }

  Future<void> getCart(BuildContext context) async {
    setLoading(true);
    final provider = Provider.of<EmailAuthProvider>(context, listen: false);
    await provider.loadUserSession();
    final userId = provider.user!.id;

    try {
      GetCartModel response = await _cartServices.getCart(userId);

      if (response.success == true &&
          response.cart != null &&
          response.cart!.isNotEmpty) {
        _cartModel = response;
        _updateCartMapFromModel();
        await _patchCartImagesFromProductCache(context);
        await _saveCartToCache(); // Cache the fresh data
        print('Cart Items: ${response.cart}');
      } else {
        _cartModel = GetCartModel(success: true, cart: []);
        _cart.clear();
        print('No items in the cart.');
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching cart data: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Patch missing imageUrls in cart items using ProductProvider's cache
  Future<void> _patchCartImagesFromProductCache(BuildContext context) async {
    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      if (_cartModel?.cart == null) return;
      bool updated = false;
      for (final item in _cartModel!.cart!) {
        if (item.imageUrl == null ||
            item.imageUrl!.isEmpty ||
            item.imageUrl!.contains('No+Image')) {
          // Try cache first
          var product = productProvider.getProductById(item.productId!);
          if (product == null) {
            // Fetch from backend if not in cache
            try {
              final products =
                  await productProvider.productService.fetchProducts();
              product = products.firstWhere(
                (p) => p.productId == item.productId!,
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
            } catch (e) {
              print('Error fetching product for cart image: $e');
            }
          }
          if (product != null &&
              product.productId != 0 &&
              product.images.isNotEmpty) {
            final img = product.images[0];
            if (img.startsWith('http')) {
              item.imageUrl = img;
            } else {
              item.imageUrl = 'https://ehomes.pk/Vendor_Panel/uploads/$img';
            }
            updated = true;
          }
        }
      }
      if (updated) notifyListeners();
    } catch (e) {
      print('Error patching cart images: $e');
    }
  }

  /// Clears the cart state after successful checkout
  Future<void> clearCart() async {
    _cart.clear();
    _cartModel = GetCartModel(success: true, cart: []);
    await _prefs.remove(_cartCacheKey); // Clear cache
    notifyListeners();
  }
}
