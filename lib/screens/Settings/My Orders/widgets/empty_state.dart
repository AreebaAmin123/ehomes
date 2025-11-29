import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Utils/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  const EmptyState({
    super.key,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48.sp,
            color: AppColors.greyColor,
          ),
          SizedBox(height: 16.h),
          Text(
            hasActiveFilters
                ? 'No orders match your filters'
                : 'No orders found',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.greyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasActiveFilters) ...[
            SizedBox(height: 8.h),
            TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear filters'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
