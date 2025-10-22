part of 'score_bloc.dart';

@immutable
abstract class ScoreState {}

class ScoreInitial extends ScoreState {}

class ScoreLoaded extends ScoreState {
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int tasksCompletedToday;
  final bool hasReached30Streak;
  final bool hasReached5Streak;

  ScoreLoaded({
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.tasksCompletedToday,
    required this.hasReached30Streak,
    required this.hasReached5Streak,
  });

  ScoreLoaded copyWith({
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    int? tasksCompletedToday,
    bool? hasReached30Streak,
    bool? hasReached5Streak,
  }) {
    return ScoreLoaded(
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      tasksCompletedToday: tasksCompletedToday ?? this.tasksCompletedToday,
      hasReached30Streak: hasReached30Streak ?? this.hasReached30Streak,
      hasReached5Streak: hasReached5Streak ?? this.hasReached5Streak,
    );
  }
}

class ScoreError extends ScoreState {
  final String message;

  ScoreError(this.message);
}
