class ExclusiveProductTag {
  final int tagId;
  final String tagName;

  ExclusiveProductTag({required this.tagId, required this.tagName});

  factory ExclusiveProductTag.fromJson(Map<String, dynamic> json) {
    return ExclusiveProductTag(
      tagId: json['tag_id'] is int
          ? json['tag_id']
          : int.tryParse(json['tag_id'].toString()) ?? 0,
      tagName: json['tag_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_id': tagId,
      'tag_name': tagName,
    };
  }
}

class ExclusiveProductModel {
  final int productId;
  final String productName;
  final String imageUrl;
  final List<int> categories;
  final List<ExclusiveProductTag> tags;

  ExclusiveProductModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.categories,
    required this.tags,
  });

  factory ExclusiveProductModel.fromJson(Map<String, dynamic> json) {
    return ExclusiveProductModel(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id'].toString()) ?? 0,
      productName: json['product_name'] ?? '',
      imageUrl: (json['image_url'] ?? '').toString(),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e is Map<String, dynamic>
                  ? ExclusiveProductTag.fromJson(e)
                  : ExclusiveProductTag(tagId: 0, tagName: e.toString()))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'image_url': imageUrl,
      'categories': categories,
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }
}
