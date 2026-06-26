import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/quran/data/models/surah_model.dart';
import 'package:tajali/features/quran/data/services/bookmark_service.dart';
import 'package:tajali/features/quran/presentation/widgets/juz_list_view.dart';
import 'package:tajali/features/quran/providers/quran_providers.dart';

final _allSurahs = List.generate(
  114,
  (i) => SurahModel(
    number: i + 1,
    name: 'سورة ${i + 1}',
    englishName: 'Surah-${i + 1}',
    revelationType: i % 2 == 0 ? 'Meccan' : 'Medinan',
    numberOfAyahs: 7 + i,
  ),
);

class _NoOpBookmarkService extends BookmarkService {
  @override
  Set<int> loadBookmarks() => {};

  @override
  void saveBookmarks(Set<int> bookmarks) {}
}

void main() {
  testWidgets('shows all 30 Juz headers', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahListProvider.overrideWith((_) async => _allSurahs),
          bookmarksProvider.overrideWith(
              (_) => BookmarksNotifier(_NoOpBookmarkService())),
        ],
        child: const MaterialApp(home: Scaffold(body: JuzListView())),
      ),
    );
    await tester.pumpAndSettle();

    for (var j = 1; j <= 30; j++) {
      expect(find.text('الجزء $j'), findsOneWidget,
          reason: 'Missing header for Juz $j');
    }
  });

  testWidgets('shows continuation note for Juz 2 and 5', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahListProvider.overrideWith((_) async => _allSurahs),
          bookmarksProvider.overrideWith(
              (_) => BookmarksNotifier(_NoOpBookmarkService())),
        ],
        child: const MaterialApp(home: Scaffold(body: JuzListView())),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('يتضمن هذا الجزء تتمة السور السابقة'),
      findsWidgets,
    );
  });

  testWidgets('shows surah cards under correct Juz', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahListProvider.overrideWith((_) async => _allSurahs),
          bookmarksProvider.overrideWith(
              (_) => BookmarksNotifier(_NoOpBookmarkService())),
        ],
        child: const MaterialApp(home: Scaffold(body: JuzListView())),
      ),
    );
    await tester.pumpAndSettle();

    // Al-Fatiha (#1) and Al-Baqarah (#2) should be visible under Juz 1
    expect(find.text('سورة 1'), findsOneWidget);
    expect(find.text('سورة 2'), findsOneWidget);
  });
}
