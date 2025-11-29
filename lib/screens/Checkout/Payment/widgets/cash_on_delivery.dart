import 'package:e_Home_app/Utils/constants/app_colors.dart';
import 'package:e_Home_app/screens/Cart/provider/cart_provider.dart';
import 'package:e_Home_app/screens/Checkout/provider/checkout_provider.dart';
import 'package:e_Home_app/Utils/helpers/show_toast_dialouge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/delivery_slot_model.dart';
import '../../../Categories/provider/product_provider.dart';
import '../providers/delivery_slot_provider.dart';
import 'order_confirmation_dialogue.dart';
import '../../../Dashboard/dashboard_page.dart';
import 'package:e_Home_app/screens/ProfileScreen/widgets/social_button.dart';

class CashOnDeliveryScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const CashOnDeliveryScreen({super.key, required this.data});

  @override
  State<CashOnDeliveryScreen> createState() => _CashOnDeliveryScreenState();
}

class _CashOnDeliveryScreenState extends State<CashOnDeliveryScreen> {
  @override
  void initState() {
    super.initState();
    // Reset delivery slot provider state when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deliverySlotProvider =
          Provider.of<DeliverySlotProvider>(context, listen: false);
      deliverySlotProvider.reset();
      _initializeDeliverySlots();
    });
  }

  Future<void> _initializeDeliverySlots() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final deliverySlotProvider =
        Provider.of<DeliverySlotProvider>(context, listen: false);

    // Reset provider state before fetching new slots
    deliverySlotProvider.reset();

    // Get product IDs from cart
    final productIds = cartProvider.cartModel?.cart
            ?.map((item) => item.productId)
            .where((id) => id != null)
            .toList() ??
        [];

    debugPrint('🔍 Found ${productIds.length} products in cart: $productIds');

    if (productIds.isEmpty) {
      debugPrint('❌ No products in cart');
      return;
    }

    // First fetch all products to ensure we have the data
    debugPrint('🔄 Fetching all products first...');
    try {
      await productProvider.fetchProducts("1"); // "1" fetches all products
    } catch (e) {
      debugPrint('❌ Error fetching all products: $e');
    }

    // Get unique category IDs from products
    final Set<String> categoryIds = {};
    for (final productId in productIds) {
      if (productId == null) continue; // Skip null product IDs

      try {
        // First try to get product from cache
        bool found = false;
        final cachedProduct = productProvider.getProductById(productId);
        if (cachedProduct != null) {
          // First try the categoryId field
          if (cachedProduct.categoryId > 0) {
            categoryIds.add(cachedProduct.categoryId.toString());
            debugPrint(
                '✅ Found category ID ${cachedProduct.categoryId} for product ${cachedProduct.productName} from cache');
            found = true;
          }
          // Then try the categories list
          else if (cachedProduct.categories.isNotEmpty) {
            for (final category in cachedProduct.categories) {
              final categoryId = int.tryParse(category);
              if (categoryId != null && categoryId > 0) {
                categoryIds.add(categoryId.toString());
                debugPrint(
                    '✅ Found category ID $categoryId from categories list for product ${cachedProduct.productName} from cache');
                found = true;
              }
            }
          }
        }

        // If not found in cache, try fetching from API
        if (!found) {
          debugPrint(
              '🔄 Product $productId not found in cache, fetching from API...');
          await productProvider.searchProducts(productId);
          final product = productProvider.productModel;
          if (product != null) {
            // First try the categoryId field
            if (product.categoryId > 0) {
              categoryIds.add(product.categoryId.toString());
              debugPrint(
                  '✅ Found category ID ${product.categoryId} for product ${product.productName} from API');
            }
            // Then try the categories list
            else if (product.categories.isNotEmpty) {
              for (final category in product.categories) {
                final categoryId = int.tryParse(category);
                if (categoryId != null && categoryId > 0) {
                  categoryIds.add(categoryId.toString());
                  debugPrint(
                      '✅ Found category ID $categoryId from categories list for product ${product.productName}');
                }
              }
            } else {
              debugPrint(
                  '⚠️ Product ${product.productName} has no category information from API');
            }
          } else {
            debugPrint('⚠️ Product $productId not found in API');
          }
        }
      } catch (e) {
        debugPrint('❌ Error getting category ID for product $productId: $e');
      }
    }

    if (categoryIds.isEmpty) {
      debugPrint('❌ No category IDs found for products');
      return;
    }

    debugPrint('📦 Found category IDs: $categoryIds');
    await deliverySlotProvider.initialize(categoryIds.toList());
    debugPrint(
        '🟢 DeliverySlotProvider initialized. Slots: ${deliverySlotProvider.deliverySlotModel?.slots.map((s) => s.toJson()).toList()}');

    if (deliverySlotProvider.deliverySlotModel == null ||
        deliverySlotProvider.deliverySlotModel!.slots.isEmpty) {
      debugPrint(
          '❌ No delivery slots returned from API for category IDs: $categoryIds');
    } else {
      debugPrint(
          '✅ Delivery slots returned: ${deliverySlotProvider.deliverySlotModel!.slots.length}');
    }
  }

  @override
  void dispose() {
    Provider.of<DeliverySlotProvider>(context, listen: false).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = provider.cartModel?.cart ?? [];
    final total = cartItems.fold<double>(
        0,
        (sum, item) =>
            sum +
            (double.tryParse(item.effectivePrice) ?? 0.0) *
                (item.quantity ?? 1));
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          "Cash on Delivery",
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteColor),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        foregroundColor: AppColors.whiteColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.whiteColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _modernSectionTitle("Order Summary"),
                SizedBox(height: 10.h),
                ...cartItems
                    .map((product) => _modernProductCard(product))
                    .toList(),
                SizedBox(height: 12.h),
                _modernTotalSummary(total),
                SizedBox(height: 28.h),
                _modernSectionTitle("Delivery Address"),
                SizedBox(height: 10.h),
                _modernAddressCard(context),
                SizedBox(height: 28.h),
                _modernSectionTitle("Payment Method"),
                SizedBox(height: 10.h),
                _modernPaymentCard(),
                SizedBox(height: 28.h),
                _modernSectionTitle("Select Delivery Time"),
                _buildDeliverySlots(context),
                SizedBox(height: 32.h),
                SocialButton(
                  icon: Icons.chat,
                  color: Colors.green,
                  label: 'WhatsApp',
                  url: 'https://wa.me/923266679797',
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: SizedBox(
            width: double.infinity,
            height: 40.h,
            child: _modernConfirmButton(context),
          ),
        ),
      ),
    );
  }

  Widget _modernSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
            letterSpacing: 0.2),
      ),
    );
  }

  Widget _modernProductCard(dynamic product) {
    final image = product.imageUrl ?? '';
    final quantity = product.quantity ?? 0;
    final productPrice = double.tryParse(product.effectivePrice) ?? 0.0;
    bool isValidImageUrl = image.isNotEmpty &&
        (image.startsWith('http://') || image.startsWith('https://')) &&
        (image.toLowerCase().endsWith('.jpg') ||
            image.toLowerCase().endsWith('.jpeg') ||
            image.toLowerCase().endsWith('.png') ||
            image.toLowerCase().endsWith('.gif') ||
            image.toLowerCase().endsWith('.webp'));
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: AppColors.whiteColor,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: isValidImageUrl
                  ? CachedNetworkImage(
                      imageUrl: image,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer rotating circle
                              TweenAnimationBuilder(
                                tween:
                                    Tween<double>(begin: 0, end: 2 * 3.14159),
                                duration: const Duration(seconds: 2),
                                builder: (context, double value, child) {
                                  return Transform.rotate(
                                    angle: value,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryColor.withOpacity(0.3),
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                              ),
                              // Inner pulsing circle
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.8, end: 1.2),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 12.w,
                                      height: 12.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60.w,
                        height: 60.w,
                        color: AppColors.scaffoldColor,
                        child: Icon(Icons.broken_image,
                            color: AppColors.greyColor, size: 32.sp),
                      ),
                    )
                  : Container(
                      width: 60.w,
                      height: 60.w,
                      color: AppColors.scaffoldColor,
                      child: Icon(Icons.image,
                          color: AppColors.greyColor, size: 32.sp),
                    ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName ?? "Unknown Product",
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Rs. ${productPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Quantity: $quantity",
                    style:
                        TextStyle(fontSize: 13.sp, color: AppColors.blackColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernTotalSummary(double total) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 2.h, bottom: 2.h),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total",
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor),
          ),
          Text(
            "PKR ${total.toStringAsFixed(0)}",
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _modernAddressCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      color: AppColors.whiteColor,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: AppColors.primaryColor, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.data["first_name"]} ${widget.data["last_name"]}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: AppColors.blackColor),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${widget.data["address"]}, ${widget.data["city"]}, ${widget.data["state"]}",
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Phone: ${widget.data["phone"]}",
                    style:
                        TextStyle(fontSize: 14.sp, color: AppColors.blackColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernPaymentCard() {
    return Card(
      elevation: .05,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      color: AppColors.whiteColor,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        child: Row(
          children: [
            Icon(Icons.payments, color: AppColors.primaryColor, size: 26.sp),
            SizedBox(width: 12.w),
            Text("Cash on Delivery",
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor)),
            Spacer(),
            Icon(Icons.check_circle,
                color: AppColors.primaryColor, size: 22.sp),
          ],
        ),
      ),
    );
  }

  String _getMonthName(String date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthIndex = int.parse(date.split('-')[1]) - 1;
    return months[monthIndex];
  }

  Widget _dateCard(String day, String date, bool isSelected) {
    return Container(
      width: 70.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.blackColor : AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            date,
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeSlotCard(String slot, bool isAvailable, bool isUnavailable) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.circle_outlined,
            color: isAvailable
                ? AppColors.primaryColor
                : Colors.grey.withOpacity(0.5),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            slot,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Text(
            isUnavailable ? "Unavailable" : "Available",
            style: TextStyle(
              fontSize: 13.sp,
              color: isUnavailable ? Colors.red : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySlots(BuildContext context) {
    return Consumer<DeliverySlotProvider>(
      builder: (context, deliverySlotProvider, child) {
        if (deliverySlotProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer rotating circle
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 2 * 3.14159),
                        duration: const Duration(seconds: 2),
                        builder: (context, double value, child) {
                          return Transform.rotate(
                            angle: value,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor.withValues(alpha: 0.3),
                              ),
                              strokeWidth: 3,
                            ),
                          );
                        },
                      ),
                      // Inner pulsing circle
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.8, end: 1.2),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.access_time_rounded,
                                  color: AppColors.primaryColor,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Loading delivery slots...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          );
        }

        if (deliverySlotProvider.error != null) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 32.w,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Delivery Slots Not Available',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sorry, delivery slots are not available for some items in your cart. This could be because:\n\n• The items are not eligible for delivery\n• Delivery is temporarily unavailable\n• The delivery schedule is not yet configured\n\nPlease try again later or contact support for assistance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.blackColor.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }

        if (deliverySlotProvider.deliverySlotModel == null ||
            deliverySlotProvider.deliverySlotModel!.slots.isEmpty) {
          return SizedBox.shrink();
        }

        final slots = deliverySlotProvider.deliverySlotModel?.slots ?? [];
        if (slots.isEmpty) {
          return SizedBox.shrink();
        }

        // Group slots by date
        final groupedSlots = <String, List<DeliverySlot>>{};
        for (var slot in slots) {
          if (!groupedSlots.containsKey(slot.date)) {
            groupedSlots[slot.date] = [];
          }
          groupedSlots[slot.date]!.add(slot);
        }

        final dates = groupedSlots.keys.toList();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Date Selection Row
              Container(
                height: 80.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final firstSlot = groupedSlots[date]!.first;
                    final isSelected =
                        deliverySlotProvider.selectedDateIndex == index;

                    return GestureDetector(
                      onTap: () =>
                          deliverySlotProvider.setSelectedDateIndex(index),
                      child: _dateCard(
                        firstSlot.day.substring(0, 3).toUpperCase(),
                        "${firstSlot.date.split('-')[2]} ${_getMonthName(firstSlot.date)}",
                        isSelected,
                      ),
                    );
                  },
                ),
              ),
              // Time Slots
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: groupedSlots[
                          dates[deliverySlotProvider.selectedDateIndex]]!
                      .map((slot) {
                    final isSelected =
                        deliverySlotProvider.selectedSlotId == slot.slotId;
                    final isAvailable =
                        slot.status.toLowerCase() == 'available';

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: isAvailable
                              ? () => deliverySlotProvider
                                  .setSelectedSlotId(slot.slotId)
                              : null,
                          child: _timeSlotCard(
                            "Slot ${slot.slotId} (${slot.startTime} - ${slot.endTime})",
                            isSelected && isAvailable,
                            !isAvailable,
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modernConfirmButton(BuildContext context) {
    final checkoutProvider =
        Provider.of<CheckoutProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final deliverySlotProvider =
        Provider.of<DeliverySlotProvider>(context, listen: false);

    // The button should always be enabled and show 'Confirm Order'.
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        elevation: 0,
      ),
      onPressed: () async {
        // Show loading overlay
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated loading indicator
                    SizedBox(
                      width: 60.w,
                      height: 60.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer rotating circle
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 2 * 3.14159),
                            duration: const Duration(seconds: 2),
                            builder: (context, double value, child) {
                              return Transform.rotate(
                                angle: value,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor.withOpacity(0.3),
                                  ),
                                  strokeWidth: 3,
                                ),
                              );
                            },
                          ),
                          // Inner pulsing circle
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.8, end: 1.2),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.shopping_cart_checkout_rounded,
                                      color: AppColors.primaryColor,
                                      size: 24.sp,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Loading text
                    Text(
                      'Processing Order...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Please wait while we confirm your order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Ensure cart is loaded and not empty before checkout
        await cartProvider.getCart(context);
        if (cartProvider.cartModel == null ||
            cartProvider.cartModel!.cart == null ||
            cartProvider.cartModel!.cart!.isEmpty) {
          Navigator.pop(context); // Remove loading overlay
          ShowToastDialog.show(
            context,
            "Your cart is empty. Please add items before placing an order.",
            type: ToastType.error,
          );
          return;
        }

        // Validate delivery slot selection
        if (deliverySlotProvider.selectedSlotId == null) {
          Navigator.pop(context); // Remove loading overlay
          ShowToastDialog.show(
            context,
            "Please select a delivery time slot before proceeding.",
            type: ToastType.error,
          );
          return;
        }

        try {
          await checkoutProvider.checkout(
            context,
            widget.data['first_name'],
            widget.data['last_name'],
            widget.data['email'],
            widget.data['phone'],
            widget.data['address'],
            widget.data['city'],
            widget.data['state'],
            widget.data['zip'],
            widget.data['order_notes'],
            'cod',
            widget.data['discount'],
            widget.data['coupon_code'],
            widget.data['coupon_amount'],
            widget.data['shipping_charge'],
            deliverySlotProvider.selectedSlotId!,
          );

          Navigator.pop(context); // Remove loading overlay

          if (checkoutProvider.checkOutModel!.success == true) {
            // Show order confirmation dialog
            if (mounted) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => OrderConfirmationDialog(
                  orderId: checkoutProvider.checkOutModel!.orderId ?? '',
                  orderDetails: {
                    'name':
                        '${widget.data['first_name']} ${widget.data['last_name']}',
                    'phone': widget.data['phone'],
                    'address':
                        '${widget.data['address']}, ${widget.data['city']}, ${widget.data['state']}',
                    'paymentMethod': 'Cash on Delivery',
                    'total': cartProvider.totalCartPrice,
                  },
                ),
              );

              // After dialog is closed, navigate to DashboardPage and clear all previous routes
              if (mounted) {
                // Clear the entire navigation stack and go to dashboard
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const DashboardPage(),
                  ),
                  (route) => false,
                );
              }
            }
          } else {
            ShowToastDialog.show(
              context,
              checkoutProvider.checkOutModel?.message ??
                  "Failed to place order",
              type: ToastType.error,
            );
          }
        } catch (e) {
          Navigator.pop(context); // Remove loading overlay
          ShowToastDialog.show(
            context,
            checkoutProvider.checkOutModel?.message ?? "Failed to place order",
            type: ToastType.error,
          );
        }
      },
      child: Text(
        "Confirm Order",
        style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2),
      ),
    );
  }
}
