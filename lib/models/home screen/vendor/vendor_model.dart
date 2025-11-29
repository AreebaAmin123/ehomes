class VendorModel {
  final int id;
  final String storeName;
  final String phone;
  final String photo;
  final String address;
  final double avgRating;
  final int totalReviews;

  const VendorModel({
    required this.id,
    required this.storeName,
    required this.phone,
    required this.photo,
    required this.address,
    required this.avgRating,
    required this.totalReviews,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] ?? 0,
      storeName: json['store_name'] ?? '',
      phone: json['phone'] ?? '',
      photo: json['photo'] ?? '',
      address: json['address'] ?? '',
      avgRating: (json['avg_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': storeName,
      'phone': phone,
      'photo': photo,
      'address': address,
      'avg_rating': avgRating,
      'total_reviews': totalReviews,
    };
  }

  VendorModel copyWith({
    int? id,
    String? storeName,
    String? phone,
    String? photo,
    String? address,
    double? avgRating,
    int? totalReviews,
  }) {
    return VendorModel(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      address: address ?? this.address,
      avgRating: avgRating ?? this.avgRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorModel &&
        other.id == id &&
        other.storeName == storeName &&
        other.phone == phone &&
        other.photo == photo &&
        other.address == address &&
        other.avgRating == avgRating &&
        other.totalReviews == totalReviews;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      storeName,
      phone,
      photo,
      address,
      avgRating,
      totalReviews,
    );
  }

  @override
  String toString() {
    return 'VendorModel(id: $id, storeName: $storeName, phone: $phone, photo: $photo, address: $address, avgRating: $avgRating, totalReviews: $totalReviews)';
  }
}
