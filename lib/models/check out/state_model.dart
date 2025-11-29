class StateModel {
  List<ShippingCharges>? shippingCharges;

  StateModel({this.shippingCharges});

  StateModel.fromJson(Map<String, dynamic> json) {
    if (json['shipping_charges'] != null) {
      shippingCharges = <ShippingCharges>[];
      json['shipping_charges'].forEach((v) {
        shippingCharges!.add(new ShippingCharges.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.shippingCharges != null) {
      data['shipping_charges'] =
          this.shippingCharges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ShippingCharges {
  String? state;
  String? shippingCharge;

  ShippingCharges({this.state, this.shippingCharge});

  ShippingCharges.fromJson(Map<String, dynamic> json) {
    state = json['state'];
    shippingCharge = json['shipping_charge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['state'] = this.state;
    data['shipping_charge'] = this.shippingCharge;
    return data;
  }
}
