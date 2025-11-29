// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../Utils/constants/app_colors.dart';
//
// class AddShippingAddress extends StatefulWidget {
//   const AddShippingAddress({super.key});
//
//   @override
//   _AddShippingAddressState createState() => _AddShippingAddressState();
// }
//
// class _AddShippingAddressState extends State<AddShippingAddress> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController cityController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController landmarkController = TextEditingController();
//
//   bool isHomeSelected = true;
//   bool isOfficeSelected = false;
//   bool isDefaultAddress = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Add Shipping Address',
//           style: TextStyle(fontSize: 18.sp, color: AppColors.whiteColor, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: AppColors.primaryColor,
//         automaticallyImplyLeading: false,
//       ),
//       backgroundColor: AppColors.scaffoldColor,
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildInputField("Recipient's Name", nameController, "Input the real name"),
//             _buildInputField("Phone Number", phoneController, "Input Phone Number"),
//             _buildInputField("Region/City/District", cityController, "Input Region/City/District"),
//             _buildInputField("Address", addressController, "House no./building/street/area"),
//             _buildInputField("Landmark (Optional)", landmarkController, "Add Additional Info", isRequired: false),
//
//             SizedBox(height: 8.h),
//             _buildAddressCategory(),
//             _buildDefaultAddressToggle(),
//
//             SizedBox(height: 20.h),
//             _buildSaveButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isRequired = true}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: label,
//                 style: TextStyle(color: AppColors.blackColor, fontSize: 12.sp, fontWeight: FontWeight.w600),
//               ),
//               if (isRequired)
//                 TextSpan(
//                   text: '*',
//                   style: TextStyle(color: AppColors.redColor, fontSize: 15.sp),
//                 ),
//             ],
//           ),
//         ),
//         SizedBox(height: 6.h),
//         TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.greyColor),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10.r),
//               borderSide: BorderSide(color: AppColors.greyColor, width: 1.5.w),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10.r),
//               borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5.w),
//             ),
//             contentPadding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
//           ),
//         ),
//         SizedBox(height: 8.h),
//       ],
//     );
//   }
//
//   Widget _buildAddressCategory() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Address Category', style: TextStyle(color: AppColors.blackColor, fontSize: 12.sp)),
//         Row(
//           children: [
//             _buildCheckbox("Home", isHomeSelected, (value) {
//               setState(() {
//                 isHomeSelected = true;
//                 isOfficeSelected = false;
//               });
//             }),
//             _buildCheckbox("Office", isOfficeSelected, (value) {
//               setState(() {
//                 isHomeSelected = false;
//                 isOfficeSelected = true;
//               });
//             }),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDefaultAddressToggle() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text('Default Shipping Address', style: TextStyle(color: AppColors.blackColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
//         Switch(
//           value: isDefaultAddress,
//           activeColor: AppColors.primaryColor,
//           onChanged: (value) {
//             setState(() {
//               isDefaultAddress = value;
//             });
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
//     return Row(
//       children: [
//         Checkbox(
//           value: value,
//           activeColor: AppColors.primaryColor,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
//           onChanged: onChanged,
//         ),
//         Text(label, style: TextStyle(color: AppColors.blackColor, fontSize: 12.sp)),
//       ],
//     );
//   }
//
//   Widget _buildSaveButton() {
//     return Center(
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primaryColor,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//           padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 40.w),
//         ),
//         onPressed: () {
//           _saveAddress();
//         },
//         child: Text("Save Address", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
//
//   void _saveAddress() {
//     // Handle form submission here
//     debugPrint("Saving Address...");
//     debugPrint("Name: ${nameController.text}");
//     debugPrint("Phone: ${phoneController.text}");
//     debugPrint("City: ${cityController.text}");
//     debugPrint("Address: ${addressController.text}");
//     debugPrint("Landmark: ${landmarkController.text}");
//     debugPrint("Category: ${isHomeSelected ? "Home" : "Office"}");
//     debugPrint("Default: $isDefaultAddress");
//   }
// }
