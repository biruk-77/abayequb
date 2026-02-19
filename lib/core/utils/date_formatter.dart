import 'package:abushakir/abushakir.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static const List<String> _ethiopianMonthsEn = [
    "Meskerem",
    "Tikimt",
    "Hidar",
    "Tahsas",
    "Tir",
    "Yekatit",
    "Megabit",
    "Miyaziya",
    "Ginbot",
    "Sene",
    "Hamle",
    "Nehase",
    "Pagume",
  ];

  static const List<String> _ethiopianMonthsAm = [
    "መስከረም",
    "ጥቅምት",
    "ህዳር",
    "ታህሳስ",
    "ጥር",
    "የካቲት",
    "መጋቢት",
    "ሚያዚያ",
    "ግንቦት",
    "ሰኔ",
    "ሐምሌ",
    "ነሐሴ",
    "ጳጉሜ",
  ];

  /// Formats a DateTime object to an Ethiopian Calendar string.
  /// [locale] can be 'en' or 'am'. Defaults to 'en'.
  static String format(DateTime date, [String locale = 'en']) {
    try {
      final etDate = EtDatetime.fromMillisecondsSinceEpoch(
        date.millisecondsSinceEpoch,
      );
      final monthIndex = etDate.month - 1; // 1-based to 0-based

      String monthName;
      if (locale == 'am') {
        monthName = _ethiopianMonthsAm[monthIndex];
      } else {
        monthName = _ethiopianMonthsEn[monthIndex];
      }

      return '$monthName ${etDate.day}, ${etDate.year}';
    } catch (e) {
      // Fallback to Gregorian if something fails
      return DateFormat.yMMMd(locale).format(date);
    }
  }

  // Wrapper for backward compatibility or explicit Ethiopian naming
  static String formatEthiopian(DateTime date, [String locale = 'en']) {
    return format(date, locale);
  }

  /// Returns just the month name
  static String getMonthName(DateTime date, [String locale = 'en']) {
    try {
      final etDate = EtDatetime.fromMillisecondsSinceEpoch(
        date.millisecondsSinceEpoch,
      );
      final monthIndex = etDate.month - 1;

      if (locale == 'am') {
        return _ethiopianMonthsAm[monthIndex];
      } else {
        return _ethiopianMonthsEn[monthIndex];
      }
    } catch (e) {
      return DateFormat.MMM(locale).format(date);
    }
  }
}
