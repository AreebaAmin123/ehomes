import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../Utils/constants/app_colors.dart';
import '../provider/my_orders_screen_provider.dart';
import 'order_card.dart';
import 'order_filters.dart';
import 'order_count_summary.dart';
import 'empty_state.dart';

class MyOrdersContent extends StatefulWidget {
  const MyOrdersContent({super.key});

  @override
  State<MyOrdersContent> createState() => _MyOrdersContentState();
}

class _MyOrdersContentState extends State<MyOrdersContent> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyOrdersScreenProvider>().loadOrders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor.withValues(alpha: 0.4),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'My Orders',
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
      body: Consumer<MyOrdersScreenProvider>(
        builder: (context, provider, child) {
          if (provider.ordersModel == null) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final orders =
              provider.filteredOrders ?? provider.ordersModel?.orders;

          return Column(
            children: [
              const OrderCountSummary(),
              const OrderFilters(),
              Expanded(
                child: orders!.isEmpty
                    ? EmptyState(
                        hasActiveFilters:
                            provider.searchController.text.isNotEmpty ||
                                provider.startDate != null ||
                                provider.selectedStatus != null,
                        onClearFilters: provider.clearFilters,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) =>
                            OrderCard(order: orders[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
