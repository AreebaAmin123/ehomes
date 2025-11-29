class FeedbackModel {
  final int id;
  final int userId;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String createdAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'created_at': createdAt,
    };
  }
}
