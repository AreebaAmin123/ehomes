import 'package:e_Home_app/screens/Inbox/promotions/promotion_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../Utils/constants/app_colors.dart';
import '../../global widgets/chats_icon_round_item.dart';
import '../../models/product/product_model.dart';
import '../../models/promotion_model.dart';
import '../../screens/ProductDetail/product_details_screen.dart';
import 'chats/chats_screen.dart';
import 'orders/order_details_screen.dart';
import 'promotions/promotion_screen.dart';
import 'promotions/provider/promotion_provider.dart';
import 'promotions/widgtes/promotion_card.dart';
import '../../screens/Auth/email section/provider/email_authProvider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
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
    final authProvider = Provider.of<EmailAuthProvider>(context, listen: false);
    final promotionProvider = Provider.of<PromotionProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Top Section
          Container(
            color: AppColors.whiteColor,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 22.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChatsIconRoundItem(
                    icon: Icons.message,
                    circleColor: AppColors.greenColor,
                    iconColor: AppColors.whiteColor,
                    iconSize: 23.sp,
                    text: "Chats",
                    textSize: 11.sp,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatsScreen()));
                    },
                  ),
                  ChatsIconRoundItem(
                    icon: Icons.shopping_bag,
                    circleColor: AppColors.blueColor,
                    iconColor: AppColors.whiteColor,
                    iconSize: 23.sp,
                    text: "Orders",
                    textSize: 11.sp,
                    onTap: () async {
                      await authProvider.loadUserSession();
                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(
                            userId: authProvider.user?.id ?? 0,
                            userName: authProvider.user?.name ?? 'User',
                          ),
                        ),
                      );
                    },
                  ),
                  ChatsIconRoundItem(
                    icon: Icons.alarm,
                    circleColor: AppColors.redColor,
                    iconColor: AppColors.whiteColor,
                    iconSize: 23.sp,
                    text: "Promotions",
                    textSize: 11.sp,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PromotionScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),
          // Promotions Section
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 10.h),
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'Active Promotions',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    promotionProvider.loading
                        ? Center(
                            child: CupertinoActivityIndicator(
                              color: AppColors.primaryColor,
                            ),
                          )
                        : promotionProvider.promotions.isEmpty
                            ? Center(
                                child: Text(
                                  'No active promotions',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 10.h),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.7,
                                    crossAxisSpacing: 16.w,
                                    mainAxisSpacing: 16.h,
                                  ),
                                  itemCount:
                                      promotionProvider.promotions.length,
                                  itemBuilder: (context, index) {
                                    final promo =
                                        promotionProvider.promotions[index];
                                    return PromotionCard(
                                      imageUrl: promo.image,
                                      title: promo.title,
                                      description: promo.description,
                                      offerText: promo.discountPercentage !=
                                              "0.00"
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
                                              builder: (context) =>
                                                  ProductDetailScreen(
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
                              ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
