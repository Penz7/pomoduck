import 'package:hive/hive.dart';

part 'pomodoro_settings.g.dart';

/// Model cho Pomodoro settings - lưu trong Hive
@HiveType(typeId: 0)
class PomodoroSettings extends HiveObject {
  @HiveField(0)
  final int workDuration; // 25 phút = 1500 giây

  @HiveField(1)
  final int shortBreakDuration; // 5 phút = 300 giây

  @HiveField(2)
  final int longBreakDuration; // 15 phút = 900 giây

  @HiveField(3)
  final int longBreakInterval; // Sau bao nhiêu pomodoro thì long break

  @HiveField(4)
  final int pomodoroCycleCount; // Tổng số pomodoro sessions cần hoàn thành (1-10)

  @HiveField(5)
  final bool isStandardMode; // true = Standard Pomodoro, false = Custom Mode

  @HiveField(6)
  final bool soundEnabled; // Bật/tắt âm thanh

  @HiveField(7)
  final String notificationSound; // Loại âm thanh thông báo

  @HiveField(8)
  final bool vibrationEnabled; // Bật/tắt rung

  @HiveField(9)
  final String theme; // Light/Dark/System theme

  PomodoroSettings({
    this.workDuration = 1500, // 25 phút
    this.shortBreakDuration = 300, // 5 phút
    this.longBreakDuration = 900, // 15 phút
    this.longBreakInterval = 4,
    this.pomodoroCycleCount = 4, // 4 pomodoro sessions cần hoàn thành
    this.isStandardMode = true, // Default: Standard Pomodoro
    this.soundEnabled = true,
    this.notificationSound = 'default',
    this.vibrationEnabled = true,
    this.theme = 'light',
  });

  /// Tạo copy với các field được update
  PomodoroSettings copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? longBreakInterval,
    int? pomodoroCycleCount,
    bool? isStandardMode,
    bool? soundEnabled,
    String? notificationSound,
    bool? vibrationEnabled,
    String? theme,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      pomodoroCycleCount: pomodoroCycleCount ?? this.pomodoroCycleCount,
      isStandardMode: isStandardMode ?? this.isStandardMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      theme: theme ?? this.theme,
    );
  }

  /// Getter để lấy thời gian theo loại session
  int getDurationForSessionType(String sessionType) {
    switch (sessionType) {
      case 'work':
        return workDuration;
      case 'shortBreak':
        return shortBreakDuration;
      case 'longBreak':
        return longBreakDuration;
      default:
        return workDuration;
    }
  }

  /// Getter để check xem có nên auto-start không (luôn false vì bỏ auto start)
  bool shouldAutoStart(String sessionType) {
    return false; // Không auto start nữa
  }

  /// Getter để check xem có nên long break không
  bool shouldTakeLongBreak(int completedPomodoros) {
    return completedPomodoros > 0 && completedPomodoros % longBreakInterval == 0;
  }

  /// Getter để check xem cycle có hoàn thành không
  bool isCycleComplete(int completedPomodoros) {
    return completedPomodoros >= pomodoroCycleCount;
  }

  /// Getter để lấy giá trị Standard Pomodoro (theo chuẩn Francesco Cirillo)
  PomodoroSettings get standardPomodoroSettings {
    return PomodoroSettings(
      workDuration: 1500, // 25 phút
      shortBreakDuration: 300, // 5 phút
      longBreakDuration: 900, // 15 phút
      longBreakInterval: 4, // Long break sau 4 pomodoros
      pomodoroCycleCount: 4, // 4 pomodoros per cycle
      isStandardMode: true,
      soundEnabled: soundEnabled,
      notificationSound: notificationSound,
      vibrationEnabled: vibrationEnabled,
      theme: theme,
    );
  }

  /// Getter để check xem có đang ở Standard Mode không
  bool get isStandardPomodoro {
    return isStandardMode;
  }

  /// Getter để lấy effective values (Standard hoặc Custom)
  int get effectiveWorkDuration {
    return isStandardMode ? 1500 : workDuration;
  }

  int get effectiveShortBreakDuration {
    return isStandardMode ? 300 : shortBreakDuration;
  }

  int get effectiveLongBreakDuration {
    return isStandardMode ? 900 : longBreakDuration;
  }

  int get effectiveLongBreakInterval {
    return isStandardMode ? 4 : longBreakInterval;
  }

  int get effectivePomodoroCycleCount {
    return isStandardMode ? 4 : pomodoroCycleCount;
  }

  @override
  String toString() {
    return 'PomodoroSettings(workDuration: $workDuration, shortBreakDuration: $shortBreakDuration, longBreakDuration: $longBreakDuration, longBreakInterval: $longBreakInterval, pomodoroCycleCount: $pomodoroCycleCount, isStandardMode: $isStandardMode, soundEnabled: $soundEnabled, notificationSound: $notificationSound, vibrationEnabled: $vibrationEnabled, theme: $theme)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PomodoroSettings &&
        other.workDuration == workDuration &&
        other.shortBreakDuration == shortBreakDuration &&
        other.longBreakDuration == longBreakDuration &&
        other.longBreakInterval == longBreakInterval &&
        other.pomodoroCycleCount == pomodoroCycleCount &&
        other.isStandardMode == isStandardMode &&
        other.soundEnabled == soundEnabled &&
        other.notificationSound == notificationSound &&
        other.vibrationEnabled == vibrationEnabled &&
        other.theme == theme;
  }

  @override
  int get hashCode {
    return workDuration.hashCode ^
        shortBreakDuration.hashCode ^
        longBreakDuration.hashCode ^
        longBreakInterval.hashCode ^
        pomodoroCycleCount.hashCode ^
        isStandardMode.hashCode ^
        soundEnabled.hashCode ^
        notificationSound.hashCode ^
        vibrationEnabled.hashCode ^
        theme.hashCode;
  }
}
