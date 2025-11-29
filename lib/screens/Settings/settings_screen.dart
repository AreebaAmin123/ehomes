import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Utils/constants/app_colors.dart';
import 'My Orders/my_orders_screen.dart';
import 'TrackOrder/track_order_screen.dart';
import 'feedback/feedback_list_screen.dart';
import 'info_pages/terms_conditions_screen.dart';
import 'info_pages/privacy_policy_screen.dart';
import 'info_pages/faq_screen.dart';
import 'info_pages/delivery_info_screen.dart';
import 'info_pages/return_refund_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Orders',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            _buildListItem(Icons.shopping_bag_outlined, 'Your Orders', context),
            _buildDivider(),
            _buildListItem(
                Icons.local_shipping_outlined, 'Track Order', context),
            _buildDivider(),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Support',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            // _buildListItem(Icons.contact_support_outlined, 'Contact us', context),
            _buildDivider(),
            _buildListItem(Icons.feedback_outlined, 'Feedback', context),
            _buildDivider(),
            _buildListItem(Icons.help_outline, 'FAQs', context),
            _buildDivider(),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            _buildListItem(
                Icons.local_shipping, 'Delivery Information', context),
            _buildDivider(),
            _buildListItem(Icons.assignment_return_outlined,
                'Return & Refund Policy', context),
            _buildDivider(),
            _buildListItem(
                Icons.description_outlined, 'Terms & Conditions', context),
            _buildDivider(),
            _buildListItem(
                Icons.privacy_tip_outlined, 'Privacy Policy', context),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      splashColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      leading: Icon(
        icon,
        color: AppColors.primaryColor,
        size: 22.sp,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.blackColor.withValues(alpha: 0.5),
        size: 16.sp,
      ),
      onTap: () {
        switch (title) {
          case 'Your Orders':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyOrdersScreen()));
            break;
          case 'Track Order':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TrackOrderScreen()));
            break;
          // case 'Contact us':
          //   Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => const ContactUs()));
          //   break;
          case 'Feedback':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FeedbackListScreen()));
            break;
          case 'FAQs':
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FAQScreen()));
            break;
          case 'Delivery Information':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DeliveryInfoScreen()));
            break;
          case 'Return & Refund Policy':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReturnRefundPolicyScreen()));
            break;
          case 'Terms & Conditions':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TermsConditionsScreen()));
            break;
          case 'Privacy Policy':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen()));
            break;
        }
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.blackColor,
      thickness: 0.1,
    );
  }
}
