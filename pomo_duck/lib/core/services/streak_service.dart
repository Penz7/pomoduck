import 'package:flutter/foundation.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';
import 'package:pomo_duck/data/models/user_score_model.dart';

/// Service quản lý streak cho user
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  /// Kiểm tra và cập nhật streak khi hoàn thành task
  Future<UserScoreModel> updateStreakOnTaskCompletion() async {
    try {
      UserScoreModel currentScore = HiveDataManager.getUserScore();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastCompleted = DateTime(
        currentScore.lastTaskCompletedDate.year,
        currentScore.lastTaskCompletedDate.month,
        currentScore.lastTaskCompletedDate.day,
      );

      int newStreak = currentScore.currentStreak;
      int newTasksToday = currentScore.tasksCompletedToday;

      // Nếu là task đầu tiên trong ngày
      if (lastCompleted.isBefore(today)) {
        newTasksToday = 1;
        
        // Kiểm tra xem đây có phải là task đầu tiên hoàn toàn không
        if (currentScore.totalTasksCompleted == 0) {
          // Task đầu tiên hoàn toàn, bắt đầu streak từ 1
          newStreak = 1;
        } else {
          // Kiểm tra xem ngày hôm qua có task không
          final yesterday = today.subtract(const Duration(days: 1));
          if (lastCompleted.isAtSameMomentAs(yesterday)) {
            // Ngày hôm qua có task, tăng streak
            newStreak += 1;
          } else {
            // Ngày hôm qua không có task hoặc streak đã bị mất, bắt đầu streak từ 1
            newStreak = 1;
          }
        }
      } else {
        // Cùng ngày, chỉ tăng số task
        newTasksToday += 1;
      }

      // Cập nhật score
      currentScore = currentScore.copyWith(
        lastTaskCompletedDate: now,
        tasksCompletedToday: newTasksToday,
        totalTasksCompleted: currentScore.totalTasksCompleted + 1,
        currentStreak: newStreak,
        longestStreak: newStreak > currentScore.longestStreak ? newStreak : currentScore.longestStreak,
        updatedAt: now,
      );

      await HiveDataManager.saveUserScore(currentScore);

      if (kDebugMode) {
        print('Streak đã cập nhật:');
        print('- Current streak: ${currentScore.currentStreak}');
        print('- Longest streak: ${currentScore.longestStreak}');
        print('- Tasks today: ${currentScore.tasksCompletedToday}');
        print('- Total tasks completed: ${currentScore.totalTasksCompleted}');
        print('- Last completed: $lastCompleted');
        print('- Today: $today');
        print('- Is first task: ${currentScore.totalTasksCompleted == 0}');
        print('- Is streak broken: ${currentScore.isStreakBroken}');
        print('- New streak will be: $newStreak');
      }

      return currentScore;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi cập nhật streak: $e');
      }
      rethrow;
    }
  }

  /// Kiểm tra và reset streak nếu bị ngắt quãng
  Future<UserScoreModel> checkAndResetStreakIfBroken() async {
    try {
      UserScoreModel currentScore = HiveDataManager.getUserScore();
      
      if (currentScore.isStreakBroken) {
        currentScore = currentScore.resetStreak();
        await HiveDataManager.saveUserScore(currentScore);
        
        if (kDebugMode) {
          print('Streak đã bị reset do không hoàn thành task trong ngày');
        }
      }
      
      return currentScore;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi kiểm tra streak: $e');
      }
      rethrow;
    }
  }

  /// Kiểm tra xem có đạt milestone streak không
  StreakMilestone checkStreakMilestone(int currentStreak) {
    if (currentStreak >= 30) {
      return StreakMilestone.special30; // Đặc biệt: 30 streak
    } else if (currentStreak >= 5 && currentStreak % 5 == 0) {
      return StreakMilestone.bonus5; // Mỗi 5 task: bonus
    } else {
      return StreakMilestone.none;
    }
  }

  /// Lấy thông tin streak hiện tại
  StreakInfo getCurrentStreakInfo() {
    final score = HiveDataManager.getUserScore();
    return StreakInfo(
      currentStreak: score.currentStreak,
      longestStreak: score.longestStreak,
      tasksCompletedToday: score.tasksCompletedToday,
      lastTaskDate: score.lastTaskCompletedDate,
      isStreakBroken: score.isStreakBroken,
    );
  }

  /// Reset toàn bộ streak (cho testing)
  Future<void> resetStreak() async {
    final now = DateTime.now();
    final defaultScore = UserScoreModel(
      lastTaskCompletedDate: now.subtract(const Duration(days: 1)),
      createdAt: now,
      updatedAt: now,
    );
    await HiveDataManager.saveUserScore(defaultScore);
  }
}

/// Enum cho các milestone streak
enum StreakMilestone {
  none,
  bonus5,      // Mỗi 5 task liền nhau
  special30,   // Đặc biệt: 30 streak
}

/// Class chứa thông tin streak
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final int tasksCompletedToday;
  final DateTime lastTaskDate;
  final bool isStreakBroken;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.tasksCompletedToday,
    required this.lastTaskDate,
    required this.isStreakBroken,
  });

  /// Kiểm tra xem có đạt streak 30 không
  bool get hasReached30Streak {
    return currentStreak >= 30;
  }

  /// Kiểm tra xem có đạt streak 5 không (để nhận bonus)
  bool get hasReached5Streak {
    return currentStreak >= 5 && currentStreak % 5 == 0;
  }

  /// Lấy số ngày streak hiện tại
  int get streakDays {
    return currentStreak;
  }

  /// Lấy thông tin streak dạng text
  String get streakText {
    if (currentStreak == 0) {
      return 'Chưa có streak';
    } else if (currentStreak == 1) {
      return '1 ngày liên tiếp';
    } else {
      return '$currentStreak ngày liên tiếp';
    }
  }

  /// Lấy thông tin streak dài nhất dạng text
  String get longestStreakText {
    if (longestStreak == 0) {
      return 'Chưa có streak dài nhất';
    } else if (longestStreak == 1) {
      return '1 ngày';
    } else {
      return '$longestStreak ngày';
    }
  }

  @override
  String toString() {
    return 'StreakInfo(currentStreak: $currentStreak, longestStreak: $longestStreak, tasksCompletedToday: $tasksCompletedToday, isStreakBroken: $isStreakBroken)';
  }
}
