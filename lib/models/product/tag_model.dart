class TagModel {
  final int tagId;
  final String tagName;

  TagModel({
    required this.tagId,
    required this.tagName,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      tagId: json['tag_id'] is int
          ? json['tag_id']
          : int.tryParse(json['tag_id'].toString()) ?? 0,
      tagName: json['tag_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_id': tagId,
      'tag_name': tagName,
    };
  }
}
