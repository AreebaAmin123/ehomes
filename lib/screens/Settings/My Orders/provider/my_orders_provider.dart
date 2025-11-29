import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:e_Home_app/models/my_order_model.dart';
import 'package:e_Home_app/services/my_order_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class MyOrdersProvider with ChangeNotifier {
  final MyOrderServices _myOrderServices = MyOrderServices();

  MyOrderModel? _myOrderModel;
  MyOrderModel? get myOrderModel => _myOrderModel;

  Future<void> getMyOrders(context) async {
    try {
      final provider = Provider.of<EmailAuthProvider>(context, listen: false);
      await provider.loadUserSession();
      int userId = provider.user!.id;
      MyOrderModel response = await _myOrderServices.myOrder(userId);
      if (response.orders!.isNotEmpty) {
        _myOrderModel = response;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
