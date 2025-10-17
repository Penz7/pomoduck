part of 'setting_cubit.dart';

@immutable
sealed class SettingState {}

final class SettingLoading extends SettingState {}

final class SettingLoaded extends SettingState {
  final UserPreferencesModel preferences;
  final String notificationSound;
  final List<String> pomodoroTags;

  SettingLoaded({
    required this.preferences,
    required this.notificationSound,
    required this.pomodoroTags,
  });

  SettingLoaded copyWith({
    UserPreferencesModel? preferences,
    String? notificationSound,
    List<String>? pomodoroTags,
  }) {
    return SettingLoaded(
      preferences: preferences ?? this.preferences,
      notificationSound: notificationSound ?? this.notificationSound,
      pomodoroTags: pomodoroTags ?? this.pomodoroTags,
    );
  }
}
