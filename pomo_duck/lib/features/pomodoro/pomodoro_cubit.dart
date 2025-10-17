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
          await HybridDataCoordinator.instance.completeSession();
          
          // Auto start break nếu vừa hoàn thành work session
          if (updated.sessionType == 'work') {
            final settings = HiveDataManager.getSettings();
            final effectiveInterval = settings.isStandardMode ? 4 : settings.longBreakInterval;
            final nextType = updated.getNextSessionType(effectiveInterval);
            
            // Auto start break session
            await HybridDataCoordinator.instance.startPomodoroSession(
              taskId: updated.taskId,
              sessionType: nextType,
            );
          } else {
            // Nếu là break session thì dừng timer
            _ticker?.cancel();
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

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
