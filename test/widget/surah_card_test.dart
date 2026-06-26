import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/quran/data/models/surah_model.dart';
import 'package:tajali/features/quran/data/services/bookmark_service.dart';
import 'package:tajali/features/quran/presentation/widgets/surah_card.dart';
import 'package:tajali/features/quran/providers/quran_providers.dart';

final _surah = SurahModel(
  number: 18,
  name: 'سُورَةُ الْكَهْفِ',
  englishName: 'Al-Kahf',
  revelationType: 'Meccan',
  numberOfAyahs: 110,
);

class _NoOpBookmarkService extends BookmarkService {
  @override
  Set<int> loadBookmarks() => {};

  @override
  void saveBookmarks(Set<int> bookmarks) {}
}

Widget _buildCard({Set<int> bookmarks = const {}}) {
  return ProviderScope(
    overrides: [
      bookmarksProvider.overrideWith((_) => BookmarksNotifier(
            _NoOpBookmarkService(),
          )..state = bookmarks),
    ],
    child: MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF1B4332),
        body: SurahCard(surah: _surah),
      ),
    ),
  );
}

void main() {
  testWidgets('renders surah number', (tester) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();
    expect(find.text('18'), findsOneWidget);
  });

  testWidgets('renders Arabic name', (tester) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();
    expect(find.text('سُورَةُ الْكَهْفِ'), findsOneWidget);
  });

  testWidgets('renders English transliteration', (tester) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();
    expect(find.text('Al-Kahf'), findsOneWidget);
  });

  testWidgets('renders Meccan revelation badge', (tester) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();
    expect(find.text('مكية'), findsOneWidget);
  });

  testWidgets('renders Medinan revelation badge', (tester) async {
    final medinanSurah = SurahModel(
      number: 2,
      name: 'سُورَةُ الْبَقَرَةِ',
      englishName: 'Al-Baqara',
      revelationType: 'Medinan',
      numberOfAyahs: 286,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookmarksProvider.overrideWith(
              (_) => BookmarksNotifier(_NoOpBookmarkService())),
        ],
        child: MaterialApp(
          home: Scaffold(body: SurahCard(surah: medinanSurah)),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('مدنية'), findsOneWidget);
  });

  testWidgets('renders ayah count', (tester) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();
    expect(find.text('110 آية'), findsOneWidget);
  });

  testWidgets('shows outlined bookmark icon when not bookmarked',
      (tester) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsNothing);
  });

  testWidgets('shows filled bookmark icon when bookmarked', (tester) async {
    await tester.pumpWidget(_buildCard(bookmarks: {18}));
    await tester.pump();
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsNothing);
  });

  testWidgets('tapping bookmark icon toggles state', (tester) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();

    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump();
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });
}
