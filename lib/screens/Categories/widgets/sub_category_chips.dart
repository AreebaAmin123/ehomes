import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/category/categories_model.dart';

class SubCategoryChips extends StatelessWidget {
  final List<CategoryModel> subCategories;
  final CategoryModel selectedSubCategory;
  final Function(CategoryModel) onSubCategorySelected;

  const SubCategoryChips({
    super.key,
    required this.subCategories,
    required this.selectedSubCategory,
    required this.onSubCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = subCategories[index];
          final isSelected = subCategory.id == selectedSubCategory.id;

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                subCategory.name,
                style: TextStyle(
                  color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              backgroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.whiteColor,
                  width: 0,
                ),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  onSubCategorySelected(subCategory);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
