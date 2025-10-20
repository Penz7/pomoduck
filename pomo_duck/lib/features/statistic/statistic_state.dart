part of 'statistic_cubit.dart';

@immutable
sealed class StatisticState {}

final class StatisticInitial extends StatisticState {}

final class StatisticLoading extends StatisticState {}

final class StatisticLoaded extends StatisticState {
  StatisticLoaded({
    required this.overview,
    required this.dailyStats,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.sessionPatterns,
    required this.periodInfo,
  });
  
  // Thống kê tổng quan
  final Map<String, dynamic> overview;
  
  // Thống kê chi tiết theo thời gian
  final List<Map<String, dynamic>> dailyStats;
  final List<Map<String, dynamic>> weeklyStats;
  final List<Map<String, dynamic>> monthlyStats;
  
  // Patterns và insights
  final Map<String, dynamic> sessionPatterns;
  
  // Thông tin khoảng thời gian
  final Map<String, dynamic> periodInfo;
}

final class StatisticError extends StatisticState {
  StatisticError(this.message);
  final String message;
}
