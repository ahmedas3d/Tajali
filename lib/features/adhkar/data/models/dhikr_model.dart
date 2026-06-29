class DhikrModel {
  const DhikrModel({
    required this.index,
    required this.categoryId,
    required this.text,
    required this.repeat,
    this.source,
    this.virtue,
  });

  final int index;
  final String categoryId;
  final String text;
  final int repeat;
  final String? source;
  final String? virtue;

  factory DhikrModel.fromJson(
    Map<String, dynamic> json,
    String categoryId,
    int index,
  ) {
    final reference = json['reference'] as String?;
    final description = json['description'] as String?;
    return DhikrModel(
      index: index,
      categoryId: categoryId,
      text: json['text'] as String,
      repeat: (json['count'] as num).toInt(),
      source: (reference != null && reference.isNotEmpty) ? reference : null,
      virtue:
          (description != null && description.isNotEmpty) ? description : null,
    );
  }
}
