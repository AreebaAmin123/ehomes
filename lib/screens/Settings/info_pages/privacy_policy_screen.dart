import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../static_info_page_screen.dart';
import '../../../Utils/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticInfoPageScreen(
      title: 'Privacy Policy',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Privacy Policy',
            'At ehomes, we understand your concern about your personal information, we care about it too. As such, we ensure we safeguard the information provided and honor your requests for confidentiality when you log in to our website and mobile app.',
          ),
          _buildSection(
            'Collection of Information',
            'This policy governs your privacy rights regarding our collection, storage and accumulation of your personally identifiable information (name, contact number, mailing and postal address, order history) concerning your use of our website. This information is stored in an electronic database, which is for ehomes\' use only.',
          ),
          _buildSection(
            'Use of Information',
            'We shall therefore only use your name and other information which relates to you in the manner set out in this Privacy Policy. We will only collect information where it is necessary for us to do so and we will only collect information if it is relevant to our dealings with you.',
          ),
          _buildSection(
            'Anonymous Browsing',
            'You can visit website and browse without having to provide personal details. During your visit to ehomes.com you remain anonymous and at no time can we identify you unless you have an account on the website and log in with your username and password.',
          ),
          _buildSection(
            'Order Information',
            'We may collect your personal identification details if you seek to place an order through our website and/or application.',
          ),
          _buildSection(
            'Cookies',
            'Whenever you interact on our site, we receive and store certain information in the form of \'cookies\' which is basically done to enhance user experience. Cookies are basically placed on your hard drive and not on our site for record-keeping purposes.',
          ),
          _buildSection(
            'Data Processing',
            'We collect, store and process your data for processing your purchase on our website and any possible later claims, and to provide you with our discounted promotions and future offers.',
          ),
          _buildSection(
            'Third Party Sharing',
            'We may pass on your basic information (name, contact number and postal address) on to a third party in order to make delivery of the product to you (for an example to courier service provider or delivery supplier).',
          ),
          _buildSection(
            'Security Measures',
            'We follow industry standards to protect your personal information from unauthorized access and unlawful processing, accidental loss, destruction and damage. Personal Information will only be shared with relevant marketing partners after due diligence of information safety and security standards.',
          ),
          _buildSection(
            'Policy Updates',
            'We are always improving and updating our website to further enhance shopping on our website. As a result, our policies would be evolving with time. As we update our website and add new services, we will update our Privacy Policy accordingly.',
          ),
          _buildSection(
            'Contact Us',
            'To use our website, you are consenting to our Privacy Policy. We appreciate your trust in us and we promise to protect data. Feel free to contact our customer service team to help you out!',
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
