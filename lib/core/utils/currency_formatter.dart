import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _etbFormat = NumberFormat.currency(
    symbol: 'ETB ',
    decimalDigits: 2,
    customPattern: '¤#,##0.00',
  );

  static final _compactFormat = NumberFormat.compactCurrency(
    symbol: 'ETB ',
    decimalDigits: 1,
  );

  /// Formats a number as ETB currency (e.g., "ETB 1,234.56")
  static String format(num amount) {
    return _etbFormat.format(amount);
  }

  /// Formats a number as compact ETB currency (e.g., "ETB 1.2K")
  static String formatCompact(num amount) {
    return _compactFormat.format(amount);
  }
}
