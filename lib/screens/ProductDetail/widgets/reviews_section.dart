import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../provider/review_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'review_bottom_sheet.dart';
import 'all_reviews_screen.dart';
import 'review_card.dart';
import 'package:flutter/cupertino.dart';

class ReviewsSection extends StatefulWidget {
  final int productId;
  final int categoryId;

  const ReviewsSection({
    super.key,
    required this.productId,
    required this.categoryId,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _reviewController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final provider = Provider.of<ReviewProvider>(context, listen: false);
    await provider.fetchReviews(widget.productId);
  }

  void _showReviewBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewBottomSheet(
        productId: widget.productId,
        categoryId: widget.categoryId,
        onReviewSubmitted: () {
          // Refresh reviews when a new review is submitted
          _loadReviews();
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 0.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.boxShadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Review Button and Expand/Collapse
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Customer Reviews',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.blackColor,
                        size: 24.sp,
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showReviewBottomSheet,
                    icon: Icon(Icons.rate_review_outlined,
                        color: AppColors.whiteColor),
                    label: Text(
                      'Write a Review',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reviews List with Animation
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Consumer<ReviewProvider>(
              builder: (context, reviewProvider, child) {
                final grouped = reviewProvider.groupedReviewsByUser;
                final sortedUserIds = grouped.keys.toList()
                  ..sort((a, b) => grouped[b]!
                      .first
                      .createdAt
                      .compareTo(grouped[a]!.first.createdAt));
                final latestTwoUserIds = sortedUserIds.take(2);

                if (reviewProvider.isLoading) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.h),
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                }

                if (reviewProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.h),
                      child: Text(
                        reviewProvider.error!,
                        style: TextStyle(
                          color: AppColors.redColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  );
                }

                if (grouped.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 40.sp,
                            color: AppColors.greyColor,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Be the first to review this product',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.greyColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...latestTwoUserIds.map((userId) {
                      final userReviews = grouped[userId]!;
                      final latestReview = userReviews.first;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: UserReviewGroupHeader(
                          name: latestReview.name,
                          email: latestReview.email,
                          child: ReviewCard(review: latestReview),
                        ),
                      );
                    }),
                    if (grouped.isNotEmpty)
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AllReviewsScreen(groupedReviews: grouped),
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_forward,
                              color: AppColors.primaryColor),
                          label: Text(
                            'View All Reviews',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          SizedBox(height: _isExpanded ? 16.h : 0),
        ],
      ),
    );
  }
}

// Add UserReviewGroupHeader widget
class UserReviewGroupHeader extends StatelessWidget {
  final String name;
  final String email;
  final Widget child;
  const UserReviewGroupHeader(
      {super.key,
      required this.name,
      required this.email,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryColor.withOpacity(0.15),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}
