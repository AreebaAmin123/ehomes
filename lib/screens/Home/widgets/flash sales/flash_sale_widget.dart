import 'package:e_Home_app/global%20widgets/product%20card/product_card.dart';
import 'package:e_Home_app/models/product/product_model.dart';
import 'package:e_Home_app/models/product/variation_model.dart';
import 'package:e_Home_app/screens/Home/widgets/flash%20sales/widgets/flash_sale_more_screen.dart';
import 'package:e_Home_app/screens/Home/provider/home_provider.dart';
import 'package:e_Home_app/screens/ProductDetail/product_details_screen.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../global widgets/product card/product_card_data.dart';
import '../../../../models/home screen/tag_product_model.dart';

class FlashSaleWidget extends StatefulWidget {
  const FlashSaleWidget({super.key});

  @override
  State<FlashSaleWidget> createState() => _FlashSaleWidgetState();
}

class _FlashSaleWidgetState extends State<FlashSaleWidget> {
  final Map<int, List<Products>> _cachedFilteredProducts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<HomeProvider>(context, listen: false);
    await provider.getTags();
    if (provider.tagModel != null && provider.tagModel!.tags!.isNotEmpty) {
      // Get products for the first tag by default
      await provider.getTagProducts(provider.tagModel!.tags![0].id!);
      // Pre-cache filtered products
      _precacheFilteredProducts(provider);
      if (mounted) setState(() => _isLoading = false);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _precacheFilteredProducts(HomeProvider provider) {
    final allProducts = provider.tagProductModel?.products ?? [];
    for (final tag in provider.tagModel?.tags ?? []) {
      _cachedFilteredProducts[tag.id!] = allProducts
          .where((product) =>
              product.tags != null &&
              product.tags!.any((t) => t.tagId == tag.id))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (_isLoading ||
            provider.tagModel == null ||
            provider.tagModel!.tags!.isEmpty) {
          return _buildShimmerEffect();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: provider.tagModel!.tags!.length,
          itemBuilder: (context, index) {
            final tag = provider.tagModel!.tags![index];
            return Column(
              children: [
                _buildSectionHeader(context, tag.name!, tag.id!),
                _buildHorizontalProductList(tag.id!)
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String tag, int tagId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tag,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FlashSaleMoreScreen(
                          tagId: tagId,
                          tagName: tag,
                        )),
              );
            },
            child: Text(
              'More',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(int tagId) {
    final filteredProducts = _cachedFilteredProducts[tagId] ?? [];

    return Stack(
      children: [
        SizedBox(
          height: 250.h,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3 / 1.79,
                mainAxisSpacing: 14),
            itemCount: filteredProducts.length,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductCard(product);
            },
          ),
        ),
        if (filteredProducts.length > 4)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 40.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColors.scaffoldColor,
                    AppColors.scaffoldColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.swipe_right_alt,
                  color: AppColors.primaryColor.withValues(alpha: 0.7),
                  size: 24.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(Products product) {
    final price = double.tryParse(product.price ?? "0") ?? 0;
    final discountPrice = double.tryParse(product.discountPrice ?? "0") ?? 0;

    return SizedBox(
      height: 250.h,
      child: ProductCard(
        data: ProductCardData(
          productId: product.productId ?? 0,
          imageUrl: product.images?.first ?? '',
          title: product.productName ?? 'Unknown',
          price: price.toInt(),
          stock: product.stock ?? 0,
          discountPrice: (discountPrice > 0 && discountPrice < price)
              ? discountPrice.toInt()
              : null,
          tags:
              product.tags?.map((t) => t.tagName).whereType<String>().toList(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: _convertToProductModel(product),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ProductModel _convertToProductModel(Products product) {
    return ProductModel(
      productId: product.productId ?? 0,
      vendorId: product.vendorId,
      productName: product.productName ?? '',
      brandName: product.brandName ?? '',
      price: _parseInt(product.price),
      discountPrice: _parseInt(product.discountPrice),
      description: product.description ?? '',
      stock: product.stock ?? 0,
      categories: product.categories ?? [],
      images: product.images ?? [],
      variations: product.variations?.map((v) {
            return VariationModel(
              variationId: v.variationId ?? 0,
              variationName: v.variationName ?? '',
              variationValue: v.variationValue ?? '',
              price: _parseDouble(v.price),
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

  int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, sectionIndex) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 16.h,
                      width: 80.w,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 14.h,
                      width: 40.w,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 245.h,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 3 / 1.79,
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      margin: EdgeInsets.only(right: 10.w),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      width: 140.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 100.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            height: 12.h,
                            width: double.infinity,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            height: 12.h,
                            width: 80.w,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            height: 12.h,
                            width: 60.w,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
