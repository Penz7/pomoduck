import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pomo_duck/data/models/session_model.dart';
import 'package:pomo_duck/data/models/task_model.dart';
import 'package:pomo_duck/data/database/database_helper.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';

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
          title: Text(LocaleKeys.history.tr()),
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
                      LocaleKeys.error_loading_history.tr(),
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
                      child: Text(LocaleKeys.retry.tr()),
                    ),
                  ],
                ),
              );
            }
            
            if (state is HistoryLoaded) {
              // Build unique task list (completed and in-progress)
              final Map<int, TaskModel> taskMap = {};
              for (final item in state.timelineItems) {
                if (item.type == TimelineItemType.task && item.task != null) {
                  final t = item.task!;
                  if (t.id != null) taskMap[t.id!] = t;
                }
              }
          final tasks = taskMap.values.toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

              return RefreshIndicator(
                onRefresh: () => context.read<HistoryCubit>().refresh(),
                child: tasks.isEmpty
                    ? ListView(children: [
                        _buildEmptyState(context),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                        return _buildTaskRow(context, task);
                        },
                      ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Removed statistics UI per new requirements

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
            LocaleKeys.no_history_yet.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.no_history_message.tr(),
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
                LocaleKeys.pomodoros_count.tr(namedArgs: {
                  'completed': task.completedPomodoros.toString(),
                  'estimated': task.estimatedPomodoros.toString(),
                }),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  // Navigate to task timeline detail
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskTimelineScreen(task: task),
                    ),
                  );
                },
                icon: const Icon(Icons.timeline, size: 16),
                label: Text(LocaleKeys.view_timeline.tr()),
              )
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
              const SizedBox(width: 8),
              if (session.taskId != null)
                Text(
                  '#${session.taskId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                LocaleKeys.duration_label.tr(namedArgs: {'duration': durationText}),
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
        return LocaleKeys.work_session.tr();
      case SessionType.shortBreak:
        return LocaleKeys.short_break.tr();
      case SessionType.longBreak:
        return LocaleKeys.long_break.tr();
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
      return LocaleKeys.today_time.tr(namedArgs: {'time': _formatTime(dateTime)});
    } else {
      return LocaleKeys.date_time.tr(namedArgs: {
        'day': dateTime.day.toString(),
        'month': dateTime.month.toString(),
        'time': _formatTime(dateTime),
      });
    }
  }

  /// Format time to HH:mm format
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Compact row item for a task in the history list
Widget _buildTaskRow(BuildContext context, TaskModel task) {
  return ListTile(
    tileColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    leading: Icon(
      task.isCompleted ? Icons.check_circle : Icons.radio_button_checked,
      color: task.isCompleted ? Colors.green : Colors.orange,
    ),
    title: Text(
      task.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Row(
      children: [
        if (task.tag != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(task.tag!, style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          LocaleKeys.pomodoros_count.tr(namedArgs: {
            'completed': task.completedPomodoros.toString(),
            'estimated': task.estimatedPomodoros.toString(),
          }),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () async {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TaskTimelineScreen(task: task)),
      );
    },
  );
}

class TaskTimelineScreen extends StatelessWidget {
  const TaskTimelineScreen({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<SessionModel>>(
        future: DatabaseHelper.instance.getSessionsByTaskId(task.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(LocaleKeys.failed_to_load_timeline.tr()),
            );
          }
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return Center(child: Text(LocaleKeys.no_sessions_for_task.tr()));
          }

          // Sort ascending by time to form a timeline
          sessions.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = sessions[index];
              return _TimelineSessionItem(session: s);
            },
          );
        },
      ),
    );
  }
}

class _TimelineSessionItem extends StatelessWidget {
  const _TimelineSessionItem({required this.session});
  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    final duration = session.actualDuration ?? session.plannedDuration;
    final durationText = _HistoryFormat.formatDuration(duration);

    Color _colorFor(SessionType type) {
      switch (type) {
        case SessionType.work:
          return Colors.blue;
        case SessionType.shortBreak:
          return Colors.orange;
        case SessionType.longBreak:
          return Colors.green;
      }
    }

    IconData _iconFor(SessionType type) {
      switch (type) {
        case SessionType.work:
          return Icons.work;
        case SessionType.shortBreak:
          return Icons.coffee;
        case SessionType.longBreak:
          return Icons.restaurant;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_iconFor(session.sessionType), color: _colorFor(session.sessionType), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              () {
                switch (session.sessionType) {
                  case SessionType.work:
                    return LocaleKeys.work_session.tr();
                  case SessionType.shortBreak:
                    return LocaleKeys.short_break.tr();
                  case SessionType.longBreak:
                    return LocaleKeys.long_break.tr();
                }
              }(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: session.isCompleted ? Colors.green : Colors.grey.shade800),
            ),
          ),
          if (session.tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _colorFor(session.sessionType).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(session.tag!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _colorFor(session.sessionType))),
            ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Text(LocaleKeys.duration_label.tr(namedArgs: {'duration': durationText}), style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const Spacer(),
          Text(_HistoryFormat.formatDateTime(session.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ]),
        if (session.startTime != null && session.endTime != null) ...[
          const SizedBox(height: 4),
          Text('${_HistoryFormat.formatTime(session.startTime!)} - ${_HistoryFormat.formatTime(session.endTime!)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ]),
    );
  }
}

class _HistoryFormat {
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (dateOnly == today) return 'Today ${formatTime(dateTime)}';
    return '${dateTime.day}/${dateTime.month} ${formatTime(dateTime)}';
  }

  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
