class TrackOrderModel {
  bool? success;
  Order? order;

  TrackOrderModel({this.success, this.order});

  TrackOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    return data;
  }
}

class Order {
  String? orderId;
  int? productId;
  int? quantity;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? state;
  String? orderStatus;
  String? orderDate;
  String? productName;

  Order(
      {this.orderId,
        this.productId,
        this.quantity,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.address,
        this.city,
        this.state,
        this.orderStatus,
        this.orderDate,
        this.productName});

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    orderStatus = json['order_status'];
    orderDate = json['order_date'];
    productName = json['product_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['order_status'] = this.orderStatus;
    data['order_date'] = this.orderDate;
    data['product_name'] = this.productName;
    return data;
  }
}
