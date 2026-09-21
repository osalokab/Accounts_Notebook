import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat('#,##0.##', 'ar');
  static final NumberFormat _plainNumberFormatter = NumberFormat('#,##0.##', 'en_US');
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd', 'ar');
  static final DateFormat _displayDateFormatter = DateFormat('dd-MM-yyyy', 'ar');
  static final DateFormat _dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm', 'ar');
  static final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy', 'ar');
  static final DateFormat _monthKeyFormatter = DateFormat('yyyy-MM', 'en_US');

  /// Format money amount: e.g. 1,500 or 1,500.50
  static String formatAmount(num amount, {String? currencySymbol}) {
    final formatted = _plainNumberFormatter.format(amount.abs());
    if (currencySymbol != null && currencySymbol.isNotEmpty) {
      return '$formatted $currencySymbol';
    }
    return formatted;
  }

  /// Format amount in Arabic numeral representation if desired
  static String formatAmountArabic(num amount, {String? currencySymbol}) {
    final formatted = _currencyFormatter.format(amount.abs());
    if (currencySymbol != null && currencySymbol.isNotEmpty) {
      return '$formatted $currencySymbol';
    }
    return formatted;
  }

  /// Format date to yyyy-MM-dd
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Format date to dd-MM-yyyy (standard in screenshot image15)
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormatter.format(date);
  }

  /// Format date to yyyy-MM-dd HH:mm
  static String formatDateTime(DateTime date) {
    return _dateTimeFormatter.format(date);
  }

  /// Format to Arabic Month Year e.g. "سبتمبر 2026"
  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  /// Format to Year-Month key e.g. "2026-09"
  static String formatMonthKey(DateTime date) {
    return _monthKeyFormatter.format(date);
  }

  /// Parse double safely rounded to 2 decimal places to avoid floating point precision issues
  static double roundMoney(double value) {
    return (value * 100).roundToDouble() / 100.0;
  }
}
