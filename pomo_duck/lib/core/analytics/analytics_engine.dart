import '../../data/database/database_helper.dart';

/// Analytics Engine - Advanced analytics và performance monitoring
/// Cung cấp deep insights về productivity patterns
class AnalyticsEngine {
  static final AnalyticsEngine _instance = AnalyticsEngine._internal();
  static AnalyticsEngine get instance => _instance;
  
  AnalyticsEngine._internal();

  // ==================== PRODUCTIVITY ANALYTICS ====================

  /// Get comprehensive productivity analytics
  Future<Map<String, dynamic>> getProductivityAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    // Basic statistics
    final basicStats = await _getBasicStatistics(start, end);
    
    // Productivity patterns
    final patterns = await _getProductivityPatterns(start, end);
    
    // Performance metrics
    final performance = await _getPerformanceMetrics(start, end);
    
    // Focus analysis
    final focusAnalysis = await _getFocusAnalysis(start, end);
    
    return {
      'period': {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'days': end.difference(start).inDays,
      },
      'basic': basicStats,
      'patterns': patterns,
      'performance': performance,
      'focus': focusAnalysis,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get productivity patterns analysis
  Future<Map<String, dynamic>> _getProductivityPatterns(
    DateTime start, 
    DateTime end,
  ) async {
    final db = await DatabaseHelper.instance.database;
    
    // Hourly productivity distribution
    final hourlyResult = await db.rawQuery('''
      SELECT 
        strftime('%H', start_time) as hour,
        COUNT(*) as session_count,
        AVG(actual_duration) as avg_duration
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ? AND is_completed = 1
      GROUP BY strftime('%H', start_time)
      ORDER BY hour
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Daily productivity trends
    final dailyResult = await db.rawQuery('''
      SELECT 
        date(start_time) as date,
        COUNT(*) as session_count,
        SUM(actual_duration) as total_duration
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ? AND is_completed = 1
      GROUP BY date(start_time)
      ORDER BY date
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Weekly patterns
    final weeklyResult = await db.rawQuery('''
      SELECT 
        strftime('%w', start_time) as day_of_week,
        COUNT(*) as session_count,
        AVG(actual_duration) as avg_duration
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ? AND is_completed = 1
      GROUP BY strftime('%w', start_time)
      ORDER BY day_of_week
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    return {
      'hourly_distribution': hourlyResult,
      'daily_trends': dailyResult,
      'weekly_patterns': weeklyResult,
    };
  }

  /// Get performance metrics
  Future<Map<String, dynamic>> _getPerformanceMetrics(
    DateTime start, 
    DateTime end,
  ) async {
    final db = await DatabaseHelper.instance.database;
    
    // Session completion rate
    final completionRateResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sessions,
        SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_sessions
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ?
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Average session duration
    final avgDurationResult = await db.rawQuery('''
      SELECT 
        AVG(actual_duration) as avg_duration,
        MIN(actual_duration) as min_duration,
        MAX(actual_duration) as max_duration
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ? AND is_completed = 1
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Focus efficiency (work sessions vs breaks)
    final focusEfficiencyResult = await db.rawQuery('''
      SELECT 
        session_type,
        COUNT(*) as count,
        AVG(actual_duration) as avg_duration
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ? AND is_completed = 1
      GROUP BY session_type
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    final completionData = completionRateResult.first;
    final totalSessions = completionData['total_sessions'] as int;
    final completedSessions = completionData['completed_sessions'] as int;
    final completionRate = totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0.0;
    
    return {
      'completion_rate': completionRate,
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'avg_duration': avgDurationResult.first['avg_duration'] as double? ?? 0.0,
      'min_duration': avgDurationResult.first['min_duration'] as int? ?? 0,
      'max_duration': avgDurationResult.first['max_duration'] as int? ?? 0,
      'focus_efficiency': focusEfficiencyResult,
    };
  }

  /// Get focus analysis
  Future<Map<String, dynamic>> _getFocusAnalysis(
    DateTime start, 
    DateTime end,
  ) async {
    final db = await DatabaseHelper.instance.database;
    
    // Deep work sessions (longer than 20 minutes)
    final deepWorkResult = await db.rawQuery('''
      SELECT COUNT(*) as deep_work_sessions
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ? 
        AND session_type = 'work' 
        AND is_completed = 1 
        AND actual_duration >= 1200
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Break efficiency
    final breakEfficiencyResult = await db.rawQuery('''
      SELECT 
        session_type,
        AVG(actual_duration) as avg_duration,
        COUNT(*) as count
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ? 
        AND session_type IN ('shortBreak', 'longBreak')
        AND is_completed = 1
      GROUP BY session_type
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Focus streaks (consecutive work sessions)
    final focusStreaksResult = await db.rawQuery('''
      WITH work_sessions AS (
        SELECT start_time, ROW_NUMBER() OVER (ORDER BY start_time) as rn
        FROM sessions 
        WHERE start_time >= ? AND start_time <= ? 
          AND session_type = 'work' 
          AND is_completed = 1
      )
      SELECT MAX(streak_length) as max_streak
      FROM (
        SELECT COUNT(*) as streak_length
        FROM work_sessions
        GROUP BY DATE(start_time, '-' || (rn - ROW_NUMBER() OVER (ORDER BY start_time)) || ' days')
      )
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    return {
      'deep_work_sessions': deepWorkResult.first['deep_work_sessions'] as int,
      'break_efficiency': breakEfficiencyResult,
      'max_focus_streak': focusStreaksResult.first['max_streak'] as int? ?? 0,
    };
  }

  /// Get basic statistics
  Future<Map<String, dynamic>> _getBasicStatistics(
    DateTime start, 
    DateTime end,
  ) async {
    final db = await DatabaseHelper.instance.database;
    
    // Total work time
    final workTimeResult = await db.rawQuery('''
      SELECT SUM(actual_duration) as total_work_time
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ? 
        AND session_type = 'work' 
        AND is_completed = 1
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Total sessions
    final totalSessionsResult = await db.rawQuery('''
      SELECT COUNT(*) as total_sessions
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ?
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Completed tasks
    final completedTasksResult = await db.rawQuery('''
      SELECT COUNT(*) as completed_tasks
      FROM tasks 
      WHERE updated_at >= ? AND updated_at <= ? AND is_completed = 1
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // Pomodoro cycles
    final cyclesResult = await db.rawQuery('''
      SELECT COUNT(*) as total_cycles
      FROM pomodoro_cycles 
      WHERE created_at >= ? AND created_at <= ?
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    return {
      'total_work_time': workTimeResult.first['total_work_time'] as int? ?? 0,
      'total_sessions': totalSessionsResult.first['total_sessions'] as int,
      'completed_tasks': completedTasksResult.first['completed_tasks'] as int,
      'total_cycles': cyclesResult.first['total_cycles'] as int,
    };
  }

  // ==================== REAL-TIME MONITORING ====================

  /// Get real-time productivity metrics
  Future<Map<String, dynamic>> getRealTimeMetrics() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfDay = today;
    final endOfDay = today.add(const Duration(days: 1));
    
    final db = await DatabaseHelper.instance.database;
    
    // Today's sessions
    final todaySessionsResult = await db.rawQuery('''
      SELECT COUNT(*) as today_sessions
      FROM sessions 
      WHERE start_time >= ? AND start_time < ?
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);
    
    // Today's work time
    final todayWorkTimeResult = await db.rawQuery('''
      SELECT SUM(actual_duration) as today_work_time
      FROM sessions 
      WHERE start_time >= ? AND start_time < ? 
        AND session_type = 'work' 
        AND is_completed = 1
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);
    
    // Current active session
    final activeSessionResult = await db.rawQuery('''
      SELECT * FROM sessions 
      WHERE start_time IS NOT NULL AND end_time IS NULL AND is_completed = 0
      ORDER BY start_time DESC LIMIT 1
    ''');
    
    // Current cycle
    final currentCycle = await DatabaseHelper.instance.getActivePomodoroCycle();
    
    return {
      'today_sessions': todaySessionsResult.first['today_sessions'] as int,
      'today_work_time': todayWorkTimeResult.first['today_work_time'] as int? ?? 0,
      'active_session': activeSessionResult.isNotEmpty ? activeSessionResult.first : null,
      'current_cycle': currentCycle?.toMap(),
      'timestamp': now.toIso8601String(),
    };
  }

  // ==================== PREDICTIVE ANALYTICS ====================

  /// Get productivity predictions
  Future<Map<String, dynamic>> getProductivityPredictions() async {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    
    final db = await DatabaseHelper.instance.database;
    
    // Average daily productivity
    final avgDailyResult = await db.rawQuery('''
      SELECT 
        AVG(daily_work_time) as avg_daily_work_time,
        AVG(daily_sessions) as avg_daily_sessions
      FROM (
        SELECT 
          date(start_time) as work_date,
          SUM(CASE WHEN session_type = 'work' AND is_completed = 1 THEN actual_duration ELSE 0 END) as daily_work_time,
          COUNT(*) as daily_sessions
        FROM sessions 
        WHERE start_time >= ? AND start_time <= ?
        GROUP BY date(start_time)
      )
    ''', [last30Days.toIso8601String(), now.toIso8601String()]);
    
    // Productivity trend
    final trendResult = await db.rawQuery('''
      SELECT 
        date(start_time) as work_date,
        SUM(CASE WHEN session_type = 'work' AND is_completed = 1 THEN actual_duration ELSE 0 END) as daily_work_time
      FROM sessions 
      WHERE start_time >= ? AND start_time <= ?
      GROUP BY date(start_time)
      ORDER BY work_date DESC
      LIMIT 7
    ''', [now.subtract(const Duration(days: 7)).toIso8601String(), now.toIso8601String()]);
    
    final avgData = avgDailyResult.first;
    final avgDailyWorkTime = avgData['avg_daily_work_time'] as double? ?? 0.0;
    final avgDailySessions = avgData['avg_daily_sessions'] as double? ?? 0.0;
    
    // Calculate trend
    double trend = 0.0;
    if (trendResult.length >= 2) {
      final recent = trendResult.first['daily_work_time'] as int? ?? 0;
      final previous = trendResult[1]['daily_work_time'] as int? ?? 0;
      if (previous > 0) {
        trend = ((recent - previous) / previous) * 100;
      }
    }
    
    return {
      'avg_daily_work_time': avgDailyWorkTime,
      'avg_daily_sessions': avgDailySessions,
      'productivity_trend': trend,
      'predicted_weekly_work_time': avgDailyWorkTime * 7,
      'confidence_level': _calculateConfidenceLevel(trendResult.length),
    };
  }

  /// Calculate confidence level for predictions
  double _calculateConfidenceLevel(int dataPoints) {
    if (dataPoints >= 30) return 0.95;
    if (dataPoints >= 14) return 0.85;
    if (dataPoints >= 7) return 0.70;
    return 0.50;
  }

  // ==================== EXPORT/IMPORT ====================

  /// Export analytics data
  Future<Map<String, dynamic>> exportAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    // Export all data
    final tasks = await DatabaseHelper.instance.getAllTasks();
    final sessions = await DatabaseHelper.instance.getAllSessions();
    final cycles = await DatabaseHelper.instance.getAllPomodoroCycles();
    
    return {
      'export_info': {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'period': {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
      },
      'data': {
        'tasks': tasks.map((task) => task.toMap()).toList(),
        'sessions': sessions.map((session) => session.toMap()).toList(),
        'cycles': cycles.map((cycle) => cycle.toMap()).toList(),
      },
    };
  }
}
