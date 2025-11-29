import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../provider/support_chat_provider.dart';
import '../support/support_chat_screen.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.boxShadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: AppColors.whiteColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Column(
            children: [
              _buildSupportItem(
                context,
                'Customer Support',
                Icons.support_agent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupportChatScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportItem(BuildContext context, String title, IconData icon,
      {VoidCallback? onTap, bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isLogout ? AppColors.primaryColor : AppColors.blackColor),
      title: Text(title, style: TextStyle(fontSize: 13.sp)),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 13.sp, color: AppColors.blackColor),
      onTap: onTap,
    );
  }
}
