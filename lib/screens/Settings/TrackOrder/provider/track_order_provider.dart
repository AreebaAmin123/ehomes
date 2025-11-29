// ignore_for_file: prefer_final_fields

import 'package:e_Home_app/models/track_order_model.dart';
import 'package:e_Home_app/services/track_order_services.dart';
import 'package:flutter/cupertino.dart';

class TrackOrderProvider with ChangeNotifier {
  TrackOrderServices _trackOrderServices = TrackOrderServices();

  TrackOrderModel? _trackOrderModel;
  TrackOrderModel? get trackOrderModel => _trackOrderModel;

  void disposeOrder() {
    _trackOrderModel = null;
  }

  Future<void> trackOrder(String orderId) async {
    try {
      TrackOrderModel response = (await _trackOrderServices.trackOrder(orderId));
     if(response.order != null){
       _trackOrderModel = response;
       notifyListeners();
     }
    } catch (e) {
      rethrow;
    }
  }
}
