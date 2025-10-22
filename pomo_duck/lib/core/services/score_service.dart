import 'package:flutter/foundation.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';
import 'package:pomo_duck/data/models/user_score_model.dart';

/// Service quản lý tính điểm cho user
class ScoreService {
  static final ScoreService _instance = ScoreService._internal();
  factory ScoreService() => _instance;
  ScoreService._internal();

  /// Tính điểm cho pomodoro session
  /// [isStandardMode]: true nếu sử dụng chế độ chuẩn, false nếu custom
  /// [workDuration]: thời gian làm việc (giây)
  /// [shortBreakDuration]: thời gian nghỉ ngắn (giây)
  /// [longBreakDuration]: thời gian nghỉ dài (giây)
  /// [sessionsCompleted]: số phiên đã hoàn thành
  int calculateSessionPoints({
    required bool isStandardMode,
    required int workDuration,
    required int shortBreakDuration,
    required int longBreakDuration,
    required int sessionsCompleted,
  }) {
    if (isStandardMode) {
      // Chế độ chuẩn: +150 điểm
      return 150;
    } else {
      // Chế độ custom: tính theo công thức
      int points = 0;
      
      // Mỗi phiên: +10 điểm
      points += sessionsCompleted * 10;
      
      // Thời gian học: mỗi phút +1 điểm
      final workMinutes = workDuration ~/ 60;
      points += workMinutes;
      
      // Short break: càng tăng điểm càng giảm, max 20 điểm
      final shortBreakMinutes = shortBreakDuration ~/ 60;
      final shortBreakPoints = (20 - (shortBreakMinutes - 5).clamp(0, 15)).clamp(0, 20);
      points += shortBreakPoints;
      
      // Long break: càng tăng điểm càng giảm, max 50 điểm
      final longBreakMinutes = longBreakDuration ~/ 60;
      final longBreakPoints = (50 - (longBreakMinutes - 15).clamp(0, 35)).clamp(0, 50);
      points += longBreakPoints;
      
      return points;
    }
  }

  /// Tính điểm penalty khi dừng giữa chừng
  /// [pauseDuration]: thời gian pause (giây)
  int calculatePausePenalty(int pauseDuration) {
    const int gracePeriodMinutes = 5; // 5 phút đầu không bị penalty
    const int penaltyIntervalMinutes = 5; // Mỗi 5 phút sau đó
    const int penaltyPerInterval = 10; // 10 điểm mỗi 5 phút
    
    final pauseMinutes = pauseDuration ~/ 60;
    
    if (pauseMinutes <= gracePeriodMinutes) {
      return 0; // Không bị penalty trong 5 phút đầu
    }
    
    // Tính số lần penalty (mỗi 5 phút sau grace period)
    final effectivePauseMinutes = pauseMinutes - gracePeriodMinutes;
    final penaltyCycles = (effectivePauseMinutes / penaltyIntervalMinutes).ceil();
    
    return penaltyCycles * penaltyPerInterval;
  }

  /// Tính điểm penalty khi tự động dừng giữa chừng
  int calculateAutoStopPenalty() {
    return 20; // -20 điểm
  }

  /// Tính điểm bonus cho streak
  /// [streak]: chuỗi streak hiện tại
  int calculateStreakBonus(int streak) {
    if (streak >= 30) {
      return 1000; // Đặc biệt: +1000 điểm cho streak 30
    } else if (streak >= 5 && streak % 5 == 0) {
      return 200; // Mỗi 5 task liền nhau: +200 điểm
    }
    
    return 0;
  }

  /// Cập nhật điểm số sau khi hoàn thành task
  Future<UserScoreModel> updateScoreAfterTaskCompletion({
    required bool isStandardMode,
    required int workDuration,
    required int shortBreakDuration,
    required int longBreakDuration,
    required int sessionsCompleted,
    required int pausePenalty,
    required int autoStopPenalty,
  }) async {
    try {
      // Lấy điểm số hiện tại
      UserScoreModel currentScore = HiveDataManager.getUserScore();
      
      // Tính điểm cho session
      final sessionPoints = calculateSessionPoints(
        isStandardMode: isStandardMode,
        workDuration: workDuration,
        shortBreakDuration: shortBreakDuration,
        longBreakDuration: longBreakDuration,
        sessionsCompleted: sessionsCompleted,
      );
      
      // Cập nhật task hoàn thành
      currentScore = currentScore.completeTask();
      
      // Cộng điểm session
      currentScore = currentScore.addPoints(sessionPoints);
      
      // Trừ điểm penalty
      if (pausePenalty > 0) {
        currentScore = currentScore.subtractPoints(pausePenalty);
      }
      if (autoStopPenalty > 0) {
        currentScore = currentScore.subtractPoints(autoStopPenalty);
      }
      
      // Tính điểm bonus streak
      final streakBonus = calculateStreakBonus(currentScore.currentStreak);
      if (streakBonus > 0) {
        currentScore = currentScore.addPoints(streakBonus);
        currentScore = currentScore.copyWith(
          bonusPointsEarned: currentScore.bonusPointsEarned + streakBonus,
        );
      }
      
      // Lưu điểm số mới
      await HiveDataManager.saveUserScore(currentScore);
      
      if (kDebugMode) {
        print('Điểm số đã cập nhật:');
        print('- Session points: $sessionPoints');
        print('- Pause penalty: -$pausePenalty');
        print('- Auto stop penalty: -$autoStopPenalty');
        print('- Streak bonus: +$streakBonus');
        print('- Total points: ${currentScore.totalPoints}');
        print('- Current streak: ${currentScore.currentStreak}');
      }
      
      return currentScore;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi cập nhật điểm số: $e');
      }
      rethrow;
    }
  }

  /// Kiểm tra và reset streak nếu cần
  Future<UserScoreModel> checkAndResetStreakIfNeeded() async {
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

  /// Lấy điểm số hiện tại
  UserScoreModel getCurrentScore() {
    return HiveDataManager.getUserScore();
  }

  /// Reset toàn bộ điểm số (cho testing)
  Future<void> resetScore() async {
    final now = DateTime.now();
    final defaultScore = UserScoreModel(
      lastTaskCompletedDate: now.subtract(const Duration(days: 1)),
      createdAt: now,
      updatedAt: now,
    );
    await HiveDataManager.saveUserScore(defaultScore);
  }
}
