import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:e_Home_app/screens/Auth/email%20section/signIn_withEmail.dart';
import 'package:e_Home_app/screens/Checkout/provider/checkout_provider.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:e_Home_app/Utils/constants/my_sharePrefs.dart';
import 'package:e_Home_app/Utils/helpers/show_toast_dialouge.dart';
import 'package:e_Home_app/screens/ProfileScreen/provider/profile_provider.dart';

import 'Payment/payment_screen.dart';

class BillingDetailsScreen extends StatefulWidget {
  const BillingDetailsScreen({super.key});

  @override
  State<BillingDetailsScreen> createState() => _BillingDetailsScreenState();
}

class _BillingDetailsScreenState extends State<BillingDetailsScreen> {
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final checkoutProvider =
          Provider.of<CheckoutProvider>(context, listen: false);
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      // Fetch states for shipping
      await checkoutProvider.fetchStates();

      // Fetch user profile data
      await profileProvider.fetchUserData(context);

      // Load user data into controllers
      final user = profileProvider.userDataModel?.profile;
      if (user != null) {
        // Split full name into first and last name
        final nameParts = (user.userName ?? '').split(' ');
        _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
        _lastNameController.text =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
      }

      // Load saved billing details if any
      final prefs = MySharedPrefs();
      final details = await prefs.getBillingDetails();
      if (details != null) {
        _firstNameController.text =
            details['first_name'] ?? _firstNameController.text;
        _lastNameController.text =
            details['last_name'] ?? _lastNameController.text;
        _emailController.text = details['email'] ?? _emailController.text;
        _phoneController.text = details['phone'] ?? _phoneController.text;
        _addressController.text = details['address'] ?? _addressController.text;
        _cityController.text = details['city'] ?? '';
        _notesController.text = details['order_notes'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
      ShowToastDialog.show(
        context,
        'Failed to load user data. Please try again.',
        type: ToastType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CheckoutProvider>(context);
    final shippingCharges = provider.shippingStates?.shippingCharges ?? [];

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Billing Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
          onPressed: () {
            provider.resetSelectedState();
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8FAFB), Color(0xFFE8F0F8)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Personal Information'),
                        SizedBox(height: 8.h),
                        _buildTextField('First Name', _firstNameController),
                        SizedBox(height: 10.h),
                        _buildTextField('Last Name', _lastNameController),
                        SizedBox(height: 10.h),
                        _buildTextField('Email', _emailController,
                            keyboardType: TextInputType.emailAddress),
                        SizedBox(height: 10.h),
                        _buildTextField('Phone', _phoneController,
                            keyboardType: TextInputType.phone),
                        SizedBox(height: 20.h),
                        _buildSectionTitle('Address Information'),
                        SizedBox(height: 8.h),
                        _buildTextField('Address', _addressController),
                        SizedBox(height: 10.h),
                        _buildTextField('City', _cityController),
                        SizedBox(height: 12.h),
                        Text('State',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                                fontSize: 15.sp)),
                        SizedBox(height: 8.h),
                        DropdownButtonFormField2<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          hint: Text('Select State'),
                          items: shippingCharges.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.state,
                              child: Text(e.state ?? ''),
                            );
                          }).toList(),
                          value: provider.selectedState,
                          onChanged: (value) {
                            provider.setSelectedState(value);
                          },
                          validator: (value) =>
                              value == null ? 'Please select a state' : null,
                        ),
                        SizedBox(height: 8.h),
                        if (provider.shippingCharge != null)
                          Text(
                            'Shipping Charge: Rs. ${provider.shippingCharge}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        SizedBox(height: 14.h),
                        _buildSectionTitle('Additional'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                            'Order Notes (Optional)', _notesController,
                            maxLines: 3),
                        SizedBox(height: 18.h),
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Have a coupon?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            tilePadding: EdgeInsets.symmetric(horizontal: 15),
                            childrenPadding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.whiteColor,
                            collapsedBackgroundColor: AppColors.whiteColor,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _couponController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Coupon Code',
                                        filled: true,
                                        fillColor: AppColors.whiteColor,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 14),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_couponController.text.isNotEmpty) {
                                          FocusScope.of(context).unfocus();
                                          await provider.getCouponDiscount(
                                              _couponController.text.trim());

                                          final discount = provider
                                              .couponCodeModel?.discount;

                                          ShowToastDialog.show(
                                            context,
                                            discount != null
                                                ? 'Coupon applied! Discount: Rs. $discount'
                                                : 'Invalid coupon code. Please try again.',
                                            type: discount != null
                                                ? ToastType.success
                                                : ToastType.error,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                        ),
                                      ),
                                      child: Text(
                                        'Apply',
                                        style: TextStyle(
                                            color: AppColors.whiteColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (provider.couponCodeModel?.discount != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: Text(
                                    'Discount Applied: Rs. ${provider.couponCodeModel?.discount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.greenColor,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Container(
            color: AppColors.whiteColor,
            width: double.infinity,
            height: 35.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                // padding: EdgeInsets.symmetric(vertical: 14.h),
                elevation: 0,
              ),
              onPressed: () async {
                print('[DEBUG] Continue to Payment button pressed');
                final authProvider =
                    Provider.of<EmailAuthProvider>(context, listen: false);
                await authProvider.loadUserSession();
                if (authProvider.user?.id == null) {
                  ShowToastDialog.show(
                    context,
                    "Login before shopping",
                    type: ToastType.error,
                  );
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignInWithEmail()));
                  return;
                }
                if (_formKey.currentState!.validate()) {
                  final selectedState = provider.selectedState;
                  if (selectedState == null || selectedState.isEmpty) {
                    ShowToastDialog.show(
                      context,
                      'Please select a state.',
                      type: ToastType.error,
                    );
                    return;
                  }
                  final couponAmount = provider.couponCodeModel?.discount;

                  /// Save billing details for next time
                  final prefs = MySharedPrefs();
                  await prefs.saveBillingDetails({
                    "first_name": _firstNameController.text,
                    "last_name": _lastNameController.text,
                    "email": _emailController.text,
                    "phone": _phoneController.text,
                    "address": _addressController.text,
                    "city": _cityController.text,
                    "order_notes": _notesController.text,
                  });
                  Map<String, dynamic> data = {
                    "first_name": _firstNameController.text,
                    "last_name": _lastNameController.text,
                    "email": _emailController.text,
                    "phone": _phoneController.text,
                    "address": _addressController.text,
                    "city": _cityController.text,
                    "state": selectedState,
                    "order_notes": _notesController.text,
                    "discount": 0,
                    "coupon_code": _couponController.text,
                    "coupon_amount": couponAmount,
                    "shipping_charge": provider.shippingCharge ?? 0,
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(data: data),
                    ),
                  );
                }
              },
              child: Text(
                'Continue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  // letterSpacing: 0.2,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        cursorColor: AppColors.primaryColor,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.primaryColor),
          filled: true,
          fillColor: AppColors.whiteColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (label.contains('(Optional)')) return null;
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
