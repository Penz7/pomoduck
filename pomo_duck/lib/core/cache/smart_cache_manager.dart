import 'dart:async';
import 'package:flutter/foundation.dart';
import '../local_storage/hive_data_manager.dart';
import '../analytics/analytics_engine.dart';

/// Smart Cache Manager - Intelligent caching với adaptive strategies
/// Tối ưu cache performance dựa trên usage patterns
class SmartCacheManager {
  static final SmartCacheManager _instance = SmartCacheManager._internal();
  static SmartCacheManager get instance => _instance;
  
  SmartCacheManager._internal();

  Timer? _cleanupTimer;
  final Map<String, CacheEntry> _cache = {};
  final Map<String, int> _accessCounts = {};
  final Map<String, DateTime> _lastAccess = {};

  // ==================== CACHE CONFIGURATION ====================

  static const Duration _defaultTTL = Duration(minutes: 5);
  static const Duration _cleanupInterval = Duration(minutes: 10);
  static const int _maxCacheSize = 100;
  static const double _hitRateThreshold = 0.8;

  /// Initialize smart cache
  void initialize() {
    _startCleanupTimer();
    debugPrint('🧠 Smart Cache Manager initialized');
  }

  /// Dispose cache manager
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    _accessCounts.clear();
    _lastAccess.clear();
    debugPrint('🧠 Smart Cache Manager disposed');
  }

  // ==================== CACHE OPERATIONS ====================

  /// Get data from cache with smart strategy
  Future<T?> get<T>(String key, {Duration? ttl}) async {
    final now = DateTime.now();
    
    // Check if key exists and is not expired
    if (_cache.containsKey(key)) {
      final entry = _cache[key]!;
      
      if (entry.isExpired(ttl ?? _defaultTTL)) {
        _cache.remove(key);
        _accessCounts.remove(key);
        _lastAccess.remove(key);
        return null;
      }
      
      // Update access tracking
      _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;
      _lastAccess[key] = now;
      
      return entry.data as T?;
    }
    
    return null;
  }

  /// Set data in cache with smart strategy
  Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    final now = DateTime.now();
    
    // Check cache size limit
    if (_cache.length >= _maxCacheSize) {
      await _evictLeastUsed();
    }
    
    // Store in cache
    _cache[key] = CacheEntry(
      data: data,
      createdAt: now,
      ttl: ttl ?? _defaultTTL,
    );
    
    _accessCounts[key] = 1;
    _lastAccess[key] = now;
    
    debugPrint('🧠 Cached: $key');
  }

  /// Get or compute data with smart caching
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
  }) async {
    // Try to get from cache first
    final cached = await get<T>(key, ttl: ttl);
    if (cached != null) {
      return cached;
    }
    
    // Compute and cache
    final data = await compute();
    await set(key, data, ttl: ttl);
    return data;
  }

  /// Invalidate cache entry
  void invalidate(String key) {
    _cache.remove(key);
    _accessCounts.remove(key);
    _lastAccess.remove(key);
    debugPrint('🧠 Invalidated: $key');
  }

  /// Invalidate cache pattern
  void invalidatePattern(String pattern) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(pattern))
        .toList();
    
    for (final key in keysToRemove) {
      invalidate(key);
    }
    
    debugPrint('🧠 Invalidated pattern: $pattern (${keysToRemove.length} entries)');
  }

  // ==================== SMART STRATEGIES ====================

  /// Get analytics data with smart caching
  Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final key = 'analytics_${startDate?.toIso8601String() ?? 'all'}_${endDate?.toIso8601String() ?? 'now'}';
    
    return await getOrCompute(
      key,
      () => AnalyticsEngine.instance.getProductivityAnalytics(
        startDate: startDate,
        endDate: endDate,
      ),
      ttl: const Duration(minutes: 15), // Analytics cache for 15 minutes
    );
  }

  /// Get real-time metrics with smart caching
  Future<Map<String, dynamic>> getRealTimeMetrics() async {
    const key = 'realtime_metrics';
    
    return await getOrCompute(
      key,
      () => AnalyticsEngine.instance.getRealTimeMetrics(),
      ttl: const Duration(seconds: 30), // Real-time cache for 30 seconds
    );
  }

  /// Get productivity predictions with smart caching
  Future<Map<String, dynamic>> getProductivityPredictions() async {
    const key = 'productivity_predictions';
    
    return await getOrCompute(
      key,
      () => AnalyticsEngine.instance.getProductivityPredictions(),
      ttl: const Duration(hours: 1), // Predictions cache for 1 hour
    );
  }

  /// Get today's statistics with smart caching
  Future<Map<String, dynamic>> getTodayStatistics() async {
    const key = 'today_stats';
    
    return await getOrCompute(
      key,
      () async {
        final stats = HiveDataManager.getTodayStats();
        return stats != null ? Map<String, dynamic>.from(stats) : <String, dynamic>{};
      },
      ttl: const Duration(minutes: 5), // Today stats cache for 5 minutes
    );
  }

  /// Get recent tasks with smart caching
  Future<List<Map<String, dynamic>>> getRecentTasks() async {
    const key = 'recent_tasks';
    
    return await getOrCompute(
      key,
      () async {
        final tasks = HiveDataManager.getRecentTasks();
        return tasks?.map((task) => Map<String, dynamic>.from(task)).toList() ?? [];
      },
      ttl: const Duration(minutes: 10), // Recent tasks cache for 10 minutes
    );
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Start cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      _cleanupExpiredEntries();
      _optimizeCache();
    });
  }

  /// Cleanup expired entries
  void _cleanupExpiredEntries() {
    final expiredKeys = <String>[];
    
    for (final entry in _cache.entries) {
      if (entry.value.isExpired(_defaultTTL)) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      invalidate(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      debugPrint('🧠 Cleaned up ${expiredKeys.length} expired entries');
    }
  }

  /// Optimize cache based on usage patterns
  void _optimizeCache() {
    if (_cache.length <= _maxCacheSize * 0.8) return;
    
    // Calculate hit rates
    final hitRates = <String, double>{};
    for (final key in _cache.keys) {
      final accessCount = _accessCounts[key] ?? 0;
      final age = DateTime.now().difference(_lastAccess[key] ?? DateTime.now()).inMinutes;
      hitRates[key] = accessCount / (age + 1); // Avoid division by zero
    }
    
    // Remove low-hit-rate entries
    final sortedEntries = hitRates.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    final toRemove = sortedEntries.take(_cache.length - _maxCacheSize).map((e) => e.key).toList();
    
    for (final key in toRemove) {
      invalidate(key);
    }
    
    if (toRemove.isNotEmpty) {
      debugPrint('🧠 Optimized cache: removed ${toRemove.length} low-hit-rate entries');
    }
  }

  /// Evict least used entries
  Future<void> _evictLeastUsed() async {
    if (_cache.isEmpty) return;
    
    // Sort by access count and last access time
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) {
        final aCount = _accessCounts[a.key] ?? 0;
        final bCount = _accessCounts[b.key] ?? 0;
        
        if (aCount != bCount) {
          return aCount.compareTo(bCount);
        }
        
        final aLastAccess = _lastAccess[a.key] ?? DateTime(1970);
        final bLastAccess = _lastAccess[b.key] ?? DateTime(1970);
        return aLastAccess.compareTo(bLastAccess);
      });
    
    // Remove 20% of least used entries
    final toRemove = sortedEntries.take((_cache.length * 0.2).ceil()).map((e) => e.key).toList();
    
    for (final key in toRemove) {
      invalidate(key);
    }
    
    debugPrint('🧠 Evicted ${toRemove.length} least used entries');
  }

  // ==================== CACHE STATISTICS ====================

  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    final totalHits = _accessCounts.values.fold(0, (sum, count) => sum + count);
    final totalEntries = _cache.length;
    final avgHitRate = totalEntries > 0 ? totalHits / totalEntries : 0.0;
    
    return {
      'total_entries': totalEntries,
      'total_hits': totalHits,
      'average_hit_rate': avgHitRate,
      'cache_size_mb': _estimateCacheSize(),
      'hit_rate_status': avgHitRate > _hitRateThreshold ? 'excellent' : 'needs_optimization',
      'most_accessed': _getMostAccessedKeys(),
      'least_accessed': _getLeastAccessedKeys(),
    };
  }

  /// Estimate cache size in MB
  double _estimateCacheSize() {
    // Rough estimation based on entry count
    return _cache.length * 0.001; // Assume 1KB per entry
  }

  /// Get most accessed keys
  List<String> _getMostAccessedKeys() {
    final sorted = _accessCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  /// Get least accessed keys
  List<String> _getLeastAccessedKeys() {
    final sorted = _accessCounts.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  /// Clear all cache
  void clearAll() {
    _cache.clear();
    _accessCounts.clear();
    _lastAccess.clear();
    debugPrint('🧠 All cache cleared');
  }
}

/// Cache entry data class
class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.ttl,
  });

  bool isExpired(Duration maxTTL) {
    final now = DateTime.now();
    final effectiveTTL = ttl.compareTo(maxTTL) < 0 ? ttl : maxTTL;
    return now.difference(createdAt) > effectiveTTL;
  }
}
