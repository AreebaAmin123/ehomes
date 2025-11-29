import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../../../../models/feedback_model.dart';
import '../provider/feedback_provider.dart';

class FeedbackListScreen extends StatelessWidget {
  const FeedbackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text('Feedback',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color:AppColors.whiteColor)),
          backgroundColor: AppColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<FeedbackProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            if (provider.feedbackList.isEmpty) {
              return Center(child: Text('No feedback found'));
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: provider.feedbackList.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final FeedbackModel feedback = provider.feedbackList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person,
                                color: AppColors.primaryColor, size: 20.w),
                            SizedBox(width: 8.w),
                            Text(feedback.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp)),
                            Spacer(),
                            Text(
                              feedback.createdAt.split(' ').first,
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(feedback.subject,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: AppColors.primaryColor)),
                        SizedBox(height: 6.h),
                        Text(feedback.message,
                            style: TextStyle(fontSize: 13.sp)),
                        SizedBox(height: 6.h),
                        Text(feedback.email,
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
  }
}
