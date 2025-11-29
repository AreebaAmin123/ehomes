import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/my_order_model.dart';
import '../../Settings/My Orders/provider/my_orders_provider.dart';
import '../../Settings/TrackOrder/track_order_screen.dart';
import '../../Settings/My Orders/my_orders_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const OrderDetailsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String? _selectedStatus;

  final List<String> _statusFilters = [
    'All Orders',
    'Pending',
    'Delivered',
    'Cancelled',
    'Processing',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = 'All Orders';
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          '${widget.userName}\'s Orders',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
        ),
      ),
      body: Consumer<MyOrdersProvider>(
        builder: (context, provider, child) {
          if (provider.myOrderModel == null) {
            return Center(child: CupertinoActivityIndicator());
          }
          final allOrders = provider.myOrderModel!.orders!;
          final filteredOrders = _getFilteredOrders(allOrders);
          return Column(
            children: [
              /// Filter Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                color: AppColors.whiteColor,
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: AppColors.greyColor),
                    SizedBox(width: 8.w),
                    Text(
                      'Filter by Status',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primaryColor
                                  .withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: AppColors.whiteColor,
                            value: _selectedStatus,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: AppColors.primaryColor),
                            items: _statusFilters.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStatus = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Order Count
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                child: Row(
                  children: [
                    Text(
                      _selectedStatus == 'All Orders'
                          ? 'All ${filteredOrders.length} orders'
                          : '$_selectedStatus ${filteredOrders.length} orders',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              /// Orders List
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64.sp,
                              color: AppColors.greyColor,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No ${_selectedStatus?.toLowerCase()} orders found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        color: AppColors.primaryColor,
                        child: ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.greyColor.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Order ID and Date
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _copyOrderId(order.orderId ?? ''),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Order #${order.orderId}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15.sp,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              SizedBox(width: 4.w),
                                              Icon(
                                                Icons.copy_outlined,
                                                size: 16.sp,
                                                color: AppColors.greyColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatDate(order.orderDate),
                                        style: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),

                                  // Labels
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Product',
                                          style: TextStyle(
                                            color: AppColors.greyColor,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Quantity',
                                          style: TextStyle(
                                            color: AppColors.greyColor,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Total',
                                            style: TextStyle(
                                              color: AppColors.greyColor,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),

                                  // Product Details
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          order.productName ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${order.quantity ?? 0}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Rs. ${order.finalTotal ?? 0}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.sp,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),

                                  // Order Status
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.orderStatus)
                                          .withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      order.orderStatus?.toLowerCase() ??
                                          'processing',
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrackOrderScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.local_shipping_outlined, size: 20.sp),
                label: Text(
                  'Track Order',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrdersScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.receipt_outlined, size: 20.sp),
                label: Text(
                  'All Orders',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whiteColor,
                  foregroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadOrders() async {
    final provider = Provider.of<MyOrdersProvider>(context, listen: false);
    await provider.getMyOrders(context);
  }

  List<Orders> _getFilteredOrders(List<Orders> orders) {
    // First exclude delivered orders
    orders = orders
        .where((order) => order.orderStatus?.toLowerCase() != 'delivered')
        .toList();

    // Then apply status filter if selected
    if (_selectedStatus == 'All Orders') return orders;
    return orders
        .where((order) =>
            order.orderStatus?.toLowerCase() == _selectedStatus?.toLowerCase())
        .toList();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr; // Return original string if parsing fails
    }
  }

  void _copyOrderId(String orderId) {
    Clipboard.setData(ClipboardData(text: orderId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order ID copied to clipboard',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
        return AppColors.greenColor;
      case 'cancelled':
        return AppColors.redColor;
      case 'processing':
        return AppColors.orangeColor;
      case 'shipped':
        return AppColors.blueColor;
      default:
        return AppColors.primaryColor;
    }
  }
}
