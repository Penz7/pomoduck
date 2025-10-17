part of 'history_cubit.dart';

@immutable
sealed class HistoryState {}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  HistoryLoaded({
    required this.timelineItems,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalSessions,
    required this.completedSessions,
  });

  final List<TimelineItem> timelineItems;
  final int totalTasks;
  final int completedTasks;
  final int totalSessions;
  final int completedSessions;
}

final class HistoryError extends HistoryState {
  HistoryError(this.message);
  final String message;
}

/// Timeline item cho hiển thị trong history
@immutable
class TimelineItem {
  const TimelineItem({
    required this.type,
    required this.date,
    required this.isCompleted,
    this.task,
    this.session,
  });

  final TimelineItemType type;
  final DateTime date;
  final bool isCompleted;
  final TaskModel? task;
  final SessionModel? session;
}

/// Loại item trong timeline
enum TimelineItemType {
  task,
  session,
}
