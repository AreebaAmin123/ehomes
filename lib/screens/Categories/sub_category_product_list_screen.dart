import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/category/categories_model.dart';
import '../ProductDetail/product_details_screen.dart';
import 'provider/product_provider.dart';
import 'provider/category_provider.dart';
import '../../Utils/constants/app_colors.dart';
import '../../global widgets/product card/product_card.dart';
import '../../global widgets/product card/product_card_data.dart';
import '../../global widgets/cart_badge.dart';
import '../Cart/cart_screen.dart';
import 'widgets/auto_scroll_chips.dart';

class SubCategoryProductListScreen extends StatefulWidget {
  final CategoryModel subCategory;
  const SubCategoryProductListScreen({super.key, required this.subCategory});

  @override
  State<SubCategoryProductListScreen> createState() =>
      _SubCategoryProductListScreenState();
}

class _SubCategoryProductListScreenState
    extends State<SubCategoryProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final String _sortBy = 'name'; // Default sort by name
  bool _isInit = true;
  late CategoryModel _selectedSubCategory;
  List<CategoryModel> _allSubCategories = [];
  List<dynamic> _allProducts = []; // Cache for all products
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _selectedSubCategory = widget.subCategory;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _initializeData();
      _isInit = false;
    }
  }

  Future<void> _initializeData() async {
    // Initialize subcategories list
    if (widget.subCategory.parentId != null) {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      try {
        final parentCategory = categoryProvider.categories
            .firstWhere((cat) => cat.id == widget.subCategory.parentId);
        if (mounted) {
          setState(() {
            _allSubCategories = parentCategory.subcategories;
          });
        }
      } catch (e) {
        debugPrint('Parent category not found: $e');
      }
    }

    // Fetch all products once
    await _fetchAllProducts();
  }

  Future<void> _fetchAllProducts() async {
    if (!mounted) return;

    setState(() => _isLoadingProducts = true);

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Use the selected category's ID to fetch products
      final products = await productProvider
          .fetchProducts(_selectedSubCategory.id.toString());

      if (mounted) {
        setState(() {
          _allProducts = products;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSubCategorySelected(CategoryModel subCategory) {
    if (mounted) {
      setState(() {
        _selectedSubCategory = subCategory;
      });
      _fetchAllProducts();
    }
  }

  // Filter products by current category
  List<dynamic> _getProductsForCurrentCategory() {
    return _allProducts.where((product) {
      // Check if product's categoryId matches
      final matchesCategoryId = product.categoryId == _selectedSubCategory.id;

      // Check if product's categories list contains this category
      final matchesCategoriesList = product.categories.any((catId) {
        try {
          final parsedId = int.tryParse(catId);
          return parsedId == _selectedSubCategory.id;
        } catch (e) {
          debugPrint('Error parsing category ID: $catId');
          return false;
        }
      });

      final matches = matchesCategoryId || matchesCategoriesList;
      if (matches) {
        debugPrint(
            'Product ${product.productName} matches category ${_selectedSubCategory.name}');
        debugPrint('- categoryId match: $matchesCategoryId');
        debugPrint('- categories list match: $matchesCategoriesList');
      }

      return matches;
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        cursorColor: AppColors.primaryColor,
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.greyColor.withOpacity(0.20),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppColors.greyColor.withOpacity(0.20),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8.r)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12.h,
                      width: 100.w,
                      color: AppColors.greyColor.withOpacity(0.20),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 12.h,
                      width: 60.w,
                      color: AppColors.greyColor.withOpacity(0.20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.w,
            color: AppColors.greyColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.greyColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterAndSortProducts(List<dynamic> products) {
    var filteredProducts = products.where((product) {
      return product.productName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_sortBy) {
      case 'name':
        filteredProducts.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'price_low':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Hero(
          tag: 'subcategory_${widget.subCategory.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              widget.subCategory.name,
              style: TextStyle(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.whiteColor,
          ),
        ),
        actions: [
          CartBadge(
            top: 0,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined,
                  color: AppColors.whiteColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          if (_allSubCategories.isNotEmpty)
            AutoScrollChips<CategoryModel>(
              items: _allSubCategories,
              selectedItem: _selectedSubCategory,
              onItemSelected: _onSubCategorySelected,
              labelBuilder: (category) => category.name,
            ),
          _buildSearchBar(),
          Expanded(
            child: _isLoadingProducts
                ? _buildLoadingSkeleton()
                : RefreshIndicator(
                    color: AppColors.primaryColor,
                    backgroundColor: AppColors.whiteColor,
                    onRefresh: _fetchAllProducts,
                    child: _buildProductGrid(_filterAndSortProducts(
                        _getProductsForCurrentCategory())),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<dynamic> products) {
    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          data: ProductCardData(
            productId: product.productId,
            imageUrl: product.images.isNotEmpty ? product.images[0] : '',
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
          width: double.infinity,
          height: 250.h,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(8.w),
        );
      },
    );
  }
}
