import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../static_info_page_screen.dart';
import '../../../Utils/constants/app_colors.dart';

class ReturnRefundPolicyScreen extends StatelessWidget {
  const ReturnRefundPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StaticInfoPageScreen(
      title: 'Return & Refund Policy',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Return & Refund Policy',
            'While we hope you\'ll be happy with your order, we do have a simple and easy-to-follow returns process. If you discover a product is faulty and aren\'t happy with the product, please call our customer support: 03266679797 (09:00am-05:00pm) discuss your options - we\'ll be happy to help. If your product is faulty or damaged, we\'ll gladly refund it.',
          ),
          _buildSection(
            'Return Eligibility',
            'You are eligible for a refund/replacement on items that we delivered to you if the item was:\n• Incorrect\n• Damaged\n• Expired\n• Missed\n\nPlease complaint by calling on 03266679797 (09:00am-05:00pm) or email us on ehomes.pk. All complaints must be submitted within 2 hours of receiving the order for highly perishable items (Bread, Eggs, Butter, Frozen Products) and 24 Hours for all other items.',
          ),
          _buildSection(
            'Return Conditions',
            'Products should ideally be returned in the original packaging, in a resalable condition, but we understand if this isn\'t always possible. We don\'t accept returns on perishable food items or items which cannot be re-sold for health protections or hygiene reasons once unwrapped. Imported items are not exchangeable or returnable.',
          ),
          _buildSection(
            'Customer Support',
            'Our customer support team will get in touch with you to resolve this issue. You can also return the products which you are dissatisfied with, at the time of delivery and we will get the refund initiated for you.',
          ),
          _buildSection(
            'Incomplete Orders',
            'When your delivery arrives, if you notice an item is missing and no substitute has been provided, please let your driver know and your bill will be instantly recalculated. If you realise any items are missing from your order after your driver has left, please contact customer support: 03266679797 (09:00am-05:00pm) within 24hrs.',
          ),
          _buildSection(
            'Refund Processing',
            'If there is any refund on returned item, our driver will gladly refund as soon as he receives the item from the customer.',
          ),
          _buildSection(
            'Refund Cancellation',
            'Before being processed, all requests are checked. From time to time, a refund request is cancelled because it hasn\'t met our returns criteria.',
          ),
          _buildSection(
            'Complaints & Feedback',
            'Complaints/Feedback/Queries are always welcome. Drop us an email at ehomes.pk@gmail.com or give us a call at 03266679797 (09:00am-05:00pm). Our customer care executives are always happy to help.',
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
