import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../static_info_page_screen.dart';
import '../../../Utils/constants/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StaticInfoPageScreen(
      title: 'Terms & Conditions',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Welcome to eHome',
            'By accessing and using the eHome app, you agree to be bound by these terms and conditions.',
          ),
          _buildSection(
            'Account Registration',
            'Users must provide accurate information when creating an account. You are responsible for maintaining the confidentiality of your account credentials.',
          ),
          _buildSection(
            'Product Information',
            'We strive to provide accurate product descriptions and pricing. However, we reserve the right to correct any errors or inaccuracies.',
          ),
          _buildSection(
            'Order Acceptance',
            'All orders are subject to acceptance and availability. We reserve the right to refuse or cancel any order for any reason.',
          ),
          _buildSection(
            'Pricing and Payment',
            'All prices are in local currency and are subject to change without notice. Payment must be made in full at the time of purchase.',
          ),
          _buildSection(
            'Shipping and Delivery',
            'Delivery times are estimates only. We are not responsible for delays beyond our control.',
          ),
          _buildSection(
            'Intellectual Property',
            'All content on the app is protected by copyright and other intellectual property rights.',
          ),
          _buildSection(
            'Privacy',
            'Your use of the app is also governed by our Privacy Policy.',
          ),
          _buildSection(
            'Modifications',
            'We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of any changes.',
          ),
          _buildSection(
              'Terms and Conditions\n\nEhomes, Terms of Use',
              '''1.1 It is strongly recommended that you read and understand the "Terms of Use'', as by accessing to this Website you're bound by the same and acknowledge that it constitutes as part of the procedure followed by ehomes. If you don't agree then, unfortunately, you won't be able to utilize our Website's services.
1.2 The following Terms of Use posted on ehomes is an agreement between us (Website) and you (Visitors) and by visiting our site you hereby are accepting and consenting to the clauses outlined in the Terms of Use. On time to time basis, we may modify the Terms of Use and your continued use of our Website signify that you are bound to approve of our modified Terms of Use.
1.3 The Website reserves the right to terminate all the clauses of the Terms of Use without any prior notice. Following this termination, ehomes also holds the right to revoke the access to your account (User ID and password) which had been issued by our website and should not be able to use our Website from thereon.
1.4 To place an order, Users are required to provide accurate personal details and in case there are any changes to be made, re-register it at your earliest.
1.5 ehomes Users are warned not to provide fraudulent details or details of other person on the behalf of that person. In case of fake order or incorrect information, order will be revoked and the person would be held liable of penalty.
1.6 In case any unusual activity is noticed from a User's account, User will be held liable for it and immediately denied access to the account. If, however, you are not involved directly in the unusual activity via your account then you may inform us at support@ehomes.pk
1.7 If it comes to ehomes notice that User is under 18 years of age, the account will be deactivated automatically. It is advisable by ehomes to its Users not to share their account details with anyone under any conditions.
1.8 Data collected through forms become property of ehomes. Information submitted by Users may be used to send promotional emails, ads, or addition to our app. Furthermore, it will only be shared with relevant marketing partners after due diligence of information safety and security standards.
1.9 ehomes reserves the right to take action against anyone who intends to disparage or destroy ehomes reputation or create confusion amongst its Users.
2.0 ehomes holds the right to cancel your order in case a discrepancy is reported any time. You shall receive a confirmation call from ehomes Customer Service department and you will be asked to provide further information in case of ambiguity.
2.1 ehomes believes in provision of accurate details regarding the products available on Website. At times there might be inaccuracies, errors or mispricing in the prices mentioned. However, in case of mispriced of product or total amount of order, User may contact our Customer Service department and we will be pleased to help. In case of unconfirmed order, ehomes reserves the right to cancel or refuse delivery at its sole discretion.
2.2 Any changes in order or its related information would not be entertained at the end moment. Users are advised to receive their order within the allotted time slot.
2.3 For an instance, if you have placed an order and till the time of delivery the product runs out of stock; we will make you our priority and get back to you as soon as we restock the product again. If an untoward incident or an unforeseen situation occurs, there might be a delay in the processing of your order. That said, ehomes will not be held responsible and promises to try its best to resolve the situation at the earliest. We would be glad to hear from you. For queries and feedback, email us: support@ehomes.pk
2.4 By signing up, you are giving us the consent to send promotional messages on channels like Push Notification, Email, SMS, WhatsApp and Calls.
2.5 Cancellation Policy, If any order got canceled/Invalid due to any reason and the customer used an online payment method then we will refund the amount in the customer’s wallet if the customer requested to get the amount on his card then we have to initiate a request for transfer in the customer’s account.'''
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.blackColor.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
