import 'package:e_Home_app/screens/Cart/provider/cart_provider.dart';
import 'package:e_Home_app/screens/Checkout/billing_details_screen.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:e_Home_app/Utils/helpers/show_toast_dialouge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../Auth/email section/provider/email_authProvider.dart';
import '../Auth/email section/signIn_withEmail.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/dynamic_product_list.dart';
import '../wishList/wishlist_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    if (!mounted) return;
    setState(() => _isInitializing = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider =
          Provider.of<EmailAuthProvider>(context, listen: false);

      if (authProvider.isLoggedIn) {
        await cartProvider.initialize(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Cart',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: AppColors.whiteColor),
            tooltip: 'Wishlist',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishlistScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<EmailAuthProvider, CartProvider>(
        builder: (context, authProvider, cartProvider, child) {
          if (!authProvider.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64.sp,
                    color: AppColors.lightGreyColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Please login to view your cart',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.lightGreyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: 200.w,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInWithEmail(),
                          ),
                        );
                      },
                      icon: Icon(Icons.login_rounded, size: 20.sp),
                      label: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (_isInitializing || cartProvider.isLoading) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          final cartItems = cartProvider.cartModel?.cart ?? [];

          return RefreshIndicator(
            onRefresh: _initializeCart,
            child: Stack(
              children: [
                /// Main Cart Content (items list)
                Column(
                  children: [
                    if (cartItems.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text("Your cart is empty"),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            return CartItemCard(
                              cartItem: cartItems[index],
                            );
                          },
                        ),
                      ),

                    /// Checkout Section (from your original code)
                    if (cartItems.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(16.h),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greyColor.withValues(alpha: 0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                                Text(
                                  'PKR ${cartProvider.totalCartPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (cartProvider.totalCartPrice < 999) {
                                  ShowToastDialog.show(
                                    context,
                                    "Minimum order amount should be Rs.999",
                                    type: ToastType.error,
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const BillingDetailsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32.w,
                                  vertical: 12.h,
                                ),
                              ),
                              child: Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                /// Suggested Products (Draggable Sheet)
                DraggableScrollableSheet(
                  initialChildSize: 0.25,
                  minChildSize: 0.15,
                  maxChildSize: 0.8,
                  snap: true,
                  builder: (context, scrollController) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 80), // keeps checkout visible
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          /// Drag handle
                          SliverToBoxAdapter(
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          /// Product list (fills remaining space & scrolls)
                          SliverFillRemaining(
                            child: DynamicProductList(
                              scrollController: scrollController,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
