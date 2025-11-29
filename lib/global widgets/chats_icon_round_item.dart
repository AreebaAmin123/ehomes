import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatsIconRoundItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double textSize;
  final Color iconColor;
  final Color circleColor;
  final VoidCallback onTap;

  const ChatsIconRoundItem({
    super.key,
    required this.icon,
    required this.text,
    required this.iconSize,
    required this.textSize,
    required this.iconColor,
    required this.circleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize + 20.w,
            height: iconSize + 20.h,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: textSize),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
