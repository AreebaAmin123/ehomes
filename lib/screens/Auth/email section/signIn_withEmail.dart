import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:e_Home_app/screens/Auth/email%20section/signup_withEmail.dart';
import 'package:e_Home_app/screens/Auth/email%20section/with%20otp/signInWith_emailOtp.dart';
import 'package:e_Home_app/screens/Dashboard/dashboard_page.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../Utils/helpers/show_toast_dialouge.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({super.key});

  @override
  State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final emailAuthProvider = Provider.of<EmailAuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        _emailController,
                        "Email",
                        Icons.email,
                        isEmail: true,
                        autofillHints: [
                          AutofillHints.username,
                          AutofillHints.email
                        ],
                      ),
                      _buildTextField(
                        _passwordController,
                        "Password",
                        Icons.lock,
                        isPassword: true,
                        autofillHints: [AutofillHints.password],
                      ),
                      SizedBox(height: 20.h),
                      _buildLoginButton(emailAuthProvider),
                      SizedBox(height: 20.h),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLoginWithEmailOTP(),
                          SizedBox(height: 15.h),
                          _buildSignupText(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sign In',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: AppColors.whiteColor)),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildSecureInfoBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
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

  Widget _buildOfferSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Container(
        width: 330.w,
        height: 80.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.primaryColor.withOpacity(0.10),
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

  Widget _buildOfferItem(IconData icon, String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: AppColors.primaryColor),
            SizedBox(width: 8.w),
            Text(title,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(subtitle, style: TextStyle(fontSize: 10.sp)),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
    List<String>? autofillHints,
  }) {
    return Consumer<EmailAuthProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: TextFormField(
            controller: controller,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            obscureText: isPassword ? !provider.isPasswordVisible : false,
            autofillHints: autofillHints,
            cursorColor: AppColors.greyColor,
            decoration: InputDecoration(
              labelText: hint,
              labelStyle: const TextStyle(color: AppColors.greyColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppColors.lightGreenColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide:
                    const BorderSide(color: AppColors.primaryColor, width: 1.0),
              ),
              prefixIcon: Icon(icon, color: AppColors.lightGreenColor),
              suffixIcon: isPassword
                  ? IconButton(
                      highlightColor: Colors.transparent,
                      icon: Icon(
                        provider.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.greyColor,
                      ),
                      onPressed: provider.togglePasswordVisibility,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(EmailAuthProvider emailAuthProvider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1,
      child: ElevatedButton(
        onPressed: emailAuthProvider.isLoading
            ? null
            : _handleLogin(emailAuthProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
        child: emailAuthProvider.isLoading
            ? const CupertinoActivityIndicator(color: AppColors.whiteColor)
            : Text("Login",
                style: TextStyle(fontSize: 14.sp, color: AppColors.whiteColor)),
      ),
    );
  }

  VoidCallback? _handleLogin(EmailAuthProvider emailAuthProvider) {
    return () async {
      if (_formKey.currentState!.validate()) {
        final response = await emailAuthProvider.loginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response != null) {
          if (response["success"] == true) {
            if (!mounted) return;
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const DashboardPage()));
          } else {
            if (!mounted) return;
            ShowToastDialog.show(
              context,
              response["message"] ?? "Login failed",
              type: ToastType.error,
            );
          }
        } else {
          if (!mounted) return;
          ShowToastDialog.show(
            context,
            "Connection error. Please try again.",
            type: ToastType.error,
          );
        }
      }
    };
  }

  Widget _buildSignupText() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SignupWithEmail())),
      child: Text(
        "Sign Up",
        style: TextStyle(
          color: AppColors.blackColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoginWithEmailOTP() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SignInWithEmailOTP())),
      child: Text(
        "Forgot password? Tap here with OTP",
        style: TextStyle(
            color: AppColors.greyColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
