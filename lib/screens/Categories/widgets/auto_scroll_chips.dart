import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/constants/app_colors.dart';

class AutoScrollChips<T> extends StatefulWidget {
  final List<T> items;
  final T selectedItem;
  final Function(T) onItemSelected;
  final String Function(T) labelBuilder;
  final double spacing;
  final EdgeInsets padding;
  final Duration scrollDuration;
  final Curve scrollCurve;

  const AutoScrollChips({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.labelBuilder,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.scrollDuration = const Duration(milliseconds: 300),
    this.scrollCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<AutoScrollChips<T>> createState() => _AutoScrollChipsState<T>();
}

class _AutoScrollChipsState<T> extends State<AutoScrollChips<T>> {
  late final ScrollController _scrollController;
  final Map<T, GlobalKey> _chipKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeChipKeys();
  }

  @override
  void didUpdateWidget(AutoScrollChips<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _initializeChipKeys();
    }
    if (widget.selectedItem != oldWidget.selectedItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedChip();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChipKeys() {
    _chipKeys.clear();
    for (var item in widget.items) {
      _chipKeys[item] = GlobalKey();
    }
  }

  void _scrollToSelectedChip() {
    final selectedKey = _chipKeys[widget.selectedItem];
    if (selectedKey?.currentContext == null) return;

    final RenderBox renderBox =
        selectedKey!.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final scrollOffset = _scrollController.offset;

    // Calculate the center position
    final screenWidth = MediaQuery.of(context).size.width;
    final chipWidth = renderBox.size.width;
    final targetOffset =
        (position.dx + scrollOffset) - (screenWidth / 2) + (chipWidth / 2);

    // Ensure the target offset is within bounds
    final minOffset = 0.0;
    final maxOffset = _scrollController.position.maxScrollExtent;
    final boundedOffset = targetOffset.clamp(minOffset, maxOffset);

    _scrollController.animateTo(
      boundedOffset,
      duration: widget.scrollDuration,
      curve: widget.scrollCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = item == widget.selectedItem;

          return Padding(
            key: _chipKeys[item],
            padding: EdgeInsets.only(right: widget.spacing),
            child: ChoiceChip(
              label: Text(
                widget.labelBuilder(item),
                style: TextStyle(
                  color:
                      isSelected ? AppColors.whiteColor : AppColors.blackColor,
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              backgroundColor: Colors.white,
              elevation: 1,
              pressElevation: 2,
              shadowColor: AppColors.boxShadowColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.greyColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  widget.onItemSelected(item);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
