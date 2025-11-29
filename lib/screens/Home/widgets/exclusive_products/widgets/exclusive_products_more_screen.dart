import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:e_Home_app/models/home screen/exclusive_product_model.dart';
import 'package:e_Home_app/screens/ProductDetail/product_details_screen.dart';
import 'package:e_Home_app/models/product/product_model.dart';
import 'package:e_Home_app/models/product/variation_model.dart';
import 'package:e_Home_app/screens/Home/provider/home_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../global widgets/product card/product_card.dart';
import '../../../../../Utils/constants/app_colors.dart';
import '../../../../../global widgets/product card/product_card_data.dart';
import '../../../../../models/home screen/tag_product_model.dart';
import '../../../../../global widgets/cart_badge.dart';
import '../../../../Cart/cart_screen.dart';

class ExclusiveProductsMoreScreen extends StatefulWidget {
  final List<ExclusiveProductModel> products;

  const ExclusiveProductsMoreScreen({Key? key, required this.products})
      : super(key: key);

  @override
  State<ExclusiveProductsMoreScreen> createState() =>
      _ExclusiveProductsMoreScreenState();
}

class _ExclusiveProductsMoreScreenState
    extends State<ExclusiveProductsMoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<ExclusiveProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.products;
    return widget.products
        .where((product) => (product.productName ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          'All Exclusive Products',
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          CartBadge(
            top: 0,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined,
                  color: AppColors.whiteColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          children: [
            _ReusableSearchBar(
              controller: _searchController,
              hintText: 'Search products...',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(child: Text('No exclusive products found.'))
                  : GridView.builder(
                      itemCount: _filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2 / 3.1,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return SizedBox(
                          height: 250.h,
                          child: ProductCard(
                            data: ProductCardData(
                              productId: product.productId ?? 0,
                              imageUrl: product.imageUrl.isNotEmpty
                                  ? 'https://ehomes.pk/Vendor_Panel/uploads/${product.imageUrl}'
                                  : 'https://via.placeholder.com/150',
                              title: product.productName ?? 'Unknown',
                              price: 0,
                              stock: 0,
                              discountPrice: null,
                              tags: product.tags
                                  .map((t) => t.tagName)
                                  .whereType<String>()
                                  .toList(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      product: convertToProductModel(product),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ProductModel convertToProductModel(ExclusiveProductModel product) {
    return ProductModel(
      productId: product.productId,
      vendorId: null,
      productName: product.productName,
      brandName: '',
      price: 0,
      discountPrice: 0,
      description: '',
      stock: 0,
      categories: product.categories.map((e) => e.toString()).toList(),
      images: product.imageUrl.isNotEmpty
          ? ['https://ehomes.pk/Vendor_Panel/uploads/${product.imageUrl}']
          : [],
      variations: [],
      tags: [],
    );
  }
}

class _ReusableSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  const _ReusableSearchBar(
      {required this.controller,
      required this.hintText,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        cursorColor: AppColors.primaryColor,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
