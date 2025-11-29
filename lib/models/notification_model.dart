class NotificationResponse {
  final bool success;
  final String message;
  final String? name; // Firebase message ID
  final Map<String, dynamic>? data;
  final String? error;

  NotificationResponse({
    required this.success,
    required this.message,
    this.name,
    this.data,
    this.error,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown response',
      name: json['name'],
      data: json['data'],
      error: json['error'],
    );
  }

  factory NotificationResponse.error(String errorMessage) {
    return NotificationResponse(
      success: false,
      message: errorMessage,
      error: errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (error != null) 'error': error,
    };
  }
}
