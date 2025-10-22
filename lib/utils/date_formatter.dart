import 'package:intl/intl.dart';

class DateFormatter {
  /// Format DateTime to Vietnamese date format (dd/MM/yyyy)
  static String formatDateVietnamese(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  }

  /// Format DateTime to Vietnamese date time format (dd/MM/yyyy HH:mm)
  static String formatDateTimeVietnamese(DateTime date) {
    return '${formatDateVietnamese(date)} ${formatTimeVietnamese(date)}';
  }

  /// Format DateTime to Vietnamese date with day name (Thứ X, dd/MM/yyyy)
  static String formatDateVietnameseWithDay(DateTime date) {
    return '${getDayNameVietnamese(date)}, ${formatDateVietnamese(date)}';
  }

  /// Format DateTime to Vietnamese time format (HH:mm)
  static String formatTimeVietnamese(DateTime date) {
    return DateFormat('HH:mm', 'vi_VN').format(date);
  }

  /// Parse Vietnamese date string (dd/MM/yyyy) to DateTime
  static DateTime? parseVietnameseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy', 'vi_VN').parseStrict(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time in Vietnamese (hôm qua, hôm nay, ngày mai, etc.)
  static String getRelativeTimeVietnamese(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    switch (difference) {
      case -1:
        return 'Hôm qua';
      case 0:
        return 'Hôm nay';
      case 1:
        return 'Ngày mai';
      default:
        if (difference > 1 && difference <= 7) {
          return 'Trong $difference ngày tới';
        } else if (difference < -1 && difference >= -7) {
          return '${-difference} ngày trước';
        } else {
          return formatDateVietnamese(date);
        }
    }
  }

  /// Get Vietnamese day name (Thứ Hai, Thứ Ba, …)
  static String getDayNameVietnamese(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }
}
