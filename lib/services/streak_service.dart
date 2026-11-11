import 'package:intl/intl.dart';
import '../models/workout_session.dart';

class StreakService {
  // India Standard Time is UTC + 5:30
  static DateTime get nowIST {
    final utc = DateTime.now().toUtc();
    return utc.add(const Duration(hours: 5, minutes: 30));
  }

  static String formatDateIST(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static String get todayKeyIST => formatDateIST(nowIST);

  /// Calculates the current streak in days, skipping Sundays as rest days.
  /// If an athlete works out on Sunday, it counts; if they rest on Sunday,
  /// it never breaks their streak!
  static int calculateCurrentStreak(Map<String, WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;

    DateTime current = DateTime(nowIST.year, nowIST.month, nowIST.day);
    final todayKey = formatDateIST(current);
    final todayHasWorkout = _hasWorkout(sessions[todayKey]);

    // If today is Sunday and has no workout, start checking from Saturday
    if (!todayHasWorkout && current.weekday == DateTime.sunday) {
      current = current.subtract(const Duration(days: 1));
    } else if (!todayHasWorkout) {
      // If today is a weekday and not yet logged, check if yesterday was logged
      final yesterday = current.subtract(const Duration(days: 1));
      final yesterdayKey = formatDateIST(yesterday);
      if (_hasWorkout(sessions[yesterdayKey]) || yesterday.weekday == DateTime.sunday) {
        current = yesterday;
      } else {
        return 0;
      }
    }

    int streak = 0;
    while (true) {
      final key = formatDateIST(current);
      final hasWorkout = _hasWorkout(sessions[key]);

      if (current.weekday == DateTime.sunday) {
        // Sunday: If workout was logged, count it; if not, skip it without breaking streak!
        if (hasWorkout) {
          streak++;
        }
      } else {
        // Monday - Saturday
        if (hasWorkout) {
          streak++;
        } else {
          // Streak broken!
          break;
        }
      }

      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculates the best streak ever achieved
  static int calculateBestStreak(Map<String, WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;

    final sortedDates = sessions.keys.where((k) => _hasWorkout(sessions[k])).toList()..sort();
    if (sortedDates.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? prevDate;

    for (var dateStr in sortedDates) {
      DateTime date = DateTime.parse(dateStr);
      if (prevDate == null) {
        currentStreak = 1;
      } else {
        var temp = prevDate.add(const Duration(days: 1));
        bool continuous = true;
        while (temp.isBefore(date)) {
          if (temp.weekday != DateTime.sunday) {
            continuous = false;
            break;
          }
          temp = temp.add(const Duration(days: 1));
        }

        if (continuous) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
      prevDate = date;
    }

    return maxStreak;
  }

  static bool _hasWorkout(WorkoutSession? s) {
    if (s == null) return false;
    return s.exercises.any((e) => e.sets.isNotEmpty);
  }
}
