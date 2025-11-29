import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../Utils/constants/app_colors.dart';
import '../../../Utils/helpers/show_toast_dialouge.dart';
import '../../../models/cart/get_cart_model.dart';
import '../../Auth/email section/provider/email_authProvider.dart';
import '../../Auth/email section/signIn_withEmail.dart';
import '../../Cart/provider/cart_provider.dart';
import '../../Categories/provider/product_provider.dart';

class CartActionButton extends StatelessWidget {
  final int productId;
  final double price;
  final int? variationId;
  final VoidCallback? onQuantityChanged;
  final int stock;

  const CartActionButton({
    super.key,
    required this.productId,
    required this.price,
    required this.stock,
    this.variationId,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final inCart = cartProvider.inCart(productId);
        CartModel? cartItem;
        if (cartProvider.cartModel?.cart != null) {
          try {
            cartItem = cartProvider.cartModel!.cart!.firstWhere(
              (item) => item.productId == productId,
            );
          } catch (e) {
            cartItem = null;
          }
        }
        final quantity = cartItem?.quantity ?? 1;

        if (stock <= 0) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'Out of Stock',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        if (!inCart) {
          return IconButton(
            icon: Icon(Icons.add_shopping_cart,
                color: AppColors.primaryColor, size: 20.sp),
            onPressed: () {
              _addToCart(context);
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 24, minHeight: 24),
          );
        }

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                icon: Icon(Icons.remove,
                    color: AppColors.primaryColor, size: 20.sp),
                onPressed: () => _decrementQuantity(context, cartItem),
              ),
              Text(
                '$quantity',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                icon:
                    Icon(Icons.add, color: AppColors.primaryColor, size: 20.sp),
                onPressed: quantity >= stock
                    ? null
                    : () => _incrementQuantity(context, cartItem),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<EmailAuthProvider>(context, listen: false);

    if (stock <= 0) {
      ShowToastDialog.show(
        context,
        "This item is out of stock",
        type: ToastType.error,
      );
      return;
    }

    if (authProvider.user?.id == null) {
      ShowToastDialog.show(
        context,
        "Login before shopping",
        type: ToastType.error,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInWithEmail()),
      );
      return;
    }

    // Use discounted price if available
    double finalPrice = price;
    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final product = productProvider.getProductById(productId);
      if (product != null &&
          product.discountPrice != null &&
          product.discountPrice > 0) {
        finalPrice = product.discountPrice.toDouble();
      }
    } catch (e) {}

    try {
      await cartProvider.postAddedCart(
        context,
        productId,
        variationId,
        1,
        finalPrice,
        finalPrice,
      );
      if (onQuantityChanged != null) {
        onQuantityChanged!();
      }
    } catch (e) {
      ShowToastDialog.show(
        context,
        "Failed to add item to cart",
        type: ToastType.error,
      );
    }
  }

  void _incrementQuantity(BuildContext context, dynamic cartItem) {
    if (cartItem == null) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final index = cartProvider.cartModel!.cart!.indexOf(cartItem);
    final newQuantity = (cartItem.quantity ?? 1) + 1;

    if (newQuantity > stock) {
      ShowToastDialog.show(
        context,
        "Cannot add more items. Stock limit reached.",
        type: ToastType.error,
      );
      return;
    }

    cartProvider.updateQuantity(index, newQuantity, productId);
    if (onQuantityChanged != null) {
      onQuantityChanged!();
    }
  }

  void _decrementQuantity(BuildContext context, dynamic cartItem) {
    if (cartItem == null) return;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final index = cartProvider.cartModel!.cart!.indexOf(cartItem);
    final currentQuantity = cartItem.quantity ?? 1;
    if (currentQuantity > 1) {
      cartProvider.updateQuantity(index, currentQuantity - 1, productId);
    } else {
      cartProvider.deleteCart(productId);
    }
    if (onQuantityChanged != null) {
      onQuantityChanged!();
    }
  }
}
