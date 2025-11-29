// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../../Utils/constants/app_colors.dart';
//
// class SavedAddressWidget extends StatelessWidget {
//   final String userName;
//   final String city;
//   final String phone;
//   final String address;
//
//   const SavedAddressWidget({
//     required this.userName,
//     required this.city,
//     required this.phone,
//     required this.address,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 8.h),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // _buildImageContainer(),
//               SizedBox(width: 8.w),
//               Expanded(child: _buildAddressDetails()),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget _buildImageContainer() {
//   //   return Container(
//   //     padding: EdgeInsets.all(8.r),
//   //     decoration: BoxDecoration(
//   //       borderRadius: BorderRadius.circular(8.r),
//   //     ),
//   //     child: Image.asset(
//   //       'assets/images/img.png',
//   //       width: 60.w,
//   //       height: 60.h,
//   //       fit: BoxFit.contain,
//   //     ),
//   //   );
//   // }
//
//   Widget _buildAddressDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildUserInfoRow(),
//         SizedBox(height: 2.h),
//         Text(
//           address,
//           style: TextStyle(fontSize: 13.sp),
//         ),
//         SizedBox(height: 2.h),
//         Text(
//           city,
//           style: TextStyle(fontSize: 12.sp),
//         ),
//         SizedBox(height: 4.h),
//         _buildDefaultAddressLabel(),
//       ],
//     );
//   }
//
//   Widget _buildUserInfoRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               userName,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(width: 6.w),
//             Text(
//               phone,
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: AppColors.greyColor,
//               ),
//             ),
//           ],
//         ),
//         Text(
//           'Edit',
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: AppColors.primaryColor,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDefaultAddressLabel() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(4.r),
//         border: Border.all(color: AppColors.primaryColor),
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 6.w),
//         child: Text(
//           'Default Shipping Address',
//           style: TextStyle(
//             fontSize: 10.sp,
//             color: AppColors.redColor,
//           ),
//         ),
//       ),
//     );
//   }
// }
