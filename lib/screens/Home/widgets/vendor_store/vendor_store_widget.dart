import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../../../../models/home screen/vendor/vendor_model.dart';
import '../../provider/vendor_provider.dart';
import 'widget/vendor list/all_vendors_screen.dart';
import 'widget/vendor list/vendor_card.dart';

class VendorStoreWidget extends StatefulWidget {
  const VendorStoreWidget({super.key});

  @override
  State<VendorStoreWidget> createState() => _VendorStoreWidgetState();
}

class _VendorStoreWidgetState extends State<VendorStoreWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<VendorProvider>().fetchVendors(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        final vendors = provider.vendors;
        if (vendors.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildVendorList(vendors),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Brands',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllVendorsScreen(),
                ),
              );
            },
            child: Text(
              'View All',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorList(List<VendorModel> vendors) {
    return Stack(
      children: [
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            scrollDirection: Axis.horizontal,
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              return VendorCard(
                vendor: vendors[index],
                isSimpleView: true,
              );
            },
          ),
        ),
        if (vendors.length > 4)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 40.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColors.scaffoldColor,
                    AppColors.scaffoldColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.swipe_right_alt,
                  color: AppColors.primaryColor.withValues(alpha: 0.7),
                  size: 24.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
