import 'package:e_Home_app/screens/Settings/TrackOrder/provider/track_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../Settings/My Orders/my_orders_screen.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  TextEditingController orderIdController = TextEditingController();

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showOrderDetailsDialog(context) {
    final order = Provider.of<TrackOrderProvider>(context, listen: false)
        .trackOrderModel
        ?.order;
    if (order == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.whiteColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final provider = Provider.of<TrackOrderProvider>(context,
                          listen: false);
                      provider.disposeOrder();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: AppColors.greyColor),
                  ),
                ],
              ),
              Divider(height: 24.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        "Order ID", "#${order.orderId ?? '-'}", true),
                    _buildDetailRow("Status", order.orderStatus ?? "-", true),
                    _buildDetailRow("Date", _formatDate(order.orderDate)),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRow("Name", order.productName ?? "-"),
                    _buildDetailRow("Quantity", order.quantity.toString()),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRow("Name",
                        "${order.firstName ?? ''} ${order.lastName ?? ''}"),
                    _buildDetailRow("Phone", order.phone ?? "-"),
                    _buildDetailRow("Email", order.email ?? "-"),
                    _buildDetailRow("Address",
                        "${order.address ?? ''}, ${order.city ?? ''}, ${order.state ?? ''}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [bool isPrimary = false]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                color:
                    isPrimary ? AppColors.primaryColor : AppColors.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor.withOpacity(0.5),
      appBar: AppBar(
        title: Text(
          'Track Order',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20.h),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Your Order',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
            Text(
                    'Enter your order ID to see real-time status',
              style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.whiteColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(20.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            TextField(
              controller: orderIdController,
              decoration: InputDecoration(
                      labelText: 'Order ID',
                      hintText: 'Enter your order ID',
                      prefixIcon: Icon(Icons.local_shipping_outlined,
                          color: AppColors.primaryColor),
                filled: true,
                      fillColor: AppColors.scaffoldColor.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.h, horizontal: 16.w),
              ),
            ),
                  SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                  ),
                        elevation: 0,
                ),
                onPressed: () async {
                        final provider = Provider.of<TrackOrderProvider>(
                            context,
                            listen: false);
                  String orderId = orderIdController.text.trim();

                  if (orderId.isNotEmpty) {
                    await provider.trackOrder(orderId);
                    if (provider.trackOrderModel?.order != null) {
                      _showOrderDetailsDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No order found with this ID'),
                          backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter your Order ID'),
                        backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                      ),
                    );
                  }
                },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                  'Track Order',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
            Row(
              children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: AppColors.primaryColor,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                                'You can find your order ID in the confirmation email or SMS we sent you.',
                                style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrdersScreen(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View All Orders',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.primaryColor,
                                size: 14.sp,
                              ),
                            ],
                  ),
                ),
              ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
