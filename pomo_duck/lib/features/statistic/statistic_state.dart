part of 'statistic_cubit.dart';

@immutable
sealed class StatisticState {}

final class StatisticInitial extends StatisticState {}

final class StatisticLoading extends StatisticState {}

final class StatisticLoaded extends StatisticState {
  StatisticLoaded({
    required this.todayStats,
    required this.overallStats,
    required this.analytics,
    required this.realtime,
    required this.predictions,
  });
  final Map<String, dynamic> todayStats;
  final Map<String, dynamic> overallStats;
  final Map<String, dynamic> analytics; // includes basic, patterns, performance, focus
  final Map<String, dynamic> realtime;   // today_sessions, today_work_time, active_session, current_cycle
  final Map<String, dynamic> predictions;
}

final class StatisticError extends StatisticState {
  StatisticError(this.message);
  final String message;
}
