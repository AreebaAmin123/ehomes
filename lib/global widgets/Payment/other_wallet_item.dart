import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Utils/constants/app_colors.dart';

class OtherWalletItem extends StatelessWidget {
  final String firstText;
  final String secondText;
  final IconData leftIcon;
  final IconData rightIcon;
  final bool showPaymentIcons;
  final VoidCallback onTap;
  final Color containerColor;

  const OtherWalletItem({
    required this.firstText,
    required this.secondText,
    this.leftIcon = Icons.info,
    this.rightIcon = Icons.check_circle,
    this.showPaymentIcons = true,
    required this.onTap,
    this.containerColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isSecondTextVisible = secondText.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(leftIcon, size: 24.sp, color: AppColors.primaryColor),
                SizedBox(width: 6.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      firstText,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    if (isSecondTextVisible)
                      Text(
                        secondText,
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 10.w),
            if (showPaymentIcons)
              Row(
                children: [
                  Icon(FontAwesomeIcons.ccMastercard, size: 14.sp),
                  SizedBox(width: 6.w),
                  Icon(FontAwesomeIcons.ccVisa, size: 14.sp),
                  SizedBox(width: 6.w),
                  Icon(FontAwesomeIcons.ccApplePay, size: 14.sp),
                  SizedBox(width: 10.w),
                ],
              ),
            Icon(rightIcon, size: 14.sp, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
