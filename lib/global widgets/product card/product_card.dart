import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Utils/constants/app_colors.dart';
import 'product_card_data.dart';
import '../../screens/ProductDetail/widgets/cart_action_button.dart';

class ProductCard extends StatelessWidget {
  final ProductCardData data;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Widget? trailing;
  final int? variationId;
  final VoidCallback? onQuantityChanged;

  const ProductCard({
    super.key,
    required this.data,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 12,
    this.trailing,
    this.variationId,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        data.discountPrice != null && data.discountPrice! < data.price;
    final savedAmount = hasDiscount ? (data.price - data.discountPrice!) : null;
    final discountPercent = hasDiscount
        ? (((data.price - data.discountPrice!) / data.price) * 100).round()
        : null;

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
              color: AppColors.boxShadowColor.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: data.onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: padding ?? EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: _buildImage(),
                            ),
                            SizedBox(height: 4.h),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: _buildTitle(),
                            ),
                            if (data.vendorName != null)
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: Text(
                                  data.vendorName!,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.greyColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasDiscount &&
                          (savedAmount != null && savedAmount > 0 ||
                              (discountPercent != null && discountPercent > 0)))
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Row(
                            children: [
                              if (savedAmount != null && savedAmount > 0)
                                Flexible(
                                  child: _buildBadge(
                                      'Rs.${savedAmount.round()}',
                                      AppColors.redColor),
                                ),
                              if (discountPercent != null &&
                                  discountPercent > 0)
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: _buildBadge('$discountPercent% OFF',
                                        AppColors.redColor),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      _buildPriceSection(),
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildImage() {
    String? imageUrl = data.imageUrl;

    // Validate and fix image URL
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        // If it's already a full URL, return as is
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
          return _buildNetworkImage(imageUrl);
        }

        // Clean the URL
        imageUrl = imageUrl.trim().replaceAll(RegExp(r'/$'), '');

        // Handle different image paths
        if (imageUrl.contains('admin_panel')) {
          imageUrl = imageUrl.replaceAll('admin_panel', 'Vendor_Panel');
        }

        // Construct final URL
        final baseUrl = 'https://ehomes.pk';
        final finalUrl = '$baseUrl/$imageUrl';

        return _buildNetworkImage(finalUrl);
      } catch (e) {
        debugPrint('Error processing image URL: $e');
        return _buildErrorWidget();
      }
    } else {
      return _buildErrorWidget();
    }
  }

  Widget _buildNetworkImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        memCacheHeight: 400,
        maxHeightDiskCache: 800,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.contain,
            ),
          ),
        ),
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) {
          debugPrint('Image Error: $error for URL: $url');
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.greyColor.withOpacity(0.5),
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            'Image not available',
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.greyColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      data.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
    );
  }

  Widget _buildPriceSection() {
    final hasDiscount =
        data.discountPrice != null && data.discountPrice! < data.price;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Price Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Regular price (crossed out if there's a discount)
              Text(
                'Rs. ${data.price}',
                style: TextStyle(
                  fontSize: hasDiscount ? 11.sp : 14.sp,
                  fontWeight: hasDiscount ? FontWeight.normal : FontWeight.bold,
                  decoration: hasDiscount ? TextDecoration.lineThrough : null,
                  color:
                      hasDiscount ? AppColors.greyColor : AppColors.greenColor,
                ),
              ),

              // Discounted price (if available)
              if (hasDiscount) ...[
                SizedBox(height: 2.h),
                Text(
                  'Rs. ${data.discountPrice}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Cart Action Button
        CartActionButton(
          productId: data.productId,
          price: data.price.toDouble(),
          stock: data.stock,
          variationId: variationId,
          onQuantityChanged: onQuantityChanged,
        ),
      ],
    );
  }
}
