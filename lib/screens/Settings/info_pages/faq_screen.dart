import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../static_info_page_screen.dart';
import '../../../Utils/constants/app_colors.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticInfoPageScreen(
      title: 'FAQs',
      content: Column(
        children: [
          _buildFAQItem(
            'What is ehomes?',
            'Ehomes has been serving Pakistani\'s with quality and genuine items for over a decade now. Whatever you want, we have it. To ensure you get the best with the least of hassles, we launched our Grocery delivery services.',
          ),
          _buildFAQItem(
            'How do I see special offers?',
            'You can click on our Promotions tab to see all of our latest special offers. In your \'Favourites\' section you can also see some special offers we think you may be interested in.',
          ),
          _buildFAQItem(
            'How do I book a delivery slot?',
            'View and book your delivery slot at any time, by clicking Choose a delivery slot\'. You can also choose a slot after you\'ve finished choosing your items, before you\'ve clicked on \'checkout\'. You\'ll be shown the available delivery slots. Select an available slot to book your delivery date and time. The delivery slot will be held for two hours, to give you time to complete your shop and confirm your order.',
          ),
          _buildFAQItem(
            'How do I check out?',
            'When you\'ve finished your shop, select the \'Check out\' button in the basket area. Make sure your delivery address details are correct, and select the delivery time you prefer. At checkout you can review all the products you\'ve bought by clicking \'View full basket\' button. At this point, you can amend any of the details in your basket, such as quantities. Then, check through the rest of your delivery details, and select \'Proceed to payment\' button. Lastly, fill in your payment details, only Cash on Delivery as of now and select \'Confirm your order\' button. Now it\'s time to put your feet up and relax. Remember, your first time will usually be the most complicated. Next time there will be fewer forms to fill in, and you\'ll be able to use \'Favorites\' to create your shopping list more quickly.',
          ),
          _buildFAQItem(
            'Do you deliver to my location?',
            'We deliver in select localities across Sahiwal.',
          ),
          _buildFAQItem(
            'What cities and locations do you operate in?',
            'ehomes currently operates in Sahiwal only. The delivery service is operational in all areas of Sahiwal: Sahiwal city areas, Farid Town, Pak Avenue, Scheme No: 2 and 3, Officers Colony, Jahaaz Ground, Fateh Shehr, Kot Khadim Ali Shah, Shaadman Town, Shadab Town, All housing schemes situated on Madhali Rd, Pakpattan Chowk and surrounding areas.\n\nWe also deliver in these villages: 82/6R, 86/6R, 89/6R, 93/6R, 94/6R, 95/6R',
          ),
          _buildFAQItem(
            'Do you charge any amount or taxes over and above the rates shown?',
            'No, we do not charge anything over and above the rates shown.',
          ),
          _buildFAQItem(
            'What is the minimum order value?',
            'The minimum order value is PKR 999.',
          ),
          _buildFAQItem(
            'How can I make changes to my order before and after confirmation?',
            'You can edit your products in the cart before checkout. If you\'ve already placed your order, you can cancel and reorder keeping in mind the order has not been confirmed or ready to dispatch.',
          ),
          _buildFAQItem(
            'What if I have a complaint regarding my order?',
            'Complaints/Feedback/Queries are always welcome. Drop us an email at ehomes.pk@gmail.com or give us a call at 03 (09:00am-09:00pm). Our customer care executives are always happy to help.',
          ),
          _buildFAQItem(
            'How is my order confirmed?',
            'Once you\'ve checked out, you\'ll receive a confirmation e-mail, detailing all the products, quantities and guide prices in your order. Our customer service call center will give you a full delivery note with details of all the products you\'ve bought, including substitutions and unavailable products. If you have any queries about substitutions or out of stock items, you can ask our customer care at ehomes.',
          ),
          _buildFAQItem(
            'How do I get a receipt?',
            'When your shopping is delivered, you\'ll be given a detailed order receipt by the delivery driver.',
          ),
          _buildFAQItem(
            'How can I pay?',
            'ehomes provides you the convenience to pay after the products are delivered at your doorstep. Once you are satisfied with the products delivered, you can pay by either cash or by card. We accept all types of cards.\n\nOnline Payments: We have a wide range of online payment options, whether it\'s just a credit or debit card or it\'s your Jazz Cash mobile account, we have you covered.\n\nCash on Delivery (COD): Don\'t want to pay online, pay via cash instead. We can come collect right on your doorstep. Your ease is our key performance indicator.',
          ),
          _buildFAQItem(
            'How do I return a product?',
            'ehomes follows open box policy to deliver your goods. This gives you the liberty to return any product there and then if you are not satisfied with it. The delivery man will take the returned products back and you will not be charged for them.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.boxShadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory),
        child: ExpansionTile(
          title: Text(
            question,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          iconColor: AppColors.primaryColor,
          collapsedIconColor: AppColors.primaryColor,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.blackColor.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
