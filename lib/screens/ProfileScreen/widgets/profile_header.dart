import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userPhoto;
  final XFile? newImage;
  final VoidCallback onPickImage;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userPhoto,
    required this.newImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 54.w,
                backgroundColor: AppColors.lightGreyColor.withOpacity(0.18),
                backgroundImage: newImage != null
                    ? FileImage(File(newImage!.path))
                    : (userPhoto.isNotEmpty
                        ? CachedNetworkImageProvider(
                            "https://ehomes.pk/API/$userPhoto?${DateTime.now().millisecondsSinceEpoch}")
                        : null) as ImageProvider?,
                child: (newImage == null && userPhoto.isEmpty)
                    ? Icon(Icons.person, size: 54.w, color: AppColors.greyColor)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 4.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.18),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(7.w),
                  child: Icon(Icons.edit, color: Colors.white, size: 20.w),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          userName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Welcome to your eHomes Profile",
          style: TextStyle(
            color: AppColors.greyColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
