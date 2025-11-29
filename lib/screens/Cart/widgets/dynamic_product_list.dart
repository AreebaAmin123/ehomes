import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/product/product_model.dart';
import '../../../models/cart/get_cart_model.dart';
import '../../Categories/provider/product_provider.dart';
import '../provider/cart_provider.dart';
import 'related_products_list.dart';
import '../../../global widgets/product card/product_card.dart';
import '../../../global widgets/product card/product_card_data.dart';
import '../../ProductDetail/product_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class DynamicProductList extends StatefulWidget {
  final ScrollController? scrollController;
  const DynamicProductList({super.key, this.scrollController});

  @override
  State<DynamicProductList> createState() => _DynamicProductListState();
}

class _DynamicProductListState extends State<DynamicProductList> {
  bool _isLoading = true;
  List<ProductModel> _products = [];
  bool _isInitialized = false;
  static const defaultCategory = "1";
  bool _isRefreshing = false;

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
      final provider = Provider.of<ProductProvider>(context, listen: false);

      // Get products from cache first
      var products = provider.getProducts(defaultCategory);

      // Only fetch if cache is empty
      if (products.isEmpty) {
        products = await provider.fetchProducts(defaultCategory);
        if (!mounted) return;
      }

      // Sort products using compute
      final sortedProducts = await compute(_sortProducts, products);

      if (mounted) {
        setState(() {
          _products = sortedProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing product list: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Static method for compute to sort products
  static List<ProductModel> _sortProducts(List<ProductModel> products) {
    return List<ProductModel>.from(products)
      ..sort((a, b) {
        // First sort by discount
        final aHasDiscount = a.discountPrice > 0;
        final bHasDiscount = b.discountPrice > 0;
        if (aHasDiscount != bHasDiscount) {
          return aHasDiscount ? -1 : 1;
        }
        // Then by stock availability
        if (a.stock != b.stock) {
          return b.stock.compareTo(a.stock);
        }
        // Finally by price
        return a.price.compareTo(b.price);
      });
  }

  Future<void> _refreshProducts() async {
    if (!mounted || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _isLoading = true;
    });

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Force refresh from API
      await productProvider.forceRefreshProducts(defaultCategory);
      final products = productProvider.getProducts(defaultCategory);

      // Sort products in background
      final sortedProducts = await compute(_sortProducts, products);

      if (mounted) {
        setState(() {
          _products = sortedProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing products: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 250.h,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250.h,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.greyColor,
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: _isRefreshing ? null : _refreshProducts,
              child: Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Container(
      color: AppColors.lightGreyColor.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Featured Products",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
                TextButton(
                  onPressed: _isRefreshing ? null : _refreshProducts,
                  child: Text(
                    "Refresh",
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
          Expanded(
            child: GridView.builder(
              controller: widget.scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(
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
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartModel?.cart ?? [];

        // Show loading indicator while initializing
        if (_isLoading) {
          return _buildLoadingIndicator();
        }

        // If cart is not empty, show related products
        if (cartItems.isNotEmpty) {
          return const CartRelatedProductsList();
        }

        // If no products available
        if (_products.isEmpty) {
          return _buildEmptyState();
        }

        // Show all products in grid view when cart is empty
        return _buildProductGrid();
      },
    );
  }
}
