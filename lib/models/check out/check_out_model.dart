class CheckOutModel {
  bool? success;
  String? message;
  String? orderId;
  int? vendorId;
  int? totalAmount;

  CheckOutModel(
      {this.success,
        this.message,
        this.orderId,
        this.vendorId,
        this.totalAmount});

  CheckOutModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    orderId = json['order_id'];
    vendorId = json['vendor_id'];
    totalAmount = json['total_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['order_id'] = this.orderId;
    data['vendor_id'] = this.vendorId;
    data['total_amount'] = this.totalAmount;
    return data;
  }
}
