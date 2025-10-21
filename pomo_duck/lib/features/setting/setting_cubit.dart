import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';
import 'package:pomo_duck/data/models/user_preferences_model.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(SettingLoading()) {
    _init();
  }

  late final VoidCallback _prefsListener;

  Future<void> _init() async {
    final prefs = HiveDataManager.getUserPreferences();
    final tags = HiveDataManager.getPomodoroTags();

    emit(SettingLoaded(
      preferences: prefs,
      notificationSound: 'quack', // Mặc định sử dụng quack sound
      pomodoroTags: tags,
    ));

    _prefsListener = () {
      final next = HiveDataManager.getUserPreferences();
      final current = state;
      if (current is SettingLoaded) {
        emit(current.copyWith(preferences: next));
      } else {
        emit(SettingLoaded(
          preferences: next,
          notificationSound: 'quack',
          pomodoroTags: tags,
        ));
      }
    };

    HiveDataManager.preferencesListener.addListener(_prefsListener);
  }


  // ===== Update methods =====
  Future<void> changeLanguage(String language) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(language: language);
    }
  }

  Future<void> setAppTheme(String theme) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(appTheme: theme);
    }
  }

  Future<void> setNotifications(bool enabled) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(showNotifications: enabled);
    }
  }

  Future<void> setHaptic(bool enabled) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(enableHapticFeedback: enabled);
    }
  }

  Future<void> setDateFormat(String format) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(dateFormat: format);
    }
  }

  Future<void> setTimeFormat(String format) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(timeFormat: format);
    }
  }

  Future<void> setShowTaskProgress(bool value) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(showTaskProgress: value);
    }
  }

  Future<void> setShowDailyStats(bool value) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(showDailyStats: value);
    }
  }

  Future<void> setShowPomodoroCounter(bool value) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(showPomodoroCounter: value);
    }
  }

  Future<void> setShowSessionProgress(bool value) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(showSessionProgress: value);
    }
  }


  Future<void> setEnableNotificationSound(bool enabled) async {
    final current = state;
    if (current is SettingLoaded) {
      await HiveDataManager.updatePreference(enableNotificationSound: enabled);
    }
  }

  @override
  Future<void> close() {
    HiveDataManager.preferencesListener.removeListener(_prefsListener);
    return super.close();
  }
}
