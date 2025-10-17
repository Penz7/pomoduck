import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';
import 'package:pomo_duck/core/data_coordinator/hybrid_data_coordinator.dart';
import 'package:pomo_duck/data/models/pomodoro_cycle_model.dart';

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
            // Task completed - show completion dialog and stop timer
            _ticker?.cancel();
            _showTaskCompletionDialog();
          } else {
          // Auto start session tiếp theo
          if (updated.sessionType == 'work') {
            // Vừa hoàn thành work session → auto start break
            final settings = HiveDataManager.getSettings();
            final nextType = updated.getNextSessionType(settings.effectiveLongBreakInterval);
              
              await HybridDataCoordinator.instance.startPomodoroSession(
                taskId: updated.taskId,
                sessionType: nextType,
              );
            } else {
              // Vừa hoàn thành break session → auto start work tiếp theo
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
    emit(state.copyWith(
      isRunning: current.isRunning,
      activeCycle: activeCycle,
    ));
  }

  Future<void> resume() async {
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
    // This will be handled by PomodoroScreen to show completion dialog
    // For now, we'll emit a state change that PomodoroScreen can listen to
    emit(PomodoroTaskCompleted());
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
