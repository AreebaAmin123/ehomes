import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../Auth/email section/signIn_withEmail.dart';
import '../../Auth/email section/signup_withEmail.dart';

class LoginSignupEngagementWidget extends StatelessWidget {
  const LoginSignupEngagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [
      // Card 1: Login / Signup
      Container(
        padding: const EdgeInsets.symmetric(horizontal:  12, vertical: 5),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color:AppColors.primaryColor.withOpacity(0.25),
            width: 2,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(1, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                // Login Button
                ElevatedButton.icon(
                  onPressed: () =>Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SignInWithEmail())),
                  icon: const Icon(Icons.login, size: 18,color: Colors.white,),
                  label: const Text("Login", style: TextStyle(color:Colors.white),),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    elevation: 4,
                    shadowColor: AppColors.primaryColor.withOpacity(0.4),
                  ),
                ),

                const SizedBox(width: 12),

                // Sign Up Button
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SignupWithEmail())),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text("Sign Up"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: AppColors.primaryColor, width: 2),
                    foregroundColor: AppColors.primaryColor,
                  ),
                ),
              ],
            )
            ,
            Divider(),
            const Text(
              "Sign in to enjoy exclusive deals and offers.",
              textAlign: TextAlign.start,
            ),
            const Spacer(),
          ],
        ),
      ),

      // Card 2: Welcome Deal
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.45)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.local_offer, size: 15, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      "Welcome Deal!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  "Get 20% off on your first order. \nDon't miss out!",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 16),
            Lottie.asset(
              "assets/lottie/Discount.json",
              height: 105.h,
              fit: BoxFit.contain,
              repeat: true,
            )
          ],
        ),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: CarouselSlider(
        items: cards,
        options: CarouselOptions(
          height: 110,
          enlargeCenterPage: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          viewportFraction: 0.85,
        ),
      ),
    );
  }
}
