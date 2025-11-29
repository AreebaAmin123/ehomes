import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Utils/constants/app_colors.dart';
import '../../models/category/categories_model.dart';
import 'provider/category_provider.dart';
import 'sub_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String? initiallySelectedCategory;

  const CategoriesScreen({super.key, this.initiallySelectedCategory});

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      provider.fetchCategories().then((_) {
        if (widget.initiallySelectedCategory != null) {
          provider.selectCategory(widget.initiallySelectedCategory!);
        } else if (provider.categories.isNotEmpty) {
          provider.selectCategory(provider.categories.first.name);
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Category',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                if (categoryProvider.isLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                final categories = categoryProvider.categories;
                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64.sp,
                          color: AppColors.greyColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "No categories available",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 8.h,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubCategoryScreen(category: category),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: CachedNetworkImage(
                  imageUrl: category.fixedIcon,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                  errorWidget: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 40.sp,
                    color: AppColors.greyColor.withOpacity(0.4),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
