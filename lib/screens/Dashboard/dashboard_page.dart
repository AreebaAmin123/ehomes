import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'provider/dashboard_provider.dart';
import '../../Utils/constants/app_colors.dart';
import '../Cart/cart_screen.dart';
import '../Categories/categories_screen.dart';
import '../Home/home_screen.dart';
import '../Inbox/messages_screen.dart';
import '../ProfileScreen/profile_screen.dart';
import '../../global widgets/cart_badge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  static final BorderRadius _navBarRadius = BorderRadius.only(
    topLeft: Radius.circular(16.r),
    topRight: Radius.circular(16.r),
  );

  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.grid_view, 'label': 'Categories'},
    {'icon': Icons.shopping_cart, 'label': 'Cart'},
    {'icon': Icons.message, 'label': 'Messages'},
    {'icon': Icons.account_circle_outlined, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, _) {
        final selectedIndex = dashboardProvider.selectedIndex;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.primaryColor,
          body: SafeArea(
            child: IndexedStack(
              index: selectedIndex,
              children: _pages,
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: _navBarRadius,
              ),
              child: ClipRRect(
                borderRadius: _navBarRadius,
                child: SizedBox(
                  height: 58.h,
                  child: BottomNavigationBar(
                    currentIndex: selectedIndex,
                    onTap: (index) {
                      dashboardProvider.updateSelectedIndex(index);
                    },
                    selectedItemColor: AppColors.whiteColor,
                    unselectedItemColor:
                    AppColors.whiteColor.withValues(alpha: 0.6),
                    backgroundColor: AppColors.primaryColor,
                    type: BottomNavigationBarType.fixed,
                    selectedLabelStyle: TextStyle(
                      fontSize: 12.sp, // larger label
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(fontSize: 11.sp),
                    items: _navItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      return _buildBottomNavigationBarItem(
                        item['icon'],
                        item['label'],
                        index,
                        selectedIndex,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon,
      String label,
      int index,
      int selectedIndex,
      ) {
    final isSelected = index == selectedIndex;

    Widget iconWidget = Icon(
      icon,
      size: isSelected ? 25.sp : 21.sp, // smaller icons
    );

    // Wrap the cart icon with CartBadge
    if (label == 'Cart') {
      iconWidget = CartBadge(
        child: iconWidget,
        top: -8.h,
        left: -8.w,
        badgeSize: 14.w,
        fontSize: 8.sp,
      );
    }

    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: iconWidget,
      ),
      label: label,
    );
  }
}
