import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../provider/email_authProvider.dart';

class PhoneOtpScreen extends StatefulWidget {
  final String phone;
  final String userId;
  final String otpId;
  final VoidCallback onVerificationSuccess;

  const PhoneOtpScreen({
    super.key,
    required this.phone,
    required this.userId,
    required this.otpId,
    required this.onVerificationSuccess,
  });

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  String _otpCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: Consumer<EmailAuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSecureInfoBanner(),
              SizedBox(height: 60.h),
              _buildHeader(),
              SizedBox(height: 24.h),
              _buildOtpFields(),
              SizedBox(height: 24.h),
              _buildResendOption(authProvider),
              const Spacer(),
              _buildVerifyButton(authProvider),
              SizedBox(height: 35.h),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Verify Phone',
              style: TextStyle(
                  fontSize: 18.sp,
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold)),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Phone Verification",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text("Enter the OTP sent to",
            style: TextStyle(color: AppColors.greyColor, fontSize: 12.sp)),
        SizedBox(height: 4.h),
        Text(widget.phone,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSecureInfoBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Container(
        color: AppColors.lightGreenColor,
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

  Widget _buildOtpFields() {
    return OtpTextField(
      numberOfFields: 6,
      cursorColor: AppColors.primaryColor,
      focusedBorderColor: AppColors.greenColor,
      enabledBorderColor: AppColors.lightGreenColor,
      fieldWidth: 40.sp,
      showFieldAsBox: true,
      textStyle: TextStyle(fontSize: 18.sp),
      borderRadius: BorderRadius.circular(10.r),
      onSubmit: (code) => setState(() => _otpCode = code),
    );
  }

  Widget _buildResendOption(EmailAuthProvider authProvider) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Didn't receive code?",
              style: TextStyle(color: AppColors.greyColor, fontSize: 12.sp)),
          GestureDetector(
            onTap: authProvider.isLoading
                ? null
                : () => authProvider.requestSmsOtp(widget.phone),
            child: Text(
              " Resend Code",
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(EmailAuthProvider authProvider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        fixedSize: Size(220.w, 35.h),
      ),
      onPressed: authProvider.isLoading ? null : _verifyOtp(authProvider),
      child: authProvider.isLoading
          ? const CupertinoActivityIndicator(color: AppColors.whiteColor)
          : Text('Verify OTP',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor)),
    );
  }

  VoidCallback _verifyOtp(EmailAuthProvider authProvider) {
    return () async {
      if (_otpCode.isNotEmpty) {
        final response = await authProvider.verifySmsOtp(
          userId: widget.userId,
          otpId: widget.otpId,
          otpCode: _otpCode,
          phone: widget.phone,
        );

        if (response?['success'] == true) {
          widget.onVerificationSuccess();
        } else {
          _showSnackBar(response?['message'] ?? "Invalid OTP");
        }
      } else {
        _showSnackBar("Please enter OTP");
      }
    };
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
