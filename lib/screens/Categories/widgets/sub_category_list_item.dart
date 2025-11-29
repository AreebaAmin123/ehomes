import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/category/categories_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SubCategoryListItem extends StatelessWidget {
  final CategoryModel subCategory;
  final VoidCallback onTap;

  const SubCategoryListItem({
    super.key,
    required this.subCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Material(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14.r),
        elevation: 1,
        shadowColor: AppColors.boxShadowColor.withOpacity(0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.greyColor.withOpacity(0.13),
                width: 1,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                // Image on the left
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl: subCategory.fixedIcon,
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      width: 50.w,
                      height: 50.h,
                      color: AppColors.greyColor.withOpacity(0.15),
                      child: Icon(Icons.image_outlined, color: AppColors.greyColor, size: 24.sp),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 50.w,
                      height: 50.h,
                      color: AppColors.greyColor.withOpacity(0.15),
                      child: Icon(Icons.broken_image_outlined, color: AppColors.greyColor, size: 24.sp),
                    ),
                  ),
                ),
                SizedBox(width: 18.w),
                // Text content
                Expanded(
                  child: Text(
                    subCategory.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.chevron_right, color: AppColors.primaryColor, size: 24.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}