import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pomo_duck/common/extensions/context_extension.dart';
import 'package:pomo_duck/common/utils/time_format.dart';
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
          centerTitle: true,
          title: Text(LocaleKeys.history.tr()),
          backgroundColor: Colors.white,
          elevation: 0,
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
                        padding: EdgeInsets.only(top: 8, bottom: context.bottomPadding),
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
}

Widget _buildTaskRow(BuildContext context, TaskModel task) {
  return _ExpandableTaskRow(task: task);
}

/// Widget expandable cho task row với dropdown timeline
class _ExpandableTaskRow extends StatefulWidget {
  const _ExpandableTaskRow({required this.task});

  final TaskModel task;

  @override
  State<_ExpandableTaskRow> createState() => _ExpandableTaskRowState();
}

class _ExpandableTaskRowState extends State<_ExpandableTaskRow>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  List<SessionModel> _sessions = [];
  bool _isLoadingSessions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleExpanded() async {
    if (!_isExpanded) {
      // Load sessions khi expand lần đầu
      if (_sessions.isEmpty && !_isLoadingSessions) {
        setState(() {
          _isLoadingSessions = true;
        });

        try {
          final sessions = await DatabaseHelper.instance
              .getSessionsByTaskId(widget.task.id!);
          setState(() {
            _sessions = sessions;
            _isLoadingSessions = false;
          });
        } catch (e) {
          setState(() {
            _isLoadingSessions = false;
          });
        }
      }
    }

    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        children: [
          // Task header
          ListTile(
    leading: Icon(
              widget.task.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_checked,
              color: widget.task.isCompleted ? Colors.green : Colors.orange,
    ),
    title: Text(
              widget.task.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Row(
      children: [
                if (widget.task.tag != null) ...[
          Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
                    child: Text(
                      widget.task.tag!,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          LocaleKeys.pomodoros_count.tr(namedArgs: {
                    'completed': widget.task.completedPomodoros.toString(),
                    'estimated': widget.task.estimatedPomodoros.toString(),
          }),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    ),
            trailing: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.keyboard_arrow_down),
            ),
            onTap: _toggleExpanded,
          ),

          // Expandable timeline
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: _buildTimelineContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent() {
    if (_isLoadingSessions) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            LocaleKeys.no_sessions_for_task.tr(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Sort sessions theo thời gian
    final sortedSessions = List<SessionModel>.from(_sessions)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return _TaskTimelineWidget(
      task: widget.task,
      sessions: sortedSessions,
    );
  }
}

/// Widget hiển thị timeline với visual progress
class _TaskTimelineWidget extends StatelessWidget {
  const _TaskTimelineWidget({
    required this.task,
    required this.sessions,
  });

  final TaskModel task;
  final List<SessionModel> sessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          const SizedBox(height: 16),

          // Timeline sessions
          _buildTimelineSessions(),

          // Task completion status
          if (!task.isCompleted) _buildIncompleteTaskIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = task.estimatedPomodoros > 0
        ? task.completedPomodoros / task.estimatedPomodoros
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.progress_label.tr(namedArgs: {
                'completed': task.completedPomodoros.toString(),
                'estimated': task.estimatedPomodoros.toString(),
              }),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSessions() {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.timeline_sessions.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...sessions.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          final isLast = index == sessions.length - 1;

          return _TimelineSessionItem(
            session: session,
            isLast: isLast,
            showConnector: !isLast,
          );
        }),
      ],
    );
  }

  Widget _buildIncompleteTaskIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Colors.orange.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LocaleKeys.task_incomplete.tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          Icon(
            Icons.pending_actions,
            color: Colors.orange.shade600,
            size: 16,
          ),
        ],
      ),
    );
  }
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
  const _TimelineSessionItem({
    required this.session,
    this.isLast = false,
    this.showConnector = true,
  });

  final SessionModel session;
  final bool isLast;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final duration = session.actualDuration ?? session.plannedDuration;
    final durationText = TimeFormat.instance.formatDuration(duration);

    Color colorFor(SessionType type) {
      switch (type) {
        case SessionType.work:
          return Colors.blue;
        case SessionType.shortBreak:
          return Colors.orange;
        case SessionType.longBreak:
          return Colors.green;
      }
    }

    IconData iconFor(SessionType type) {
      switch (type) {
        case SessionType.work:
          return Icons.work;
        case SessionType.shortBreak:
          return Icons.coffee;
        case SessionType.longBreak:
          return Icons.restaurant;
      }
    }

    final sessionColor = colorFor(session.sessionType);
    final isCompleted = session.isCompleted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
      decoration: BoxDecoration(
                color: isCompleted ? sessionColor : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? sessionColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : iconFor(session.sessionType),
                size: 12,
                color: isCompleted ? Colors.white : Colors.grey.shade600,
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.only(top: 4),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Session content
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: showConnector ? 16 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? sessionColor.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted
                    ? sessionColor.withOpacity(0.3)
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      iconFor(session.sessionType),
                      color: isCompleted ? sessionColor : Colors.grey.shade600,
                      size: 16,
                    ),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isCompleted ? sessionColor : Colors.grey.shade700,
                        ),
            ),
          ),
          if (session.tag != null)
            Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: sessionColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          session.tag!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: sessionColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      LocaleKeys.duration_label
                          .tr(namedArgs: {'duration': durationText}),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
          const Spacer(),
                    Text(
                      TimeFormat.instance.formatDateTime(session.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
        if (session.startTime != null && session.endTime != null) ...[
          const SizedBox(height: 4),
                  Text(
                    '${TimeFormat.instance.formatTime(session.startTime!)} - ${TimeFormat.instance.formatTime(session.endTime!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
