import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/popup_model.dart';

class PopupModal extends StatelessWidget {
  final List<PopupBanner> banners;
  final VoidCallback onClose;
  final bool isLoading;
  final String? error;

  const PopupModal({
    super.key,
    required this.banners,
    required this.onClose,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 1.sh,
            color: AppColors.blackColor.withValues(alpha: 0.85),
            child: isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : error != null
                    ? Center(
                        child: Text(
                          error!,
                          style: const TextStyle(color: AppColors.whiteColor),
                        ),
                      )
                    : banners.isEmpty
                        ? const SizedBox.shrink()
                        : PageView.builder(
                            itemCount: banners.length,
                            itemBuilder: (context, index) {
                              final banner = banners[index];
                              return GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to product detail page using banner.productId
                                  onClose();
                                },
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 32.h),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: banner.imageUrl,
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CupertinoActivityIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.broken_image,
                                                  color:AppColors.whiteColor,
                                                  size: 80.sp),
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          banner.productName,
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          Positioned(
            top: 100.h,
            right: 0.w,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.whiteColor, size: 32.sp),
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }
}
