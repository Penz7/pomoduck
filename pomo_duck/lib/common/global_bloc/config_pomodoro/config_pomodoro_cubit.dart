import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:pomo_duck/core/base_state.dart';

import '../../../core/local_storage/hive_data_manager.dart';
import '../../../data/models/pomodoro_settings.dart';

part 'config_pomodoro_state.dart';

class ConfigPomodoroCubit extends Cubit<ConfigPomodoroState> {
  ConfigPomodoroCubit()
      : super(
          ConfigPomodoroState(
            settings: HiveDataManager.getSettings(),
            tags: HiveDataManager.getPomodoroTags(),
            selectedTag: HiveDataManager.getSelectedPomodoroTag(),
          ),
        ) {
    _listener = () {
      emit(state.copyWith(settings: HiveDataManager.getSettings()));
    };
    HiveDataManager.settingsListener.addListener(_listener);
  }

  late final VoidCallback _listener;

  // ==== Update helpers (realtime) ====
  Future<void> updateWorkMinutes(int minutes) async {
    if (minutes > 0) {
      await HiveDataManager.updateSetting(workDuration: minutes * 60);
    }
  }

  Future<void> updateShortBreakMinutes(int minutes) async {
    if (minutes > 0) {
      await HiveDataManager.updateSetting(shortBreakDuration: minutes * 60);
    }
  }

  Future<void> updateLongBreakMinutes(int minutes) async {
    if (minutes > 0) {
      await HiveDataManager.updateSetting(longBreakDuration: minutes * 60);
    }
  }

  Future<void> updateLongBreakInterval(int value) async {
    if (value > 0) {
      await HiveDataManager.updateSetting(longBreakInterval: value);
    }
  }

  Future<void> updatePomodoroCycleCount(int count) async {
    if (count > 0 && count <= 10) {
      await HiveDataManager.updateSetting(pomodoroCycleCount: count);
    }
  }

  Future<void> setStandardMode(bool isStandard) async {
    await HiveDataManager.updateSetting(isStandardMode: isStandard);
  }

  Future<void> setSoundEnabled(bool value) async {
    await HiveDataManager.updateSetting(soundEnabled: value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    await HiveDataManager.updateSetting(vibrationEnabled: value);
  }

  Future<void> setTheme(String theme) async {
    await HiveDataManager.updateSetting(theme: theme);
  }

  Future<void> resetDefaults() async {
    await HiveDataManager.saveSettings(PomodoroSettings());
  }

  // ===== Tag management =====
  void selectTag(String tag) {
    if (!state.tags.contains(tag)) return;
    emit(state.copyWith(selectedTag: tag));
    HiveDataManager.saveSelectedPomodoroTag(tag);
  }

  void addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    if (state.tags.contains(trimmed)) {
      emit(state.copyWith(selectedTag: trimmed));
      HiveDataManager.saveSelectedPomodoroTag(trimmed);
      return;
    }
    final updated = List<String>.from(state.tags)..add(trimmed);
    emit(state.copyWith(tags: updated, selectedTag: trimmed));
    HiveDataManager.savePomodoroTags(updated);
    HiveDataManager.saveSelectedPomodoroTag(trimmed);
  }

  void removeTag(String tag) {
    if (!state.tags.contains(tag)) return;
    final updated = List<String>.from(state.tags)..remove(tag);
    final newSelected = state.selectedTag == tag
        ? (updated.isNotEmpty ? updated.first : 'focus')
        : state.selectedTag;
    emit(state.copyWith(tags: updated, selectedTag: newSelected));
    HiveDataManager.savePomodoroTags(updated);
    HiveDataManager.saveSelectedPomodoroTag(newSelected);
  }

  @override
  Future<void> close() {
    HiveDataManager.settingsListener.removeListener(_listener);
    return super.close();
  }
}
