import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/constants/app_colors.dart';

class ProfilePasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback toggleVisibility;
  final String? Function(String?)? validator;

  const ProfilePasswordField({
    Key? key,
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.toggleVisibility,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(fontSize: 15.sp, color: AppColors.blackColor),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.primaryColor),
            onPressed: toggleVisibility,
          ),
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor,
            fontSize: 15.sp,
          ),
          filled: true,
          fillColor: AppColors.scaffoldColor,
          contentPadding:
              EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
