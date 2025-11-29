// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_const_literals_to_create_immutables

import 'package:e_Home_app/screens/Categories/provider/product_provider.dart';
import 'package:e_Home_app/screens/Home/provider/search_bar_provider.dart';
import 'package:e_Home_app/screens/ProductDetail/product_details_screen.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:e_Home_app/models/search_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const SearchOverlay({super.key, required this.onClose});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        setState(() => _isSearching = true);
        Provider.of<SearchBarProvider>(context, listen: false)
            .searchQuery(query)
            .then((_) {
          if (mounted) setState(() => _isSearching = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget buildSearchBar() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 16.sp, color: Colors.black87),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          Provider.of<SearchBarProvider>(context, listen: false)
                              .searchQuery('');
                        },
                        child: Icon(Icons.close, color: Colors.grey[600]),
                      )
                    : null,
                hintText: 'Search for products, brands, or categories...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryFilters() {
    final searchProvider = Provider.of<SearchBarProvider>(context);
    final categories = searchProvider.categories;

    if (categories.length <= 1) return SizedBox.shrink();

    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == searchProvider.selectedCategory;

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  searchProvider.setCategory(category);
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
            ),
          );
        },
      ),
    );
  }

  Widget buildResults() {
    final searchModel = Provider.of<SearchBarProvider>(context).searchModel;

    if (_isSearching) {
      return Center(child: CupertinoActivityIndicator());
    }

    if (searchModel == null ||
        (searchModel.products?.isEmpty ?? true) &&
            (searchModel.brands?.isEmpty ?? true) &&
            (searchModel.categories?.isEmpty ?? true)) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off,
                  color: AppColors.primaryColor, size: 80.sp),
              SizedBox(height: 24.h),
              Text(
                "No results found!",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Try searching for something else, or check your spelling.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
      children: [
        if (searchModel.products?.isNotEmpty ?? false) ...[
          _buildSectionTitle('Products'),
          ...searchModel.products!.map((product) => _buildProductItem(product)),
          SizedBox(height: 16.h),
        ],
        if (searchModel.brands?.isNotEmpty ?? false) ...[
          _buildSectionTitle('Brands'),
          ...searchModel.brands!.map((brand) => _buildBrandItem(brand)),
          SizedBox(height: 16.h),
        ],
        if (searchModel.categories?.isNotEmpty ?? false) ...[
          _buildSectionTitle('Categories'),
          ...searchModel.categories!
              .map((category) => _buildCategoryItem(category)),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildProductItem(Products product) {
    return GestureDetector(
      onTap: () async {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final productId = product.productId ?? 0;

        await productProvider.searchProducts(productId);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: productProvider.productModel!,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (product.imageUrl?.isNotEmpty ?? false)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl!,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.error_outline, color: Colors.grey[400]),
                  ),
                ),
              )
            else
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName ?? 'Unnamed Product',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (product.brandName?.isNotEmpty ?? false) ...[
                    SizedBox(height: 4.h),
                    Text(
                      product.brandName!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (product.discountPrice != null &&
                          product.discountPrice! > 0) ...[
                        Text(
                          'Rs. ${product.discountPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Rs. ${product.price!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else if (product.price != null) ...[
                        Text(
                          'Rs. ${product.price!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandItem(Brand brand) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (brand.imageUrl?.isNotEmpty ?? false)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: brand.imageUrl!,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.error_outline, color: Colors.grey[400]),
                ),
              ),
            )
          else
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.business, color: Colors.grey[400]),
            ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              brand.brandName ?? 'Unnamed Brand',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16.sp, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (category.imageUrl?.isNotEmpty ?? false)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: category.imageUrl!,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.error_outline, color: Colors.grey[400]),
                ),
              ),
            )
          else
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.category, color: Colors.grey[400]),
            ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              category.categoryName ?? 'Unnamed Category',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16.sp, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.96),
        child: SafeArea(
          child: Column(
            children: [
              buildSearchBar(),
              buildCategoryFilters(),
              Expanded(child: buildResults()),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: widget.onClose,
                child: Text(
                  "Close",
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
