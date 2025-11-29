import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../provider/review_provider.dart';
import '../../Auth/email section/provider/email_authProvider.dart';
import 'package:e_Home_app/Utils/helpers/show_toast_dialouge.dart';

class ReviewBottomSheet extends StatefulWidget {
  final int productId;
  final int categoryId;
  final VoidCallback onReviewSubmitted;

  const ReviewBottomSheet({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.onReviewSubmitted,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  double _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<EmailAuthProvider>(context, listen: false).user;
    final String userName = user?.name ?? '';
    final String userEmail = user?.email ?? '';

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Write a Review',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: AppColors.greyColor),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Rating
                      Text(
                        'Your Rating',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Center(
                        child: RatingBar.builder(
                          initialRating: _rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 40.sp,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rating = rating;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Name Field (read-only)
                      TextFormField(
                        initialValue: userName,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppColors.greyColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                                color: AppColors.greyColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                                color: AppColors.greyColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                          labelStyle: TextStyle(color: AppColors.greyColor),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Email Field (read-only)
                      TextFormField(
                        initialValue: userEmail,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Your Email',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppColors.greyColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                                color: AppColors.greyColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                                color: AppColors.greyColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                          labelStyle: TextStyle(color: AppColors.greyColor),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Review Field (editable)
                      TextFormField(
                        controller: _reviewController,
                        cursorColor: AppColors.primaryColor,
                        style: TextStyle(color: AppColors.blackColor),
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Your Review',
                          hintText: 'Share your experience with this product',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                                color: AppColors.greyColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                                color: AppColors.greyColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                          labelStyle: TextStyle(color: AppColors.greyColor),
                          hintStyle: TextStyle(
                              color: AppColors.greyColor.withOpacity(0.7)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your review';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: Consumer<ReviewProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate() &&
                                          _rating > 0) {
                                        final success =
                                            await provider.submitReview(
                                          productId: widget.productId,
                                          categoryId: widget.categoryId,
                                          name: userName,
                                          email: userEmail,
                                          rating: _rating.toInt(),
                                          review: _reviewController.text,
                                        );

                                        if (success) {
                                          _reviewController.clear();
                                          setState(() => _rating = 0);
                                          _formKey.currentState?.reset();
                                          if (mounted) {
                                            Navigator.pop(context);
                                            ShowToastDialog.show(
                                              context,
                                              'Review submitted',
                                              type: ToastType.success,
                                            );
                                            widget.onReviewSubmitted();
                                          }
                                        } else {
                                          if (mounted) {
                                            ShowToastDialog.show(
                                              context,
                                              provider.error ??
                                                  'Failed to submit review',
                                              type: ToastType.error,
                                            );
                                          }
                                        }
                                      } else {
                                        ShowToastDialog.show(
                                          context,
                                          'Please select a rating',
                                          type: ToastType.error,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Submit Review',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
