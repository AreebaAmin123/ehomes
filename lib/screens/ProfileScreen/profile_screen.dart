import 'dart:io';

import 'package:e_Home_app/screens/ProfileScreen/provider/profile_provider.dart';
import 'package:e_Home_app/screens/ProfileScreen/widgets/social_button.dart';
import 'package:e_Home_app/screens/Settings/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/constants/AppTextWidgets.dart';
import 'widgets/support_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_section.dart';
import 'widgets/profile_field.dart';
import 'widgets/profile_password_field.dart';
import '../../Utils/helpers/show_toast_dialouge.dart';
import 'package:e_Home_app/screens/Auth/signIn_widget.dart';
import 'package:e_Home_app/screens/Auth/email section/provider/email_authProvider.dart';
import '../Settings/info_pages/terms_conditions_screen.dart';
import '../Settings/info_pages/privacy_policy_screen.dart';
import '../Settings/info_pages/faq_screen.dart';
import '../Settings/info_pages/delivery_info_screen.dart';
import '../Settings/info_pages/return_refund_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  XFile? _newImage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.fetchUserData(context);
      if (mounted) {
        final user = provider.userDataModel?.profile;
        if (user != null) {
          _emailController.text = user.email ?? "";
          _phoneController.text = user.phone ?? "";
          _addressController.text = user.address ?? "";
          provider.setInitialized(true);
        }
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newImage = image;
      });
    }
  }

  Widget _buildInfoLink(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 20.h, color: AppColors.primaryColor),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.blackColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.h,
              color: AppColors.greyColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return ProfileSection(
      title: 'Information',
      icon: Icons.info_outline,
      initiallyExpanded: false,
      children: [
        _buildInfoLink(
          Icons.description_outlined,
          'Terms & Conditions',
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TermsConditionsScreen()),
          ),
        ),
        _buildInfoLink(
          Icons.privacy_tip_outlined,
          'Privacy Policy',
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen()),
          ),
        ),
        // _buildInfoLink(
        //   Icons.contact_support_outlined,
        //   'Contact Us',
        //   () => Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const ContactUs()),
        //   ),
        // ),
        _buildInfoLink(
          Icons.help_outline,
          'FAQs',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FAQScreen()),
          ),
        ),
        _buildInfoLink(
          Icons.local_shipping,
          'Delivery Information',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DeliveryInfoScreen()),
          ),
        ),
        _buildInfoLink(
          Icons.assignment_return_outlined,
          'Return & Refund Policy',
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ReturnRefundPolicyScreen()),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            final isLoading =
                provider.userDataModel == null || !provider.isInitialized;
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: isLoading
                            ? _buildShimmerUI()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ProfileHeader(
                                    userName: provider
                                            .userDataModel?.profile?.userName ??
                                        '',
                                    userPhoto: provider.userDataModel?.profile
                                            ?.userPhoto ??
                                        '',
                                    newImage: _newImage,
                                    onPickImage: _pickImage,
                                  ),
                                  SizedBox(height: 18.h),
                                  ProfileSection(
                                    title: 'Personal Information',
                                    icon: Icons.person_outline,
                                    children: [
                                      ProfileField(
                                        label: 'Email',
                                        controller: _emailController,
                                        icon: Icons.email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      ProfileField(
                                        label: 'Phone',
                                        controller: _phoneController,
                                        icon: Icons.phone,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      ProfileField(
                                        label: 'Address',
                                        controller: _addressController,
                                        icon: Icons.location_on,
                                        keyboardType:
                                            TextInputType.streetAddress,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  ProfileSection(
                                    title: 'Security',
                                    icon: Icons.lock_outline,
                                    initiallyExpanded: false,
                                    children: [
                                      ProfilePasswordField(
                                        label: 'Password',
                                        controller: _passwordController,
                                        obscureText: provider.obscurePassword,
                                        toggleVisibility:
                                            provider.toggleObscurePassword,
                                      ),
                                      ProfilePasswordField(
                                        label: 'Confirm Password',
                                        controller: _confirmPasswordController,
                                        obscureText:
                                            provider.obscureConfirmPassword,
                                        toggleVisibility: provider
                                            .toggleObscureConfirmPassword,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.h),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40.w, vertical: 16.h),
                                    ),
                                    onPressed: provider.loading
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              final _email =
                                                  _emailController.text.trim();
                                              final _phone =
                                                  _phoneController.text.trim();
                                              final _address =
                                                  _addressController.text
                                                      .trim();
                                              final _password =
                                                  _passwordController.text
                                                      .trim();
                                              final _confirmPassword =
                                                  _confirmPasswordController
                                                      .text
                                                      .trim();

                                              if (_newImage == null) {
                                                ShowToastDialog.show(context,
                                                    "Please select an image",
                                                    type: ToastType.error);
                                                return;
                                              }

                                              File _image =
                                                  File(_newImage!.path);
                                              final profileProvider =
                                                  Provider.of<ProfileProvider>(
                                                      context,
                                                      listen: false);

                                              await profileProvider
                                                  .postUserProfileData(
                                                context,
                                                provider.userDataModel!.profile!
                                                    .userName!,
                                                _email,
                                                _phone,
                                                _address,
                                                _password,
                                                _confirmPassword,
                                                _image,
                                              );

                                              final responseModel =
                                                  profileProvider
                                                      .postUserProfileDataModel;

                                              if (responseModel != null &&
                                                  responseModel.success !=
                                                      null &&
                                                  responseModel.success ==
                                                      "Profile updated successfully") {
                                                await profileProvider
                                                    .fetchUserData(context);
                                                ShowToastDialog.show(
                                                    context, "Profile Updated",
                                                    type: ToastType.success);
                                              } else {
                                                ShowToastDialog.show(context,
                                                    "Failed to update profile",
                                                    type: ToastType.error);
                                              }
                                            }
                                          },
                                    child: provider.loading
                                        ? CupertinoActivityIndicator(
                                            color: AppColors.whiteColor)
                                        : Text('Update Profile',
                                            style: getBoldStyle(
                                                fontSize: 16,
                                                color: AppColors.whiteColor)),
                                  ),
                                  SizedBox(height: 24.h),
                                  _buildInfoSection(),
                                  SizedBox(height: 24.h),
                                  const SupportSection(),
                                  SizedBox(height: 24.h),
                                  // SOCIAL MEDIA LINKS START
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 24.h, bottom: 8.h),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Follow us on',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.greyColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SocialButton(
                                              icon: Icons.facebook,
                                              color: AppColors.blueColor,
                                              label: 'Facebook',
                                              url:
                                                  'https://www.facebook.com/share/1FfGdC2ZcL/',
                                            ),
                                            SizedBox(width: 24.w),
                                            SocialButton(
                                              icon: Icons.camera_alt,
                                              color: AppColors.redColor,
                                              label: 'Instagram',
                                              url:
                                                  'https://www.instagram.com/ehomes.pk?utm_source=qr&igsh=MXYwanpwMWx2YjRkbw==',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SOCIAL MEDIA LINKS END
                                  const Spacer(),
                                  // Company Attribution
                                  Padding(
                                    padding: EdgeInsets.only(top: 16.h),
                                    child: Text(
                                      'Developed by IT Genesis',
                                      style: TextStyle(
                                        color: AppColors.greyColor,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerUI() {
    Widget shimmerBox({double height = 50, double? width}) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: height,
          width: width ?? double.infinity,
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: CircleAvatar(radius: 70, backgroundColor: Colors.white),
        ),
        SizedBox(height: 24),
        shimmerBox(height: 24, width: 150),
        shimmerBox(height: 16, width: 200),
        SizedBox(height: 24),
        shimmerBox(),
        shimmerBox(),
        shimmerBox(),
        shimmerBox(),
        SizedBox(height: 16),
        shimmerBox(height: 48, width: 180),
        SizedBox(height: 16),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('My Profile',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: AppColors.whiteColor)),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsScreen()));
          },
          icon: Icon(Icons.settings, color: AppColors.whiteColor),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.logout, color: AppColors.whiteColor),
          onSelected: (value) async {
            if (value == 'logout') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Logout'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel',
                          style: TextStyle(color: AppColors.blackColor)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Logout',
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final provider =
                    Provider.of<EmailAuthProvider>(context, listen: false);
                await provider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInWidget()),
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.redColor),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}