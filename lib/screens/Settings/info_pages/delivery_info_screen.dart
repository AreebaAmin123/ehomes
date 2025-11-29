import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../static_info_page_screen.dart';
import '../../../Utils/constants/app_colors.dart';

class DeliveryInfoScreen extends StatelessWidget {
  const DeliveryInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StaticInfoPageScreen(
      title: 'Delivery Information',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Delivery Areas',
            'We currently deliver to all major cities and surrounding areas. Enter your pincode during checkout to check if delivery is available in your area.',
          ),
          _buildSection(
            'Delivery Times',
            'View and book your delivery slot at any time, by clicking Choose a delivery slot\'. You can also choose a slot after you\'ve finished choosing your items, before you\'ve clicked on \'checkout\'. You\'ll be shown the available delivery slots. Select an available slot to book your delivery date and time. The delivery slot will be held for two hours, to give you time to complete your shop and confirm your order.\n\nDelivery Slots:\n1- 10:00am-12:30pm\n2- 02:00pm-04:30pm\n3- 06:00pm-08:30pm',
          ),
          _buildSection(
            'Scheduling Orders',
            'Sure. At the checkout page, you can select a delivery slot of your choice.',
          ),
          _buildSection(
            'Delayed Orders',
            'On rare occasions, due to unforeseen circumstances, your order might be delayed. In case of imminent delay, our customer support executive will keep you updated about the delivery time of your order.',
          ),
          _buildSection(
            'Order Receipt',
            'You will be emailed your receipt and the driver will hand you a receipt, which is a summary of your order. The driver will also ask you to sign their copy as proof of delivery.',
          ),
          _buildSection(
            'Delivery Service Policy',
            'We provide a \'to your front door\' delivery service. If a customer needs any further support, our drivers will assist where possible, but they are not obliged to enter a customer\'s house. Please understand that we take the health and safety of our drivers seriously. If you need your shopping taken inside, this also won\'t be possible if our drivers will be at risk.',
          ),
          _buildSection(
            'Missed Deliveries',
            'Your shopping will be taken back to the warehouse. We will do our best to try to arrange another delivery time for you once you have contacted us.',
          ),
          _buildSection(
            'Packaging',
            'We are committed to delivering responsibly packaged goods and our range is constantly reviewed. Where possible, most of our products will be packed and wrapped in recyclable or reusable materials which will be placed in a plastic cart.',
          ),
          _buildSection(
            'Order Tracking',
            'Yes, you can track the status of your order under the My Orders section.\n\nTrack my order:\nOnce you\'ve completed your order and checkout, we\'ll email you an order summary.\n\nYou will be able to see its progress:\n1- When your order is being packed.\n2- When you order has finished being packed.\n3- When your order has been dispatched from our warehouse.',
          ),
          _buildSection(
            'How to Track Orders',
            'The status of your order can always be found in your account:\n1- View your account.\n2- Scroll to the order in question.\n3- The order status appears on the right side of the page.',
          ),
          _buildSection(
            'Order Confirmation',
            'As soon as you place an order, we send a confirmation to your email address. This email includes your order number, estimated delivery time and an order summary.',
          ),
          _buildSection(
            'Cancellation Policy',
            'ehomes provides an easy and hassle-free cancellation policy. You can cancel any item or your order at any time prior to the confirmation of your order. You cannot cancel your order or an item after this time unless it is damaged or faulty.',
          ),
          _buildSection(
            'How to Cancel Orders',
            'You can cancel your order by simply calling 03266679797 before your order is confirmed.',
          ),
          _buildSection(
            'Order Cancellation Reasons',
            'We\'ll always try our best to get your order to you. However, there are times when we\'re unable to - such as in extreme weather, a customer not being at home, or because of other circumstances beyond our control. On the rare occasion that we do have to cancel your order, we\'ll send you an email or text to inform you.',
          ),
          _buildSection(
            'Re-booking Orders',
            'If your order was cancelled before collection or delivery, your trolley will still be available to re-order. Please follow the steps below:\n1. Visit the ehomes app or website.\n2. Click on Sign in and enter your login details.\n3. Click on Your Orders.\n4. Select the order which has been cancelled.\n5. Click on Re-order - a message will pop up asking you to confirm adding the order to your trolley.\n6. If you would like to add more items to your order you can click the Continue shopping button.\n7. When you\'re finished, click Checkout.',
          ),
          _buildSection(
            'Changing Delivery Address',
            'You can change your delivery address before you confirm your order. After this, we\'re unable to make changes to the delivery address.',
          ),
          _buildSection(
            'Changing Delivery Time',
            'Provided there are available slots at the time when you placed your order, you can change the time of your delivery from 8am to 8pm',
          ),
          _buildSection(
            'Product Availability',
            'We always try our best to stock all your favourite products but all the products we sell are subject to availability and our ranges can vary.',
          ),
          _buildSection(
            'Finding Products',
            'There are a few different ways you can search for products:\n1. By category. All the products we stock are grouped into categories. If you click on the \'Catalogue\' tab at the top left of the page, several new tabs will appear below it, each one representing a different group of products. If you hover over each new tab, you\'ll be able to see products grouped under that category.\n2. Product search. You\'ll find a search ehomes in the top right-hand corner of the page. So, if you\'re looking for a particular product, type the name of the item into the product search ehomes and click on the \'Search\' button.',
          ),
          _buildSection(
            'Sale Products',
            'We have lots of products on offer each week. You\'ll find these throughout our site. If you want to go straight to all the offers, simply click on the \'Offers\' tab at the top of the page. This will take you through to our dedicated \'Offers\' page, where you can browse through each of the products on sale.',
          ),
          _buildSection(
            'Product Suggestions',
            'We are always trying our best to increase our variety in quality products. If you find that we do not have a particular product available, you can always email us at ehomes.pk@gmail.com suggesting which products you need.',
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
