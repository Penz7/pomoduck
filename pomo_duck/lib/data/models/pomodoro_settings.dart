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
  final bool autoStartBreaks; // Tự động bắt đầu break

  @HiveField(5)
  final bool autoStartPomodoros; // Tự động bắt đầu pomodoro tiếp theo

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
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
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
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
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
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
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

  /// Getter để check xem có nên auto-start không
  bool shouldAutoStart(String sessionType) {
    if (sessionType == 'work') {
      return autoStartPomodoros;
    } else if (sessionType == 'shortBreak' || sessionType == 'longBreak') {
      return autoStartBreaks;
    }
    return false;
  }

  @override
  String toString() {
    return 'PomodoroSettings(workDuration: $workDuration, shortBreakDuration: $shortBreakDuration, longBreakDuration: $longBreakDuration, longBreakInterval: $longBreakInterval, autoStartBreaks: $autoStartBreaks, autoStartPomodoros: $autoStartPomodoros, soundEnabled: $soundEnabled, notificationSound: $notificationSound, vibrationEnabled: $vibrationEnabled, theme: $theme)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PomodoroSettings &&
        other.workDuration == workDuration &&
        other.shortBreakDuration == shortBreakDuration &&
        other.longBreakDuration == longBreakDuration &&
        other.longBreakInterval == longBreakInterval &&
        other.autoStartBreaks == autoStartBreaks &&
        other.autoStartPomodoros == autoStartPomodoros &&
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
        autoStartBreaks.hashCode ^
        autoStartPomodoros.hashCode ^
        soundEnabled.hashCode ^
        notificationSound.hashCode ^
        vibrationEnabled.hashCode ^
        theme.hashCode;
  }
}
