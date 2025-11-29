import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/feedback_model.dart';
import 'provider/feedback_provider.dart';
import 'widgets/feedback_form_modal.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<FeedbackProvider>(context, listen: false).fetchFeedback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text('Feedback',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            )),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.whiteColor,
          ),
        ),
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
              return Container(
                margin: EdgeInsets.symmetric(vertical: 4.h),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  elevation: 4,
                  shadowColor: AppColors.primaryColor.withOpacity(0.08),
                  child: Padding(
                    padding: EdgeInsets.all(18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Avatar, Name, Date
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor:
                                  AppColors.primaryColor.withOpacity(0.12),
                              child: Text(
                                feedback.name.isNotEmpty
                                    ? feedback.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                feedback.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                            Text(
                              feedback.createdAt.split(' ').first,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.greyColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        // Subject
                        Row(
                          children: [
                            Icon(Icons.subject,
                                color: AppColors.primaryColor, size: 18.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                feedback.subject,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        // Message
                        Text(
                          feedback.message,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.blackColor,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Email
                        Row(
                          children: [
                            Icon(Icons.email_outlined,
                                color: AppColors.greyColor, size: 16.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                feedback.email,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.greyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          backgroundColor: AppColors.primaryColor,
          icon: Icon(Icons.add_comment_outlined, color: Colors.white),
          label: Text('Submit Feedback', style: TextStyle(color: Colors.white)),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            builder: (context) => const FeedbackFormModal(),
          ),
        ),
      ),
    );
  }
}
