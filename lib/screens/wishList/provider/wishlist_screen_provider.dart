import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../models/product/product_model.dart';
import '../../../Utils/constants/my_sharePrefs.dart';
import '../../ProductDetail/provider/wish_list_provider.dart';

class WishlistScreenProvider extends ChangeNotifier {
  bool isLoading = true;
  List<ProductModel> wishlistProducts = [];

  Future<void> fetchWishlistProducts(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    await wishlistProvider.fetchWishlist(context);
    final wishlistIds = wishlistProvider.wishlist;
    // Use cached products data
    final productsJsonStr = await MySharedPrefs().getProductsData();
    if (productsJsonStr != null) {
      final productsJson = jsonDecode(productsJsonStr);
      List<ProductModel> allProducts = [];
      if (productsJson is Map && productsJson['products'] is List) {
        allProducts = (productsJson['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
      }
      wishlistProducts =
          allProducts.where((p) => wishlistIds.contains(p.productId)).toList();
    } else {
      wishlistProducts = [];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> removeFromWishlist(
      BuildContext context, ProductModel product) async {
    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);
    await wishlistProvider.toggleWishlist(product: product, context: context);
    await fetchWishlistProducts(context);
  }
}
