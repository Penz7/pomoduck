part of 'pomodoro_cubit.dart';

@immutable
class PomodoroState {
  const PomodoroState({
    required this.plannedSeconds,
    required this.elapsedSeconds,
    required this.sessionType,
    required this.isRunning,
    this.activeCycle,
  });

  final int plannedSeconds;
  final int elapsedSeconds;
  final String sessionType; // 'work', 'shortBreak', 'longBreak'
  final bool isRunning;
  final PomodoroCycleModel? activeCycle;

  int get remainingSeconds => (plannedSeconds - elapsedSeconds).clamp(0, plannedSeconds);

  PomodoroState copyWith({
    int? plannedSeconds,
    int? elapsedSeconds,
    String? sessionType,
    bool? isRunning,
    PomodoroCycleModel? activeCycle,
  }) {
    return PomodoroState(
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      sessionType: sessionType ?? this.sessionType,
      isRunning: isRunning ?? this.isRunning,
      activeCycle: activeCycle ?? this.activeCycle,
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
