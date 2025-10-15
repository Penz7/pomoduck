import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/base_state.dart';
import '../../core/data_coordinator/hybrid_data_coordinator.dart';
import '../../core/local_storage/hive_data_manager.dart';
import '../../data/models/current_timer_state.dart';
import 'timer_state.dart';

/// TimerCubit - Quản lý timer state và logic
/// Core timer functionality với integration với hybrid data system
class TimerCubit extends Cubit<TimerState> {
  Timer? _timer;
  Timer? _updateTimer;
  final HybridDataCoordinator _coordinator = HybridDataCoordinator.instance;
  
  TimerCubit() : super(TimerState()) {
    _initializeTimer();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _updateTimer?.cancel();
    return super.close();
  }

  // ==================== INITIALIZATION ====================

  /// Initialize timer với current state
  void _initializeTimer() {
    final currentState = HiveDataManager.getCurrentTimerState();
    final settings = HiveDataManager.getSettings();
    
    emit(state.copyWith(
      isRunning: currentState.isRunning,
      sessionType: currentState.sessionType,
      taskId: currentState.taskId,
      plannedDurationSeconds: currentState.plannedDurationSeconds,
      elapsedSeconds: currentState.elapsedSeconds,
      startTime: currentState.startTime,
      completedPomodoros: currentState.completedPomodoros,
      sessionId: currentState.sessionId,
      settings: settings,
    ));

    // Nếu timer đang chạy, resume timer
    if (currentState.isRunning && currentState.startTime != null) {
      _startTimer();
    }
  }

  // ==================== TIMER OPERATIONS ====================

  /// Start timer
  Future<void> startTimer({int? taskId}) async {
    try {
      emit(state.copyWith(status: BlocStatus.loading));
      
      // Get current settings
      final settings = HiveDataManager.getSettings();
      
      // Determine session type
      String sessionType;
      if (state.sessionType == 'work' || state.sessionType.isEmpty) {
        sessionType = 'work';
      } else {
        sessionType = state.nextSessionType;
      }
      
      // Get duration from settings
      final plannedDuration = settings.getDurationForSessionType(sessionType);
      
      // Start session in database
      final session = await _coordinator.startPomodoroSession(
        taskId: taskId,
        sessionType: sessionType,
      );
      
      // Update state
      emit(state.copyWith(
        status: BlocStatus.success,
        isRunning: true,
        sessionType: sessionType,
        taskId: taskId,
        plannedDurationSeconds: plannedDuration,
        elapsedSeconds: 0,
        startTime: DateTime.now(),
        sessionId: session.id,
        settings: settings,
      ));
      
      // Start timer
      _startTimer();
      
      debugPrint('🚀 Timer started: $sessionType for ${plannedDuration}s');
      
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.error,
        message: 'Error starting timer: $e',
      ));
      debugPrint('❌ Error starting timer: $e');
    }
  }

  /// Pause timer
  Future<void> pauseTimer() async {
    try {
      if (!state.isRunning) return;
      
      await _coordinator.pauseSession();
      
      emit(state.copyWith(
        isRunning: false,
        pauseTime: DateTime.now(),
      ));
      
      _stopTimer();
      
      debugPrint('⏸️ Timer paused');
      
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.error,
        message: 'Error pausing timer: $e',
      ));
      debugPrint('❌ Error pausing timer: $e');
    }
  }

  /// Resume timer
  Future<void> resumeTimer() async {
    try {
      if (state.isRunning) return;
      
      await _coordinator.resumeSession();
      
      emit(state.copyWith(
        isRunning: true,
        pauseTime: null,
      ));
      
      _startTimer();
      
      debugPrint('▶️ Timer resumed');
      
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.error,
        message: 'Error resuming timer: $e',
      ));
      debugPrint('❌ Error resuming timer: $e');
    }
  }

  /// Stop timer
  Future<void> stopTimer() async {
    try {
      await _coordinator.stopSession();
      
      emit(state.copyWith(
        isRunning: false,
        elapsedSeconds: 0,
        startTime: null,
        pauseTime: null,
        sessionId: null,
      ));
      
      _stopTimer();
      
      debugPrint('⏹️ Timer stopped');
      
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.error,
        message: 'Error stopping timer: $e',
      ));
      debugPrint('❌ Error stopping timer: $e');
    }
  }

  /// Reset timer
  Future<void> resetTimer() async {
    try {
      await stopTimer();
      
      emit(state.copyWith(
        sessionType: 'work',
        taskId: null,
        plannedDurationSeconds: state.settings?.workDuration ?? 1500,
        elapsedSeconds: 0,
        completedPomodoros: 0,
      ));
      
      debugPrint('🔄 Timer reset');
      
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.error,
        message: 'Error resetting timer: $e',
      ));
      debugPrint('❌ Error resetting timer: $e');
    }
  }

  // ==================== TIMER LOGIC ====================

  /// Start internal timer
  void _startTimer() {
    _stopTimer();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateElapsedTime();
    });
    
    // Update timer state every second
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimerState();
    });
  }

  /// Stop internal timer
  void _stopTimer() {
    _timer?.cancel();
    _updateTimer?.cancel();
    _timer = null;
    _updateTimer = null;
  }

  /// Update elapsed time
  void _updateElapsedTime() {
    if (!state.isRunning || state.startTime == null) return;
    
    final now = DateTime.now();
    final elapsed = now.difference(state.startTime!).inSeconds;
    
    // Account for pause time
    final pauseDuration = state.pauseTime != null 
        ? now.difference(state.pauseTime!).inSeconds 
        : 0;
    
    final actualElapsed = elapsed - pauseDuration;
    
    if (actualElapsed != state.elapsedSeconds) {
      emit(state.copyWith(elapsedSeconds: actualElapsed));
      
      // Update in Hive (ultra-fast)
      HiveDataManager.updateElapsedTime(actualElapsed);
    }
  }

  /// Update timer state in Hive
  void _updateTimerState() {
    if (!state.isRunning) return;
    
    final currentState = CurrentTimerState(
      isRunning: state.isRunning,
      sessionType: state.sessionType,
      taskId: state.taskId,
      plannedDurationSeconds: state.plannedDurationSeconds,
      elapsedSeconds: state.elapsedSeconds,
      startTime: state.startTime,
      completedPomodoros: state.completedPomodoros,
      pauseTime: state.pauseTime,
      sessionId: state.sessionId,
    );
    
    HiveDataManager.updateTimerState(currentState);
  }

  // ==================== SESSION COMPLETION ====================

  /// Complete current session
  Future<void> completeSession() async {
    try {
      if (state.sessionId == null) return;
      
      await _coordinator.completeSession();
      
      // Update completed pomodoros if it's a work session
      if (state.sessionType == 'work') {
        final newCompletedPomodoros = state.completedPomodoros + 1;
        emit(state.copyWith(
          completedPomodoros: newCompletedPomodoros,
        ));
        
        // Update cycle if needed
        await _updatePomodoroCycle();
      }
      
      // Auto-transition to next session
      await _autoTransitionToNextSession();
      
      debugPrint('✅ Session completed: ${state.sessionType}');
      
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.error,
        message: 'Error completing session: $e',
      ));
      debugPrint('❌ Error completing session: $e');
    }
  }

  /// Auto-transition to next session
  Future<void> _autoTransitionToNextSession() async {
    final settings = state.settings;
    if (settings == null) return;
    
    final nextSessionType = _getNextSessionType();
    final shouldAutoStart = settings.shouldAutoStart(nextSessionType);
    
    if (shouldAutoStart) {
      // Auto-start next session
      await Future.delayed(const Duration(seconds: 2)); // Brief pause
      await startTimer(taskId: state.taskId);
    } else {
      // Stop timer and wait for manual start
      await stopTimer();
      emit(state.copyWith(
        sessionType: nextSessionType,
        plannedDurationSeconds: settings.getDurationForSessionType(nextSessionType),
      ));
    }
  }

  /// Get next session type
  String _getNextSessionType() {
    if (state.sessionType == 'work') {
      // After work session, decide break type
      return state.shouldTakeLongBreak ? 'longBreak' : 'shortBreak';
    } else {
      // After break, go back to work
      return 'work';
    }
  }

  /// Update pomodoro cycle
  Future<void> _updatePomodoroCycle() async {
    try {
      // Get or create active cycle
      var activeCycle = await _coordinator.getActiveCycle();
      
      if (activeCycle == null) {
        // Create new cycle
        activeCycle = await _coordinator.startNewCycle();
      }
      
      // Add session to cycle
      if (state.sessionId != null) {
        await _coordinator.addSessionToCycle(activeCycle.id!, state.sessionId!);
      }
      
      // Increment pomodoros in cycle
      final updatedCycle = await _coordinator.incrementCyclePomodoros(activeCycle.id!);
      
      // Check if cycle is complete
      if (updatedCycle.isFullyCompleted) {
        await _coordinator.completeCycle(updatedCycle.id!);
        debugPrint('🎉 Pomodoro cycle completed!');
      }
      
    } catch (e) {
      debugPrint('❌ Error updating pomodoro cycle: $e');
    }
  }

  // ==================== GETTERS ====================

  /// Get remaining seconds
  int get remainingSeconds {
    return state.plannedDurationSeconds - state.elapsedSeconds;
  }

  /// Get progress percentage
  double get progressPercentage {
    if (state.plannedDurationSeconds == 0) return 0.0;
    return (state.elapsedSeconds / state.plannedDurationSeconds).clamp(0.0, 1.0);
  }

  /// Check if session is completed
  bool get isSessionCompleted {
    return state.elapsedSeconds >= state.plannedDurationSeconds;
  }

  /// Check if should take long break
  bool get shouldTakeLongBreak {
    return state.completedPomodoros > 0 && state.completedPomodoros % 4 == 0;
  }

  /// Get next session type
  String get nextSessionType {
    if (state.sessionType == 'work') {
      return shouldTakeLongBreak ? 'longBreak' : 'shortBreak';
    } else {
      return 'work';
    }
  }

  /// Get session type display name
  String get sessionTypeDisplayName {
    switch (state.sessionType) {
      case 'work':
        return 'Focus Time';
      case 'shortBreak':
        return 'Short Break';
      case 'longBreak':
        return 'Long Break';
      default:
        return 'Focus Time';
    }
  }

  /// Get session type color
  int get sessionTypeColor {
    switch (state.sessionType) {
      case 'work':
        return 0xFF4CAF50; // Green
      case 'shortBreak':
        return 0xFF2196F3; // Blue
      case 'longBreak':
        return 0xFF9C27B0; // Purple
      default:
        return 0xFF4CAF50; // Green
    }
  }
}
