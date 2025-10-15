import '../../core/base_state.dart';
import '../../data/models/pomodoro_settings.dart';

/// TimerState - State cho TimerCubit
class TimerState extends BaseState {
  final bool isRunning;
  final String sessionType; // 'work', 'shortBreak', 'longBreak'
  final int? taskId;
  final int plannedDurationSeconds;
  final int elapsedSeconds;
  final DateTime? startTime;
  final DateTime? pauseTime;
  final int completedPomodoros;
  final int? sessionId;
  final PomodoroSettings? settings;

  TimerState({
    super.status,
    super.message,
    this.isRunning = false,
    this.sessionType = 'work',
    this.taskId,
    this.plannedDurationSeconds = 1500, // 25 phút
    this.elapsedSeconds = 0,
    this.startTime,
    this.pauseTime,
    this.completedPomodoros = 0,
    this.sessionId,
    this.settings,
  });

  /// Tạo copy với các field được update
  @override
  TimerState copyWith({
    BlocStatus? status,
    String? message,
    bool? isRunning,
    String? sessionType,
    int? taskId,
    int? plannedDurationSeconds,
    int? elapsedSeconds,
    DateTime? startTime,
    DateTime? pauseTime,
    int? completedPomodoros,
    int? sessionId,
    PomodoroSettings? settings,
  }) {
    return TimerState(
      status: status ?? this.status,
      message: message ?? this.message,
      isRunning: isRunning ?? this.isRunning,
      sessionType: sessionType ?? this.sessionType,
      taskId: taskId ?? this.taskId,
      plannedDurationSeconds: plannedDurationSeconds ?? this.plannedDurationSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startTime: startTime ?? this.startTime,
      pauseTime: pauseTime ?? this.pauseTime,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      sessionId: sessionId ?? this.sessionId,
      settings: settings ?? this.settings,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Get remaining seconds
  int get remainingSeconds {
    return plannedDurationSeconds - elapsedSeconds;
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (plannedDurationSeconds == 0) return 0.0;
    return (elapsedSeconds / plannedDurationSeconds).clamp(0.0, 1.0);
  }

  /// Check if session is completed
  bool get isSessionCompleted {
    return elapsedSeconds >= plannedDurationSeconds;
  }

  /// Check if timer is paused
  bool get isPaused {
    return !isRunning && startTime != null && pauseTime != null;
  }

  /// Check if timer is active
  bool get isActive {
    return isRunning && startTime != null;
  }

  /// Check if should take long break
  bool get shouldTakeLongBreak {
    return completedPomodoros > 0 && completedPomodoros % 4 == 0;
  }

  /// Get next session type
  String get nextSessionType {
    if (sessionType == 'work') {
      return shouldTakeLongBreak ? 'longBreak' : 'shortBreak';
    } else {
      return 'work';
    }
  }

  /// Get session type display name
  String get sessionTypeDisplayName {
    switch (sessionType) {
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

  /// Get session type description
  String get sessionTypeDescription {
    switch (sessionType) {
      case 'work':
        return 'Time to focus and work on your tasks';
      case 'shortBreak':
        return 'Take a short break to rest and recharge';
      case 'longBreak':
        return 'Take a longer break to fully recharge';
      default:
        return 'Time to focus and work on your tasks';
    }
  }

  /// Get session type color
  int get sessionTypeColor {
    switch (sessionType) {
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

  /// Get formatted time remaining (mm:ss)
  String get formattedTimeRemaining {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted elapsed time (mm:ss)
  String get formattedElapsedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted planned duration (mm:ss)
  String get formattedPlannedDuration {
    final minutes = plannedDurationSeconds ~/ 60;
    final seconds = plannedDurationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get session progress text
  String get sessionProgressText {
    if (isSessionCompleted) {
      return 'Session completed!';
    } else if (isRunning) {
      return 'Focusing...';
    } else if (isPaused) {
      return 'Paused';
    } else {
      return 'Ready to start';
    }
  }

  /// Get pomodoro progress text
  String get pomodoroProgressText {
    if (completedPomodoros == 0) {
      return 'Start your first pomodoro';
    } else if (completedPomodoros < 4) {
      return '$completedPomodoros of 4 pomodoros completed';
    } else {
      return 'Cycle completed! Take a long break';
    }
  }

  /// Get cycle progress percentage
  double get cycleProgressPercentage {
    return (completedPomodoros / 4).clamp(0.0, 1.0);
  }

  /// Get cycle status
  String get cycleStatus {
    if (completedPomodoros == 0) {
      return 'New cycle';
    } else if (completedPomodoros < 4) {
      return 'In progress';
    } else {
      return 'Cycle complete';
    }
  }

  // ==================== VALIDATION ====================

  /// Check if timer can start
  bool get canStart {
    return !isRunning && !isSessionCompleted;
  }

  /// Check if timer can pause
  bool get canPause {
    return isRunning && !isSessionCompleted;
  }

  /// Check if timer can resume
  bool get canResume {
    return !isRunning && startTime != null && pauseTime != null;
  }

  /// Check if timer can stop
  bool get canStop {
    return isRunning || isPaused;
  }

  /// Check if timer can reset
  bool get canReset {
    return !isRunning;
  }

  /// Check if session can be completed
  bool get canCompleteSession {
    return isSessionCompleted && sessionId != null;
  }

  // ==================== UTILITY ====================

  /// Get session duration in minutes
  double get sessionDurationMinutes {
    return plannedDurationSeconds / 60.0;
  }

  /// Get elapsed time in minutes
  double get elapsedTimeMinutes {
    return elapsedSeconds / 60.0;
  }

  /// Get remaining time in minutes
  double get remainingTimeMinutes {
    return remainingSeconds / 60.0;
  }

  /// Get session efficiency (elapsed / planned)
  double get sessionEfficiency {
    if (plannedDurationSeconds == 0) return 0.0;
    return (elapsedSeconds / plannedDurationSeconds).clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'TimerState(isRunning: $isRunning, sessionType: $sessionType, taskId: $taskId, plannedDurationSeconds: $plannedDurationSeconds, elapsedSeconds: $elapsedSeconds, startTime: $startTime, pauseTime: $pauseTime, completedPomodoros: $completedPomodoros, sessionId: $sessionId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerState &&
        other.isRunning == isRunning &&
        other.sessionType == sessionType &&
        other.taskId == taskId &&
        other.plannedDurationSeconds == plannedDurationSeconds &&
        other.elapsedSeconds == elapsedSeconds &&
        other.startTime == startTime &&
        other.pauseTime == pauseTime &&
        other.completedPomodoros == completedPomodoros &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    return isRunning.hashCode ^
        sessionType.hashCode ^
        taskId.hashCode ^
        plannedDurationSeconds.hashCode ^
        elapsedSeconds.hashCode ^
        startTime.hashCode ^
        pauseTime.hashCode ^
        completedPomodoros.hashCode ^
        sessionId.hashCode;
  }
}
