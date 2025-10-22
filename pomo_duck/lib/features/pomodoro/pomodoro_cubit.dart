import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';
import 'package:pomo_duck/core/data_coordinator/hybrid_data_coordinator.dart';
import 'package:pomo_duck/data/models/pomodoro_cycle_model.dart';
import 'package:pomo_duck/core/services/score_service.dart';

part 'pomodoro_state.dart';

class PomodoroCubit extends Cubit<PomodoroState> {
  PomodoroCubit()
      : super(
          PomodoroState(
            plannedSeconds: HiveDataManager.getCurrentTimerState().plannedDurationSeconds,
            elapsedSeconds: HiveDataManager.getCurrentTimerState().elapsedSeconds,
            sessionType: HiveDataManager.getCurrentTimerState().sessionType,
            isRunning: HiveDataManager.getCurrentTimerState().isRunning,
            activeCycle: null,
          ),
        ) {
    _startTicking();
  }

  Timer? _ticker;
  Timer? _pauseTimer;
  DateTime? _pauseStartTime;

  void _startTicking() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final current = HiveDataManager.getCurrentTimerState();
      if (current.isRunning) {
        final nextElapsed = current.elapsedSeconds + 1;
        await HiveDataManager.updateElapsedTime(nextElapsed);
        final updated = HiveDataManager.getCurrentTimerState();
        final activeCycle = await HybridDataCoordinator.instance.getActiveCycle();
        
        emit(state.copyWith(
          elapsedSeconds: updated.elapsedSeconds,
          plannedSeconds: updated.plannedDurationSeconds,
          sessionType: updated.sessionType,
          isRunning: updated.isRunning,
          activeCycle: activeCycle,
        ));

        if (updated.elapsedSeconds >= updated.plannedDurationSeconds) {
          final taskCompleted = await HybridDataCoordinator.instance.completeSession();
          
          if (taskCompleted) {
            _ticker?.cancel();
            _showTaskCompletionDialog();
          } else {
          if (updated.sessionType == 'work') {
            final settings = HiveDataManager.getSettings();
            final nextType = updated.getNextSessionType(settings.effectiveLongBreakInterval);
              
              await HybridDataCoordinator.instance.startPomodoroSession(
                taskId: updated.taskId,
                sessionType: nextType,
              );
            } else {
              await HybridDataCoordinator.instance.startPomodoroSession(
                taskId: updated.taskId,
                sessionType: 'work',
              );
            }
          }
        }
      }
    });
  }

  Future<void> pause() async {
    await HiveDataManager.pauseTimer();
    final current = HiveDataManager.getCurrentTimerState();
    final activeCycle = await HybridDataCoordinator.instance.getActiveCycle();
    _ticker?.cancel();
    
    // Bắt đầu theo dõi thời gian pause để tính penalty
    _startPauseTracking();
    
    emit(state.copyWith(
      isRunning: current.isRunning,
      activeCycle: activeCycle,
    ));
  }

  Future<void> resume() async {
    // Dừng theo dõi pause và tính penalty nếu cần
    await _stopPauseTracking();
    
    await HiveDataManager.resumeTimer();
    final current = HiveDataManager.getCurrentTimerState();
    final activeCycle = await HybridDataCoordinator.instance.getActiveCycle();
    _startTicking();
    
    emit(state.copyWith(
      isRunning: current.isRunning,
      activeCycle: activeCycle,
    ));
  }

  Future<void> stop() async {
    await HiveDataManager.pauseTimer();
    await HybridDataCoordinator.instance.stopSession();
    
    // Áp dụng penalty cho việc dừng giữa chừng
    await _applyStopPenalty();

    // Reset streak về 0 khi dừng giữa chừng
    try {
      final currentScore = HiveDataManager.getUserScore();
      final now = DateTime.now();
      final resetScore = currentScore.copyWith(
        currentStreak: 0,
        lastTaskCompletedDate: now.subtract(const Duration(days: 2)), // Đặt về 2 ngày trước để đảm bảo streak bị mất
        updatedAt: now,
      );
      await HiveDataManager.saveUserScore(resetScore);
      
      if (kDebugMode) {
        print('Streak đã bị reset do dừng giữa chừng:');
        print('- Current streak: 0');
        print('- Last completed date: ${resetScore.lastTaskCompletedDate}');
        print('- Is streak broken: ${resetScore.isStreakBroken}');
      }
    } catch (_) {}
    
    try {
      final active = await HybridDataCoordinator.instance.getActiveCycle();
      if (active != null && active.id != null) {
        await HybridDataCoordinator.instance.completeCycle(active.id!);
      }
    } catch (_) {}

    await HiveDataManager.resetTimerState();

    emit(state.copyWith(
      activeCycle: null,
      isRunning: false,
      elapsedSeconds: 0,
    ));
    
    _ticker?.cancel();
  }

  void _showTaskCompletionDialog() {
    emit(const PomodoroTaskCompleted());
  }

  /// Bắt đầu theo dõi thời gian pause
  void _startPauseTracking() {
    _pauseStartTime = DateTime.now();
    
    if (kDebugMode) {
      print('Bắt đầu theo dõi pause tại: ${_pauseStartTime}');
    }
    
    // Không cần timer.periodic nữa, chỉ tính penalty khi resume
  }

  /// Dừng theo dõi pause và tính penalty cuối cùng
  Future<void> _stopPauseTracking() async {
    _pauseTimer?.cancel();
    _pauseTimer = null;
    
    if (_pauseStartTime != null) {
      final pauseDuration = DateTime.now().difference(_pauseStartTime!).inSeconds;
      final penalty = ScoreService().calculatePausePenalty(pauseDuration);
      
      if (kDebugMode) {
        print('Kết thúc pause:');
        print('- Thời gian pause: ${pauseDuration ~/ 60} phút ${pauseDuration % 60} giây');
        print('- Penalty: $penalty điểm');
      }
      
      if (penalty > 0) {
        await _applyPausePenalty(penalty);
      }
      
      _pauseStartTime = null;
    }
  }

  /// Áp dụng penalty cho pause
  Future<void> _applyPausePenalty(int penalty) async {
    try {
      final currentScore = HiveDataManager.getUserScore();
      final updatedScore = currentScore.subtractPoints(penalty);
      await HiveDataManager.saveUserScore(updatedScore);
      
      // Cập nhật ScoreBloc để emit state mới
      // Note: Cần context để access ScoreBloc, sẽ xử lý trong pomodoro_screen.dart
      
      print('Pause penalty: -$penalty điểm');
    } catch (e) {
      print('Lỗi áp dụng pause penalty: $e');
    }
  }

  /// Áp dụng penalty cho việc dừng giữa chừng
  Future<void> _applyStopPenalty() async {
    try {
      final scoreService = ScoreService();
      final penalty = scoreService.calculateAutoStopPenalty();
      
      final currentScore = HiveDataManager.getUserScore();
      final updatedScore = currentScore.subtractPoints(penalty);
      await HiveDataManager.saveUserScore(updatedScore);
      
      // Cập nhật ScoreBloc để emit state mới
      // Note: Cần context để access ScoreBloc, sẽ xử lý trong pomodoro_screen.dart
      
      print('Stop penalty: -$penalty điểm');
    } catch (e) {
      print('Lỗi áp dụng stop penalty: $e');
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _pauseTimer?.cancel();
    return super.close();
  }
}
