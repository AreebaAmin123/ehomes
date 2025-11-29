// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../Utils/constants/app_colors.dart';
// import 'widgets/saved_address_widget.dart';
// import 'add_shipping_address.dart';
//
// class SelectShippingAddress extends StatelessWidget {
//   const SelectShippingAddress({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       backgroundColor: AppColors.scaffoldColor,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
//           child: Column(
//             children: [
//               _buildAddAddressButton(context),
//               SizedBox(height: 8.h),
//               _buildSavedAddresses(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   AppBar _buildAppBar() {
//     return AppBar(
//       title: Text(
//         'Select Shipping Address',
//         style: TextStyle(
//           fontSize: 18.sp,
//           color: AppColors.whiteColor,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       centerTitle: true,
//       backgroundColor: AppColors.primaryColor,
//       automaticallyImplyLeading: false,
//     );
//   }
//
//   Widget _buildAddAddressButton(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 90.h,
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.greyColor),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Center(
//         child: TextButton(
//           onPressed: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddShippingAddress()),
//           ),
//           child: Text(
//             '+ Address',
//             style: TextStyle(fontSize: 16.sp, color: AppColors.blackColor),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSavedAddresses() {
//     return const Column(
//       children: [
//         SavedAddressWidget(
//           userName: 'Abdul Rehman',
//           phone: '03401607563',
//           address: 'Wazirabad Road , Harrar , Sialkot',
//           city: 'Punjab , Sialkot',
//         ),
//       ],
//     );
//   }
// }
