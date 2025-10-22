import 'package:hive/hive.dart';

part 'user_score_model.g.dart';

/// Model cho điểm số của user
@HiveType(typeId: 10)
class UserScoreModel extends HiveObject {
  @HiveField(0)
  final int totalPoints; // Tổng điểm hiện có

  @HiveField(1)
  final int currentStreak; // Chuỗi streak hiện tại

  @HiveField(2)
  final int longestStreak; // Chuỗi streak dài nhất từ trước

  @HiveField(3)
  final DateTime lastTaskCompletedDate; // Ngày hoàn thành task cuối cùng

  @HiveField(4)
  final int tasksCompletedToday; // Số task hoàn thành hôm nay

  @HiveField(5)
  final int totalTasksCompleted; // Tổng số task đã hoàn thành

  @HiveField(6)
  final int bonusPointsEarned; // Tổng điểm bonus đã nhận

  @HiveField(7)
  final DateTime createdAt; // Ngày tạo

  @HiveField(8)
  final DateTime updatedAt; // Ngày cập nhật cuối

  UserScoreModel({
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastTaskCompletedDate,
    this.tasksCompletedToday = 0,
    this.totalTasksCompleted = 0,
    this.bonusPointsEarned = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo copy với các field được update
  UserScoreModel copyWith({
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastTaskCompletedDate,
    int? tasksCompletedToday,
    int? totalTasksCompleted,
    int? bonusPointsEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserScoreModel(
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastTaskCompletedDate: lastTaskCompletedDate ?? this.lastTaskCompletedDate,
      tasksCompletedToday: tasksCompletedToday ?? this.tasksCompletedToday,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      bonusPointsEarned: bonusPointsEarned ?? this.bonusPointsEarned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Cộng điểm vào tổng điểm
  UserScoreModel addPoints(int points) {
    return copyWith(
      totalPoints: totalPoints + points,
      updatedAt: DateTime.now(),
    );
  }

  /// Trừ điểm khỏi tổng điểm
  UserScoreModel subtractPoints(int points) {
    final newTotal = (totalPoints - points).clamp(0, double.infinity).toInt();
    return copyWith(
      totalPoints: newTotal,
      updatedAt: DateTime.now(),
    );
  }

  /// Cập nhật streak
  UserScoreModel updateStreak(int newStreak) {
    return copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      updatedAt: DateTime.now(),
    );
  }

  /// Reset streak về 0
  UserScoreModel resetStreak() {
    return copyWith(
      currentStreak: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// Hoàn thành task mới
  UserScoreModel completeTask() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      lastTaskCompletedDate.year,
      lastTaskCompletedDate.month,
      lastTaskCompletedDate.day,
    );

    int newStreak = currentStreak;
    int newTasksToday = tasksCompletedToday;

    // Nếu là task đầu tiên trong ngày
    if (lastCompleted.isBefore(today)) {
      newTasksToday = 1;
      // Nếu ngày hôm qua cũng có task hoàn thành thì tăng streak
      if (lastCompleted.isAtSameMomentAs(DateTime(
        today.subtract(const Duration(days: 1)).year,
        today.subtract(const Duration(days: 1)).month,
        today.subtract(const Duration(days: 1)).day,
      ))) {
        newStreak += 1;
      } else {
        newStreak = 1; // Reset streak nếu bị ngắt quãng
      }
    } else {
      // Cùng ngày, chỉ tăng số task
      newTasksToday += 1;
    }

    return copyWith(
      lastTaskCompletedDate: now,
      tasksCompletedToday: newTasksToday,
      totalTasksCompleted: totalTasksCompleted + 1,
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      updatedAt: now,
    );
  }

  /// Kiểm tra xem có bị mất streak không (không có task trong ngày)
  bool get isStreakBroken {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      lastTaskCompletedDate.year,
      lastTaskCompletedDate.month,
      lastTaskCompletedDate.day,
    );
    
    // Nếu ngày cuối cùng hoàn thành task không phải hôm nay và không phải hôm qua
    // thì streak bị mất
    final yesterday = today.subtract(const Duration(days: 1));
    return !lastCompleted.isAtSameMomentAs(today) && 
           !lastCompleted.isAtSameMomentAs(yesterday);
  }

  /// Kiểm tra xem có đạt streak 30 không
  bool get hasReached30Streak {
    return currentStreak >= 30;
  }

  /// Kiểm tra xem có đạt streak 5 không (để nhận bonus)
  bool get hasReached5Streak {
    return currentStreak >= 5 && currentStreak % 5 == 0;
  }

  @override
  String toString() {
    return 'UserScoreModel(totalPoints: $totalPoints, currentStreak: $currentStreak, longestStreak: $longestStreak, lastTaskCompletedDate: $lastTaskCompletedDate, tasksCompletedToday: $tasksCompletedToday, totalTasksCompleted: $totalTasksCompleted, bonusPointsEarned: $bonusPointsEarned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserScoreModel &&
        other.totalPoints == totalPoints &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.lastTaskCompletedDate == lastTaskCompletedDate &&
        other.tasksCompletedToday == tasksCompletedToday &&
        other.totalTasksCompleted == totalTasksCompleted &&
        other.bonusPointsEarned == bonusPointsEarned;
  }

  @override
  int get hashCode {
    return totalPoints.hashCode ^
        currentStreak.hashCode ^
        longestStreak.hashCode ^
        lastTaskCompletedDate.hashCode ^
        tasksCompletedToday.hashCode ^
        totalTasksCompleted.hashCode ^
        bonusPointsEarned.hashCode;
  }
}
