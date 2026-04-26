import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy', 'tr_TR');
    return formatter.format(date);
  }

  static String formatDateShort(DateTime date) {
    final formatter = DateFormat('d MMM yyyy', 'tr_TR');
    return formatter.format(date);
  }

  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy HH:mm', 'tr_TR');
    return formatter.format(date);
  }

  static String formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm', 'tr_TR');
    return formatter.format(date);
  }

  static String formatDayMonth(DateTime date) {
    final formatter = DateFormat('d MMMM', 'tr_TR');
    return formatter.format(date);
  }

  static String formatMonthYear(DateTime date) {
    final formatter = DateFormat('MMMM yyyy', 'tr_TR');
    return formatter.format(date);
  }

  static String formatWeekday(DateTime date) {
    final formatter = DateFormat('EEEE', 'tr_TR');
    return formatter.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Şimdi';
        }
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }
}
