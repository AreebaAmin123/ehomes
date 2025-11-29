import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../Utils/constants/app_colors.dart';
import '../provider/my_orders_screen_provider.dart';

class DateFilterSheet extends StatelessWidget {
  const DateFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MyOrdersScreenProvider>();

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildQuickFilters(context),
          const Divider(height: 1),
          _buildCustomRangeButton(context, provider),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
          Text(
            'Select Date Range',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.blackColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Filters',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.greyColor,
            ),
          ),
          SizedBox(height: 12.h),
          _buildQuickFilterOptions(context),
        ],
      ),
    );
  }

  Widget _buildQuickFilterOptions(BuildContext context) {
    final provider = context.read<MyOrdersScreenProvider>();
    final List<Map<String, dynamic>> quickDateRanges = [
      {
        'label': 'Today',
        'range': () {
          final now = DateTime.now();
          return DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: now,
          );
        },
      },
      {
        'label': 'Last 7 days',
        'range': () {
          final now = DateTime.now();
          return DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          );
        },
      },
      {
        'label': 'Last 30 days',
        'range': () {
          final now = DateTime.now();
          return DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          );
        },
      },
      {
        'label': 'This month',
        'range': () {
          final now = DateTime.now();
          return DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          );
        },
      },
    ];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: quickDateRanges.map((range) {
        return InkWell(
          onTap: () {
            final dateRange = range['range']();
            provider.setDateRange(dateRange.start, dateRange.end);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              range['label'],
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomRangeButton(
      BuildContext context, MyOrdersScreenProvider provider) {
    return ListTile(
      onTap: () => _showDateRangePicker(context, provider),
      leading: Icon(Icons.calendar_today, color: AppColors.primaryColor),
      title: Text(
        'Custom Range',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Select specific start and end dates',
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.greyColor,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
    );
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    MyOrdersScreenProvider provider,
  ) async {
    Navigator.pop(context);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.whiteColor,
              surface: AppColors.whiteColor,
              onSurface: AppColors.blackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
    }
  }
}
