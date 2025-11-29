import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/review_model.dart';
import 'review_card.dart';

class AllReviewsScreen extends StatelessWidget {
  final Map<int, List<ReviewModel>> groupedReviews;
  const AllReviewsScreen({super.key, required this.groupedReviews});

  @override
  Widget build(BuildContext context) {
    final sortedUserIds = groupedReviews.keys.toList()
      ..sort((a, b) => groupedReviews[b]!
          .first
          .createdAt
          .compareTo(groupedReviews[a]!.first.createdAt));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'All Reviews',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.whiteColor),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.whiteColor,
          ),
        ),
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: sortedUserIds.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final userId = sortedUserIds[index];
          final userReviews = groupedReviews[userId]!;
          return Column(
            children: userReviews
                .map((review) => ReviewCard(review: review))
                .toList(),
          );
        },
      ),
    );
  }
}
