import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class SvgUtils {
  static Widget loadSvg(
    String assetPath, {
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: fit,
      placeholderBuilder: (context) => Icon(
        Icons.image,
        size: height ?? 24.h,
        color: color ?? AppColors.greyColor,
      ),
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading SVG: $error');
        return Icon(
          Icons.error_outline,
          size: height ?? 24.h,
          color: AppColors.redColor,
        );
      },
      allowDrawingOutsideViewBox: true,
      cacheColorFilter: true,
    );
  }

  static Future<void> preloadSvg(BuildContext context, String assetPath) async {
    try {
      /// Load the SVG file to ensure it's in memory
      final data = await rootBundle.load(assetPath);
      final svgString = String.fromCharCodes(data.buffer.asUint8List());

      /// Validate SVG content
      if (!svgString.contains('<svg')) {
        throw Exception('Invalid SVG file: $assetPath');
      }

      debugPrint('SVG preloaded successfully: $assetPath');
    } catch (e) {
      debugPrint('Error preloading SVG: $e');
    }
  }
}
