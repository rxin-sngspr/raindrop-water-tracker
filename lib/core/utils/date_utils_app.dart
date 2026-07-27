import 'package:intl/intl.dart';

class DateUtilsApp {
  DateUtilsApp._();

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatShortDay(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime get today => DateTime.now();
  static DateTime get todayDate => DateTime(today.year, today.month, today.day);

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static List<DateTime> getDaysInMonth(int year, int month) {
    final days = <DateTime>[];
    final count = daysInMonth(year, month);
    for (int i = 1; i <= count; i++) {
      days.add(DateTime(year, month, i));
    }
    return days;
  }

}
