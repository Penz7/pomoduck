import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/data/database/database_helper.dart';
import 'package:pomo_duck/data/models/session_model.dart';
import 'package:pomo_duck/data/models/task_model.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitial()) {
    loadHistoryData();
  }

  /// Load tất cả dữ liệu history từ database
  Future<void> loadHistoryData() async {
    try {
      emit(HistoryLoading());
      
      // Load tasks và sessions
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final sessions = await DatabaseHelper.instance.getAllSessions();
      
      // Group sessions theo ngày
      final groupedSessions = _groupSessionsByDate(sessions);
      
      // Tạo timeline items
      final timelineItems = _createTimelineItems(tasks, sessions, groupedSessions);
      
      emit(HistoryLoaded(
        timelineItems: timelineItems,
        totalTasks: tasks.length,
        completedTasks: tasks.where((t) => t.isCompleted).length,
        totalSessions: sessions.length,
        completedSessions: sessions.where((s) => s.isCompleted).length,
      ));
    } catch (e) {
      emit(HistoryError('Failed to load history: $e'));
    }
  }

  /// Refresh dữ liệu history
  Future<void> refresh() async {
    await loadHistoryData();
  }

  /// Group sessions theo ngày
  Map<String, List<SessionModel>> _groupSessionsByDate(List<SessionModel> sessions) {
    final Map<String, List<SessionModel>> grouped = {};
    
    for (final session in sessions) {
      final dateKey = _formatDate(session.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(session);
    }
    
    // Sort sessions trong mỗi ngày theo thời gian
    grouped.forEach((key, value) {
      value.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
    
    return grouped;
  }

  /// Tạo timeline items từ tasks và sessions
  List<TimelineItem> _createTimelineItems(
    List<TaskModel> tasks,
    List<SessionModel> sessions,
    Map<String, List<SessionModel>> groupedSessions,
  ) {
    final List<TimelineItem> items = [];
    
    // Tạo items cho tasks
    for (final task in tasks) {
      items.add(TimelineItem(
        type: TimelineItemType.task,
        task: task,
        date: task.createdAt,
        isCompleted: task.isCompleted,
      ));
    }
    
    // Tạo items cho sessions
    for (final session in sessions) {
      items.add(TimelineItem(
        type: TimelineItemType.session,
        session: session,
        date: session.createdAt,
        isCompleted: session.isCompleted,
      ));
    }
    
    // Sort tất cả items theo thời gian (mới nhất trước)
    items.sort((a, b) => b.date.compareTo(a.date));
    
    return items;
  }

  /// Format date thành string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
