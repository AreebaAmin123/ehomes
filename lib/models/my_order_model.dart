class MyOrderModel {
  bool? success;
  List<Orders>? orders;

  MyOrderModel({this.success, this.orders});

  MyOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(new Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  String? orderId;
  String? userId;
  String? productName;
  Variation? variation;
  int? quantity;
  int? price;
  int? discountPrice;
  String? couponCode;
  int? couponAmount;
  int? shippingCharge;
  String? subtotal;
  String? finalTotal;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? state;
  String? zip;
  String? orderNotes;
  String? paymentMethod;
  String? orderStatus;
  String? orderDate;

  Orders(
      {this.orderId,
        this.userId,
        this.productName,
        this.variation,
        this.quantity,
        this.price,
        this.discountPrice,
        this.couponCode,
        this.couponAmount,
        this.shippingCharge,
        this.subtotal,
        this.finalTotal,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.address,
        this.city,
        this.state,
        this.zip,
        this.orderNotes,
        this.paymentMethod,
        this.orderStatus,
        this.orderDate});

  Orders.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    userId = json['user_id'];
    productName = json['product_name'];
    variation = json['variation'] != null
        ? new Variation.fromJson(json['variation'])
        : null;
    quantity = json['quantity'];
    price = json['price'];
    discountPrice = json['discount_price'];
    couponCode = json['coupon_code'];
    couponAmount = json['coupon_amount'];
    shippingCharge = json['shipping_charge'];
    subtotal = json['subtotal'];
    finalTotal = json['final_total'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    orderNotes = json['order_notes'];
    paymentMethod = json['payment_method'];
    orderStatus = json['order_status'];
    orderDate = json['order_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['user_id'] = this.userId;
    data['product_name'] = this.productName;
    if (this.variation != null) {
      data['variation'] = this.variation!.toJson();
    }
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['discount_price'] = this.discountPrice;
    data['coupon_code'] = this.couponCode;
    data['coupon_amount'] = this.couponAmount;
    data['shipping_charge'] = this.shippingCharge;
    data['subtotal'] = this.subtotal;
    data['final_total'] = this.finalTotal;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zip'] = this.zip;
    data['order_notes'] = this.orderNotes;
    data['payment_method'] = this.paymentMethod;
    data['order_status'] = this.orderStatus;
    data['order_date'] = this.orderDate;
    return data;
  }
}

class Variation {
  String? name;
  String? value;

  Variation({this.name, this.value});

  Variation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['value'] = this.value;
    return data;
  }
}
