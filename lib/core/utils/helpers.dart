class AppHelpers {
  AppHelpers._();

  static String formatDate(DateTime date) => date.toIso8601String();
}

class TimeFormatter {
  TimeFormatter._();

  static String toArabic12h(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    final marker = isPm ? 'م' : 'ص';
    return '$displayHour:$minuteStr $marker';
  }

  static const _indic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  /// Converts Western digits to Eastern Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩).
  static String toIndicDigits(String s) =>
      s.runes.map((r) {
        final d = r - 48; // '0' == 48
        return (d >= 0 && d <= 9) ? _indic[d] : String.fromCharCode(r);
      }).join();
}
