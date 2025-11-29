import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../provider/my_orders_screen_provider.dart';
import 'date_filter_sheet.dart';

class OrderFilters extends StatelessWidget {
  const OrderFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrdersScreenProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatusFilters(context, provider),
              _buildSearchBar(provider),
              SizedBox(height: 12.h),
              _buildDateFilter(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilters(
      BuildContext context, MyOrdersScreenProvider provider) {
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListView.separated(
        controller: provider.statusScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: provider.statusFilters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = provider.statusFilters[index];
          final isSelected = provider.selectedStatus == filter['value'];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                provider.setSelectedStatus(filter['value']);
                provider.scrollToSelectedStatus(index, context);
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? filter['color'].withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? filter['color']
                        : AppColors.greyColor.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      filter['icon'],
                      size: 18.sp,
                      color: isSelected ? filter['color'] : AppColors.greyColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      filter['label'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        color:
                            isSelected ? filter['color'] : AppColors.greyColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(MyOrdersScreenProvider provider) {
    return TextField(
      controller: provider.searchController,
      decoration: InputDecoration(
        hintText: 'Search by Order ID',
        prefixIcon: Icon(Icons.search, color: AppColors.greyColor),
        suffixIcon: provider.searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: AppColors.blackColor),
                onPressed: () {
                  provider.searchController.clear();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide:
              BorderSide(color: AppColors.greyColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide:
              BorderSide(color: AppColors.greyColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildDateFilter(
      BuildContext context, MyOrdersScreenProvider provider) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _showDateFilterSheet(context),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: provider.startDate != null
                      ? AppColors.primaryColor
                      : AppColors.greyColor.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 20.sp,
                    color: provider.startDate != null
                        ? AppColors.primaryColor
                        : AppColors.greyColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      provider.startDate != null && provider.endDate != null
                          ? '${DateFormat('dd MMM').format(provider.startDate!)} - ${DateFormat('dd MMM').format(provider.endDate!)}'
                          : 'Select dates',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: provider.startDate != null
                            ? AppColors.blackColor
                            : AppColors.greyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (provider.searchController.text.isNotEmpty ||
            provider.startDate != null ||
            provider.selectedStatus != null) ...[
          SizedBox(width: 12.w),
          IconButton(
            onPressed: provider.clearFilters,
            icon: Icon(Icons.clear_all, color: AppColors.primaryColor),
            tooltip: 'Clear all filters',
          ),
        ],
      ],
    );
  }

  void _showDateFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const DateFilterSheet(),
    );
  }
}
