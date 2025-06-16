import 'package:intl/intl.dart';

class DateUtils {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  static String formatMissionDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final missionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (missionDate == today) {
      return 'Aujourd\'hui à ${formatTime(dateTime)}';
    } else if (missionDate == today.add(const Duration(days: 1))) {
      return 'Demain à ${formatTime(dateTime)}';
    } else {
      return '${formatDate(dateTime)} à ${formatTime(dateTime)}';
    }
  }

  static String getDayName(DateTime date) {
    return DateFormat('EEEE', 'fr_FR').format(date);
  }

  static String getMonthName(DateTime date) {
    return DateFormat('MMMM', 'fr_FR').format(date);
  }
} 