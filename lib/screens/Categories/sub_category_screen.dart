import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/category/categories_model.dart';
import '../../Utils/constants/app_colors.dart';
import 'widgets/sub_category_list_item.dart';
import 'sub_category_product_list_screen.dart';
import 'widgets/category_products_list.dart';
import 'provider/product_provider.dart';

class SubCategoryScreen extends StatefulWidget {
  final CategoryModel category;
  const SubCategoryScreen({super.key, required this.category});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  bool _isLoading = false;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    if (widget.category.subcategories.isEmpty) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final products =
          await productProvider.fetchProducts(widget.category.id.toString());

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = widget.category.subcategories;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Hero(
          tag: 'category_${widget.category.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              widget.category.name,
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
      ),
      body: subcategories.isEmpty
          ? _isLoading
              ? Center(child: CircularProgressIndicator())
              : CategoryProductsList(
                  category: widget.category,
                  products: _products,
                )
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: subcategories.length,
              separatorBuilder: (context, index) => SizedBox(height: 0),
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                return SubCategoryListItem(
                  subCategory: sub,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubCategoryProductListScreen(
                          subCategory: sub,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
