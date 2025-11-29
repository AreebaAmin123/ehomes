import 'package:e_Home_app/screens/Home/provider/home_provider.dart';
import 'package:e_Home_app/screens/Home/widgets/For%20you%20section/for_you_section.dart';
import 'package:e_Home_app/screens/Home/widgets/banner/banner_widget.dart';
import 'package:e_Home_app/screens/Home/widgets/direct_categories/direct_categories_widget.dart';
import 'package:e_Home_app/screens/Home/widgets/exclusive_products/exclusive_products_widget.dart';
import 'package:e_Home_app/screens/Home/widgets/flash%20sales/flash_sale_widget.dart';
import 'package:e_Home_app/screens/Home/widgets/search%20bar/search_items_screen.dart';
import 'package:e_Home_app/screens/Home/widgets/vendor_store/vendor_store_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../Utils/constants/app_colors.dart';
import '../../Utils/constants/svg_utils.dart';
import '../../Utils/constants/asset_preloader.dart';
import 'package:e_Home_app/screens/Home/provider/popup_provider.dart';
import 'package:e_Home_app/screens/Home/widgets/popup_modal.dart';
import 'package:e_Home_app/screens/Dashboard/provider/dashboard_provider.dart';
import 'package:e_Home_app/screens/Categories/provider/category_provider.dart';
import '../../Utils/constants/my_sharePrefs.dart';
import 'widgets/login_signup_engagement_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearchOverlay = false;
  bool _popupChecked = false;
  bool _isLoading = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initialize());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen for home tab reselection
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    if (dashboardProvider.isHomeReselected) {
      _scrollToTop();
      dashboardProvider.resetHomeReselection();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _initialize() async {
    try {
      // Preload critical assets
      await AssetPreloader.preloadCriticalAssets(context);

      // Initialize home data with caching
      final provider = Provider.of<HomeProvider>(context, listen: false);
      await provider.initializeHomeData();

      // Initialize categories
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      await categoryProvider.fetchCategories();

      // Fetch popup data separately (no caching)
      if (!_popupChecked) {
        final popupProvider =
            Provider.of<PopupProvider>(context, listen: false);
        await popupProvider.fetchPopupImages();
        _popupChecked = true;
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error initializing home screen: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleSearchOverlay() {
    setState(() {
      _showSearchOverlay = !_showSearchOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CupertinoActivityIndicator())
          else
            CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      switch (index) {
                        case 0:
                          return const BannerWidget();
                        case 1:
                          return const VendorStoreWidget();
                        case 2:
                          return FutureBuilder<bool>(
                            future: MySharedPrefs().isUserLoggedIn(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox.shrink(); // Or a small loading indicator
                              }
                              final isLoggedIn = snapshot.data ?? false;
                              if (!isLoggedIn) {
                                return const LoginSignupEngagementWidget();
                              }
                              return const SizedBox.shrink(); // Logged in → show nothing
                            },
                          );
                        case 3:
                          return const DirectCategoriesWidget();
                        case 4:
                          return Consumer<HomeProvider>(
                            builder: (context, provider, child) {
                              return ExclusiveProductsWidget(
                                products: provider.exclusiveProducts ?? [],
                              );
                            },
                          );
                        case 5:
                          return const FlashSaleWidget();
                        case 6:
                          return const ForYouSectionWidget();
                        default:
                          return null;
                      }
                    },
                    childCount: 6,
                  ),
                ),
              ],
            ),
          if (_showSearchOverlay)
            SearchOverlay(
              onClose: _toggleSearchOverlay,
            ),
          Consumer<PopupProvider>(
            builder: (context, popupProvider, _) {
              if (popupProvider.showPopup) {
                return PopupModal(
                  banners: popupProvider.banners,
                  isLoading: popupProvider.isLoading,
                  error: popupProvider.error,
                  onClose: () => popupProvider.hidePopup(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/app_logo/white_logo.png',
            height: 60.h,
            width: 60.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 15.w),
          child: IconButton(
            onPressed: _toggleSearchOverlay,
            icon: const Icon(LucideIcons.search,
                color: AppColors.whiteColor, size: 22),
          ),
        ),
      ],
    );
  }
}
