import 'package:e_Home_app/screens/Home/widgets/vendor_store/widget/vendor%20product%20list/product_card_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../../Utils/constants/app_colors.dart';
import '../../../../../../global widgets/cart_badge.dart';
import '../../../../../../global widgets/shimmer_product_card.dart';
import '../../../../../../models/home screen/vendor/vendor_model.dart';
import '../../../../../../models/home screen/vendor/vendor_product_model.dart';
import '../../../../../../models/product/product_model.dart';
import '../../../../../Cart/cart_screen.dart';
import '../../../../../ProductDetail/product_details_screen.dart';
import '../../../../provider/vendor_provider.dart';

enum PriceSortOrder {
  none,
  lowToHigh,
  highToLow,
}

class VendorProductsScreen extends StatefulWidget {
  final VendorModel vendor;
  static const int pageSize = 20;

  const VendorProductsScreen({super.key, required this.vendor});

  @override
  State<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _chipScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoadingMore = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();
  PriceSortOrder _currentSortOrder = PriceSortOrder.none;
  String? _selectedCategory;
  Set<String> _uniqueCategories = {};

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    Future.microtask(() => _loadInitialProducts());
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 500) {
        _loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chipScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProducts() async {
    if (!mounted) return;
    await context.read<VendorProvider>().fetchVendorProducts(
          widget.vendor.id.toString(),
          page: 1,
          pageSize: VendorProductsScreen.pageSize,
        );
  }

  Future<void> _loadMoreProducts() async {
    if (!mounted || _isLoadingMore) return;

    final provider = context.read<VendorProvider>();
    if (provider.hasMoreProducts) {
      setState(() => _isLoadingMore = true);

      await provider.fetchVendorProducts(
        widget.vendor.id.toString(),
        page: provider.currentPage + 1,
        pageSize: VendorProductsScreen.pageSize,
      );

      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    await context.read<VendorProvider>().refreshVendorProducts(
          widget.vendor.id.toString(),
          pageSize: VendorProductsScreen.pageSize,
        );
  }

  /// Compute-intensive task moved to isolate
  static Future<ProductModel> _convertToProductModel(
      VendorProductModel product) async {
    return compute(_productConverter, product);
  }

  static ProductModel _productConverter(VendorProductModel product) {
    return ProductModel(
      productId: product.productId,
      vendorId: product.vendorId,
      productName: product.productName,
      brandName: product.brandName,
      price: product.price.toInt(),
      discountPrice: product.discountPrice.toInt(),
      description: product.description,
      stock: product.stock,
      categories: product.categories,
      images: product.images,
      variations: [],
      tags: product.tags
          .map((tag) => TagModel(
                tagId: tag.tagId,
                tagName: tag.tagName,
              ))
          .toList(),
    );
  }

  void _updateCategories(List<VendorProductModel> products) {
    _uniqueCategories =
        products.expand((product) => product.categories).toSet();
  }

  void _onCategorySelected(String? category) {
    setState(() => _selectedCategory = category);

    // Scroll to top when category changes
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // Auto-scroll to the selected category chip
    if (_chipScrollController.hasClients && category != null) {
      // Calculate the approximate position of the chip
      final chipWidth = 100.w; // Approximate width of each chip
      final index = _uniqueCategories.toList().indexOf(category);
      if (index != -1) {
        final scrollPosition = (chipWidth + 8.w) * index; // Include padding
        _chipScrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else if (category == null && _chipScrollController.hasClients) {
      // If "All" is selected, scroll to the start
      _chipScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<VendorProductModel> _getFilteredAndSortedProducts(
      List<VendorProductModel> products) {
    // First filter by category if selected
    var filteredProducts = _selectedCategory == null
        ? products
        : products
            .where((product) => product.categories.contains(_selectedCategory))
            .toList();

    // Then apply price sorting
    switch (_currentSortOrder) {
      case PriceSortOrder.lowToHigh:
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case PriceSortOrder.highToLow:
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case PriceSortOrder.none:
        break;
    }

    return filteredProducts;
  }

  Widget _buildCategoryChips() {
    if (_uniqueCategories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView(
        controller: _chipScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(), // Add smooth scrolling physics
        children: [
          // "All" chip
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(
                'All',
                style: TextStyle(
                  color: _selectedCategory == null
                      ? AppColors.whiteColor
                      : AppColors.blackColor,
                  fontSize: 12.sp,
                ),
              ),
              selected: _selectedCategory == null,
              onSelected: (_) => _onCategorySelected(null),
              backgroundColor: AppColors.whiteColor,
              selectedColor: AppColors.primaryColor,
              checkmarkColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: _selectedCategory == null
                      ? AppColors.primaryColor
                      : AppColors.greyColor,
                ),
              ),
            ),
          ),
          ..._uniqueCategories
              .map((category) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: _selectedCategory == category
                              ? AppColors.whiteColor
                              : AppColors.blackColor,
                          fontSize: 12.sp,
                        ),
                      ),
                      selected: _selectedCategory == category,
                      onSelected: (_) => _onCategorySelected(category),
                      backgroundColor: AppColors.whiteColor,
                      selectedColor: AppColors.primaryColor,
                      checkmarkColor: AppColors.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: _selectedCategory == category
                              ? AppColors.primaryColor
                              : AppColors.greyColor,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreenColor.withOpacity(0.3),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.whiteColor,
        key: _refreshIndicatorKey,
        onRefresh: () {
          setState(() {
            _currentSortOrder = PriceSortOrder.none;
            _selectedCategory = null;
          });
          return _onRefresh();
        },
        child: Consumer<VendorProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingProducts && provider.vendorProducts.isEmpty) {
              return _buildLoadingGrid();
            }

            if (provider.productsError != null &&
                provider.vendorProducts.isEmpty) {
              return _buildErrorWidget(provider.productsError!);
            }

            // Update categories whenever products change
            _updateCategories(provider.vendorProducts);

            final filteredProducts =
                _getFilteredAndSortedProducts(provider.vendorProducts)
                    .where((product) =>
                        _searchQuery.isEmpty ||
                        (product.productName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase())))
                    .toList();
            if (filteredProducts.isEmpty) {
              return _buildEmptyWidget();
            }

            return Column(
              children: [
                _ReusableSearchBar(
                  controller: _searchController,
                  hintText: 'Search products...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                _buildCategoryChips(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Showing ',
                            style: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 12.sp,
                            ),
                          ),
                          TextSpan(
                            text: '${filteredProducts.length}',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                          if (_selectedCategory != null) ...[
                            TextSpan(
                              text: ' of ',
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text: '${provider.vendorProducts.length}',
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                          TextSpan(
                            text: ' Products',
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
                SizedBox(height: 8.h),
                Expanded(
                  child: _buildProductsGrid(filteredProducts),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerProductCard(),
    );
  }

  Widget _buildProductsGrid(List<VendorProductModel> products) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= products.length) {
                  return null;
                }

                return ProductCardWrapper(
                  key: ValueKey('product_${products[index].productId}'),
                  product: products[index],
                  vendorName: widget.vendor.storeName,
                  onProductSelected: _onProductSelected,
                );
              },
              childCount: products.length,
            ),
          ),
        ),
        if (_isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: const Center(child: CupertinoActivityIndicator()),
            ),
          ),
      ],
    );
  }

  Future<void> _onProductSelected(VendorProductModel product) async {
    final convertedProduct = await _convertToProductModel(product);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: convertedProduct,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.vendor.storeName,
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Products',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      actions: [
        PopupMenuButton<PriceSortOrder>(
          icon: Icon(Icons.sort, color: AppColors.whiteColor),
          onSelected: (PriceSortOrder sortOrder) {
            setState(() => _currentSortOrder = sortOrder);
          },
          color: AppColors.whiteColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: PriceSortOrder.none,
              child: Text(
                'Default Order',
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
            PopupMenuItem(
              value: PriceSortOrder.lowToHigh,
              child: Text(
                'Price: Low to High',
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
            PopupMenuItem(
              value: PriceSortOrder.highToLow,
              child: Text(
                'Price: High to Low',
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        CartBadge(
          top: 0,
          left: 0,
          child: IconButton(
            icon:
                Icon(Icons.shopping_cart_outlined, color: AppColors.whiteColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 48.sp,
              color: AppColors.redColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading products',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.greyColor,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(AppColors.whiteColor)),
              onPressed: _loadInitialProducts,
              child:
                  Text('Retry', style: TextStyle(color: AppColors.blackColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 48.sp,
              color: AppColors.greyColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This vendor has not added any products yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductImage(String? imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? 'https://via.placeholder.com/300x400?text=No+Image',
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.greyColor.withOpacity(0.1),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.greyColor.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.greyColor,
              size: 32.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              'Image not available',
              style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReusableSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  const _ReusableSearchBar(
      {required this.controller,
      required this.hintText,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        cursorColor: AppColors.primaryColor,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
