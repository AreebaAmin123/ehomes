import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../screens/Cart/provider/cart_provider.dart';
import '../Utils/constants/app_colors.dart';

class CartBadge extends StatelessWidget {
  final Widget child;
  final double? top;
  final double? left;
  final double? badgeSize;
  final double? fontSize;

  const CartBadge({
    Key? key,
    required this.child,
    this.top,
    this.left,
    this.badgeSize,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final itemCount = cartProvider.cartItemCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (itemCount > 0)
              Positioned(
                top: top ?? -5.h,
                left: left ?? -5.w,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: AppColors.redColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: badgeSize ?? 16.w,
                    minHeight: badgeSize ?? 16.w,
                  ),
                  child: Center(
                    child: Text(
                      itemCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize ?? 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
