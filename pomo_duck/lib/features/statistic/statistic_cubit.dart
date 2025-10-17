import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/core/cache/smart_cache_manager.dart';
import 'package:pomo_duck/core/data_coordinator/hybrid_data_coordinator.dart';

part 'statistic_state.dart';

class StatisticCubit extends Cubit<StatisticState> {
  StatisticCubit() : super(StatisticInitial()) {
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      emit(StatisticLoading());

      // Parallel loads (simple sequencing here for readability)
      final todayStats = await HybridDataCoordinator.instance.getTodayStatistics();
      final overallStats = await HybridDataCoordinator.instance.getOverallStatistics();
      final analytics = await SmartCacheManager.instance.getAnalytics();
      final realtime = await SmartCacheManager.instance.getRealTimeMetrics();
      final predictions = await SmartCacheManager.instance.getProductivityPredictions();

      emit(StatisticLoaded(
        todayStats: todayStats,
        overallStats: overallStats,
        analytics: analytics,
        realtime: realtime,
        predictions: predictions,
      ));
    } catch (e) {
      emit(StatisticError('Failed to load statistics: $e'));
    }
  }
}
