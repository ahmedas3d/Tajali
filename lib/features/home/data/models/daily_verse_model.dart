class DailyVerseModel {
  const DailyVerseModel({
    required this.text,
    required this.surahName,
    required this.ayahNumber,
    required this.surahNumber,
  });

  final String text;
  final String surahName;
  final int ayahNumber;
  final int surahNumber;

  String get ref => '$surahName: $ayahNumber';

  factory DailyVerseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final surah = data['surah'] as Map<String, dynamic>;
    return DailyVerseModel(
      text: data['text'] as String,
      surahName: surah['name'] as String,
      ayahNumber: data['numberInSurah'] as int,
      surahNumber: surah['number'] as int,
    );
  }
}
