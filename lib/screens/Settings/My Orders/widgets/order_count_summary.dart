import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../Utils/constants/app_colors.dart';
import '../provider/my_orders_screen_provider.dart';

class OrderCountSummary extends StatelessWidget {
  const OrderCountSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrdersScreenProvider>(
      builder: (context, provider, child) {
        final totalOrders = provider.ordersModel?.orders?.length ?? 0;
        final filteredCount = provider.filteredOrders?.length ?? totalOrders;

        if (totalOrders == 0) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: AppColors.greyColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 20.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                filteredCount == totalOrders
                    ? 'Total Orders: $totalOrders'
                    : 'Showing $filteredCount of $totalOrders orders',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
