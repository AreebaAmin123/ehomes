// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class MyCartCard extends StatelessWidget {
  final String image;
  final String shippedBy;
  final String productName;
  final String storeId;
  final String category;
  final double productPrice;
  final double upcomingRupees;
  final int quantity;
  final Function onAdd;
  final Function onRemove;
  final Function onDelete;

  const MyCartCard({
    required this.image,
    required this.shippedBy,
    required this.productName,
    required this.storeId,
    required this.category,
    required this.productPrice,
    required this.upcomingRupees,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: image,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CupertinoActivityIndicator()),
                errorWidget: (context, url, error) => Container(
                  width: 80.w,
                  height: 80.w,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "PKR ${productPrice.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      // Quantity Controls
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () => onRemove(),
                      ),
                      Text(
                        '$quantity',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () => onAdd(),
                      ),
                      Spacer(),
                      // Remove Button
                      IconButton(
                        icon:
                            Icon(Icons.delete_outline, color: Colors.grey[600]),
                        onPressed: () => onDelete(),
                        tooltip: 'Remove from cart',
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.blue, size: 18),
                      SizedBox(width: 4.w),
                      Text(
                        "Delivery Charges Included",
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
