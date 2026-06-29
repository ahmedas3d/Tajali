import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/adhkar_category_model.dart';
import '../models/dhikr_model.dart';

class AdhkarService {
  static List<AdhkarCategoryModel>? _cachedCategories;
  static Map<String, List<DhikrModel>>? _cachedDhikr;

  Future<List<AdhkarCategoryModel>> getCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;
    await _load();
    return _cachedCategories!;
  }

  Future<List<DhikrModel>> getDhikrByCategory(String categoryId) async {
    if (_cachedDhikr != null) {
      return _cachedDhikr![categoryId] ?? [];
    }
    await _load();
    return _cachedDhikr![categoryId] ?? [];
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/azkar.json');
    final List<dynamic> json = jsonDecode(raw) as List<dynamic>;

    final categories = <AdhkarCategoryModel>[];
    final dhikrMap = <String, List<DhikrModel>>{};

    for (final item in json) {
      final map = item as Map<String, dynamic>;
      final category = AdhkarCategoryModel.fromJson(map);
      categories.add(category);

      final adhkarList = map['adhkar'] as List<dynamic>;
      dhikrMap[category.id] = adhkarList.asMap().entries.map((e) {
        return DhikrModel.fromJson(
          e.value as Map<String, dynamic>,
          category.id,
          e.key,
        );
      }).toList();
    }

    _cachedCategories = categories;
    _cachedDhikr = dhikrMap;
  }

  static void clearCache() {
    _cachedCategories = null;
    _cachedDhikr = null;
  }
}
