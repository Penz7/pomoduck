import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../local_storage/hive_data_manager.dart';
import '../../data/database/database_helper.dart';

/// Performance Monitor - Real-time performance tracking
/// Monitor app performance, memory usage, và database operations
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  static PerformanceMonitor get instance => _instance;
  
  PerformanceMonitor._internal();

  Timer? _monitoringTimer;
  final List<PerformanceMetric> _metrics = [];
  bool _isMonitoring = false;

  // ==================== PERFORMANCE METRICS ====================

  /// Start performance monitoring
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(interval, (timer) {
      _collectMetrics();
    });
    
    debugPrint('📊 Performance monitoring started');
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
    
    debugPrint('📊 Performance monitoring stopped');
  }

  /// Collect performance metrics
  Future<void> _collectMetrics() async {
    try {
      final metric = PerformanceMetric(
        timestamp: DateTime.now(),
        memoryUsage: await _getMemoryUsage(),
        databasePerformance: await _getDatabasePerformance(),
        hivePerformance: await _getHivePerformance(),
        appPerformance: await _getAppPerformance(),
      );
      
      _metrics.add(metric);
      
      // Keep only last 100 metrics
      if (_metrics.length > 100) {
        _metrics.removeAt(0);
      }
      
      // Log performance issues
      _checkPerformanceThresholds(metric);
      
    } catch (e) {
      debugPrint('❌ Error collecting performance metrics: $e');
    }
  }

  /// Get memory usage
  Future<Map<String, dynamic>> _getMemoryUsage() async {
    try {
      // Get memory info (platform specific)
      final memoryInfo = await _getPlatformMemoryInfo();
      
      return {
        'total_memory': memoryInfo['total'],
        'used_memory': memoryInfo['used'],
        'free_memory': memoryInfo['free'],
        'memory_pressure': memoryInfo['pressure'],
      };
    } catch (e) {
      return {
        'total_memory': 0,
        'used_memory': 0,
        'free_memory': 0,
        'memory_pressure': 'unknown',
      };
    }
  }

  /// Get platform-specific memory info
  Future<Map<String, dynamic>> _getPlatformMemoryInfo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile platforms
      return {
        'total': 4000000000, // 4GB assumed
        'used': 2000000000, // 2GB assumed
        'free': 2000000000, // 2GB assumed
        'pressure': 'normal',
      };
    } else {
      // Desktop/Web platforms
      return {
        'total': 8000000000, // 8GB assumed
        'used': 4000000000, // 4GB assumed
        'free': 4000000000, // 4GB assumed
        'pressure': 'normal',
      };
    }
  }

  /// Get database performance metrics
  Future<Map<String, dynamic>> _getDatabasePerformance() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Test database query performance
      final db = await DatabaseHelper.instance.database;
      await db.rawQuery('SELECT COUNT(*) FROM tasks');
      await db.rawQuery('SELECT COUNT(*) FROM sessions');
      await db.rawQuery('SELECT COUNT(*) FROM pomodoro_cycles');
      
      stopwatch.stop();
      
      return {
        'query_time_ms': stopwatch.elapsedMilliseconds,
        'status': 'healthy',
        'connection_pool': 'active',
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'query_time_ms': stopwatch.elapsedMilliseconds,
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Get Hive performance metrics
  Future<Map<String, dynamic>> _getHivePerformance() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Test Hive operations
      HiveDataManager.getSettings();
      HiveDataManager.getCurrentTimerState();
      HiveDataManager.getUserPreferences();
      
      stopwatch.stop();
      
      return {
        'operation_time_ms': stopwatch.elapsedMilliseconds,
        'status': 'healthy',
        'cache_hit_rate': 0.85, // Simulated
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'operation_time_ms': stopwatch.elapsedMilliseconds,
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Get app performance metrics
  Future<Map<String, dynamic>> _getAppPerformance() async {
    return {
      'fps': 60, // Simulated
      'frame_drops': 0,
      'ui_thread_blocking': false,
      'gc_pressure': 'low',
    };
  }

  /// Check performance thresholds
  void _checkPerformanceThresholds(PerformanceMetric metric) {
    // Database performance check
    if (metric.databasePerformance['query_time_ms'] > 1000) {
      debugPrint('⚠️ Database performance warning: ${metric.databasePerformance['query_time_ms']}ms');
    }
    
    // Hive performance check
    if (metric.hivePerformance['operation_time_ms'] > 10) {
      debugPrint('⚠️ Hive performance warning: ${metric.hivePerformance['operation_time_ms']}ms');
    }
    
    // Memory pressure check
    final memoryPressure = metric.memoryUsage['memory_pressure'] as String;
    if (memoryPressure == 'high') {
      debugPrint('⚠️ High memory pressure detected');
    }
  }

  // ==================== PERFORMANCE REPORTS ====================

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (_metrics.isEmpty) {
      return {
        'status': 'no_data',
        'message': 'No performance data available',
      };
    }
    
    final recentMetrics = _metrics.length > 10 ? _metrics.sublist(_metrics.length - 10) : _metrics;
    
    // Calculate averages
    final avgDbTime = recentMetrics
        .map((m) => m.databasePerformance['query_time_ms'] as int)
        .reduce((a, b) => a + b) / recentMetrics.length;
    
    final avgHiveTime = recentMetrics
        .map((m) => m.hivePerformance['operation_time_ms'] as int)
        .reduce((a, b) => a + b) / recentMetrics.length;
    
    // Performance status
    String status = 'excellent';
    if (avgDbTime > 500 || avgHiveTime > 5) {
      status = 'good';
    }
    if (avgDbTime > 1000 || avgHiveTime > 10) {
      status = 'poor';
    }
    
    return {
      'status': status,
      'metrics_count': _metrics.length,
      'monitoring_duration': _getMonitoringDuration(),
      'average_database_time_ms': avgDbTime.round(),
      'average_hive_time_ms': avgHiveTime.round(),
      'performance_trend': _getPerformanceTrend(),
      'recommendations': _getRecommendations(avgDbTime, avgHiveTime),
    };
  }

  /// Get performance trend
  String _getPerformanceTrend() {
    if (_metrics.length < 2) return 'stable';
    
    final recent = _metrics.length > 5 ? _metrics.sublist(_metrics.length - 5) : _metrics;
    final older = _metrics.length > 10 ? _metrics.sublist(0, 5) : _metrics.take(5).toList();
    
    if (recent.length < 2 || older.length < 2) return 'stable';
    
    final recentAvg = recent
        .map((m) => m.databasePerformance['query_time_ms'] as int)
        .reduce((a, b) => a + b) / recent.length;
    
    final olderAvg = older
        .map((m) => m.databasePerformance['query_time_ms'] as int)
        .reduce((a, b) => a + b) / older.length;
    
    if (recentAvg > olderAvg * 1.2) return 'degrading';
    if (recentAvg < olderAvg * 0.8) return 'improving';
    return 'stable';
  }

  /// Get monitoring duration
  Duration _getMonitoringDuration() {
    if (_metrics.isEmpty) return Duration.zero;
    
    final first = _metrics.first.timestamp;
    final last = _metrics.last.timestamp;
    return last.difference(first);
  }

  /// Get performance recommendations
  List<String> _getRecommendations(double avgDbTime, double avgHiveTime) {
    final recommendations = <String>[];
    
    if (avgDbTime > 1000) {
      recommendations.add('Consider database optimization');
    }
    
    if (avgHiveTime > 10) {
      recommendations.add('Consider Hive cache optimization');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Performance is optimal');
    }
    
    return recommendations;
  }

  /// Get detailed performance report
  Map<String, dynamic> getDetailedReport() {
    return {
      'summary': getPerformanceSummary(),
      'metrics': _metrics.map((m) => m.toMap()).toList(),
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Clear performance metrics
  void clearMetrics() {
    _metrics.clear();
    debugPrint('📊 Performance metrics cleared');
  }
}

/// Performance metric data class
class PerformanceMetric {
  final DateTime timestamp;
  final Map<String, dynamic> memoryUsage;
  final Map<String, dynamic> databasePerformance;
  final Map<String, dynamic> hivePerformance;
  final Map<String, dynamic> appPerformance;

  PerformanceMetric({
    required this.timestamp,
    required this.memoryUsage,
    required this.databasePerformance,
    required this.hivePerformance,
    required this.appPerformance,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'memory_usage': memoryUsage,
      'database_performance': databasePerformance,
      'hive_performance': hivePerformance,
      'app_performance': appPerformance,
    };
  }
}
