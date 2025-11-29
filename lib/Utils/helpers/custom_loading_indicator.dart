import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class CustomLoadingIndicator extends StatefulWidget {
  final String? message;
  final String? subMessage;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? size;

  const CustomLoadingIndicator({
    super.key,
    this.message,
    this.subMessage,
    this.barrierDismissible = false,
    this.backgroundColor,
    this.indicatorColor,
    this.size,
  });

  static void show(
    BuildContext context, {
    String? message,
    String? subMessage,
    bool barrierDismissible = false,
    Color? backgroundColor,
    Color? indicatorColor,
    double? size,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: CustomLoadingIndicator(
          message: message,
          subMessage: subMessage,
          barrierDismissible: barrierDismissible,
          backgroundColor: backgroundColor,
          indicatorColor: indicatorColor,
          size: size,
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Loading Icon
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (widget.indicatorColor ?? AppColors.primaryColor)
                                .withOpacity(0.1),
                            (widget.indicatorColor ?? AppColors.primaryColor)
                                .withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: widget.size ?? 80.w,
                            height: widget.size ?? 80.w,
                            decoration: BoxDecoration(
                              color: (widget.indicatorColor ??
                                      AppColors.primaryColor)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(
                            width: (widget.size ?? 80.w) * 0.6,
                            height: (widget.size ?? 80.w) * 0.6,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.indicatorColor ?? AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.message != null) ...[
              SizedBox(height: 24.h),
              Text(
                widget.message!,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
            ],
            if (widget.subMessage != null) ...[
              SizedBox(height: 8.h),
              Text(
                widget.subMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
