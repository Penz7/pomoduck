import 'package:hive/hive.dart';

part 'current_timer_state.g.dart';

/// Model cho current timer state - lưu trong Hive
/// Quản lý trạng thái timer hiện tại với performance tối ưu
@HiveType(typeId: 2)
class CurrentTimerState extends HiveObject {
  @HiveField(0)
  final bool isRunning; // Timer có đang chạy không

  @HiveField(1)
  final String sessionType; // 'work', 'shortBreak', 'longBreak'

  @HiveField(2)
  final int? taskId; // ID của task đang làm (null cho break sessions)

  @HiveField(3)
  final int plannedDurationSeconds; // Thời gian dự định (giây)

  @HiveField(4)
  final int elapsedSeconds; // Thời gian đã trôi qua (giây)

  @HiveField(5)
  final DateTime? startTime; // Thời gian bắt đầu session

  @HiveField(6)
  final int completedPomodoros; // Số pomodoro đã hoàn thành trong cycle hiện tại

  @HiveField(7)
  final DateTime? pauseTime; // Thời gian pause (nếu có)

  @HiveField(8)
  final int? sessionId; // ID của session hiện tại trong SQLite

  CurrentTimerState({
    this.isRunning = false,
    this.sessionType = 'work',
    this.taskId,
    this.plannedDurationSeconds = 1500, // 25 phút mặc định
    this.elapsedSeconds = 0,
    this.startTime,
    this.completedPomodoros = 0,
    this.pauseTime,
    this.sessionId,
  });

  /// Tạo copy với các field được update
  CurrentTimerState copyWith({
    bool? isRunning,
    String? sessionType,
    int? taskId,
    int? plannedDurationSeconds,
    int? elapsedSeconds,
    DateTime? startTime,
    int? completedPomodoros,
    DateTime? pauseTime,
    int? sessionId,
  }) {
    return CurrentTimerState(
      isRunning: isRunning ?? this.isRunning,
      sessionType: sessionType ?? this.sessionType,
      taskId: taskId ?? this.taskId,
      plannedDurationSeconds: plannedDurationSeconds ?? this.plannedDurationSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startTime: startTime ?? this.startTime,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      pauseTime: pauseTime ?? this.pauseTime,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  /// Getter để tính thời gian còn lại
  int get remainingSeconds {
    return plannedDurationSeconds - elapsedSeconds;
  }

  /// Getter để check xem session có hoàn thành không
  bool get isCompleted {
    return elapsedSeconds >= plannedDurationSeconds;
  }

  /// Getter để check xem có đang pause không
  bool get isPaused {
    return !isRunning && startTime != null && pauseTime != null;
  }

  /// Getter để check xem có đang active không
  bool get isActive {
    return isRunning && startTime != null;
  }

  /// Getter để tính thời gian đã pause
  Duration get pauseDuration {
    if (pauseTime == null) return Duration.zero;
    return DateTime.now().difference(pauseTime!);
  }

  /// Getter để tính thời gian thực tế đã chạy (không tính pause)
  Duration get actualDuration {
    if (startTime == null) return Duration.zero;
    final endTime = pauseTime ?? DateTime.now();
    return endTime.difference(startTime!);
  }

  /// Getter để tính progress percentage
  double get progressPercentage {
    if (plannedDurationSeconds == 0) return 0.0;
    return (elapsedSeconds / plannedDurationSeconds).clamp(0.0, 1.0);
  }

  /// Getter để check xem có nên chuyển sang long break không
  bool get shouldTakeLongBreak {
    return completedPomodoros > 0 && completedPomodoros % 4 == 0;
  }

  /// Getter để lấy session type tiếp theo
  String get nextSessionType {
    if (sessionType == 'work') {
      return shouldTakeLongBreak ? 'longBreak' : 'shortBreak';
    } else {
      return 'work';
    }
  }

  /// Reset timer về trạng thái ban đầu
  CurrentTimerState reset() {
    return CurrentTimerState();
  }

  /// Start timer với session type và task ID
  CurrentTimerState start({
    required String sessionType,
    int? taskId,
    required int plannedDurationSeconds,
    int? sessionId,
  }) {
    return copyWith(
      isRunning: true,
      sessionType: sessionType,
      taskId: taskId,
      plannedDurationSeconds: plannedDurationSeconds,
      elapsedSeconds: 0,
      startTime: DateTime.now(),
      pauseTime: null,
      sessionId: sessionId,
    );
  }

  /// Pause timer
  CurrentTimerState pause() {
    return copyWith(
      isRunning: false,
      pauseTime: DateTime.now(),
    );
  }

  /// Resume timer
  CurrentTimerState resume() {
    return copyWith(
      isRunning: true,
      pauseTime: null,
    );
  }

  /// Stop timer
  CurrentTimerState stop() {
    return copyWith(
      isRunning: false,
      pauseTime: null,
    );
  }

  /// Update elapsed time (được gọi mỗi giây)
  CurrentTimerState updateElapsed(int elapsedSeconds) {
    return copyWith(
      elapsedSeconds: elapsedSeconds,
    );
  }

  /// Complete session
  CurrentTimerState complete() {
    return copyWith(
      isRunning: false,
      elapsedSeconds: plannedDurationSeconds,
      pauseTime: null,
    );
  }

  @override
  String toString() {
    return 'CurrentTimerState(isRunning: $isRunning, sessionType: $sessionType, taskId: $taskId, plannedDurationSeconds: $plannedDurationSeconds, elapsedSeconds: $elapsedSeconds, startTime: $startTime, completedPomodoros: $completedPomodoros, pauseTime: $pauseTime, sessionId: $sessionId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrentTimerState &&
        other.isRunning == isRunning &&
        other.sessionType == sessionType &&
        other.taskId == taskId &&
        other.plannedDurationSeconds == plannedDurationSeconds &&
        other.elapsedSeconds == elapsedSeconds &&
        other.startTime == startTime &&
        other.completedPomodoros == completedPomodoros &&
        other.pauseTime == pauseTime &&
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
        completedPomodoros.hashCode ^
        pauseTime.hashCode ^
        sessionId.hashCode;
  }
}
