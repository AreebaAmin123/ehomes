import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../global widgets/product card/product_card.dart';
import '../../../global widgets/product card/product_card_data.dart';
import '../../../global widgets/cart_badge.dart';
import '../../Cart/cart_screen.dart';
import '../../Categories/provider/product_provider.dart';
import '../product_details_screen.dart';

class RelatedProductsScreen extends StatefulWidget {
  final int categoryId;
  final int currentProductId;

  const RelatedProductsScreen({
    super.key,
    required this.categoryId,
    required this.currentProductId,
  });

  @override
  State<RelatedProductsScreen> createState() => _RelatedProductsScreenState();
}

class _RelatedProductsScreenState extends State<RelatedProductsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRelatedProducts();
  }

  Future<void> _fetchRelatedProducts() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    try {
      await productProvider.fetchProducts(widget.categoryId.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Related Products',
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
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
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          final products = provider
              .getProducts(widget.categoryId.toString())
              .where((product) => product.productId != widget.currentProductId)
              .toList();

          if (products.isEmpty) {
            return Center(
              child: Text(
                'No related products found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyColor,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryColor,
            backgroundColor: AppColors.whiteColor,
            onRefresh: _fetchRelatedProducts,
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  data: ProductCardData(
                    productId: product.productId,
                    imageUrl:
                        product.images.isNotEmpty ? product.images[0] : '',
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
