import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../provider/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class CartItemCard extends StatelessWidget {
  final dynamic cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final image = (cartItem.imageUrl != null &&
            cartItem.imageUrl!.isNotEmpty &&
            (cartItem.imageUrl!.startsWith('http') ||
                cartItem.imageUrl!.startsWith('https')))
        ? cartItem.imageUrl!
        : '';
    debugPrint(
        'CartItemCard: productId=${cartItem.productId}, imageUrl=$image');
    final quantity = cartItem.quantity ?? 0;
    final productPrice = double.tryParse(cartItem.effectivePrice) ?? 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.40), width: 1.2.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: image,
                      width: 64.w,
                      height: 64.w,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const Center(child: CupertinoActivityIndicator()),
                      errorWidget: (context, url, error) => Container(
                        width: 64.w,
                        height: 64.w,
                        color: AppColors.greyColor,
                        child: Icon(Icons.broken_image,
                            color: Colors.grey, size: 32.sp),
                      ),
                    )
                  : Container(
                      width: 64.w,
                      height: 64.w,
                      color: AppColors.greyColor,
                      child: Icon(Icons.image,
                          color: AppColors.greyColor, size: 32.sp),
                    ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.productName ?? "Unknown Product",
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  "PKR ${productPrice.toStringAsFixed(0)}",
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      color: AppColors.primaryColor,
                      onTap: () => _decrementQuantity(context),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '$quantity',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor),
                    ),
                    SizedBox(width: 12.w),
                    _QuantityButton(
                      icon: Icons.add,
                      color: AppColors.primaryColor,
                      onTap: () => _incrementQuantity(context),
                    ),
                    SizedBox(width: 18.w),
                    _DeleteButton(
                      onTap: () => _deleteItem(context),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(Icons.local_shipping,
                        color: AppColors.blueColor, size: 18.sp),
                    SizedBox(width: 6.w),
                    Text(
                      "Free Delivery",
                      style: TextStyle(fontSize: 13.sp, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _incrementQuantity(BuildContext context) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final newQuantity = (cartItem.quantity ?? 1) + 1;
    provider.updateQuantity(provider.cartModel!.cart!.indexOf(cartItem),
        newQuantity, cartItem.productId!);
  }

  void _decrementQuantity(BuildContext context) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final currentQuantity = cartItem.quantity ?? 1;
    if (currentQuantity > 1) {
      provider.updateQuantity(provider.cartModel!.cart!.indexOf(cartItem),
          currentQuantity - 1, cartItem.productId!);
    } else {
      provider.deleteCart(cartItem.productId!);
    }
  }

  void _deleteItem(BuildContext context) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    provider.deleteCart(cartItem.productId!);
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25.w,
        height: 25.w,
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color, width: 0.9.w),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: color, size: 18.sp),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        margin: EdgeInsets.only(left: 4.w),
        decoration: BoxDecoration(
          color: AppColors.redColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.redColor, width: 0.9.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.redColor.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.delete, color: AppColors.redColor, size: 18.sp),
        ),
      ),
    );
  }
}
