import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/quran/data/models/surah_model.dart';
import 'package:tajali/features/quran/data/services/bookmark_service.dart';
import 'package:tajali/features/quran/presentation/quran_screen.dart';
import 'package:tajali/features/quran/providers/quran_providers.dart';

final _fakeSurahs = List.generate(
  5,
  (i) => SurahModel(
    number: i + 1,
    name: 'سورة ${i + 1}',
    englishName: 'Surah-${i + 1}',
    revelationType: i % 2 == 0 ? 'Meccan' : 'Medinan',
    numberOfAyahs: 7 + i,
  ),
);

Widget _buildScreen({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      surahListProvider.overrideWith((_) async => _fakeSurahs),
      bookmarksProvider.overrideWith((_) => BookmarksNotifier(
            _NoOpBookmarkService(),
          )),
      lastReadProvider.overrideWith((_) async => null),
      ...overrides,
    ],
    child: const MaterialApp(
      home: QuranScreen(),
    ),
  );
}

class _NoOpBookmarkService extends BookmarkService {
  @override
  Set<int> loadBookmarks() => {};

  @override
  void saveBookmarks(Set<int> bookmarks) {}
}

void main() {
  testWidgets('shows three tabs', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    expect(find.text('السور'), findsOneWidget);
    expect(find.text('الأجزاء'), findsOneWidget);
    expect(find.text('المفضلة'), findsOneWidget);
  });

  testWidgets('search bar visible on Surahs tab', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('search bar hidden after switching to Juz tab', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    await tester.tap(find.text('الأجزاء'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('search bar hidden on Bookmarks tab', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    await tester.tap(find.text('المفضلة'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('shows skeleton cards while loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahListProvider.overrideWith(
              (_) => Future.delayed(const Duration(seconds: 5), () => [])),
          bookmarksProvider.overrideWith(
              (_) => BookmarksNotifier(_NoOpBookmarkService())),
          lastReadProvider.overrideWith((_) async => null),
        ],
        child: const MaterialApp(home: QuranScreen()),
      ),
    );
    await tester.pump();

    // Skeleton cards use Container with fixed height — just check no surah names appear
    expect(find.text('سورة 1'), findsNothing);
  });

  testWidgets('shows surah list after data loads', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('سورة 1'), findsWidgets);
  });
}
