import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';
import 'package:pomo_duck/core/services/streak_service.dart';

part 'score_state.dart';

class ScoreBloc extends Cubit<ScoreState> {
  ScoreBloc() : super(ScoreInitial()) {
    _init();
  }

  late final StreakService _streakService;

  void _init() {
    _streakService = StreakService();
    _loadScore();
  }

  /// Load điểm số hiện tại
  void _loadScore() {
    try {
      final score = HiveDataManager.getUserScore();
      final streakInfo = _streakService.getCurrentStreakInfo();
      
      emit(ScoreLoaded(
        totalPoints: score.totalPoints,
        currentStreak: streakInfo.currentStreak,
        longestStreak: streakInfo.longestStreak,
        tasksCompletedToday: streakInfo.tasksCompletedToday,
        hasReached30Streak: streakInfo.hasReached30Streak,
        hasReached5Streak: streakInfo.hasReached5Streak,
      ));
    } catch (e) {
      emit(ScoreError('Lỗi tải điểm số: $e'));
    }
  }

  /// Refresh điểm số (gọi khi có thay đổi)
  void refreshScore() {
    _loadScore();
  }

  /// Cập nhật điểm số sau khi hoàn thành task
  void updateScoreAfterTaskCompletion() {
    _loadScore();
  }

  /// Cập nhật điểm số sau khi bị penalty
  void updateScoreAfterPenalty() {
    _loadScore();
  }

  /// Cập nhật điểm số và emit state mới ngay lập tức
  void updateScore() {
    _loadScore();
  }

  /// Cộng điểm và emit state mới
  void addPoints(int points) {
    try {
      final currentScore = HiveDataManager.getUserScore();
      final newScore = currentScore.addPoints(points);
      HiveDataManager.saveUserScore(newScore);
      _loadScore(); // Emit state mới
    } catch (e) {
      emit(ScoreError('Lỗi cộng điểm: $e'));
    }
  }

  /// Trừ điểm và emit state mới
  void subtractPoints(int points) {
    try {
      final currentScore = HiveDataManager.getUserScore();
      final newScore = currentScore.subtractPoints(points);
      HiveDataManager.saveUserScore(newScore);
      _loadScore(); // Emit state mới
    } catch (e) {
      emit(ScoreError('Lỗi trừ điểm: $e'));
    }
  }
}
