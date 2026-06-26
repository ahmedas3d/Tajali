import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tajali/features/quran/data/services/bookmark_service.dart';

void main() {
  late Directory tmpDir;
  late Box box;
  late BookmarkService service;

  setUpAll(() async {
    tmpDir = await Directory.systemTemp.createTemp('hive_bookmark_test_');
    Hive.init(tmpDir.path);
    box = await Hive.openBox(BookmarkService.boxName);
  });

  setUp(() {
    service = BookmarkService();
  });

  tearDown(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await box.close();
    await tmpDir.delete(recursive: true);
  });

  test('loadBookmarks returns empty set when no data stored', () {
    final result = service.loadBookmarks();
    expect(result, isEmpty);
  });

  test('saveBookmarks persists bookmarks to Hive', () {
    service.saveBookmarks({1, 18, 36});
    final loaded = service.loadBookmarks();
    expect(loaded, containsAll([1, 18, 36]));
    expect(loaded.length, 3);
  });

  test('saveBookmarks overwrites previous bookmarks', () {
    service.saveBookmarks({1, 2, 3});
    service.saveBookmarks({18, 36});
    final loaded = service.loadBookmarks();
    expect(loaded, containsAll([18, 36]));
    expect(loaded.length, 2);
  });

  test('saveBookmarks with empty set clears all bookmarks', () {
    service.saveBookmarks({1, 18});
    service.saveBookmarks({});
    final loaded = service.loadBookmarks();
    expect(loaded, isEmpty);
  });

  test('loadBookmarks round-trips values correctly', () {
    final original = {1, 36, 67, 78, 114};
    service.saveBookmarks(original);
    final loaded = service.loadBookmarks();
    expect(loaded, equals(original));
  });
}
