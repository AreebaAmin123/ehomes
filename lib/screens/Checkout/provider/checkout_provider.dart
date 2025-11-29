import 'package:e_Home_app/screens/Cart/provider/cart_provider.dart';
import 'package:e_Home_app/screens/Dashboard/dashboard_page.dart';
import 'package:e_Home_app/services/checkout_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/check out/coupon_code_model.dart';
import '../../../models/check out/state_model.dart';
import '../../Auth/email section/provider/email_authProvider.dart';
import '../../../models/check out/check_out_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Payment/providers/delivery_slot_provider.dart';

class CheckoutProvider with ChangeNotifier {
  final CheckoutServices _checkoutServices = CheckoutServices();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void resetSelectedState() {
    _selectedState = null;
    _shippingCharge = null;
    notifyListeners();
  }

  CheckOutModel? _checkOutModel;

  CheckOutModel? get checkOutModel => _checkOutModel;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  CouponCodeModel? _couponCodeModel;

  CouponCodeModel? get couponCodeModel => _couponCodeModel;

  bool _isCouponLoading = false;

  bool get isCouponLoading => _isCouponLoading;

  Future<void> checkout(
    BuildContext context,
    String firstName,
    String lastName,
    String email,
    String phone,
    String address,
    String city,
    String state,
    String? zip,
    String orderNotes,
    String paymentMethod,
    int discount,
    String couponCode,
    int? couponAmount,
    int shippingCharge,
    int slotId,
  ) async {
    final provider = Provider.of<EmailAuthProvider>(context, listen: false);
    await provider.loadUserSession();
    final userId = provider.user!.id;

    try {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CupertinoActivityIndicator()),
      );

      CheckOutModel response = await _checkoutServices.checkout(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: state,
        zip: zip,
        orderNotes: orderNotes,
        paymentMethod: paymentMethod,
        discount: discount,
        couponCode: couponCode,
        couponAmount: couponAmount,
        shippingCharge: shippingCharge,
        slotId: slotId,
      );
      if (response.success == true) {
        _checkOutModel = response;
        _selectedState = null;
        _shippingCharge = null;

        // Show local notification for successful order
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final productNames = cartProvider.cartModel?.cart
                ?.map((item) => item.productName ?? 'Unknown Product')
                .join(', ') ??
            'Your products';

        final totalItems = cartProvider.cartModel?.cart?.length ?? 0;
        final totalAmount = cartProvider.totalCartPrice;

        // Get delivery slot details
        final deliverySlotProvider =
            Provider.of<DeliverySlotProvider>(context, listen: false);
        final selectedSlot = deliverySlotProvider.getSelectedSlot();
        final deliveryTime = selectedSlot != null
            ? '${selectedSlot.date} (${selectedSlot.startTime} - ${selectedSlot.endTime})'
            : 'To be confirmed';

        await _flutterLocalNotificationsPlugin.show(
          0, // Notification ID
          'Order Placed Successfully',
          '''Your order #${response.orderId} has been confirmed!
          
Products: $productNames
Total Items: $totalItems
Amount: ₹${totalAmount.toStringAsFixed(2)}
Delivery: $deliveryTime
Payment: $paymentMethod''',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              enableVibration: true,
              playSound: true,
              showWhen: true,
              styleInformation: BigTextStyleInformation(
                '''Your order #${response.orderId} has been confirmed!
                
Products: $productNames
Total Items: $totalItems
Amount: Rs.${totalAmount.toStringAsFixed(2)}
Delivery: $deliveryTime
Payment: $paymentMethod''',
                htmlFormatBigText: true,
                contentTitle: 'Order Placed Successfully',
                htmlFormatContentTitle: true,
                summaryText: 'Order #${response.orderId}',
                htmlFormatSummaryText: true,
              ),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );

        // Clear the cart after successful checkout
        cartProvider.clearCart();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  response.message ?? "Checkout failed. Please try again.")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print("Checkout Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  StateModel? _shippingStates;

  StateModel? get shippingStates => _shippingStates;

  int? _shippingCharge;

  int? get shippingCharge => _shippingCharge;

  String? _selectedState;

  String? get selectedState => _selectedState;

  void setSelectedState(String? state) {
    _selectedState = state;

    final match = _shippingStates?.shippingCharges?.firstWhere(
      (e) => e.state?.toLowerCase() == state?.toLowerCase(),
      orElse: () => ShippingCharges(state: null, shippingCharge: '0'),
    );

    _shippingCharge = double.tryParse(match?.shippingCharge ?? '0')?.toInt();
    print('Selected State: $state | Charge: $_shippingCharge');

    notifyListeners();
  }

  /// Get discount from coupon code
  Future<void> getCouponDiscount(String couponCode) async {
    _isCouponLoading = true;
    notifyListeners();

    try {
      final response = await _checkoutServices.getCouponDiscount(couponCode);
      if (response != null && response.containsKey('discount')) {
        _couponCodeModel = CouponCodeModel.fromJson(response);
      } else {
        _couponCodeModel = null;
      }
    } catch (e) {
      _couponCodeModel = null;
      rethrow;
    } finally {
      _isCouponLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStates() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    try {
      _isLoading = true;
      notifyListeners();

      final states = await _checkoutServices.getStates();

      // Update all state at once
      _shippingStates = states;
      if (states?.shippingCharges?.isNotEmpty ?? false) {
        _selectedState = states!.shippingCharges!.first.state;
        _shippingCharge = int.tryParse(
          states.shippingCharges!.first.shippingCharge ?? '0',
        );
      }
    } catch (e) {
      print('Error fetching states: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners(); // Only notify once at the end
    }
  }
}
