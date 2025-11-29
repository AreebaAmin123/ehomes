import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../../../Categories/provider/category_provider.dart';
import '../../../Categories/sub_category_product_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/category/categories_model.dart';

class DirectCategoriesWidget extends StatefulWidget {
  final bool showSearchBar;
  const DirectCategoriesWidget({super.key, this.showSearchBar = false});

  @override
  State<DirectCategoriesWidget> createState() => _DirectCategoriesWidgetState();
}

class _DirectCategoriesWidgetState extends State<DirectCategoriesWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> _filterCategories(List<CategoryModel> categories) {
    if (_searchQuery.isEmpty) return categories;
    return categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        cursorColor: AppColors.primaryColor,
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.blackColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                );
              },
            ),
          );
        }

        // Get categories that have no subcategories but have products
        final directCategories = categoryProvider.categories.where((category) {
          final isLeaf = category.isLeaf;
          final hasProducts = category.hasProducts;
          return isLeaf && hasProducts;
        }).toList();

        if (directCategories.isEmpty) {
          debugPrint('DirectCategoriesWidget - No direct categories found');
          return const SizedBox.shrink();
        }

        final filteredCategories = _filterCategories(directCategories);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Shop by Choice',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            if (widget.showSearchBar) _buildSearchBar(),
            if (filteredCategories.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'No categories found',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return _buildCategoryTile(context, category);
                  },
                ),
              ),
            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTile(BuildContext context, CategoryModel category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubCategoryProductListScreen(
              subCategory: category,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        width: 100.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.boxShadowColor,
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: CachedNetworkImage(
                  imageUrl: category.fixedIcon,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12.r)),
              ),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
