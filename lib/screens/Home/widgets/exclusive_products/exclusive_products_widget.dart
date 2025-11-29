import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:e_Home_app/Utils/constants/app_colors.dart';
import 'package:e_Home_app/models/home screen/exclusive_product_model.dart';
import 'package:e_Home_app/screens/Home/widgets/exclusive_products/widgets/exclusive_products_more_screen.dart';
import 'package:e_Home_app/screens/ProductDetail/product_details_screen.dart';
import 'package:e_Home_app/models/product/product_model.dart';
import 'package:e_Home_app/global%20widgets/product%20card/product_card.dart';

import '../../../../global widgets/product card/product_card_data.dart';

class ExclusiveProductsWidget extends StatelessWidget {
  final List<ExclusiveProductModel> products;

  const ExclusiveProductsWidget({
    super.key,
    required this.products,
  });

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

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exclusive Products',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExclusiveProductsMoreScreen(products: products),
                    ),
                  );
                },
                child: Text(
                  'More',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: AppColors.scaffoldColor,
          height: 230.h,
          child: Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                cacheExtent: 1000,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: SizedBox(
                      width: 170.w,
                      child: RepaintBoundary(
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
                                ?.map((t) => t.tagName)
                                .whereType<String>()
                                .toList(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    product: convertToProductModel(product),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (products.length > 4)
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
          ),
        ),
      ],
    );
  }
}
