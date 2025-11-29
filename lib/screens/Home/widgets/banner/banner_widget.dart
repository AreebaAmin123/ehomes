import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../../provider/home_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../services/url_cache_service.dart';
import '../../../../services/custom_image_provider.dart';
import 'package:shimmer/shimmer.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  BannerWidgetState createState() => BannerWidgetState();
}

class BannerWidgetState extends State<BannerWidget>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  final UrlCacheService _urlCache = UrlCacheService();
  final Map<String, bool> _failedImages = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      provider.getSlider();
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      final sliders = Provider.of<HomeProvider>(context, listen: false)
              .sliderModel
              ?.sliders ??
          [];

      final sliderList =
          sliders.length == 1 ? List.filled(2, sliders.first) : sliders;

      if (sliderList.isEmpty) return;

      final nextPage = (_currentPage + 1) % sliderList.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImageWithFallback(
      String? imageUrl, String heading1, String? heading2) {
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        _failedImages[imageUrl] == true) {
      return _buildFallbackWidget(heading1, heading2);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: ClipRRect(
            child: Stack(
              children: [
                // Image
                CachedNetworkImage(
                  imageUrl: CustomNetworkImageProvider.fixImageUrl(imageUrl),
                  cacheManager: DefaultCacheManager(),
                  maxWidthDiskCache: 1080,
                  maxHeightDiskCache: 1080,
                  memCacheWidth: constraints.maxWidth.round(),
                  memCacheHeight: constraints.maxHeight.round(),
                  fadeInDuration: const Duration(milliseconds: 500),
                  fadeOutDuration: const Duration(milliseconds: 300),
                  imageBuilder: (context, imageProvider) => Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => _buildLoadingWidget(),
                  errorWidget: (context, url, error) {
                    debugPrint(
                        'Error loading banner image: $error for URL: $url');
                    _failedImages[imageUrl] = true;
                    return _buildFallbackWidget(heading1, heading2);
                  },
                ),

                /// Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.6, 0.8, 1.0],
                    ),
                  ),
                ),

                /// Text Content
                Positioned(
                  bottom: 24.h,
                  left: 16.w,
                  right: 16.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading1,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                      if (heading2 != null && heading2.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          heading2,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }

  Widget _buildFallbackWidget(String heading1, String? heading2) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12.h),
            Text(
              heading1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            if (heading2 != null) ...[
              SizedBox(height: 8.h),
              Text(
                heading2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSlider) {
          return _buildLoadingWidget();
        }

        final sliders = provider.sliderModel?.sliders ?? [];
        if (sliders.isEmpty) {
          return _buildFallbackWidget(
            'No banners available',
            'Check back later for updates',
          );
        }

        final sliderList =
            sliders.length == 1 ? List.filled(2, sliders.first) : sliders;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: AspectRatio(
            aspectRatio: 22 / 9,
            child: Stack(
              children: [
                /// Banner Slider
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: sliderList.length,
                  itemBuilder: (context, index) {
                    final slider = sliderList[index];
                    return _buildImageWithFallback(
                      slider.sliderImage,
                      slider.heading1 ?? 'Banner Image',
                      slider.heading2,
                    );
                  },
                ),
                // Scroll Indicator
                if (sliderList.length > 1)
                  Positioned(
                    bottom: 8.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_right_alt,
                          color: Colors.white.withOpacity(0.7),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Swipe to see more',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Page Indicators
                if (sliderList.length > 1)
                  Positioned(
                    bottom: 18.h,
                    right: 18.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(
                        sliderList.length,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: _currentPage == index ? 24.w : 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            color: _currentPage == index
                                ? AppColors.primaryColor
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
