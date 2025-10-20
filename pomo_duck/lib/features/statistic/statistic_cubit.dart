import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pomo_duck/core/data_coordinator/hybrid_data_coordinator.dart';

part 'statistic_state.dart';

class StatisticCubit extends Cubit<StatisticState> {
  StatisticCubit() : super(StatisticInitial()) {
    loadRolling30Days();
  }

  /// Load thống kê với filter theo thời gian
  Future<void> loadStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String periodType = 'custom', // mặc định dùng khoảng tùy chỉnh (30 ngày)
  }) async {
    try {
      emit(StatisticLoading());

      // Lấy thống kê tổng hợp với filter
      final comprehensiveStats = await HybridDataCoordinator.instance.getComprehensiveStatistics(
        startDate: startDate,
        endDate: endDate,
        periodType: periodType,
      );

      emit(StatisticLoaded(
        overview: comprehensiveStats['overview'] as Map<String, dynamic>,
        dailyStats: comprehensiveStats['daily_stats'] as List<Map<String, dynamic>>,
        weeklyStats: comprehensiveStats['weekly_stats'] as List<Map<String, dynamic>>,
        monthlyStats: comprehensiveStats['monthly_stats'] as List<Map<String, dynamic>>,
        sessionPatterns: comprehensiveStats['session_patterns'] as Map<String, dynamic>,
        periodInfo: comprehensiveStats['period_info'] as Map<String, dynamic>,
      ));
    } catch (e) {
      // vn: Lỗi khi tải thống kê
      emit(StatisticError('stats_load_failed'.tr(args: [e.toString()])));
    }
  }

  /// Load 30 ngày gần nhất (tính từ hôm nay lùi về 30 ngày)
  Future<void> loadRolling30Days() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
    final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    await loadStatistics(startDate: start, endDate: end, periodType: 'custom');
  }

  /// Load thống kê theo ngày
  Future<void> loadTodayStatistics() async {
    await loadRolling30Days();
  }

  /// Load thống kê theo tuần
  Future<void> loadWeeklyStatistics() async {
    await loadRolling30Days();
  }

  /// Load thống kê theo tháng
  Future<void> loadMonthlyStatistics() async {
    await loadRolling30Days();
  }

  /// Load thống kê với khoảng thời gian tùy chỉnh
  Future<void> loadCustomStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await loadStatistics(
      startDate: startDate,
      endDate: endDate,
      periodType: 'custom',
    );
  }

  /// Refresh thống kê hiện tại
  Future<void> refreshStatistics() async {
    if (state is StatisticLoaded) {
      final currentState = state as StatisticLoaded;
      final periodInfo = currentState.periodInfo;
      final periodType = periodInfo['period_type'] as String;
      
      if (periodType == 'custom') {
        final startDate = DateTime.parse(periodInfo['start_date'] as String);
        final endDate = DateTime.parse(periodInfo['end_date'] as String);
        await loadCustomStatistics(startDate: startDate, endDate: endDate);
      } else {
        await loadRolling30Days();
      }
    } else {
      await loadRolling30Days();
    }
  }
}
