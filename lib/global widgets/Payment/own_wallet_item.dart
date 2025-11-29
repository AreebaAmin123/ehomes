import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Utils/constants/app_colors.dart';

class OwnWalletItem extends StatelessWidget {
  final String firstText;
  final String secondText;
  final String amount;
  final IconData leftIcon;
  final IconData rightIcon;

  const OwnWalletItem({
    required this.firstText,
    required this.secondText,
    required this.amount,
    this.leftIcon = Icons.info,
    this.rightIcon = Icons.check_circle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor),
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
                  Text(
                    secondText,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Rs.$amount',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6.w),
              Icon(rightIcon, size: 22.sp, color: AppColors.primaryColor),
            ],
          ),
        ],
      ),
    );
  }
}
