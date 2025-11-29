import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../models/category/categories_model.dart';
import '../../../global widgets/product card/product_card.dart';
import '../../../global widgets/product card/product_card_data.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../ProductDetail/product_details_screen.dart';

class CategoryProductsList extends StatelessWidget {
  final CategoryModel category;
  final List<dynamic> products;

  const CategoryProductsList({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48.sp,
              color: AppColors.greyColor.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final imageUrl = product.images.isNotEmpty
            ? product.images[0].startsWith('http')
                ? product.images[0]
                : 'Vendor_Panel/uploads/${product.images[0]}'
            : '';

        return ProductCard(
          data: ProductCardData(
            productId: product.productId,
            imageUrl: imageUrl,
            title: product.productName,
            price: product.price,
            stock: product.stock,
            discountPrice: product.discountPrice,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
          ),
          width: double.infinity,
          height: 250.h,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(8.w),
        );
      },
    );
  }
}
