import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../Utils/constants/app_colors.dart';
import '../../../../models/my_order_model.dart';
import '../provider/my_orders_screen_provider.dart';

class OrderCard extends StatelessWidget {
  final Orders order;

  const OrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MyOrdersScreenProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, provider),
          if (order.productName != null && order.productName!.isNotEmpty)
            _buildProductDetails(provider),
          _buildPriceDetails(provider),
          if (provider.hasCustomerDetails(order))
            _buildCustomerDetails(provider),
          _buildOrderStatus(provider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MyOrdersScreenProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  'Order #${order.orderId}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: order.orderId ?? ''),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Order ID copied to clipboard!'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.copy,
                    size: 16.sp,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            provider.formatDate(order.orderDate),
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(MyOrdersScreenProvider provider) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          _buildDetailRow('Product', order.productName!),
          if (order.variation?.name != null &&
              order.variation!.name!.isNotEmpty)
            _buildDetailRow('Variation', order.variation!.name!),
          _buildDetailRow('Quantity', order.quantity.toString()),
          Divider(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(MyOrdersScreenProvider provider) {
    // Calculate the effective price (price after product discount)
    final effectivePrice =
        order.discountPrice != null && order.discountPrice! > 0
            ? order.discountPrice!
            : order.price!;

    // Calculate total before coupon
    final totalBeforeCoupon = effectivePrice * (order.quantity ?? 1);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),

          // Show original price if there's a discount
          if (order.discountPrice != null &&
              order.discountPrice! > 0 &&
              order.discountPrice! < order.price!)
            _buildPriceRow('Original Price', order.price),

          // Show effective price (after product discount)
          _buildPriceRow(
            order.discountPrice != null &&
                    order.discountPrice! > 0 &&
                    order.discountPrice! < order.price!
                ? 'Discounted Price'
                : 'Price',
            effectivePrice,
          ),

          // Show quantity and subtotal
          _buildPriceRow('Quantity', order.quantity),
          _buildPriceRow('Subtotal', totalBeforeCoupon),

          // Show coupon discount if applicable
          if (order.couponCode != null && order.couponCode!.isNotEmpty) ...[
            _buildDetailRow('Coupon Code', order.couponCode!),
            if (order.couponAmount != null && order.couponAmount! > 0)
              _buildPriceRow('Coupon Discount', order.couponAmount),
          ],

          // Show shipping charge
          if (order.shippingCharge != null && order.shippingCharge! > 0)
            _buildPriceRow('Shipping Charge', order.shippingCharge),

          Divider(height: 16.h),

          // Show final total
          _buildPriceRow('Total Amount', order.finalTotal, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(MyOrdersScreenProvider provider) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          if (order.firstName != null || order.lastName != null)
            _buildDetailRow(
              'Name',
              '${order.firstName ?? ''} ${order.lastName ?? ''}'.trim(),
            ),
          if (order.email != null && order.email!.isNotEmpty)
            _buildDetailRow('Email', order.email!),
          if (order.phone != null && order.phone!.isNotEmpty)
            _buildDetailRow('Phone', order.phone!),
          if (provider.hasAddress(order))
            _buildDetailRow(
              'Address',
              provider.formatAddress(order),
            ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(MyOrdersScreenProvider provider) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: provider.getStatusColor(order.orderStatus),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            provider.getStatusIcon(order.orderStatus),
            color: AppColors.whiteColor,
            size: 16.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            order.orderStatus?.toUpperCase() ?? 'PENDING',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.greyColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, dynamic amount, {bool isTotal = false}) {
    // Format the amount based on its type
    String formattedAmount;
    if (amount is String) {
      formattedAmount = amount;
    } else if (amount is int || amount is double) {
      formattedAmount = amount.toString();
    } else {
      formattedAmount = '0';
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isTotal ? AppColors.blackColor : AppColors.greyColor,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            'Rs. $formattedAmount',
            style: TextStyle(
              fontSize: 13.sp,
              color: isTotal ? AppColors.primaryColor : AppColors.blackColor,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
