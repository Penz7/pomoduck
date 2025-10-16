part of 'pomodoro_cubit.dart';

@immutable
class PomodoroState {
  const PomodoroState({
    required this.plannedSeconds,
    required this.elapsedSeconds,
    required this.sessionType,
    required this.isRunning,
  });

  final int plannedSeconds;
  final int elapsedSeconds;
  final String sessionType; // 'work', 'shortBreak', 'longBreak'
  final bool isRunning;

  int get remainingSeconds => (plannedSeconds - elapsedSeconds).clamp(0, plannedSeconds);

  PomodoroState copyWith({
    int? plannedSeconds,
    int? elapsedSeconds,
    String? sessionType,
    bool? isRunning,
  }) {
    return PomodoroState(
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      sessionType: sessionType ?? this.sessionType,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
