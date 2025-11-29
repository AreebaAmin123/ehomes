// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, curly_braces_in_flow_control_structures

import 'package:e_Home_app/global%20widgets/product%20card/product_card.dart';
import 'package:e_Home_app/models/product/product_model.dart';
import 'package:e_Home_app/models/product/variation_model.dart';
import 'package:e_Home_app/screens/Home/provider/home_provider.dart';
import 'package:e_Home_app/screens/ProductDetail/product_details_screen.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../global widgets/product card/product_card_data.dart';
import '../../../../models/home screen/tag_product_model.dart';

class ForYouSectionWidget extends StatefulWidget {
  const ForYouSectionWidget({super.key});

  @override
  State<ForYouSectionWidget> createState() => _ForYouSectionWidgetState();
}

class _ForYouSectionWidgetState extends State<ForYouSectionWidget>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, ProductModel> _convertedProducts = {};
  List<Products> _filteredProducts = [];
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Implement your pagination logic here
    // For now, we'll just simulate a delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoading = false);
  }

  ProductModel _getConvertedProduct(Products product) {
    final key = '${product.productId}';
    if (_convertedProducts.containsKey(key)) {
      return _convertedProducts[key]!;
    }

    final converted = ProductModel(
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

    _convertedProducts[key] = converted;
    return converted;
  }

  int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String)
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void _updateFilteredProducts(int tagId, List<Products> allProducts) {
    if (_filteredProducts.isEmpty) {
      _filteredProducts = allProducts.where((product) {
        return product.tags != null &&
            product.tags!.any((tag) => tag.tagId == tagId);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          final tagModel = provider.tagModel;
          final tagId = provider.getTagId() ?? 0;

          if (tagModel == null ||
              tagModel.tags == null ||
              tagModel.tags!.isEmpty ||
              provider.tagProductModel == null ||
              provider.tagProductModel!.products == null ||
              provider.tagProductModel!.products!.isEmpty) {
            return _buildShimmerEffect();
          }

          _updateFilteredProducts(tagId, provider.tagProductModel!.products!);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabButtons(provider),
              SizedBox(height: 10.h),
              Flexible(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: CustomScrollView(
                    slivers: [
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.57,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= _filteredProducts.length) return null;

                            final product = _filteredProducts[index];
                            final convertedProduct =
                                _getConvertedProduct(product);
                            String imageUrl = '';

                            if (convertedProduct.images.isNotEmpty) {
                              imageUrl = convertedProduct.images.first;
                              // Convert WebP URLs to JPG
                              if (imageUrl.toLowerCase().endsWith('.webp')) {
                                imageUrl =
                                    '${imageUrl.substring(0, imageUrl.length - 5)}.jpg';
                              }
                            }

                            return RepaintBoundary(
                              child: SizedBox(
                                height: 250.h,
                                child: ProductCard(
                                  data: ProductCardData(
                                    productId: convertedProduct.productId,
                                    imageUrl: imageUrl,
                                    title: convertedProduct.productName,
                                    price: convertedProduct.price,
                                    stock: convertedProduct.stock,
                                    discountPrice:
                                        (convertedProduct.discountPrice !=
                                                    null &&
                                                convertedProduct.discountPrice >
                                                    0 &&
                                                convertedProduct.discountPrice <
                                                    convertedProduct.price)
                                            ? convertedProduct.discountPrice
                                            : null,
                                    tags: convertedProduct.tags
                                            ?.map((t) => t.tagName ?? '')
                                            .toList() ??
                                        [],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailScreen(
                                            product: convertedProduct,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _filteredProducts.length,
                        ),
                      ),
                      if (_isLoading)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(8.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButtons(HomeProvider provider) {
    return Stack(
      children: [
        SizedBox(
          height: 25.h,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: provider.tagModel!.tags!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  provider.selectTag(index);
                  _filteredProducts = [];
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: provider.isSelected(index)
                          ? AppColors.primaryColor
                          : AppColors.scaffoldColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.r),
                        bottomLeft: Radius.circular(12.r),
                      ),
                      boxShadow: provider.isSelected(index)
                          ? [
                              BoxShadow(
                                  color: AppColors.boxShadowColor,
                                  blurRadius: 2)
                            ]
                          : [],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Center(
                        child: Text(
                          "${provider.tagModel!.tags![index].name}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: provider.isSelected(index)
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: provider.isSelected(index)
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (provider.tagModel!.tags!.length > 4)
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
                    AppColors.scaffoldColor.withOpacity(0.0),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.swipe_right_alt,
                  color: AppColors.primaryColor.withOpacity(0.7),
                  size: 24.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 25.h,
          margin: EdgeInsets.symmetric(vertical: 5.h),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                    ),
                  ),
                  width: 80.w,
                  height: 25.h,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 14,
            childAspectRatio: 0.57,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
