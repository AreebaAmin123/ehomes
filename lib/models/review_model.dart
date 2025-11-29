class ReviewModel {
  final int id;
  final String name;
  final String email;
  final int rating;
  final String review;
  final String createdAt;
  final int productId;
  final int categoryId;
  final int isApproved;

  ReviewModel({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.productId,
    required this.categoryId,
    required this.isApproved,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      name: json['user_name'] ?? '',
      email: json['user_email'] ?? '',
      rating: json['rating'] ?? 0,
      review: json['review'] ?? '',
      createdAt: json['created_at'] ?? '',
      productId: json['product_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      isApproved: json['is_approved'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': name,
      'user_email': email,
      'rating': rating,
      'review': review,
      'created_at': createdAt,
      'product_id': productId,
      'category_id': categoryId,
      'is_approved': isApproved,
    };
  }
}
