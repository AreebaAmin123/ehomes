import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:e_Home_app/screens/Auth/email%20section/signIn_withEmail.dart';
import 'package:e_Home_app/screens/Auth/email%20section/with%20otp/phone_otp_screen.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class SignupWithEmail extends StatefulWidget {
  const SignupWithEmail({super.key});

  @override
  SignupWithEmailState createState() => SignupWithEmailState();
}

class SignupWithEmailState extends State<SignupWithEmail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  String countryCode = '+92';
  bool isPhoneValid = true;

  @override
  Widget build(BuildContext context) {
    final emailAuthProvider = Provider.of<EmailAuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSecureInfoBanner(),
            _buildOfferSection(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                          _nameController, 'Full Name', Icons.person),
                      _buildTextField(
                          _emailController, 'Email Address', Icons.email,
                          isEmail: true),
                      _buildPhoneField(),
                      _buildTextField(
                          _passwordController, 'Password', Icons.lock,
                          isPassword: true),
                      _buildTextField(_confirmPasswordController,
                          'Confirm Password', Icons.lock,
                          isPassword: true),
                      _buildTextField(_referralController,
                          'Referral Code (Optional)', Icons.card_giftcard),
                      SizedBox(height: 16.h),
                      _buildSignupButton(context, emailAuthProvider),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      backgroundColor: AppColors.primaryColor,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sign Up',
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

  Widget _buildPhoneField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: IntlPhoneField(
        cursorColor: AppColors.primaryColor,
        controller: _phoneController,
        initialCountryCode: 'PK',
        decoration: InputDecoration(
          labelText: 'Phone Number',
          labelStyle: const TextStyle(color: AppColors.greyColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
                color: isPhoneValid
                    ? AppColors.lightGreenColor
                    : AppColors.lightGreenColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
                color: isPhoneValid
                    ? AppColors.primaryColor
                    : AppColors.primaryColor,
                width: 1.0),
          ),
        ),
        onChanged: (phone) {
          setState(() {
            countryCode = phone.countryCode;
            isPhoneValid = phone.number.isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false, bool isEmail = false}) {
    return Consumer<EmailAuthProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: TextFormField(
            controller: controller,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            obscureText: isPassword
                ? (controller == _passwordController
                    ? !provider.isPasswordVisible
                    : !provider.isConfirmPasswordVisible)
                : false,
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
                      icon: Icon(
                        controller == _passwordController
                            ? (provider.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off)
                            : (provider.isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                        color: AppColors.greyColor,
                      ),
                      onPressed: () {
                        if (controller == _passwordController) {
                          provider.togglePasswordVisibility();
                        } else {
                          provider.toggleConfirmPasswordVisibility();
                        }
                      },
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignupButton(BuildContext context, EmailAuthProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading
            ? null
            : () async {
                debugPrint('🔵 Starting signup process...');

                if (!_formKey.currentState!.validate()) {
                  debugPrint('❌ Form validation failed');
                  _showSnackBar(context, 'Please fill all fields correctly');
                  return;
                }

                if (_passwordController.text !=
                    _confirmPasswordController.text) {
                  debugPrint('❌ Passwords do not match');
                  _showSnackBar(context, 'Passwords do not match');
                  return;
                }

                final phoneNumber =
                    "$countryCode${_phoneController.text.trim()}";
                debugPrint('📱 Phone number: $phoneNumber');

                // 🛠️ Call API using provider
                debugPrint('🔄 Calling signUpUser API...');
                final response = await provider.signUpUser(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  phone: phoneNumber,
                  countryCode: countryCode,
                  password: _passwordController.text,
                  confirmPassword: _confirmPasswordController.text,
                  deviceId: '',
                  referralCode: _referralController.text.trim(),
                );

                debugPrint('📥 Received API Response: $response');

                // 🔹 Handle API Response
                if (response == null) {
                  debugPrint('❌ API Response is null');
                  _showSnackBar(
                      context, 'Something went wrong. Please try again.');
                  return;
                }

                // ✅ Direct API Response Check
                final isSuccess = response['success'] == true ||
                    (response['success'] is String &&
                        response['success']
                            .toString()
                            .contains('User registered'));

                debugPrint('✅ Success check: $isSuccess');
                debugPrint('📦 Response data:');
                debugPrint('- success: ${response['success']}');
                debugPrint('- user_id: ${response['user_id']}');
                debugPrint('- otp_id: ${response['otp_id']}');

                if (isSuccess) {
                  if (!mounted) {
                    debugPrint('❌ Widget not mounted');
                    return;
                  }

                  debugPrint('🔄 Navigating to Phone OTP Screen...');
                  // Navigate to Phone OTP Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneOtpScreen(
                        phone: phoneNumber,
                        userId: response['user_id'].toString(),
                        otpId: response['otp_id'].toString(),
                        onVerificationSuccess: () {
                          debugPrint('✅ OTP verification successful');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInWithEmail(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  debugPrint('❌ Signup failed: ${response['message']}');
                  _showSnackBar(
                      context, response['message'] ?? 'An error occurred');
                }
              },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.whiteColor,
          backgroundColor:
              provider.isLoading ? AppColors.greyColor : AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        child: provider.isLoading
            ? CupertinoActivityIndicator(color: AppColors.whiteColor)
            : Text(
                'Sign Up',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

// Helper Function for Showing SnackBars**
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.greyColor,
      ),
    );
  }
}
