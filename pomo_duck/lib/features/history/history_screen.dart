import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/data/models/session_model.dart';
import 'package:pomo_duck/data/models/task_model.dart';

import 'history_cubit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('History'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    context.read<HistoryCubit>().refresh();
                  },
                  icon: const Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is HistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading history',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HistoryCubit>().refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is HistoryLoaded) {
              return RefreshIndicator(
                onRefresh: () => context.read<HistoryCubit>().refresh(),
                child: CustomScrollView(
                  slivers: [
                    // Statistics header
                    SliverToBoxAdapter(
                      child: _buildStatisticsHeader(context, state),
                    ),
                    // Timeline
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    // Timeline items
                    if (state.timelineItems.isEmpty)
                      SliverToBoxAdapter(
                        child: _buildEmptyState(context),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = state.timelineItems[index];
                            return _buildTimelineItem(context, item, index, state.timelineItems.length);
                          },
                          childCount: state.timelineItems.length,
                        ),
                      ),
                  ],
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Build statistics header
  Widget _buildStatisticsHeader(BuildContext context, HistoryLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tasks',
                  '${state.completedTasks}/${state.totalTasks}',
                  Icons.task_alt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Sessions',
                  '${state.completedSessions}/${state.totalSessions}',
                  Icons.timer,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first Pomodoro session to see your history here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build timeline item
  Widget _buildTimelineItem(BuildContext context, TimelineItem item, int index, int totalItems) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.isCompleted ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              if (index < totalItems - 1)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: _buildTimelineContent(context, item),
          ),
        ],
      ),
    );
  }

  /// Build timeline content based on item type
  Widget _buildTimelineContent(BuildContext context, TimelineItem item) {
    if (item.type == TimelineItemType.task && item.task != null) {
      return _buildTaskItem(context, item.task!);
    } else if (item.type == TimelineItemType.session && item.session != null) {
      return _buildSessionItem(context, item.session!);
    }
    return const SizedBox.shrink();
  }

  /// Build task timeline item
  Widget _buildTaskItem(BuildContext context, TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.task_alt,
                color: task.isCompleted ? Colors.green : Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? Colors.green : Colors.grey.shade800,
                  ),
                ),
              ),
              if (task.tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.tag!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Pomodoros: ${task.completedPomodoros}/${task.estimatedPomodoros}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateTime(task.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build session timeline item
  Widget _buildSessionItem(BuildContext context, SessionModel session) {
    final duration = session.actualDuration ?? session.plannedDuration;
    final durationText = _formatDuration(duration);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSessionIcon(session.sessionType),
                color: _getSessionColor(session.sessionType),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getSessionTitle(session.sessionType),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: session.isCompleted ? Colors.green : Colors.grey.shade800,
                  ),
                ),
              ),
              if (session.tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSessionColor(session.sessionType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session.tag!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getSessionColor(session.sessionType),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Duration: $durationText',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateTime(session.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          if (session.startTime != null && session.endTime != null) ...[
            const SizedBox(height: 4),
            Text(
              '${_formatTime(session.startTime!)} - ${_formatTime(session.endTime!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get session icon based on type
  IconData _getSessionIcon(SessionType type) {
    switch (type) {
      case SessionType.work:
        return Icons.work;
      case SessionType.shortBreak:
        return Icons.coffee;
      case SessionType.longBreak:
        return Icons.restaurant;
    }
  }

  /// Get session color based on type
  Color _getSessionColor(SessionType type) {
    switch (type) {
      case SessionType.work:
        return Colors.blue;
      case SessionType.shortBreak:
        return Colors.orange;
      case SessionType.longBreak:
        return Colors.green;
    }
  }

  /// Get session title based on type
  String _getSessionTitle(SessionType type) {
    switch (type) {
      case SessionType.work:
        return 'Work Session';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  /// Format duration in seconds to readable format
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Format DateTime to readable string
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (dateOnly == today) {
      return 'Today ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';
    }
  }

  /// Format time to HH:mm format
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
