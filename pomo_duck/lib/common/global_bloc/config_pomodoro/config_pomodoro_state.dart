part of 'config_pomodoro_cubit.dart';

class ConfigPomodoroState extends BaseState {
  ConfigPomodoroState({
    super.message,
    super.status,
    required this.settings,
    required this.tags,
    required this.selectedTag,
  });

  final PomodoroSettings settings;
  final List<String> tags; // danh sách tag hiển thị để chọn
  final String selectedTag; // tag đang được chọn

  @override
  ConfigPomodoroState copyWith({
    BlocStatus? status,
    String? message,
    PomodoroSettings? settings,
    List<String>? tags,
    String? selectedTag,
  }) {
    return ConfigPomodoroState(
      status: status ?? this.status,
      message: message ?? this.message,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      selectedTag: selectedTag ?? this.selectedTag,
    );
  }
}
