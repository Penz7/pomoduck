part of 'pomodoro_cubit.dart';

@immutable
class PomodoroState {
  const PomodoroState({
    required this.plannedSeconds,
    required this.elapsedSeconds,
    required this.sessionType,
    required this.isRunning,
    this.activeCycle,
    this.sessionShieldActive = false,
  });

  final int plannedSeconds;
  final int elapsedSeconds;
  final String sessionType; // 'work', 'shortBreak', 'longBreak'
  final bool isRunning;
  final PomodoroCycleModel? activeCycle;
  final bool sessionShieldActive; // Khiên đã kích hoạt cho lần dừng kế tiếp trong phiên

  int get remainingSeconds => (plannedSeconds - elapsedSeconds).clamp(0, plannedSeconds);

  PomodoroState copyWith({
    int? plannedSeconds,
    int? elapsedSeconds,
    String? sessionType,
    bool? isRunning,
    PomodoroCycleModel? activeCycle,
    bool? sessionShieldActive,
  }) {
    return PomodoroState(
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      sessionType: sessionType ?? this.sessionType,
      isRunning: isRunning ?? this.isRunning,
      activeCycle: activeCycle ?? this.activeCycle,
      sessionShieldActive: sessionShieldActive ?? this.sessionShieldActive,
    );
  }
}

@immutable
class PomodoroTaskCompleted extends PomodoroState {
  const PomodoroTaskCompleted() : super(
    plannedSeconds: 0,
    elapsedSeconds: 0,
    sessionType: '',
    isRunning: false,
    activeCycle: null,
  );
}
