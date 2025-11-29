import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class ProductList extends StatelessWidget {
  final double containerWidth;
  final String imageUrl;
  final String text;
  final FontWeight textWeight;
  final double textSize;
  final VoidCallback onTap;

  const ProductList({
    super.key,
    required this.containerWidth,
    required this.imageUrl,
    required this.text,
    required this.textWeight,
    required this.textSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: containerWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImage(),
              SizedBox(height: 5.h),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: textWeight,
                    fontSize: textSize.sp,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: Uri.encodeFull(imageUrl),
            height: 116.h,
            width: 116.w,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const Center(child: CupertinoActivityIndicator()),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image, size: 40),
          )
        : const Icon(Icons.image, size: 40);
  }
}
