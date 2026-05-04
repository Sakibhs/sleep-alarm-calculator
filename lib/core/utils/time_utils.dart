import 'package:intl/intl.dart';

class TimeUtils {
  TimeUtils._();

  static const int fallAsleepMinutes = 15;
  static const int cycleMinutes = 90;

  /// Returns hh:mm AM/PM string from a DateTime
  static String formatTime(DateTime dt) => DateFormat('hh:mm a').format(dt);

  /// Returns "Xh Ym" from total minutes
  static String formatDuration(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Adds [minutes] to [base], wrapping around midnight
  static DateTime addMinutes(DateTime base, int minutes) =>
      base.add(Duration(minutes: minutes));

  /// Subtracts [minutes] from [base], wrapping around midnight
  static DateTime subtractMinutes(DateTime base, int minutes) =>
      base.subtract(Duration(minutes: minutes));

  /// Strips date portion — returns today's date with given hour/minute
  static DateTime todayAt(int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Strips date portion — returns today's date with given TimeOfDay
  static DateTime fromTimeOfDay(
    int hour,
    int minute, {
    bool nextDayIfPast = false,
  }) {
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, hour, minute);
    if (nextDayIfPast && dt.isBefore(now)) {
      dt = dt.add(const Duration(days: 1));
    }
    return dt;
  }
}
