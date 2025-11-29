import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/promotion_model.dart';
import '../../../models/product/product_model.dart';
import '../../../screens/ProductDetail/product_details_screen.dart';
import 'provider/promotion_provider.dart';
import 'widgtes/promotion_card.dart';
import 'widgtes/empty_state.dart';
import 'widgtes/error_state.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<PromotionProvider>(context, listen: false)
            .fetchPromotions();
      });
      _fetched = true;
    }
  }

  ProductModel convertToProductModel(
      PromotionProductModel product, String promotionImage) {
    return ProductModel(
      productId: product.productId,
      productName: product.productName,
      brandName: '',
      price: 0,
      discountPrice: 0,
      description: '',
      stock: 0,
      categories: [],
      images: promotionImage.isNotEmpty ? [promotionImage] : [],
      variations: [],
      tags: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Promotions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.whiteColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.1),
              AppColors.scaffoldColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<PromotionProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (provider.error != null) {
              return ErrorState(
                  error: provider.error!, onRetry: provider.refresh);
            }
            if (provider.promotions.isEmpty) {
              return const EmptyState();
            }
            return RefreshIndicator(
              onRefresh: () async => provider.refresh(),
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: provider.promotions.length,
                itemBuilder: (context, index) {
                  final promo = provider.promotions[index];
                  return PromotionCard(
                    imageUrl: promo.image,
                    title: promo.title,
                    description: promo.description,
                    offerText: promo.discountPercentage != "0.00"
                        ? "${double.parse(promo.discountPercentage).round()}% OFF"
                        : "Rs.${double.parse(promo.discountAmount).round()} OFF",
                    validity:
                        "${promo.startDate.split(' ').first} to ${promo.endDate.split(' ').first}",
                    products: promo.products,
                    onTap: () {
                      if (promo.products.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: convertToProductModel(
                                promo.products.first,
                                promo.image,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
