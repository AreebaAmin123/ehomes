import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../Utils/constants/app_colors.dart';
import '../../../../../../models/home screen/vendor/vendor_model.dart';
import '../vendor product list/vendor_products_screen.dart';

class VendorCard extends StatelessWidget {
  final VendorModel vendor;
  final bool isSimpleView;

  const VendorCard({
    super.key,
    required this.vendor,
    this.isSimpleView = false,
  });

  bool get _isSvgImage => vendor.photo.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSimpleView ? 2.h : 5.h),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorProductsScreen(vendor: vendor),
          ),
        ),
        child: Container(
          width: isSimpleView ? 110.w : 160.w,
          constraints: BoxConstraints(
            minHeight: isSimpleView ? 110.h : 180.h,
            maxHeight: isSimpleView ? 130.h : 200.h,
          ),
          margin: EdgeInsets.symmetric(horizontal: isSimpleView ? 4.w : 6.w),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.boxShadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isSimpleView) SizedBox(height: 16.h),
              _buildVendorAvatar(),
              SizedBox(height: isSimpleView ? 4.h : 8.h),
              if (isSimpleView) _buildSimpleInfo() else _buildDetailedInfo(),
              if (!isSimpleView) SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        vendor.storeName.isEmpty ? 'Unknown Store' : vendor.storeName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
              ),
      ),
    );
  }

  Widget _buildDetailedInfo() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            vendor.storeName.isEmpty ? 'Unknown Store' : vendor.storeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 4.h),
          _buildRatingRow(),
          if (vendor.phone.isNotEmpty || vendor.address.isNotEmpty)
            Flexible(
                child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (vendor.phone.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                    _buildContactRow(
                      icon: Icons.phone,
                      text: vendor.phone,
                    ),
                  ],
                  if (vendor.address.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    _buildContactRow(
                      icon: Icons.location_on,
                      text: vendor.address,
                    ),
                  ],
                ],
                  ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildVendorAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: isSimpleView ? 38.r : 40.r,
        backgroundColor: AppColors.lightGreyColor.withValues(alpha: 0.2),
        child: ClipOval(
          child: SizedBox(
            width: isSimpleView ? 76.w : 80.w,
            height: isSimpleView ? 76.w : 80.w,
            child: vendor.photo.isNotEmpty
                ? _isSvgImage
                    ? SvgPicture.network(
                        vendor.photo,
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => Center(
                          child: SizedBox(
                            width: isSimpleView ? 22.w : 24.w,
                            height: isSimpleView ? 22.h : 24.h,
                            child: const CupertinoActivityIndicator(),
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: vendor.photo,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: isSimpleView ? 22.w : 24.w,
                            height: isSimpleView ? 22.h : 24.h,
                            child: const CupertinoActivityIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildPlaceholderIcon(),
                      )
                : _buildPlaceholderIcon(),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          Icon(Icons.star, size: 12.sp, color: AppColors.yellowColor),
        SizedBox(width: 2.w),
        Text(
          vendor.avgRating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
          ),
        ),
        Text(
          ' (${vendor.totalReviews})',
          style: TextStyle(
              fontSize: 10.sp,
            color: AppColors.greyColor,
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 11.sp, color: AppColors.primaryColor),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.greyColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderIcon() {
    return Icon(
        Icons.store,
      size: isSimpleView ? 38.sp : 35.sp,
      color: AppColors.greyColor,
    );
  }
}
