import 'package:hive/hive.dart';

part 'user_preferences_model.g.dart';

/// Model cho user preferences - lưu trong Hive
@HiveType(typeId: 1)
class UserPreferencesModel extends HiveObject {
  @HiveField(0)
  final String language; // 'vi', 'en'

  @HiveField(1)
  final String dateFormat; // 'dd/MM/yyyy', 'MM/dd/yyyy'

  @HiveField(2)
  final String timeFormat; // '24h', '12h'

  @HiveField(3)
  final bool showNotifications; // Hiển thị thông báo

  @HiveField(4)
  final bool showTaskProgress; // Hiển thị tiến độ task

  @HiveField(5)
  final bool showDailyStats; // Hiển thị thống kê hàng ngày

  @HiveField(6)
  final bool showPomodoroCounter; // Hiển thị số pomodoro đã hoàn thành

  @HiveField(7)
  final bool showSessionProgress; // Hiển thị tiến độ session

  @HiveField(8)
  final String defaultTaskCategory; // Category mặc định cho task mới

  @HiveField(9)
  final bool enableDarkMode; // Bật dark mode

  @HiveField(10)
  final bool enableHapticFeedback; // Bật haptic feedback

  @HiveField(11)
  final String appTheme; // 'light', 'dark', 'system'

  UserPreferencesModel({
    this.language = 'vi',
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = '24h',
    this.showNotifications = true,
    this.showTaskProgress = true,
    this.showDailyStats = true,
    this.showPomodoroCounter = true,
    this.showSessionProgress = true,
    this.defaultTaskCategory = 'general',
    this.enableDarkMode = false,
    this.enableHapticFeedback = true,
    this.appTheme = 'system',
  });

  /// Tạo copy với các field được update
  UserPreferencesModel copyWith({
    String? language,
    String? dateFormat,
    String? timeFormat,
    bool? showNotifications,
    bool? showTaskProgress,
    bool? showDailyStats,
    bool? showPomodoroCounter,
    bool? showSessionProgress,
    String? defaultTaskCategory,
    bool? enableDarkMode,
    bool? enableHapticFeedback,
    String? appTheme,
  }) {
    return UserPreferencesModel(
      language: language ?? this.language,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      showNotifications: showNotifications ?? this.showNotifications,
      showTaskProgress: showTaskProgress ?? this.showTaskProgress,
      showDailyStats: showDailyStats ?? this.showDailyStats,
      showPomodoroCounter: showPomodoroCounter ?? this.showPomodoroCounter,
      showSessionProgress: showSessionProgress ?? this.showSessionProgress,
      defaultTaskCategory: defaultTaskCategory ?? this.defaultTaskCategory,
      enableDarkMode: enableDarkMode ?? this.enableDarkMode,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      appTheme: appTheme ?? this.appTheme,
    );
  }

  /// Getter để check xem có nên hiển thị thông báo không
  bool get shouldShowNotifications {
    return showNotifications;
  }

  /// Getter để check xem có nên hiển thị progress không
  bool get shouldShowProgress {
    return showTaskProgress || showSessionProgress;
  }

  /// Getter để check xem có nên hiển thị stats không
  bool get shouldShowStats {
    return showDailyStats;
  }

  /// Getter để lấy locale
  String get locale {
    return language;
  }

  /// Getter để check xem có nên enable haptic feedback không
  bool get shouldEnableHaptic {
    return enableHapticFeedback;
  }

  /// Getter để lấy theme mode
  String get themeMode {
    return appTheme;
  }

  /// Getter để check xem có nên force dark mode không
  bool get isDarkMode {
    return appTheme == 'dark' || (appTheme == 'system' && enableDarkMode);
  }

  /// Getter để lấy date format pattern
  String get dateFormatPattern {
    switch (dateFormat) {
      case 'MM/dd/yyyy':
        return 'MM/dd/yyyy';
      case 'yyyy-MM-dd':
        return 'yyyy-MM-dd';
      default:
        return 'dd/MM/yyyy';
    }
  }

  /// Getter để lấy time format pattern
  String get timeFormatPattern {
    return timeFormat == '12h' ? 'h:mm a' : 'HH:mm';
  }

  /// Getter để lấy datetime format pattern
  String get dateTimeFormatPattern {
    return '${dateFormatPattern} ${timeFormatPattern}';
  }

  /// Reset về default values
  UserPreferencesModel reset() {
    return UserPreferencesModel();
  }

  /// Update language
  UserPreferencesModel updateLanguage(String newLanguage) {
    return copyWith(language: newLanguage);
  }

  /// Update theme
  UserPreferencesModel updateTheme(String newTheme) {
    return copyWith(appTheme: newTheme);
  }

  /// Toggle notifications
  UserPreferencesModel toggleNotifications() {
    return copyWith(showNotifications: !showNotifications);
  }

  /// Toggle haptic feedback
  UserPreferencesModel toggleHapticFeedback() {
    return copyWith(enableHapticFeedback: !enableHapticFeedback);
  }

  @override
  String toString() {
    return 'UserPreferencesModel(language: $language, dateFormat: $dateFormat, timeFormat: $timeFormat, showNotifications: $showNotifications, showTaskProgress: $showTaskProgress, showDailyStats: $showDailyStats, showPomodoroCounter: $showPomodoroCounter, showSessionProgress: $showSessionProgress, defaultTaskCategory: $defaultTaskCategory, enableDarkMode: $enableDarkMode, enableHapticFeedback: $enableHapticFeedback, appTheme: $appTheme)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferencesModel &&
        other.language == language &&
        other.dateFormat == dateFormat &&
        other.timeFormat == timeFormat &&
        other.showNotifications == showNotifications &&
        other.showTaskProgress == showTaskProgress &&
        other.showDailyStats == showDailyStats &&
        other.showPomodoroCounter == showPomodoroCounter &&
        other.showSessionProgress == showSessionProgress &&
        other.defaultTaskCategory == defaultTaskCategory &&
        other.enableDarkMode == enableDarkMode &&
        other.enableHapticFeedback == enableHapticFeedback &&
        other.appTheme == appTheme;
  }

  @override
  int get hashCode {
    return language.hashCode ^
        dateFormat.hashCode ^
        timeFormat.hashCode ^
        showNotifications.hashCode ^
        showTaskProgress.hashCode ^
        showDailyStats.hashCode ^
        showPomodoroCounter.hashCode ^
        showSessionProgress.hashCode ^
        defaultTaskCategory.hashCode ^
        enableDarkMode.hashCode ^
        enableHapticFeedback.hashCode ^
        appTheme.hashCode;
  }
}
