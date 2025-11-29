// ignore_for_file: avoid_print

import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:e_Home_app/services/wish_list_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product/product_model.dart';
import '../../../models/wish_list_model.dart';

class WishlistProvider extends ChangeNotifier {
  final WishListService _wishListService = WishListService();
  final List<int> _wishlist = [];
  final Map<int, int> _wishlistMap = {};
  final List<Wishlist> _wishlistItems = [];

  List<int> get wishlist => _wishlist;
  List<Wishlist> get wishlistItems => _wishlistItems;

  bool isWishListed(int productId) => _wishlist.contains(productId);

  /// **Toggle Wishlist**
  Future<void> toggleWishlist({
    required ProductModel product,
    required BuildContext context,
    int? variationId,
    int quantity = 1,
  }) async {
    final authProvider = Provider.of<EmailAuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      print("User ID is null. Cannot toggle wishlist.");
      return;
    }

    print(
        'Request to toggle wishlist for product: ${product.productId}, user: $userId');

    if (!isWishListed(product.productId)) {
      try {
        // Optimistically update local state
        _wishlist.add(product.productId);
        notifyListeners();

        final response = await _wishListService.postWishList(
          userId: userId,
          productId: product.productId,
          variationId: variationId,
          quantity: quantity,
          discountPrice: product.discountPrice,
          price: product.price,
          totalPrice: (product.discountPrice != null &&
                  product.discountPrice > 0 &&
                  product.discountPrice < product.price)
              ? product.discountPrice * quantity
              : product.price * quantity,
        );

        if (response != null &&
            (response["success"] == true ||
                (response["success"] is String &&
                    response["success"]
                        .toString()
                        .toLowerCase()
                        .contains("added")))) {
          print("Item added to wishlist: ${product.productId}");
          await fetchWishlist(context);
        } else if (response != null &&
            response["error"] != null &&
            response["error"].toString().toLowerCase().contains("already")) {
          print("Product already in wishlist, refreshing wishlist");
          await fetchWishlist(context); // Ensure UI updates to filled icon
        } else {
          // Rollback if failed
          _wishlist.remove(product.productId);
          notifyListeners();
          print(
              "Failed to add to wishlist: ${response?["error"] ?? response?["success"] ?? "Unknown error"}");
        }
      } catch (e) {
        _wishlist.remove(product.productId);
        notifyListeners();
        print("Exception while adding to wishlist: $e");
      }
    } else {
      try {
        int? wishlistId = _wishlistMap[product.productId];

        if (wishlistId == null) {
          print("Wishlist ID not found for product: ${product.productId}");
          return;
        }

        final response = await _wishListService.deleteWishList(wishlistId);

        if (response != null &&
            (response["success"] == true ||
                (response["success"] is String &&
                    (response["success"]
                            .toString()
                            .toLowerCase()
                            .contains("removed") ||
                        response["success"]
                            .toString()
                            .toLowerCase()
                            .contains("wishlist item deleted"))))) {
          print("Removed from wishlist: ${product.productId}");
          await fetchWishlist(context);
          print('Updated wishlist after removal: \\_wishlist');
          notifyListeners(); // Force UI update after async fetch
        } else {
          print(
              "Failed to remove from wishlist: ${response?["error"] ?? 'Unknown error'}");
        }
      } catch (e) {
        print("Exception while removing from wishlist: $e");
      }
    }
  }

  /// **Fetch Wishlist**
  Future<void> fetchWishlist(BuildContext context) async {
    final provider = Provider.of<EmailAuthProvider>(context, listen: false);
    await provider.loadUserSession();

    if (provider.user == null) {
      print("User is not logged in or session is null.");
      return;
    }

    final userId = provider.user!.id;
    final wishListModel = await _wishListService.getWishList(userId);

    print("Fetched wishlist model: $wishListModel");

    _wishlistItems.clear();
    if (wishListModel != null &&
        wishListModel.wishlist != null &&
        wishListModel.wishlist!.isNotEmpty) {
      _wishlist.clear();
      _wishlistMap.clear();

      print("Wishlist found ==> : ${wishListModel.wishlist}");

      for (var item in wishListModel.wishlist!) {
        int wishlistId = item.id!;
        int productId = item.productId!;
        _wishlist.add(productId);
        _wishlistMap[productId] = wishlistId;
        _wishlistItems.add(item);
      }

      print("Wishlist fetched: $_wishlist");
    } else {
      print("No items found in wishlist.");
    }

    notifyListeners();
  }

  /// Remove wishlist item by wishlistId
  Future<void> deleteWishlistById(int wishlistId, BuildContext context) async {
    try {
      final response = await _wishListService.deleteWishList(wishlistId);
      if (response != null &&
          (response["success"] == true ||
              (response["success"] is String &&
                  (response["success"]
                          .toString()
                          .toLowerCase()
                          .contains("removed") ||
                      response["success"]
                          .toString()
                          .toLowerCase()
                          .contains("wishlist item deleted"))))) {
        // Remove from local lists
        _wishlistItems.removeWhere((item) => item.id == wishlistId);
        _wishlistMap.removeWhere((_, v) => v == wishlistId);
        _wishlist
            .removeWhere((productId) => !_wishlistMap.containsKey(productId));
        notifyListeners();
      } else {
        print(
            "Failed to remove from wishlist: \\${response?["error"] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Exception while removing from wishlist: $e");
    }
  }
}
