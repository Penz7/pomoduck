import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';
import 'package:pomo_duck/core/data_coordinator/hybrid_data_coordinator.dart';

part 'pomodoro_state.dart';

class PomodoroCubit extends Cubit<PomodoroState> {
  PomodoroCubit()
      : super(
          PomodoroState(
            plannedSeconds: HiveDataManager.getCurrentTimerState().plannedDurationSeconds,
            elapsedSeconds: HiveDataManager.getCurrentTimerState().elapsedSeconds,
            sessionType: HiveDataManager.getCurrentTimerState().sessionType,
            isRunning: HiveDataManager.getCurrentTimerState().isRunning,
          ),
        ) {
    _startTicking();
  }

  Timer? _ticker;

  void _startTicking() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final current = HiveDataManager.getCurrentTimerState();
      if (current.isRunning) {
        final nextElapsed = current.elapsedSeconds + 1;
        await HiveDataManager.updateElapsedTime(nextElapsed);
        final updated = HiveDataManager.getCurrentTimerState();
        emit(state.copyWith(
          elapsedSeconds: updated.elapsedSeconds,
          plannedSeconds: updated.plannedDurationSeconds,
          sessionType: updated.sessionType,
          isRunning: updated.isRunning,
        ));

        // Khi hoàn thành
        if (updated.elapsedSeconds >= updated.plannedDurationSeconds) {
          await HybridDataCoordinator.instance.completeSession();
          // Auto-next theo settings
          final settings = HiveDataManager.getSettings();
          // Xác định session tiếp theo dựa trên nextSessionType trong Hive state
          final nextType = updated.nextSessionType; // 'shortBreak'/'longBreak' hoặc 'work'
          final shouldAuto = settings.shouldAutoStart(nextType);
          if (shouldAuto) {
            // Start next session automatically, keep same taskId
            await HybridDataCoordinator.instance.startPomodoroSession(
              taskId: updated.taskId,
              sessionType: nextType,
            );
            // continue ticking (state will be refreshed next loop)
          } else {
            _ticker?.cancel();
          }
        }
      } else {
        // Đồng bộ state khi pause/stop
        emit(state.copyWith(
          elapsedSeconds: current.elapsedSeconds,
          plannedSeconds: current.plannedDurationSeconds,
          sessionType: current.sessionType,
          isRunning: current.isRunning,
        ));
      }
    });
  }

  Future<void> pause() async {
    await HiveDataManager.pauseTimer();
    final current = HiveDataManager.getCurrentTimerState();
    emit(state.copyWith(isRunning: current.isRunning));
  }

  Future<void> resume() async {
    await HiveDataManager.resumeTimer();
    final current = HiveDataManager.getCurrentTimerState();
    emit(state.copyWith(isRunning: current.isRunning));
  }

  Future<void> stop() async {
    await HybridDataCoordinator.instance.stopSession();
    // Reset cycle (complete and clear Hive state)
    try {
      final active = await HybridDataCoordinator.instance.getActiveCycle();
      if (active != null && active.id != null) {
        await HybridDataCoordinator.instance.completeCycle(active.id!);
      }
    } catch (_) {}
    _ticker?.cancel();
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
