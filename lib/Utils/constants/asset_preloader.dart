import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'svg_utils.dart';

class AssetPreloader {
  static final List<String> _criticalAssets = [
    'assets/bottom_nav_icons/cart_white.svg',
    // Add other critical assets here
  ];

  static Future<void> preloadCriticalAssets(BuildContext context) async {
    try {
      for (final asset in _criticalAssets) {
        if (asset.endsWith('.svg')) {
          // For SVG files, use SvgUtils
          await SvgUtils.preloadSvg(context, asset);
        } else if (asset.startsWith('http')) {
          // For network images, use CachedNetworkImage
          await precacheImage(
            CachedNetworkImageProvider(asset),
            context,
          );
        } else {
          // For local image files, we precache them
          await precacheImage(AssetImage(asset), context);
        }
      }
      debugPrint('Critical assets preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading assets: $e');
    }
  }

  static Future<void> preloadNetworkImage(String url) async {
    try {
      await CachedNetworkImageProvider(url).resolve(ImageConfiguration());
      debugPrint('Network image preloaded successfully: $url');
    } catch (e) {
      debugPrint('Error preloading network image: $e');
    }
  }
}
