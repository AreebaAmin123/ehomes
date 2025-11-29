import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' show min, max;
import '../../../Utils/constants/app_colors.dart';
import '../../../global widgets/product card/product_card.dart';
import '../../../global widgets/product card/product_card_data.dart';
import '../../../models/product/product_model.dart';
import '../../Categories/provider/product_provider.dart';
import '../product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Data class for compute
class _RecommendationData {
  final List<ProductModel> allProducts;
  final ProductModel currentProduct;

  _RecommendationData({
    required this.allProducts,
    required this.currentProduct,
  });
}

class ProductRecommendations extends StatefulWidget {
  final ProductModel product;
  final bool showTitle;
  final bool showSeeAll;

  const ProductRecommendations({
    Key? key,
    required this.product,
    this.showTitle = true,
    this.showSeeAll = true,
  }) : super(key: key);

  @override
  State<ProductRecommendations> createState() => _ProductRecommendationsState();
}

class _ProductRecommendationsState extends State<ProductRecommendations> {
  bool _isLoading = true;
  List<ProductModel> _recommendations = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      Future.microtask(() => _initialize());
    }
  }

  Future<void> _initialize() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);

      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      const defaultCategory = "1";

      // Get products from cache first
      var products = productProvider.getProducts(defaultCategory);

      // Only fetch if cache is empty
      if (products.isEmpty) {
        products = await productProvider.fetchProducts(defaultCategory);
        if (!mounted) return;
      }

      // Get recommendations using compute
      final recommendationData = _RecommendationData(
        allProducts: products,
        currentProduct: widget.product,
      );

      final recommendations =
          await compute(_getRecommendations, recommendationData);

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      if (mounted) {
        setState(() {
          _recommendations = [];
          _isLoading = false;
        });
      }
    }
  }

  // Static method for compute to calculate recommendations
  static List<ProductModel> _getRecommendations(_RecommendationData data) {
    final currentProduct = data.currentProduct;
    final allProducts = data.allProducts;
    final Map<int, double> productScores = {};

    // Calculate scores for each product
    for (final product in allProducts) {
      // Skip the current product
      if (product.productId == currentProduct.productId) continue;

      double score = 0.0;

      // Category match (using both categoryId and categories list)
      if (product.categoryId == currentProduct.categoryId) {
        score += 3.0; // Increased weight for direct category match
      }

      // Check for category matches in the categories list
      final productCategories = product.categories.toSet();
      final currentProductCategories = currentProduct.categories.toSet();
      final commonCategories =
          productCategories.intersection(currentProductCategories);
      score += commonCategories.length *
          2.0; // Increased weight for category matches

      // Price range match (within 30% range - increased from 20%)
      final priceRatio = product.price / currentProduct.price;
      if (priceRatio >= 0.7 && priceRatio <= 1.3) {
        score += 1.5;
      }

      // Brand match (using both brandId and brandName)
      if (product.brandId == currentProduct.brandId ||
          product.brandName.toLowerCase() ==
              currentProduct.brandName.toLowerCase()) {
        score += 2.0; // Increased weight for brand match
      }

      // Tag matching
      final productTags =
          product.tags.map((t) => t.tagName.toLowerCase()).toSet();
      final currentProductTags =
          currentProduct.tags.map((t) => t.tagName.toLowerCase()).toSet();
      final commonTags = productTags.intersection(currentProductTags);
      score += commonTags.length * 1.5; // Increased weight for tag matches

      // Rating consideration
      score += (product.rating / 5.0) * 0.5; // Reduced weight for rating

      // Stock availability boost
      if (product.stock > 0) {
        score += 0.3; // Reduced weight for stock
      }

      // Discount consideration
      if (product.discountPrice > 0) {
        final discountPercentage =
            ((product.price - product.discountPrice) / product.price) * 100;
        if (discountPercentage > 0) {
          score += 0.3; // Reduced weight for discount
        }
      }

      // Always include products in the same category with a minimum score
      if (product.categoryId == currentProduct.categoryId) {
        score = max(score, 1.0);
      }

      productScores[product.productId] = score;
    }

    // Return all products sorted by score, no minimum score filtering
    return allProducts
        .where((p) => p.productId != currentProduct.productId)
        .toList()
      ..sort((a, b) => (productScores[b.productId] ?? 0)
          .compareTo(productScores[a.productId] ?? 0));
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 250.h,
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 100.h,
      child: Center(
        child: Text(
          'No related products found',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_recommendations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "You May Also Like",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
                if (widget.showSeeAll && _recommendations.length > 6)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductRecommendationsScreen(
                            product: widget.product,
                            recommendations: _recommendations,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(height: 12.h),
        if (widget.showSeeAll)
          // Horizontal scrolling list for main screen
          SizedBox(
            height: 250.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final product = _recommendations[index];
                return Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: SizedBox(
                    width: 160.w,
                    child: ProductCard(
                      data: ProductCardData(
                        productId: product.productId,
                        imageUrl:
                            product.images.isNotEmpty ? product.images[0] : '',
                        title: product.productName,
                        price: product.price,
                        stock: product.stock,
                        discountPrice: (product.discountPrice != null &&
                                product.discountPrice > 0 &&
                                product.discountPrice < product.price)
                            ? product.discountPrice
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          // Vertical list for "See All" screen
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final product = _recommendations[index];
              return Container(
                margin: EdgeInsets.only(bottom: 18.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.40),
                      width: 1.2.w),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: product.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.images[0],
                                width: 64.w,
                                height: 64.w,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator()),
                                errorWidget: (context, url, error) => Container(
                                  width: 64.w,
                                  height: 64.w,
                                  color: AppColors.greyColor,
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey, size: 32.sp),
                                ),
                              )
                            : Container(
                                width: 64.w,
                                height: 64.w,
                                color: AppColors.greyColor,
                                child: Icon(Icons.image,
                                    color: AppColors.greyColor, size: 32.sp),
                              ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Text(
                                "PKR ${product.discountPrice != null ? product.discountPrice : product.price}",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (product.discountPrice != null &&
                                  product.discountPrice < product.price) ...[
                                SizedBox(width: 8.w),
                                Text(
                                  "PKR ${product.price}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.redColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Icon(Icons.local_shipping,
                                  color: AppColors.blueColor, size: 18.sp),
                              SizedBox(width: 6.w),
                              Text(
                                "Free Delivery",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class ProductRecommendationsScreen extends StatelessWidget {
  final ProductModel product;
  final List<ProductModel> recommendations;

  const ProductRecommendationsScreen({
    Key? key,
    required this.product,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Similar Products',
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final product = recommendations[index];
          return ProductCard(
            data: ProductCardData(
              productId: product.productId,
              imageUrl: product.images.isNotEmpty ? product.images[0] : '',
              title: product.productName,
              price: product.price,
              stock: product.stock,
              discountPrice: (product.discountPrice != null &&
                      product.discountPrice > 0 &&
                      product.discountPrice < product.price)
                  ? product.discountPrice
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
