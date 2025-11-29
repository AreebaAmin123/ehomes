import 'package:e_Home_app/global%20widgets/Payment/other_wallet_item.dart';
import 'package:e_Home_app/global%20widgets/Payment/own_wallet_item.dart';
import 'package:e_Home_app/screens/Checkout/Payment/widgets/cash_on_delivery.dart';
import 'package:e_Home_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const PaymentScreen({super.key, required this.data});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFB), Color(0xFFE8F0F8)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 7.h),
                      child: Text(
                        'Recommended method(s)',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                    const OwnWalletItem(
                      firstText: 'Ehomes Wallet (Coming Soon...)',
                      secondText: 'Select to top-up & pay',
                      amount: '0',
                      leftIcon: Icons.wallet,
                      rightIcon: Icons.radio_button_checked,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 7.h),
                      child: Text(
                        'Other Payment Methods',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                    OtherWalletItem(
                      firstText: 'Cash on Delivery',
                      secondText: 'Pay when delivered',
                      leftIcon: Icons.credit_card,
                      showPaymentIcons: false,
                      rightIcon: Icons.arrow_forward_ios_rounded,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CashOnDeliveryScreen(data: widget.data)));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
