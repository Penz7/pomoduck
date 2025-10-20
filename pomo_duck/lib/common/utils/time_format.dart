import 'package:easy_localization/easy_localization.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';

class TimeFormat {
  TimeFormat._();
  static final instance = TimeFormat._();


  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (dateOnly == today) return '${LocaleKeys.today.tr()} ${formatTime(dateTime)}';
    return '${dateTime.day}/${dateTime.month} ${formatTime(dateTime)}';
  }

  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}