import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../../../Utils/constants/app_colors.dart';
import '../../../../../../models/home screen/vendor/vendor_model.dart';
import '../../../../provider/vendor_provider.dart';
import 'vendor_card.dart';

class AllVendorsScreen extends StatefulWidget {
  const AllVendorsScreen({super.key});

  @override
  State<AllVendorsScreen> createState() => _AllVendorsScreenState();
}

class _AllVendorsScreenState extends State<AllVendorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<VendorProvider>().fetchVendors(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreenColor.withOpacity(0.5),
      appBar: _buildAppBar(),
      body: Consumer<VendorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (provider.error != null) {
            return _buildErrorWidget(provider.error!);
          }

          final vendors = provider.vendors;
          final filteredVendors = _searchQuery.isEmpty
              ? vendors
              : vendors
                  .where((vendor) => (vendor.storeName)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

          if (vendors.isEmpty) {
            return _buildEmptyWidget();
          }

          return Column(
            children: [
              _ReusableSearchBar(
                controller: _searchController,
                hintText: 'Search vendors...',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              Expanded(child: _buildVendorGrid(filteredVendors)),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      title: Text(
        'All Stores',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteColor,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 18.sp,
          color: AppColors.whiteColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.redColor,
            ),
            SizedBox(height: 16.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.greyColor,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                context.read<VendorProvider>().fetchVendors();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 48.sp,
              color: AppColors.greyColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Stores Available',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back later for new stores',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorGrid(List<VendorModel> vendors) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<VendorProvider>().fetchVendors();
      },
      color: AppColors.primaryColor,
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          // crossAxisSpacing: 0.w,
          // mainAxisSpacing: 10.h,
        ),
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          return VendorCard(vendor: vendors[index]);
        },
      ),
    );
  }
}

class _ReusableSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  const _ReusableSearchBar(
      {required this.controller,
      required this.hintText,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        cursorColor: AppColors.primaryColor,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
