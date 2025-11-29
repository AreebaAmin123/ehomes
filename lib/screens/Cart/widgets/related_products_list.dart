import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../global widgets/product card/product_card.dart';
import '../../../global widgets/product card/product_card_data.dart';
import '../../../models/product/product_model.dart';
import '../../../models/cart/get_cart_model.dart';
import '../../Categories/provider/product_provider.dart';
import '../../ProductDetail/product_details_screen.dart';
import '../provider/cart_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// Data class for passing to compute
class _RecommendationData {
  final List<ProductModel> allProducts;
  final List<ProductModel> cartProducts;
  final Map<int, double> productScores;

  _RecommendationData({
    required this.allProducts,
    required this.cartProducts,
    required this.productScores,
  });
}

class CartRelatedProductsList extends StatefulWidget {
  const CartRelatedProductsList({super.key});

  @override
  State<CartRelatedProductsList> createState() =>
      _CartRelatedProductsListState();
}

class _CartRelatedProductsListState extends State<CartRelatedProductsList> {
  bool _isLoading = true;
  List<ProductModel> _relatedProducts = [];
  bool _isInitialized = false;
  Map<String, List<ProductModel>> _categoryCache = {};
  Map<int, double> _productScores = {};

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
    await _initializeProducts();
  }

  Future<void> _initializeProducts() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);

      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      const defaultCategory = "1";

      // Get cart items
      final cartItems = cartProvider.cartModel?.cart ?? [];

      // Get products from cache first
      var products = productProvider.getProducts(defaultCategory);

      // Only fetch if cache is empty
      if (products.isEmpty) {
        products = await productProvider.fetchProducts(defaultCategory);
        if (!mounted) return;
      }

      List<ProductModel> recommendations = [];

      if (cartItems.isEmpty) {
        // For empty cart, show all available products sorted by rating
        recommendations = await compute(
            _sortProductsByRating, List<ProductModel>.from(products));
      } else {
        // Find the actual ProductModel objects for cart items
        final cartProducts = products
            .where(
                (p) => cartItems.any((item) => item.productId == p.productId))
            .toList();

        if (cartProducts.isEmpty) {
          recommendations = await compute(
              _sortProductsByRating, List<ProductModel>.from(products));
        } else {
          // Cache product scores for each category
          await _cacheProductScores(products, cartProducts);

          // Get recommendations based on all cart items using compute
          final recommendationData = _RecommendationData(
            allProducts: products,
            cartProducts: cartProducts,
            productScores: _productScores,
          );
          recommendations =
              await compute(_getCartBasedRecommendations, recommendationData);
        }
      }

      if (mounted) {
        setState(() {
          _relatedProducts = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading related products: $e');
      if (mounted) {
        setState(() {
          _relatedProducts = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cacheProductScores(
    List<ProductModel> allProducts,
    List<ProductModel> cartProducts,
  ) async {
    final result = await compute(
      _calculateProductScores,
      _RecommendationData(
        allProducts: allProducts,
        cartProducts: cartProducts,
        productScores: {},
      ),
    );
    _productScores = result;
  }

  static Map<int, double> _calculateProductScores(_RecommendationData data) {
    final Map<int, double> scores = {};
    final Set<int> cartProductIds =
        data.cartProducts.map((p) => p.productId).toSet();

    for (final product in data.allProducts) {
      if (cartProductIds.contains(product.productId)) continue;

      double score = 0.0;
      for (final cartProduct in data.cartProducts) {
        // Category match
        if (product.categoryId == cartProduct.categoryId) {
          score += 2.0;
        }
        // Check categories list
        final productCategories = product.categories.toSet();
        final cartProductCategories = cartProduct.categories.toSet();
        final commonCategories =
            productCategories.intersection(cartProductCategories);
        score += commonCategories.length * 1.5;

        // Price range match
        final priceRatio = product.price / cartProduct.price;
        if (priceRatio >= 0.8 && priceRatio <= 1.2) {
          score += 1.0;
        }

        // Brand match
        if (product.brandId == cartProduct.brandId ||
            product.brandName.toLowerCase() ==
                cartProduct.brandName.toLowerCase()) {
          score += 1.5;
        }

        // Tag matching
        final productTags =
            product.tags.map((t) => t.tagName.toLowerCase()).toSet();
        final cartProductTags =
            cartProduct.tags.map((t) => t.tagName.toLowerCase()).toSet();
        final commonTags = productTags.intersection(cartProductTags);
        score += commonTags.length * 1.0;

        // Rating and availability
        score += (product.rating / 5.0) + (product.stock > 0 ? 0.5 : 0);
      }

      scores[product.productId] = score / data.cartProducts.length;
    }

    return scores;
  }

  // Helper method to calculate product similarity score
  double _calculateSimilarityScore(
      ProductModel product, ProductModel cartProduct) {
    double score = 0.0;

    // Category match gives highest weight
    if (product.categories.any((cat) => cartProduct.categories.contains(cat))) {
      score += 5.0;
    }

    // Tag matches
    final productTags =
        product.tags.map((t) => t.tagName.toLowerCase()).toSet();
    final cartTags =
        cartProduct.tags.map((t) => t.tagName.toLowerCase()).toSet();
    final commonTags = productTags.intersection(cartTags);
    score += commonTags.length * 2.0;

    // Price range similarity (within 20% range)
    final priceRange = cartProduct.price * 0.2;
    if ((product.price - cartProduct.price).abs() <= priceRange) {
      score += 2.0;
    }

    // Brand match
    if (product.brandName.toLowerCase() ==
        cartProduct.brandName.toLowerCase()) {
      score += 3.0;
    }

    return score;
  }

  // Get recommendations for a single product
  List<ProductModel> _getSingleProductRecommendations(
      List<ProductModel> allProducts, ProductModel cartProduct, int limit) {
    final recommendations = allProducts
        .where((p) =>
            p.productId != cartProduct.productId) // Exclude the cart product
        .map((product) =>
            MapEntry(product, _calculateSimilarityScore(product, cartProduct)))
        .where((entry) =>
            entry.value > 0) // Only include products with some similarity
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort by similarity score

    return recommendations.take(limit).map((entry) => entry.key).toList();
  }

  // Get merged recommendations for multiple products
  List<ProductModel> _getMergedRecommendations(
      List<ProductModel> allProducts,
      List<CartModel> cartItems,
      List<ProductModel> cartProducts,
      int totalLimit) {
    // Map to store product scores
    final Map<int, double> productScores = {};

    // Calculate scores for each product against each cart item
    for (var product in allProducts) {
      if (cartItems.any((item) => item.id == product.productId)) {
        continue; // Skip products already in cart
      }

      double totalScore = 0;
      for (var cartProduct in cartProducts) {
        totalScore += _calculateSimilarityScore(product, cartProduct);
      }

      // Average score based on number of cart items
      if (totalScore > 0) {
        productScores[product.productId] = totalScore / cartProducts.length;
      }
    }

    // Sort products by score and return top recommendations
    return allProducts
        .where((p) => productScores.containsKey(p.productId))
        .toList()
      ..sort((a, b) => (productScores[b.productId] ?? 0)
          .compareTo(productScores[a.productId] ?? 0));
  }

  // Static method for compute to sort products by rating
  static List<ProductModel> _sortProductsByRating(List<ProductModel> products) {
    return List<ProductModel>.from(products)
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // Static method for compute to calculate recommendations
  static List<ProductModel> _getCartBasedRecommendations(
      _RecommendationData data) {
    // Create a map to store product scores
    final Map<int, double> productScores = {};
    final Set<int> cartProductIds =
        data.cartProducts.map((p) => p.productId).toSet();

    // Calculate scores for each product
    for (final product in data.allProducts) {
      // Skip products already in cart
      if (cartProductIds.contains(product.productId)) continue;

      double score = 0.0;

      for (final cartProduct in data.cartProducts) {
        // Category match (using both categoryId and categories list)
        if (product.categoryId == cartProduct.categoryId) {
          score += 2.0;
        }
        // Check for category matches in the categories list
        final productCategories = product.categories.toSet();
        final cartProductCategories = cartProduct.categories.toSet();
        final commonCategories =
            productCategories.intersection(cartProductCategories);
        score += commonCategories.length * 1.5;

        // Price range match (within 20% range)
        final priceRatio = product.price / cartProduct.price;
        if (priceRatio >= 0.8 && priceRatio <= 1.2) {
          score += 1.0;
        }

        // Brand match (using both brandId and brandName)
        if (product.brandId == cartProduct.brandId ||
            product.brandName.toLowerCase() ==
                cartProduct.brandName.toLowerCase()) {
          score += 1.5;
        }

        // Tag matching
        final productTags =
            product.tags.map((t) => t.tagName.toLowerCase()).toSet();
        final cartProductTags =
            cartProduct.tags.map((t) => t.tagName.toLowerCase()).toSet();
        final commonTags = productTags.intersection(cartProductTags);
        score += commonTags.length * 1.0;

        // Rating consideration
        score += (product.rating / 5.0);

        // Stock availability boost
        if (product.stock > 0) {
          score += 0.5;
        }

        // Discount consideration
        if (product.discountPrice > 0) {
          final discountPercentage =
              ((product.price - product.discountPrice) / product.price) * 100;
          if (discountPercentage > 0) {
            score += 0.5;
          }
        }
      }

      // Store the average score
      productScores[product.productId] = score / data.cartProducts.length;
    }

    // Sort products by score and return all products
    return data.allProducts
        .where((p) => !cartProductIds.contains(p.productId))
        .toList()
      ..sort((a, b) =>
          productScores[b.productId]!.compareTo(productScores[a.productId]!));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_relatedProducts.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              "You May Also Like",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: _relatedProducts.length, // Show all related products
              itemBuilder: (context, index) {
                final product = _relatedProducts[index];
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
        child: Text(
          'No related products found',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyColor,
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(CartRelatedProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if cart has changed
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cartModel?.cart ?? [];

    // Only update recommendations if cart items have changed
    if (_relatedProducts.isNotEmpty && cartItems.isNotEmpty) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final products = productProvider.getProducts("1");

      if (products.isNotEmpty) {
        final cartProducts = products
            .where(
                (p) => cartItems.any((item) => item.productId == p.productId))
            .toList();

        if (cartProducts.isNotEmpty) {
          _cacheProductScores(products, cartProducts).then((_) {
            compute(
              _getCartBasedRecommendations,
              _RecommendationData(
                allProducts: products,
                cartProducts: cartProducts,
                productScores: _productScores,
              ),
            ).then((recommendations) {
              if (mounted) {
                setState(() => _relatedProducts = recommendations);
              }
            });
          });
        }
      }
    }
  }
}
