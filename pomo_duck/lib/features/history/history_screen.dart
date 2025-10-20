import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pomo_duck/common/extensions/context_extension.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/common/utils/font_size.dart';
import 'package:pomo_duck/common/utils/time_format.dart';
import 'package:pomo_duck/common/widgets/text.dart';
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
          title: LCText.medium(
            LocaleKeys.history,
            fontSize: FontSizes.big,
          ),
          backgroundColor: Colors.white,
          actions: [
            BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () => _showClearHistoryDialog(context),
                  tooltip: 'clear_history'.tr(),
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
                    16.height,
                    LCText.base(
                      LocaleKeys.error_loading_history,
                    ),
                    const SizedBox(height: 8),
                    LCText.base(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    16.height,
                    ElevatedButton(
                      onPressed: () {
                        context.read<HistoryCubit>().refresh();
                      },
                      child: LCText.medium(LocaleKeys.retry),
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
                    ? ListView(
                        children: [
                          _buildEmptyState(context),
                        ],
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: context.bottomPadding,
                        ),
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
          50.height,
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          16.height,
          LCText.base(
            LocaleKeys.no_history_yet,
            color: Colors.grey.shade600,
            fontSize: FontSizes.medium,
          ),
          8.height,
          LCText.base(
            LocaleKeys.no_history_message,
            color: Colors.grey.shade600,
            fontSize: FontSizes.small,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: LCText.bold(LocaleKeys.clear_history, fontSize: FontSizes.big,),
          content: LCText.base(
            LocaleKeys.clear_history_message,
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: LCText.medium(LocaleKeys.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context.read<HistoryCubit>().clearHistory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: LCText.medium(LocaleKeys.clear, color: Colors.white,),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildTaskRow(BuildContext context, TaskModel task) {
  return _ExpandableTaskRow(task: task);
}

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
        borderRadius: BorderRadius.circular(10),
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
          ListTile(
            leading: Icon(
              widget.task.isCompleted ? Icons.check_circle : Icons.close,
              color: Colors.black,
            ),
            title: LCText.base(
              widget.task.title,
              maxLines: 1,
              fontSize: FontSizes.medium,
            ),
            subtitle: Row(
              children: [
                if (widget.task.tag != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: LCText.medium(
                      widget.task.tag!,
                      color: Colors.white,
                      fontSize: FontSizes.extraSmall,
                    ),
                  ),
                  10.width,
                ],
                LCText.base(
                  LocaleKeys.pomodoros_count.tr(namedArgs: {
                    'completed': widget.task.completedPomodoros.toString(),
                    'estimated': widget.task.estimatedPomodoros.toString(),
                  }),
                  fontSize: FontSizes.small,
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
          child: LCText.base(
            LocaleKeys.no_sessions_for_task,
          ),
        ),
      );
    }
    final sortedSessions = List<SessionModel>.from(_sessions)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return _TaskTimelineWidget(
      task: widget.task,
      sessions: sortedSessions,
    );
  }
}

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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          16.height,
          _buildTimelineSessions(),
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
            LCText.medium(
              LocaleKeys.progress_label.tr(namedArgs: {
                'completed': task.completedPomodoros.toString(),
                'estimated': task.estimatedPomodoros.toString(),
              }),
              fontSize: FontSizes.small,
            ),
            LCText.medium(
              '${(progress * 100).toInt()}%',
              fontSize: FontSizes.small,
            ),
          ],
        ),
        8.height,
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.black : Colors.grey.shade300,
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
        LCText.medium(
          LocaleKeys.timeline_sessions,
          fontSize: FontSizes.medium,
        ),
        16.height,
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
          10.width,
          Expanded(
            child: LCText.base(
              LocaleKeys.task_incomplete,
              fontSize: FontSizes.small,
              color: Colors.orange.shade700,
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
              child: LCText.medium(LocaleKeys.failed_to_load_timeline),
            );
          }
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return Center(child: LCText.medium(LocaleKeys.no_sessions_for_task));
          }
          sessions.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => 8.height,
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

    final isCompleted = session.isCompleted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.black : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.black : Colors.grey.shade400,
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
        12.width,
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: showConnector ? 16 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.black.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted
                    ? Colors.black.withOpacity(0.3)
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
                      color: isCompleted ? Colors.black : Colors.grey.shade600,
                      size: 16,
                    ),
                    10.width,
                    Expanded(
                      child: LCText.base(
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
                        fontSize: FontSizes.small,
                      ),
                    ),
                    if (session.tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: LCText.base(
                          session.tag!,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    LCText.base(
                      LocaleKeys.duration_label
                          .tr(namedArgs: {'duration': durationText}),
                      fontSize: FontSizes.extraSmall,
                    ),
                    const Spacer(),
                    LCText.base(
                      TimeFormat.instance.formatDateTime(session.createdAt),
                      fontSize: FontSizes.extraSmall,
                    ),
                  ],
                ),
                if (session.startTime != null && session.endTime != null) ...[
                  LCText.base(
                    '${TimeFormat.instance.formatTime(session.startTime!)} - ${TimeFormat.instance.formatTime(session.endTime!)}',
                    fontSize: FontSizes.extraSmall,
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
