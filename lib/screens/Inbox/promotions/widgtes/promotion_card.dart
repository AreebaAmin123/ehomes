import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../../../../models/promotion_model.dart';
import '../../../../models/product/product_model.dart';
import '../../../../screens/ProductDetail/product_details_screen.dart';

class PromotionCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String offerText;
  final String validity;
  final List<PromotionProductModel> products;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const PromotionCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.offerText,
    required this.validity,
    required this.products,
    this.onTap,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 12,
  });

  ProductModel convertToProductModel(PromotionProductModel product) {
    return ProductModel(
      productId: product.productId,
      productName: product.productName,
      brandName: '',
      price: 0,
      discountPrice: 0,
      description: '',
      stock: 0,
      categories: [],
      images: imageUrl.isNotEmpty ? [imageUrl] : [],
      variations: [],
      tags: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.boxShadowColor.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: padding ?? EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Image with Discount Badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl.isNotEmpty
                              ? imageUrl
                              : 'https://via.placeholder.com/400x200?text=No+Image',
                          height: 110.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.lightGreyColor,
                            child: const Center(
                                child: CupertinoActivityIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.lightGreyColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported,
                                    color: AppColors.greyColor),
                                SizedBox(height: 4.h),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Product Name
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  // Product Variant (if available)
                  if (products.isNotEmpty)
                    Text(
                      products.first.productName,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.greyColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 3.h),
                  // Validity Period
                  Row(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 12.sp,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          validity,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.greyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
