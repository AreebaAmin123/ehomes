class VariationModel {
  final int variationId;
  final String variationName;
  final String variationValue;
  final double price;
  final int stock;
  final String imageUrl;

  VariationModel({
    required this.variationId,
    required this.variationName,
    required this.variationValue,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  static String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300x400?text=No+Variation+Image';
    }

    // Clean the URL
    var cleanUrl = url.trim();

    // If it's already a full URL, validate and return
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      // Handle old klik.pk URLs
      if (cleanUrl.contains('klik.pk')) {
        final uri = Uri.parse(cleanUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final filename = pathSegments.last;
          return 'https://ehomes.pk/Vendor_Panel/uploads/variations/$filename';
        }
      }
      return cleanUrl;
    }

    // Remove any leading/trailing slashes
    cleanUrl = cleanUrl.replaceAll(RegExp(r'^/+|/+$'), '');

    // Split path into components
    final components = cleanUrl.split('/');

    // Extract filename (last component)
    String filename = components.last;

    // Add extension if missing
    if (!filename.contains('.')) {
      filename = '$filename.jpg';
    }

    // Default to variations folder
    return 'https://ehomes.pk/Vendor_Panel/uploads/variations/$filename';
  }

  // Factory method to create an object from JSON
  factory VariationModel.fromJson(Map<String, dynamic> json) {
    return VariationModel(
      variationId: json['variation_id'] is int
          ? json['variation_id']
          : int.tryParse(json['variation_id'].toString()) ?? 0,
      variationName: json['variation_name']?.toString() ?? '',
      variationValue: json['variation_value']?.toString() ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock'].toString()) ?? 0,
      imageUrl: _fixImageUrl(json['image_url']?.toString()),
    );
  }

  // Method to convert object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'variation_id': variationId,
      'variation_name': variationName,
      'variation_value': variationValue,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
    };
  }
}
