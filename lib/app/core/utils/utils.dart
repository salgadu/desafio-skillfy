// utils/date_helpers.dart
import 'package:intl/intl.dart';

class Utils {
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Hoje às ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateOnly == tomorrow) {
      return 'Amanhã às ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == now.year) {
      return DateFormat('dd/MM às HH:mm').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy às HH:mm').format(dateTime);
    }
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  static String formatDateOnly(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year) {
      return DateFormat('dd/MM').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }
}
