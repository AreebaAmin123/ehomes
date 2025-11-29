import 'package:e_Home_app/screens/Auth/email%20section/signIn_withEmail.dart';
import 'package:e_Home_app/screens/Dashboard/dashboard_page.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInWidget extends StatelessWidget {
  const SignInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Column(
            children: [
              _buildPartnersText(),
              _buildSecureInfoBanner(),
              _buildOfferSection(),
              SizedBox(height: 40.h),
              Center(
                child: Image.asset(
                  'assets/app_logo/ehomes logo green.png',
                  height: 120.h,
                  width: 120.h,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 40.h),
              _buildLoginOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.h),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          Image.asset(
          'assets/app_logo/white_logo.png',
          height: 60.h,
          width: 60.w,
          fit: BoxFit.contain,
        ),
          ],
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildPartnersText() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(
        'Official E-commerce Services Partner',
        style: TextStyle(color: AppColors.greyColor, fontSize: 12.sp),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// **Secure Info Banner**
  Widget _buildSecureInfoBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.lightGreenColor,
          borderRadius: BorderRadius.circular(6.r)
        ),
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gpp_good, size: 18.sp, color: AppColors.greenColor),
            SizedBox(width: 8.w),
            Text('Your information is protected',
                style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }

  /// **Offer Section**
  Widget _buildOfferSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
      child: Container(
        width: 330.w,
        height: 80.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.primaryColor.withValues(alpha: 0.10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOfferItem(Icons.percent, 'Welcome Deal', 'Upto 70% off'),
              Container(width: 3.w, color: AppColors.whiteColor),
              _buildOfferItem(Icons.local_shipping_outlined, 'Buyer Protection',
                  'Easy returns & refunds'),
            ],
          ),
        ),
      ),
    );
  }

  /// **Offer Item**
  Widget _buildOfferItem(IconData icon, String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14.sp, color: AppColors.primaryColor),
            SizedBox(width: 8.w),
            Text(title,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor)),
          ],
        ),
        Text(subtitle,
            style: TextStyle(fontSize: 10.sp, color: AppColors.blackColor)),
      ],
    );
  }

  Widget _buildLoginOptions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLoginButton(Icons.email, 'Email', AppColors.primaryColor, () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SignInWithEmail()));
        }),
        _buildOrDivider(),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashboardPage()));
          },
          child: Text(
            'Continue as Guest',
            style: TextStyle(
                color: AppColors.blackColor,
                decoration: TextDecoration.underline,
                fontSize: 14.sp),
          ),
        ),
        SizedBox(height: 24.h),
        _buildTermsText(),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildLoginButton(
      IconData icon, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.whiteColor,
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp),
            SizedBox(width: 10.w),
            Text(text,
                style: TextStyle(fontSize: 14.sp, color: AppColors.whiteColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.greyColor)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text('Or', style: TextStyle(fontSize: 12.sp)),
          ),
          const Expanded(child: Divider(color: AppColors.greyColor)),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: Text(
        'By registering for an eHomes account, you agree that you have read and accepted our eHomes Free Membership Agreement and Privacy Policy.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.sp, color: AppColors.greyColor),
      ),
    );
  }
}
