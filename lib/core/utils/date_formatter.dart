import 'package:intl/intl.dart';

class AppDateFormatter {
  static String formatFullDateWithTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy, EEEE - HH:mm', 'tr_TR').format(dateTime);
  }

  static String formatDateWithDay(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(dateTime);
  }

  static String formatShortDateWithTime(DateTime dateTime) {
    return DateFormat('dd MMMM EEEE, HH:mm', 'tr_TR').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
