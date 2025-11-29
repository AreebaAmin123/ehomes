import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_Home_app/models/product/product_model.dart';
import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:e_Home_app/screens/Auth/email%20section/signIn_withEmail.dart';
import 'package:e_Home_app/screens/Cart/cart_screen.dart';
import 'package:e_Home_app/screens/Cart/provider/cart_provider.dart';
import 'package:e_Home_app/screens/ProductDetail/provider/wish_list_provider.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:e_Home_app/Utils/helpers/show_toast_dialouge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Inbox/chats/chats_screen.dart';
import 'widgets/reviews_section.dart';
import 'widgets/cart_action_button.dart';
import '../../global widgets/cart_badge.dart';
import '../../models/cart/get_cart_model.dart';
import 'widgets/product_recommendations.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool isWishListed = false;
  int selectedVariationIndex = 0;
  int? selectedVariationId;
  bool _showDetails = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.product.variations.isNotEmpty) {
      selectedVariationId = widget.product.variations[0].variationId;
    }
    // Use post-frame callback to initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _initializeData();
        _isInitialized = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      final wishlistProvider =
          Provider.of<WishlistProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      await Future.wait([
        wishlistProvider.fetchWishlist(context),
        cartProvider.getCart(context),
      ]);
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product.images.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final productId = widget.product.productId;
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageCarousel(),
            _buildProductDetails(),
            ReviewsSection(
              productId: widget.product.productId,
              categoryId: widget.product.categories.isNotEmpty
                  ? int.tryParse(widget.product.categories.first) ?? 0
                  : 0,
            ),
            SizedBox(height: 20.h),
            ProductRecommendations(product: widget.product),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(productId),
    );
  }

  /// **App Bar**
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.whiteColor,
          )),
      backgroundColor: AppColors.primaryColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Product details',
        style: TextStyle(
          fontSize: 18.sp,
          color: AppColors.whiteColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
            icon: Icon(Icons.chat_outlined, color: AppColors.whiteColor),
            onPressed: () async {
              final authProvider =
                  Provider.of<EmailAuthProvider>(context, listen: false);
              if (authProvider.user?.id == null) {
                ShowToastDialog.show(
                  context,
                  "Login before starting a chat",
                  type: ToastType.error,
                );
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignInWithEmail()));
                return;
              }
              if (widget.product.vendorId == null) {
                ShowToastDialog.show(
                  context,
                  "Vendor information not available",
                  type: ToastType.error,
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatsScreen(
                    vendorId: widget.product.vendorId!,
                    userId: authProvider.user!.id,
                  ),
                ),
              );
            }),
        CartBadge(
          top: 0,
          left: 0,
          child: IconButton(
            icon:
                Icon(Icons.shopping_cart_outlined, color: AppColors.whiteColor),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CartScreen()));
            },
          ),
        ),
      ],
    );
  }

  /// **Image Carousel**
  Widget _buildImageCarousel() {
    bool hasMultipleImages = widget.product.images.length > 1;

    return Container(
      width: double.infinity,
      color: AppColors.whiteColor,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              hasMultipleImages
                  ? CarouselSlider(
                      items: widget.product.images.map((image) {
                        return _buildImage(image);
                      }).toList(),
                      options: CarouselOptions(
                        height: 250.h,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() => _currentImageIndex = index);
                        },
                      ),
                    )
                  : _buildImage(widget.product.images.first),
              if (hasMultipleImages)
                Positioned(
                  bottom: 4.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.product.images.asMap().entries.map((entry) {
                      return Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == entry.key
                              ? AppColors.primaryColor
                              : AppColors.greyColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper function for image widget
  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty || !Uri.parse(imageUrl).isAbsolute) {
      return _buildPlaceholderImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: 250.h,
        placeholder: (context, url) => Container(
          height: 250.h,
          alignment: Alignment.center,
          child: const CupertinoActivityIndicator(),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 250.h,
      alignment: Alignment.center,
      color: AppColors.greyColor,
      child:
          const Icon(Icons.broken_image, size: 50, color: AppColors.greyColor),
    );
  }

  /// **Product Details**
  Widget _buildProductDetails() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.boxShadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Price, Discount & Percentage**
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price section
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final int price = widget.product.price;
                      final int discountPrice = widget.product.discountPrice;
                      int originalPrice = price;
                      int discountedPrice = discountPrice;
                      if (discountPrice > 0 && discountPrice < price) {
                        originalPrice = price;
                        discountedPrice = discountPrice;
                      } else if (discountPrice > price && price > 0) {
                        originalPrice = discountPrice;
                        discountedPrice = price;
                      } else if (discountPrice == 0) {
                        originalPrice = price;
                        discountedPrice = price;
                      }
                      final double discountPercent = (originalPrice > 0 &&
                              discountedPrice > 0 &&
                              discountedPrice < originalPrice)
                          ? ((originalPrice - discountedPrice) /
                                  originalPrice) *
                              100
                          : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Rs. ${discountedPrice.toString()}",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greenColor,
                                ),
                              ),
                              if (originalPrice != discountedPrice) ...[
                                SizedBox(width: 8.w),
                                Text(
                                  "Rs. ${originalPrice.toString()}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.redColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (discountPercent > 0)
                            Container(
                              margin: EdgeInsets.only(top: 4.h),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.redColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                "${discountPercent.toStringAsFixed(1)}% OFF",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.redColor,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                // Cart Action Button
                CartActionButton(
                  productId: widget.product.productId,
                  price: widget.product.price.toDouble(),
                  stock: widget.product.stock,
                  variationId: selectedVariationId,
                  onQuantityChanged: () {
                    setState(() {});
                  },
                ),
              ],
            ),

            /// **Product Name with Wishlist Icon**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.product.productName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                      // height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Consumer<WishlistProvider>(
                  builder: (context, wishlistProvider, child) {
                    final bool isWishListed =
                        wishlistProvider.isWishListed(widget.product.productId);
                    return StatefulBuilder(
                      builder: (context, setState) => IconButton(
                        onPressed: () async {
                          await wishlistProvider.toggleWishlist(
                            product: widget.product,
                            context: context,
                          );
                          setState(() {});
                        },
                        icon: Icon(
                          isWishListed ? Icons.favorite : Icons.favorite_border,
                          color: isWishListed
                              ? AppColors.primaryColor
                              : AppColors.lightGreenColor,
                          size: 24.sp,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),

            /// **Details Section**
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _showDetails = !_showDetails),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Product Details",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ),
                        Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.blackColor,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),

                      /// **Brand Name**
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: "Brand: ",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                            children: [
                              TextSpan(
                                text: widget.product.brandName,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      /// **Stock**
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: widget.product.stock > 0
                              ? AppColors.greenColor.withOpacity(0.1)
                              : AppColors.redColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: "Stock available : ",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: widget.product.stock > 0
                                  ? AppColors.greenColor
                                  : AppColors.redColor,
                            ),
                            children: [
                              TextSpan(
                                text: widget.product.stock > 0
                                    ? "${widget.product.stock} units"
                                    : "Out of Stock",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: widget.product.stock > 0
                                      ? AppColors.blackColor
                                      : AppColors.redColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      /// **Description**
                      if (widget.product.description.isNotEmpty) ...[
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            widget.product.description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.blackColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  crossFadeState: _showDetails
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),

            /// **Variations**
            if (widget.product.variations.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _buildVariations(),
            ],
          ],
        ),
      ),
    );
  }

  /// **Product Variations List (Horizontally Scrollable)**
  Widget _buildVariations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Variations",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.product.variations.length, (index) {
              final variation = widget.product.variations[index];
              final isSelected = index == selectedVariationIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVariationIndex = index;
                    selectedVariationId = variation.variationId;
                  });
                },
                child: Container(
                  width: 140.w,
                  margin: EdgeInsets.only(right: 10.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Card(
                    elevation: 0.5,
                    color: AppColors.scaffoldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              color: AppColors.whiteColor,
                              width: double.infinity,
                              child: Image.network(
                                variation.imageUrl,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Name & Value
                          Text(
                            "${variation.variationName}: ${variation.variationValue}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5.h),

                          // Price
                          RichText(
                            text: TextSpan(
                              text: "Rs. ",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackColor,
                              ),
                              children: [
                                TextSpan(
                                  text: "${variation.price}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.greenColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5.h),

                          // Stock
                          Text(
                            variation.stock > 0
                                ? "In Stock: ${variation.stock}"
                                : "Out of Stock",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: variation.stock > 0
                                  ? AppColors.greenColor
                                  : AppColors.redColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  /// **Bottom Navigation Bar with Action Buttons**
  Widget _buildBottomNavigationBar(int productId) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border(
            top: BorderSide(color: AppColors.boxShadowColor, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.boxShadowColor.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final inCart = cartProvider.inCart(productId);
            final bool isOutOfStock = widget.product.stock <= 0;
            final bool isAddingToCart = cartProvider.isAddingToCart;

            // Get cart item quantity if in cart
            int quantity = 1;
            if (inCart && cartProvider.cartModel?.cart != null) {
              final cartItem = cartProvider.cartModel!.cart!.firstWhere(
                (item) => item.productId == productId,
                orElse: () => CartModel(
                  id: 0,
                  productId: productId,
                  productName: '',
                  imageUrl: '',
                  userId: '',
                  variationId: null,
                  quantity: 1,
                  discountPrice: '0',
                  price: '0',
                  totalPrice: '0',
                  variationName: '',
                  variationValue: '',
                ),
              );
              quantity = cartItem.quantity ?? 1;
            }

            // Calculate total price
            final double basePrice = widget.product.price.toDouble();
            final double totalPrice = basePrice * quantity;

            return Row(
              children: [
                if (inCart) ...[
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Rs. ${basePrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.greyColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'x$quantity',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Rs. ${totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: AppColors.greenColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        isOutOfStock
                            ? Icons.remove_shopping_cart
                            : (inCart
                                ? Icons.remove_shopping_cart
                                : Icons.add_shopping_cart),
                        color: AppColors.whiteColor,
                      ),
                      label: isAddingToCart
                          ? CupertinoActivityIndicator(
                              color: AppColors.whiteColor)
                          : Text(
                              isOutOfStock
                                  ? "Out of Stock"
                                  : (inCart
                                      ? "Remove from Cart"
                                      : "Add to Cart"),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.whiteColor,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOutOfStock
                            ? Colors.grey
                            : (inCart
                                ? AppColors.redColor
                                : AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: (isOutOfStock || isAddingToCart)
                          ? null
                          : () async {
                              final authProvider =
                                  Provider.of<EmailAuthProvider>(context,
                                      listen: false);
                              if (authProvider.user?.id == null) {
                                ShowToastDialog.show(
                                  context,
                                  "Login before shopping",
                                  type: ToastType.error,
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInWithEmail()),
                                );
                                return;
                              }

                              if (widget.product.stock <= 0) {
                                ShowToastDialog.show(
                                  context,
                                  "This item is out of stock",
                                  type: ToastType.error,
                                );
                                return;
                              }

                              if (inCart) {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(Icons.remove_shopping_cart,
                                            color: AppColors.redColor),
                                        SizedBox(width: 8.w),
                                        Text('Remove from Cart',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    content: Text(
                                        'Are you sure you want to remove this item from your cart?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('Cancel',
                                            style: TextStyle(
                                                color: AppColors.blackColor)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.redColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text('Remove',
                                            style: TextStyle(
                                                color: AppColors.whiteColor)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await cartProvider.deleteCart(productId);
                                }
                              } else {
                                await cartProvider.postAddedCart(
                                  context,
                                  productId,
                                  selectedVariationId,
                                  1,
                                  widget.product.price.toDouble(),
                                  widget.product.price.toDouble(),
                                );
                              }
                            },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
