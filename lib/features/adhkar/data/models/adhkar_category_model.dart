class AdhkarCategoryModel {
  const AdhkarCategoryModel({
    required this.id,
    required this.nameAr,
    required this.count,
    required this.iconName,
  });

  final String id;
  final String nameAr;
  final int count;
  final String iconName;

  factory AdhkarCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdhkarCategoryModel(
      id: json['id'] as String,
      nameAr: json['category'] as String,
      count: json['count'] as int,
      iconName: _iconForCategory(json['id'] as String),
    );
  }

  static String _iconForCategory(String id) {
    const map = {
      'morning': 'icon_adhkar',
      'evening': 'icon_adhkar',
      'prayer': 'icon_prayer',
      'sleep': 'icon_adhkar',
      'wakeup': 'icon_adhkar',
      'misc': 'icon_adhkar',
      'food': 'icon_adhkar',
      'istighfar': 'icon_adhkar',
    };
    return map[id] ?? 'icon_adhkar';
  }
}
