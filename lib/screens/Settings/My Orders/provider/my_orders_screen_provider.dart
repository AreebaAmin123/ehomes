import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../../../../models/my_order_model.dart';
import 'my_orders_provider.dart';

class MyOrdersScreenProvider with ChangeNotifier {
  final MyOrdersProvider _ordersProvider;
  final TextEditingController searchController = TextEditingController();
  final ScrollController statusScrollController = ScrollController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  List<Orders>? _filteredOrders;

  MyOrdersScreenProvider(this._ordersProvider) {
    _initializeListeners();
  }

  // Getters
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedStatus => _selectedStatus;
  List<Orders>? get filteredOrders => _filteredOrders;
  MyOrderModel? get ordersModel => _ordersProvider.myOrderModel;

  final List<Map<String, dynamic>> statusFilters = [
    {
      'label': 'All',
      'value': null,
      'color': AppColors.greenColor,
      'icon': Icons.list_alt,
    },
    {
      'label': 'Pending',
      'value': 'pending',
      'color': AppColors.orangeColor,
      'icon': Icons.pending_outlined,
    },
    {
      'label': 'Processing',
      'value': 'processing',
      'color': AppColors.blackColor,
      'icon': Icons.sync,
    },
    {
      'label': 'Delivered',
      'value': 'delivered',
      'color': AppColors.greenColor,
      'icon': Icons.check_circle_outline,
    },
    {
      'label': 'Cancelled',
      'value': 'cancelled',
      'color': AppColors.redColor,
      'icon': Icons.cancel_outlined,
    },
  ];

  void _initializeListeners() {
    searchController.addListener(_updateFilteredOrders);
  }

  @override
  void dispose() {
    searchController.dispose();
    statusScrollController.dispose();
    super.dispose();
  }

  Future<void> loadOrders(BuildContext context) async {
    await _ordersProvider.getMyOrders(context);
    _updateFilteredOrders();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _updateFilteredOrders();
    notifyListeners();
  }

  void setSelectedStatus(String? status) {
    _selectedStatus = status;
    _updateFilteredOrders();
    notifyListeners();
  }

  void clearFilters() {
    searchController.clear();
    _startDate = null;
    _endDate = null;
    _selectedStatus = null;
    _filteredOrders = null;
    notifyListeners();
  }

  void _updateFilteredOrders() {
    if (_ordersProvider.myOrderModel?.orders == null) {
      _filteredOrders = null;
      notifyListeners();
      return;
    }

    List<Orders> orders = List.from(_ordersProvider.myOrderModel!.orders!);

    // Always exclude delivered orders
    orders = orders
        .where((order) => order.orderStatus?.toLowerCase() != 'delivered')
        .toList();

    // Filter by order ID
    if (searchController.text.isNotEmpty) {
      orders = orders
          .where((order) =>
              order.orderId
                  ?.toLowerCase()
                  .contains(searchController.text.toLowerCase()) ??
              false)
          .toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      orders = orders
          .where((order) =>
              order.orderStatus?.toLowerCase() ==
              _selectedStatus?.toLowerCase())
          .toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      orders = orders.where((order) {
        if (order.orderDate == null) return false;
        try {
          final orderDate = DateTime.parse(order.orderDate!);
          return orderDate.isAfter(_startDate!.subtract(Duration(days: 1))) &&
              orderDate.isBefore(_endDate!.add(Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    _filteredOrders = orders;
    notifyListeners();
  }

  void scrollToSelectedStatus(int index, BuildContext context) {
    if (!statusScrollController.hasClients) return;

    final itemWidth = 100.0; // Approximate width of each item
    final padding = 16.0; // Horizontal padding of the list
    final screenWidth = MediaQuery.of(context).size.width - (2 * padding);
    final maxScroll = statusScrollController.position.maxScrollExtent;

    double targetScroll =
        (itemWidth * index) - (screenWidth / 2) + (itemWidth / 2);
    targetScroll = targetScroll.clamp(0.0, maxScroll);

    statusScrollController.animateTo(
      targetScroll,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
        return AppColors.greenColor;
      case 'cancelled':
        return AppColors.redColor;
      case 'processing':
        return AppColors.blueColor;
      case 'pending':
        return AppColors.orangeColor;
      default:
        return AppColors.primaryColor;
    }
  }

  IconData getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'processing':
        return Icons.sync;
      case 'pending':
        return Icons.pending_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String formatAddress(Orders order) {
    List<String> parts = [];
    if (order.address != null && order.address!.isNotEmpty) {
      parts.add(order.address!);
    }
    if (order.city != null && order.city!.isNotEmpty) parts.add(order.city!);
    if (order.state != null && order.state!.isNotEmpty) parts.add(order.state!);
    if (order.zip != null && order.zip!.isNotEmpty) parts.add(order.zip!);
    return parts.join(', ');
  }

  bool hasCustomerDetails(Orders order) {
    return (order.firstName != null && order.firstName!.isNotEmpty) ||
        (order.lastName != null && order.lastName!.isNotEmpty) ||
        (order.email != null && order.email!.isNotEmpty) ||
        (order.phone != null && order.phone!.isNotEmpty) ||
        hasAddress(order);
  }

  bool hasAddress(Orders order) {
    return (order.address != null && order.address!.isNotEmpty) ||
        (order.city != null && order.city!.isNotEmpty) ||
        (order.state != null && order.state!.isNotEmpty) ||
        (order.zip != null && order.zip!.isNotEmpty);
  }
}
