/// Model cho thống kê tổng quan
class StatisticsModel {
  final int totalTasks;
  final int completedTasks;
  final int totalSessions;
  final int completedSessions;
  final int totalWorkTime; // giây
  final int totalBreakTime; // giây
  final double completionRate; // phần trăm
  final double productivityScore; // điểm hiệu suất 0-100
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodType; // 'day', 'week', 'month'

  const StatisticsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.totalSessions,
    required this.completedSessions,
    required this.totalWorkTime,
    required this.totalBreakTime,
    required this.completionRate,
    required this.productivityScore,
    required this.periodStart,
    required this.periodEnd,
    required this.periodType,
  });

  /// Tạo StatisticsModel từ Map
  factory StatisticsModel.fromMap(Map<String, dynamic> map) {
    return StatisticsModel(
      totalTasks: map['total_tasks'] as int,
      completedTasks: map['completed_tasks'] as int,
      totalSessions: map['total_sessions'] as int,
      completedSessions: map['completed_sessions'] as int,
      totalWorkTime: map['total_work_time'] as int,
      totalBreakTime: map['total_break_time'] as int,
      completionRate: (map['completion_rate'] as num).toDouble(),
      productivityScore: (map['productivity_score'] as num).toDouble(),
      periodStart: DateTime.parse(map['period_start'] as String),
      periodEnd: DateTime.parse(map['period_end'] as String),
      periodType: map['period_type'] as String,
    );
  }

  /// Chuyển thành Map
  Map<String, dynamic> toMap() {
    return {
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'total_work_time': totalWorkTime,
      'total_break_time': totalBreakTime,
      'completion_rate': completionRate,
      'productivity_score': productivityScore,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'period_type': periodType,
    };
  }

  /// Tính thời gian làm việc trung bình mỗi ngày (phút)
  double get averageWorkTimePerDay {
    final days = periodEnd.difference(periodStart).inDays + 1;
    return (totalWorkTime / 60) / days;
  }

  /// Tính số session trung bình mỗi ngày
  double get averageSessionsPerDay {
    final days = periodEnd.difference(periodStart).inDays + 1;
    return completedSessions / days;
  }

  /// Tính tỷ lệ hoàn thành task
  double get taskCompletionRate {
    return totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  }

  /// Tính tỷ lệ hoàn thành session
  double get sessionCompletionRate {
    return totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0;
  }

  /// Tính điểm chăm chỉ (dựa trên tần suất và thời gian)
  double get diligenceScore {
    // Điểm chăm chỉ = (tần suất session + thời gian làm việc + tỷ lệ hoàn thành) / 3
    final frequencyScore = (averageSessionsPerDay / 8) * 100; // 8 session/ngày = 100 điểm
    final timeScore = (averageWorkTimePerDay / 240) * 100; // 4 giờ/ngày = 100 điểm
    final completionScore = (taskCompletionRate + sessionCompletionRate) / 2;
    
    return ((frequencyScore + timeScore + completionScore) / 3).clamp(0, 100);
  }

  @override
  String toString() {
    return 'StatisticsModel(totalTasks: $totalTasks, completedTasks: $completedTasks, totalSessions: $totalSessions, completedSessions: $completedSessions, totalWorkTime: $totalWorkTime, totalBreakTime: $totalBreakTime, completionRate: $completionRate, productivityScore: $productivityScore, periodStart: $periodStart, periodEnd: $periodEnd, periodType: $periodType)';
  }
}

/// Model cho thống kê chi tiết theo thời gian
class TimeBasedStatisticsModel {
  final List<DailyStatisticsModel> dailyStats;
  final List<WeeklyStatisticsModel> weeklyStats;
  final List<MonthlyStatisticsModel> monthlyStats;
  final Map<String, int> sessionFrequencyByHour; // giờ trong ngày
  final Map<String, int> sessionFrequencyByDay; // ngày trong tuần
  final Map<String, int> sessionFrequencyByMonth; // tháng trong năm

  const TimeBasedStatisticsModel({
    required this.dailyStats,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.sessionFrequencyByHour,
    required this.sessionFrequencyByDay,
    required this.sessionFrequencyByMonth,
  });

  /// Tạo TimeBasedStatisticsModel từ Map
  factory TimeBasedStatisticsModel.fromMap(Map<String, dynamic> map) {
    return TimeBasedStatisticsModel(
      dailyStats: (map['daily_stats'] as List)
          .map((e) => DailyStatisticsModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      weeklyStats: (map['weekly_stats'] as List)
          .map((e) => WeeklyStatisticsModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      monthlyStats: (map['monthly_stats'] as List)
          .map((e) => MonthlyStatisticsModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      sessionFrequencyByHour: Map<String, int>.from(map['session_frequency_by_hour'] as Map),
      sessionFrequencyByDay: Map<String, int>.from(map['session_frequency_by_day'] as Map),
      sessionFrequencyByMonth: Map<String, int>.from(map['session_frequency_by_month'] as Map),
    );
  }

  /// Chuyển thành Map
  Map<String, dynamic> toMap() {
    return {
      'daily_stats': dailyStats.map((e) => e.toMap()).toList(),
      'weekly_stats': weeklyStats.map((e) => e.toMap()).toList(),
      'monthly_stats': monthlyStats.map((e) => e.toMap()).toList(),
      'session_frequency_by_hour': sessionFrequencyByHour,
      'session_frequency_by_day': sessionFrequencyByDay,
      'session_frequency_by_month': sessionFrequencyByMonth,
    };
  }
}

/// Model cho thống kê theo ngày
class DailyStatisticsModel {
  final DateTime date;
  final int sessionsCompleted;
  final int workTime; // giây
  final int breakTime; // giây
  final int tasksCompleted;
  final double productivityScore;

  const DailyStatisticsModel({
    required this.date,
    required this.sessionsCompleted,
    required this.workTime,
    required this.breakTime,
    required this.tasksCompleted,
    required this.productivityScore,
  });

  factory DailyStatisticsModel.fromMap(Map<String, dynamic> map) {
    return DailyStatisticsModel(
      date: DateTime.parse(map['date'] as String),
      sessionsCompleted: map['sessions_completed'] as int,
      workTime: map['work_time'] as int,
      breakTime: map['break_time'] as int,
      tasksCompleted: map['tasks_completed'] as int,
      productivityScore: (map['productivity_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'sessions_completed': sessionsCompleted,
      'work_time': workTime,
      'break_time': breakTime,
      'tasks_completed': tasksCompleted,
      'productivity_score': productivityScore,
    };
  }
}

/// Model cho thống kê theo tuần
class WeeklyStatisticsModel {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int sessionsCompleted;
  final int workTime; // giây
  final int breakTime; // giây
  final int tasksCompleted;
  final double averageProductivityScore;
  final int activeDays; // số ngày có hoạt động

  const WeeklyStatisticsModel({
    required this.weekStart,
    required this.weekEnd,
    required this.sessionsCompleted,
    required this.workTime,
    required this.breakTime,
    required this.tasksCompleted,
    required this.averageProductivityScore,
    required this.activeDays,
  });

  factory WeeklyStatisticsModel.fromMap(Map<String, dynamic> map) {
    return WeeklyStatisticsModel(
      weekStart: DateTime.parse(map['week_start'] as String),
      weekEnd: DateTime.parse(map['week_end'] as String),
      sessionsCompleted: map['sessions_completed'] as int,
      workTime: map['work_time'] as int,
      breakTime: map['break_time'] as int,
      tasksCompleted: map['tasks_completed'] as int,
      averageProductivityScore: (map['average_productivity_score'] as num).toDouble(),
      activeDays: map['active_days'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'week_start': weekStart.toIso8601String(),
      'week_end': weekEnd.toIso8601String(),
      'sessions_completed': sessionsCompleted,
      'work_time': workTime,
      'break_time': breakTime,
      'tasks_completed': tasksCompleted,
      'average_productivity_score': averageProductivityScore,
      'active_days': activeDays,
    };
  }
}

/// Model cho thống kê theo tháng
class MonthlyStatisticsModel {
  final DateTime monthStart;
  final DateTime monthEnd;
  final int sessionsCompleted;
  final int workTime; // giây
  final int breakTime; // giây
  final int tasksCompleted;
  final double averageProductivityScore;
  final int activeDays; // số ngày có hoạt động
  final int activeWeeks; // số tuần có hoạt động

  const MonthlyStatisticsModel({
    required this.monthStart,
    required this.monthEnd,
    required this.sessionsCompleted,
    required this.workTime,
    required this.breakTime,
    required this.tasksCompleted,
    required this.averageProductivityScore,
    required this.activeDays,
    required this.activeWeeks,
  });

  factory MonthlyStatisticsModel.fromMap(Map<String, dynamic> map) {
    return MonthlyStatisticsModel(
      monthStart: DateTime.parse(map['month_start'] as String),
      monthEnd: DateTime.parse(map['month_end'] as String),
      sessionsCompleted: map['sessions_completed'] as int,
      workTime: map['work_time'] as int,
      breakTime: map['break_time'] as int,
      tasksCompleted: map['tasks_completed'] as int,
      averageProductivityScore: (map['average_productivity_score'] as num).toDouble(),
      activeDays: map['active_days'] as int,
      activeWeeks: map['active_weeks'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month_start': monthStart.toIso8601String(),
      'month_end': monthEnd.toIso8601String(),
      'sessions_completed': sessionsCompleted,
      'work_time': workTime,
      'break_time': breakTime,
      'tasks_completed': tasksCompleted,
      'average_productivity_score': averageProductivityScore,
      'active_days': activeDays,
      'active_weeks': activeWeeks,
    };
  }
}

/// Model cho thống kê session patterns
class SessionPatternsModel {
  final int averageSessionDuration; // giây
  final int mostCommonSessionDuration; // giây
  final int averageShortBreakDuration; // giây
  final int averageLongBreakDuration; // giây
  final Map<String, int> sessionDurationDistribution; // phân bố thời gian session
  final Map<String, int> breakDurationDistribution; // phân bố thời gian nghỉ
  final String mostProductiveHour; // giờ hiệu suất cao nhất
  final String mostProductiveDay; // ngày hiệu suất cao nhất

  const SessionPatternsModel({
    required this.averageSessionDuration,
    required this.mostCommonSessionDuration,
    required this.averageShortBreakDuration,
    required this.averageLongBreakDuration,
    required this.sessionDurationDistribution,
    required this.breakDurationDistribution,
    required this.mostProductiveHour,
    required this.mostProductiveDay,
  });

  factory SessionPatternsModel.fromMap(Map<String, dynamic> map) {
    return SessionPatternsModel(
      averageSessionDuration: map['average_session_duration'] as int,
      mostCommonSessionDuration: map['most_common_session_duration'] as int,
      averageShortBreakDuration: map['average_short_break_duration'] as int,
      averageLongBreakDuration: map['average_long_break_duration'] as int,
      sessionDurationDistribution: Map<String, int>.from(map['session_duration_distribution'] as Map),
      breakDurationDistribution: Map<String, int>.from(map['break_duration_distribution'] as Map),
      mostProductiveHour: map['most_productive_hour'] as String,
      mostProductiveDay: map['most_productive_day'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'average_session_duration': averageSessionDuration,
      'most_common_session_duration': mostCommonSessionDuration,
      'average_short_break_duration': averageShortBreakDuration,
      'average_long_break_duration': averageLongBreakDuration,
      'session_duration_distribution': sessionDurationDistribution,
      'break_duration_distribution': breakDurationDistribution,
      'most_productive_hour': mostProductiveHour,
      'most_productive_day': mostProductiveDay,
    };
  }
}
