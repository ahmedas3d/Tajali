import 'package:hive_flutter/hive_flutter.dart';

class BookmarkService {
  static const String boxName = 'bookmarksBox';
  static const String _key = 'bookmarks';

  Box get _box => Hive.box(boxName);

  Set<int> loadBookmarks() {
    final stored = _box.get(_key);
    if (stored == null) return {};
    return Set<int>.from((stored as List).cast<int>());
  }

  void saveBookmarks(Set<int> bookmarks) {
    _box.put(_key, bookmarks.toList());
  }
}
