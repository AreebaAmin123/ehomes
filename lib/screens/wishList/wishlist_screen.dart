import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../Utils/constants/app_colors.dart';
import '../ProductDetail/provider/wish_list_provider.dart';
import '../../../models/wish_list_model.dart';
import 'package:flutter/cupertino.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      Provider.of<WishlistProvider>(context, listen: false)
          .fetchWishlist(context);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, provider, _) {
        final List<Wishlist> wishlistItems = provider.wishlistItems;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: AppColors.whiteColor),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            ),
            title: Text('My Wishlist',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor)),
            centerTitle: true,
            backgroundColor: AppColors.primaryColor,
            iconTheme: IconThemeData(color: AppColors.whiteColor),
          ),
          body: wishlistItems.isEmpty
              ? Center(
                  child: Text('Your wishlist is empty.',
                      style:
                          TextStyle(fontSize: 16, color: AppColors.greyColor)))
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  itemCount: wishlistItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = wishlistItems[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      shadowColor: AppColors.primaryColor.withOpacity(0.08),
                      child: ListTile(
                        leading:
                            Icon(Icons.favorite, color: AppColors.primaryColor),
                        title: Text('Product ID: ${item.productId}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wishlist ID: ${item.id}'),
                            Text('Quantity: ${item.quantity ?? '-'}'),
                            Text('Price: PKR ${item.price ?? '-'}'),
                            Text(
                                'Discount Price: PKR ${item.discountPrice ?? '-'}'),
                            Text('Total Price: PKR ${item.totalPrice ?? '-'}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              color: AppColors.redColor, size: 28),
                          tooltip: 'Remove from wishlist',
                          onPressed: () {
                            provider.deleteWishlistById(item.id!, context);
                          },
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
