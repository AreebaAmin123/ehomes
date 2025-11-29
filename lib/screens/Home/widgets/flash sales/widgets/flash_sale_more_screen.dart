import 'package:e_Home_app/models/product/product_model.dart';
import 'package:e_Home_app/models/product/variation_model.dart';
import 'package:e_Home_app/screens/Home/provider/home_provider.dart';
import 'package:e_Home_app/screens/ProductDetail/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../../Utils/constants/app_colors.dart';
import '../../../../../global widgets/product card/product_card.dart';
import '../../../../../global widgets/product card/product_card_data.dart';
import '../../../../../models/home screen/tag_product_model.dart';
import '../../../../../global widgets/cart_badge.dart';
import '../../../../Cart/cart_screen.dart';

class FlashSaleMoreScreen extends StatefulWidget {
  final String tagName;
  final int tagId;

  const FlashSaleMoreScreen(
      {super.key, required this.tagId, required this.tagName});

  @override
  State<FlashSaleMoreScreen> createState() => _FlashSaleMoreScreenState();
}

class _FlashSaleMoreScreenState extends State<FlashSaleMoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final allProducts = provider.tagProductModel?.products ?? [];
    final filteredProducts = allProducts.where((product) {
      final matchesTag = product.tags != null &&
          product.tags!.any((tag) => tag.tagId == widget.tagId);
      final matchesSearch = _searchQuery.isEmpty ||
          (product.productName
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesTag && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.tagName,
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
              child: filteredProducts.isEmpty
                  ? Center(child: Text('No products found.'))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.57,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        double price =
                            double.tryParse(product.price ?? "0") ?? 0;
                        double discountPrice =
                            double.tryParse(product.discountPrice ?? "0") ?? 0;
                        return SizedBox(
                          height: 250.h,
                          child: ProductCard(
                            data: ProductCardData(
                              productId: product.productId ?? 0,
                              imageUrl: product.images?.first ?? '',
                              title: product.productName ?? 'Unknown',
                              price: price.toInt(),
                              stock: product.stock ?? 0,
                              discountPrice:
                                  (discountPrice > 0 && discountPrice < price)
                                      ? discountPrice.toInt()
                                      : null,
                              tags: product.tags
                                  ?.map((t) => t.tagName)
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

  ProductModel convertToProductModel(Products product) {
    return ProductModel(
      productId: product.productId ?? 0,
      vendorId: product.vendorId,
      productName: product.productName ?? '',
      brandName: product.brandName ?? '',
      price: parseInt(product.price),
      discountPrice: parseInt(product.discountPrice),
      description: product.description ?? '',
      stock: product.stock ?? 0,
      categories: product.categories ?? [],
      images: product.images ?? [],
      variations: product.variations?.map((v) {
            return VariationModel(
              variationId: v.variationId ?? 0,
              variationName: v.variationName ?? '',
              variationValue: v.variationValue ?? '',
              price: parseDouble(v.price),
              stock: v.stock ?? 0,
              imageUrl: v.imageUrl ?? '',
            );
          }).toList() ??
          [],
      tags: product.tags
              ?.map((t) => TagModel(
                    tagId: t.tagId ?? 0,
                    tagName: t.tagName ?? '',
                  ))
              .toList() ??
          [],
    );
  }

  int parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  double parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
