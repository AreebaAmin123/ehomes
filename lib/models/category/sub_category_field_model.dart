class SubCategoryFieldModel {
  final String name;
  final String? image;

  SubCategoryFieldModel({
    required this.name,
    this.image,
  });

  factory SubCategoryFieldModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryFieldModel(
      name: json['name'] ?? 'Unknown',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }
}
