import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/pomodoro_settings.dart';
import '../../data/models/current_timer_state.dart';
import '../../data/models/user_preferences_model.dart';


class HiveDataManager {
  static const String _settingsBoxName = 'pomodoro_settings';
  static const String _timerStateBoxName = 'timer_state';
  static const String _userPreferencesBoxName = 'user_preferences';
  static const String _cacheBoxName = 'cache_data';

  // Box instances
  static late Box<PomodoroSettings> _settingsBox;
  static late Box<CurrentTimerState> _timerStateBox;
  static late Box<UserPreferencesModel> _userPreferencesBox;
  static late Box<Map> _cacheBox;

  /// Initialize all Hive boxes
  static Future<void> initialize() async {
    _settingsBox = await Hive.openBox<PomodoroSettings>(_settingsBoxName);
    _timerStateBox = await Hive.openBox<CurrentTimerState>(_timerStateBoxName);
    _userPreferencesBox = await Hive.openBox<UserPreferencesModel>(_userPreferencesBoxName);
    _cacheBox = await Hive.openBox<Map>(_cacheBoxName);
  }

  // ==================== POMODORO SETTINGS ====================

  /// Get Pomodoro settings
  static PomodoroSettings getSettings() {
    return _settingsBox.get('settings') ?? PomodoroSettings();
  }

  /// Save Pomodoro settings
  static Future<void> saveSettings(PomodoroSettings settings) async {
    await _settingsBox.put('settings', settings);
  }

  /// Update specific setting
  static Future<void> updateSetting({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? longBreakInterval,
    int? pomodoroCycleCount,
    bool? isStandardMode,
    bool? soundEnabled,
    String? notificationSound,
    bool? vibrationEnabled,
  }) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(
      workDuration: workDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      longBreakInterval: longBreakInterval,
      pomodoroCycleCount: pomodoroCycleCount,
      isStandardMode: isStandardMode,
      soundEnabled: soundEnabled,
      notificationSound: notificationSound,
      vibrationEnabled: vibrationEnabled,
    );
    await saveSettings(updatedSettings);
  }

  // ==================== TIMER STATE ====================

  /// Get current timer state
  static CurrentTimerState getCurrentTimerState() {
    return _timerStateBox.get('current_state') ?? CurrentTimerState();
  }

  /// Update timer state
  static Future<void> updateTimerState(CurrentTimerState state) async {
    await _timerStateBox.put('current_state', state);
  }

  /// Start timer
  static Future<void> startTimer({
    required String sessionType,
    int? taskId,
    required int plannedDurationSeconds,
    int? sessionId,
  }) async {
    final newState = CurrentTimerState().start(
      sessionType: sessionType,
      taskId: taskId,
      plannedDurationSeconds: plannedDurationSeconds,
      sessionId: sessionId,
    );
    await updateTimerState(newState);
  }

  /// Pause timer
  static Future<void> pauseTimer() async {
    final currentState = getCurrentTimerState();
    final pausedState = currentState.pause();
    await updateTimerState(pausedState);
  }

  /// Resume timer
  static Future<void> resumeTimer() async {
    final currentState = getCurrentTimerState();
    final resumedState = currentState.resume();
    await updateTimerState(resumedState);
  }

  /// Stop timer
  static Future<void> stopTimer() async {
    final currentState = getCurrentTimerState();
    final stoppedState = currentState.stop();
    await updateTimerState(stoppedState);
  }

  /// Update elapsed time (ultra-fast operation)
  static Future<void> updateElapsedTime(int elapsedSeconds) async {
    final currentState = getCurrentTimerState();
    final updatedState = currentState.updateElapsed(elapsedSeconds);
    await updateTimerState(updatedState);
  }

  /// Complete session
  static Future<void> completeSession() async {
    final currentState = getCurrentTimerState();
    final completedState = currentState.complete();
    await updateTimerState(completedState);
  }

  /// Reset timer state
  static Future<void> resetTimerState() async {
    await updateTimerState(CurrentTimerState());
  }

  // ==================== USER PREFERENCES ====================

  /// Get user preferences
  static UserPreferencesModel getUserPreferences() {
    return _userPreferencesBox.get('preferences') ?? UserPreferencesModel();
  }

  /// Save user preferences
  static Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    await _userPreferencesBox.put('preferences', preferences);
  }

  /// Update specific preference
  static Future<void> updatePreference({
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
    bool? enableNotificationSound,
  }) async {
    final currentPreferences = getUserPreferences();
    final updatedPreferences = currentPreferences.copyWith(
      language: language,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      showNotifications: showNotifications,
      showTaskProgress: showTaskProgress,
      showDailyStats: showDailyStats,
      showPomodoroCounter: showPomodoroCounter,
      showSessionProgress: showSessionProgress,
      defaultTaskCategory: defaultTaskCategory,
      enableDarkMode: enableDarkMode,
      enableHapticFeedback: enableHapticFeedback,
      appTheme: appTheme,
      enableNotificationSound: enableNotificationSound,
    );
    await saveUserPreferences(updatedPreferences);
  }

  // ==================== CACHE DATA ====================

  /// Get cached data
  static Map? getCachedData(String key) {
    return _cacheBox.get(key);
  }

  /// Save cached data
  static Future<void> saveCachedData(String key, Map data) async {
    await _cacheBox.put(key, data);
  }

  // ===== Pomodoro Tags Persistence =====
  static List<String> getPomodoroTags() {
    final data = getCachedData('pomodoro_tags');
    if (data != null) {
      final list = List<String>.from(data['tags'] ?? <String>[]);
      if (list.isNotEmpty) return list;
    }
    // default tags
    return const ['sport', 'study', 'work', 'practice', 'focus'];
  }

  static Future<void> savePomodoroTags(List<String> tags) async {
    await saveCachedData('pomodoro_tags', {'tags': tags});
  }

  static String getSelectedPomodoroTag() {
    final prefs = getUserPreferences();
    // Nếu chưa có, dùng 'focus' làm mặc định
    return (prefs.defaultTaskCategory.isEmpty || prefs.defaultTaskCategory == 'general')
        ? 'focus'
        : prefs.defaultTaskCategory;
  }

  static Future<void> saveSelectedPomodoroTag(String tag) async {
    await updatePreference(defaultTaskCategory: tag);
  }

  /// Get recent tasks cache
  static List<Map>? getRecentTasks() {
    final data = getCachedData('recent_tasks');
    return data != null ? List<Map>.from(data['tasks'] ?? []) : null;
  }

  /// Save recent tasks cache
  static Future<void> saveRecentTasks(List<Map> tasks) async {
    await saveCachedData('recent_tasks', {'tasks': tasks});
  }


  // ==================== UTILITY METHODS ====================

  /// Clear all timer state
  static Future<void> clearTimerState() async {
    await _timerStateBox.clear();
  }

  /// Clear all cache data
  static Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  /// Clear all data (for logout/reset)
  static Future<void> clearAllData() async {
    await _settingsBox.clear();
    await _timerStateBox.clear();
    await _userPreferencesBox.clear();
    await _cacheBox.clear();
  }

  /// Get box listeners for reactive UI
  static ValueListenable<Box<PomodoroSettings>> get settingsListener => _settingsBox.listenable();
  static ValueListenable<Box<CurrentTimerState>> get timerStateListener => _timerStateBox.listenable();
  static ValueListenable<Box<UserPreferencesModel>> get preferencesListener => _userPreferencesBox.listenable();
  static ValueListenable<Box<Map>> get cacheListener => _cacheBox.listenable();

  /// Close all boxes
  static Future<void> closeAll() async {
    await _settingsBox.close();
    await _timerStateBox.close();
    await _userPreferencesBox.close();
    await _cacheBox.close();
  }
}
