class CouponCodeModel {
  String? discount;

  CouponCodeModel({this.discount});

  CouponCodeModel.fromJson(Map<String, dynamic> json) {
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['discount'] = this.discount;
    return data;
  }
}
