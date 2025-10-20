import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pomo_duck/common/extensions/context_extension.dart';
import 'package:pomo_duck/common/utils/font_size.dart';
import 'package:pomo_duck/common/widgets/text.dart';
import 'package:pomo_duck/features/statistic/statistic_cubit.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return StatisticCubit();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: LCText.medium(
            LocaleKeys.statistic,
            fontSize: FontSizes.big,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'stats_export_pdf'.tr(),
              onPressed: () {
                _showExportPdfComingSoon(context);
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
          ],
        ),
        body: BlocBuilder<StatisticCubit, StatisticState>(
          builder: (context, state) {
            if (state is StatisticLoading || state is StatisticInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StatisticError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<StatisticCubit>().refreshStatistics(),
                      child: Text(LocaleKeys.retry.tr()),
                    )
                  ],
                ),
              );
            }

            final loaded = state as StatisticLoaded;
            final hasData = loaded.overview.isNotEmpty ||
                loaded.dailyStats.isNotEmpty ||
                loaded.weeklyStats.isNotEmpty ||
                loaded.monthlyStats.isNotEmpty;

            if (!hasData) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<StatisticCubit>().refreshStatistics(),
                child: ListView(
                  children: [
                    _buildEmptyState(context),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<StatisticCubit>().refreshStatistics(),
              child: ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: context.bottomPadding,
                ),
                children: [
                  _Section(
                    title: 'stats_overview'.tr(),
                    child: _OverviewGrid(overview: loaded.overview),
                  ),
                  const SizedBox(height: 12),

                  // Daily statistics
                  if (loaded.dailyStats.isNotEmpty)
                    _Section(
                      title: 'stats_daily'.tr(),
                      child: _DailyStatsChart(dailyStats: loaded.dailyStats),
                    ),
                  const SizedBox(height: 12),

                  // Weekly statistics
                  if (loaded.weeklyStats.isNotEmpty)
                    _Section(
                      title: 'stats_weekly'.tr(),
                      child: _WeeklyStatsChart(weeklyStats: loaded.weeklyStats),
                    ),
                  const SizedBox(height: 12),

                  // Monthly statistics
                  if (loaded.monthlyStats.isNotEmpty)
                    _Section(
                      title: 'stats_monthly'.tr(),
                      child:
                          _MonthlyStatsChart(monthlyStats: loaded.monthlyStats),
                    ),
                  const SizedBox(height: 12),

                  // Session patterns
                  if (loaded.sessionPatterns.isNotEmpty)
                    _Section(
                      title: 'stats_patterns'.tr(),
                      child: _SessionPatternsGrid(
                          patterns: loaded.sessionPatterns),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.map});
  final Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) return Text(LocaleKeys.no_data.tr());
    // Normalize values to double and positive range
    final entries = map.entries
        .where((e) => e.value is num)
        .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
        .toList();
    if (entries.isEmpty) return Text(LocaleKeys.no_data.tr());
    final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final barColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    e.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: maxVal > 0
                            ? (e.value / maxVal).clamp(0.0, 1.0)
                            : 0.0,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    e.value.toStringAsFixed(0),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ToggleSection extends StatefulWidget {
  const _ToggleSection({required this.title, required this.map});
  final String title;
  final Map<String, dynamic> map;

  @override
  State<_ToggleSection> createState() => _ToggleSectionState();
}

class _ToggleSectionState extends State<_ToggleSection> {
  bool showChart = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox.shrink()
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: _BarChart(map: widget.map),
        ),
      ],
    );
  }
}

/// Overview grid hiển thị các chỉ số chính
class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.overview});
  final Map<String, dynamic> overview;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: _getOverviewItems().length,
      itemBuilder: (context, index) {
        final item = _getOverviewItems()[index];
        final card = Container(
          decoration: BoxDecoration(
            color: item['color'],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'],
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                item['value'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['label'],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );

        if (item['label'] == 'Điểm hiệu suất') {
          return InkWell(
            onTap: () => _showProductivityScoreDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: card,
          );
        }
        return card;
      },
    );
  }

  List<Map<String, dynamic>> _getOverviewItems() {
    final totalTasks = overview['total_tasks'] as int? ?? 0;
    final completedTasks = overview['completed_tasks'] as int? ?? 0;
    final totalSessions = overview['total_sessions'] as int? ?? 0;
    final completedSessions = overview['completed_sessions'] as int? ?? 0;
    final totalWorkTime = overview['total_work_time'] as int? ?? 0;
    final productivityScore = overview['productivity_score'] as double? ?? 0.0;

    return [
      {
        'label': 'stats_tasks_completed'.tr(),
        'value': '$completedTasks/$totalTasks',
        'icon': Icons.task_alt,
        'color': Colors.blue,
      },
      {
        'label': 'stats_sessions_completed'.tr(),
        'value': '$completedSessions/$totalSessions',
        'icon': Icons.timer,
        'color': Colors.green,
      },
      {
        'label': 'stats_work_time'.tr(),
        'value': '${(totalWorkTime / 3600).toStringAsFixed(1)}h',
        'icon': Icons.access_time,
        'color': Colors.orange,
      },
      {
        'label': 'stats_productivity_score'.tr(),
        'value': '${productivityScore.toStringAsFixed(0)}%',
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
    ];
  }
}

/// Daily statistics chart
class _DailyStatsChart extends StatelessWidget {
  const _DailyStatsChart({required this.dailyStats});
  final List<Map<String, dynamic>> dailyStats;

  @override
  Widget build(BuildContext context) {
    if (dailyStats.isEmpty) {
      return Text(LocaleKeys.no_data.tr());
    }

    return Column(
      children: [
        // Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'stats_active_days'.tr(),
              value: dailyStats.length.toString(),
              icon: Icons.calendar_today,
            ),
            _StatItem(
              label: 'stats_avg_sessions_per_day'.tr(),
              value: (dailyStats
                          .map((e) => e['sessions_completed'] as int)
                          .reduce((a, b) => a + b) /
                      dailyStats.length)
                  .toStringAsFixed(1),
              icon: Icons.timer,
            ),
            _StatItem(
              label: 'stats_avg_time_per_day'.tr(),
              value:
                  '${(dailyStats.map((e) => e['work_time'] as int).reduce((a, b) => a + b) / dailyStats.length / 3600).toStringAsFixed(1)}h',
              icon: Icons.access_time,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Chart
        SizedBox(
          height: 200,
          child: _buildDailyChart(),
        ),
      ],
    );
  }

  Widget _buildDailyChart() {
    final maxSessions = dailyStats
        .map((e) => e['sessions_completed'] as int)
        .reduce((a, b) => a > b ? a : b);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: dailyStats.length,
      itemBuilder: (context, index) {
        final day = dailyStats[index];
        final sessions = day['sessions_completed'] as int;
        final height = maxSessions > 0 ? (sessions / maxSessions) * 150 : 0.0;
        final date = DateTime.parse(day['date'] as String);

        return Container(
          width: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${date.day}/${date.month}',
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                sessions.toString(),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Weekly statistics chart
class _WeeklyStatsChart extends StatelessWidget {
  const _WeeklyStatsChart({required this.weeklyStats});
  final List<Map<String, dynamic>> weeklyStats;

  @override
  Widget build(BuildContext context) {
    if (weeklyStats.isEmpty) {
      return Text(LocaleKeys.no_data.tr());
    }

    return Column(
      children: [
        // Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'stats_active_weeks'.tr(),
              value: weeklyStats.length.toString(),
              icon: Icons.calendar_view_week,
            ),
            _StatItem(
              label: 'stats_avg_sessions_per_week'.tr(),
              value: (weeklyStats
                          .map((e) => e['sessions_completed'] as int)
                          .reduce((a, b) => a + b) /
                      weeklyStats.length)
                  .toStringAsFixed(1),
              icon: Icons.timer,
            ),
            _StatItem(
              label: 'stats_avg_active_days_per_week'.tr(),
              value: (weeklyStats
                          .map((e) => e['active_days'] as int)
                          .reduce((a, b) => a + b) /
                      weeklyStats.length)
                  .toStringAsFixed(1),
              icon: Icons.calendar_today,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Chart
        SizedBox(
          height: 200,
          child: _buildWeeklyChart(),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    final maxSessions = weeklyStats
        .map((e) => e['sessions_completed'] as int)
        .reduce((a, b) => a > b ? a : b);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: weeklyStats.length,
      itemBuilder: (context, index) {
        final week = weeklyStats[index];
        final sessions = week['sessions_completed'] as int;
        final height = maxSessions > 0 ? (sessions / maxSessions) * 150 : 0.0;
        final weekStart = DateTime.parse(week['week_start'] as String);

        return Container(
          width: 60,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tuần ${weekStart.day}/${weekStart.month}',
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              Text(
                sessions.toString(),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Monthly statistics chart
class _MonthlyStatsChart extends StatelessWidget {
  const _MonthlyStatsChart({required this.monthlyStats});
  final List<Map<String, dynamic>> monthlyStats;

  @override
  Widget build(BuildContext context) {
    if (monthlyStats.isEmpty) {
      return Text(LocaleKeys.no_data.tr());
    }

    return Column(
      children: [
        // Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'stats_active_months'.tr(),
              value: monthlyStats.length.toString(),
              icon: Icons.calendar_view_month,
            ),
            _StatItem(
              label: 'stats_avg_sessions_per_month'.tr(),
              value: (monthlyStats
                          .map((e) => e['sessions_completed'] as int)
                          .reduce((a, b) => a + b) /
                      monthlyStats.length)
                  .toStringAsFixed(1),
              icon: Icons.timer,
            ),
            _StatItem(
              label: 'stats_avg_active_weeks_per_month'.tr(),
              value: (monthlyStats
                          .map((e) => e['active_weeks'] as int)
                          .reduce((a, b) => a + b) /
                      monthlyStats.length)
                  .toStringAsFixed(1),
              icon: Icons.calendar_view_week,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Chart
        SizedBox(
          height: 200,
          child: _buildMonthlyChart(),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    final maxSessions = monthlyStats
        .map((e) => e['sessions_completed'] as int)
        .reduce((a, b) => a > b ? a : b);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: monthlyStats.length,
      itemBuilder: (context, index) {
        final month = monthlyStats[index];
        final sessions = month['sessions_completed'] as int;
        final height = maxSessions > 0 ? (sessions / maxSessions) * 150 : 0.0;
        final monthStart = DateTime.parse(month['month_start'] as String);

        return Container(
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${monthStart.month}/${monthStart.year}',
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              Text(
                sessions.toString(),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Session patterns grid
class _SessionPatternsGrid extends StatelessWidget {
  const _SessionPatternsGrid({required this.patterns});
  final Map<String, dynamic> patterns;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Key metrics
        Row(
          children: [
            Expanded(
              child: _PatternItem(
                label: 'stats_avg_session_duration'.tr(),
                value:
                    '${(patterns['average_session_duration'] as int? ?? 0) ~/ 60} ${'minutes_short'.tr()}',
                icon: Icons.timer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PatternItem(
                label: 'stats_avg_short_break'.tr(),
                value:
                    '${(patterns['average_short_break_duration'] as int? ?? 0) ~/ 60} ' +
                        'minutes_short'.tr(),
                icon: Icons.pause,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _PatternItem(
                label: 'stats_avg_long_break'.tr(),
                value:
                    '${(patterns['average_long_break_duration'] as int? ?? 0) ~/ 60} ' +
                        'minutes_short'.tr(),
                icon: Icons.coffee,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PatternItem(
                label: 'stats_most_productive_hour'.tr(),
                value: patterns['most_productive_hour'] as String? ?? '09:00',
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Distribution charts
        if (patterns['session_duration_distribution'] != null)
          _DistributionChart(
            title: 'stats_session_duration_distribution'.tr(),
            data: patterns['session_duration_distribution'] as Map<String, int>,
          ),
      ],
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Pattern item widget
class _PatternItem extends StatelessWidget {
  const _PatternItem({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Distribution chart widget
class _DistributionChart extends StatelessWidget {
  const _DistributionChart({required this.title, required this.data});
  final String title;
  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Text('Không có dữ liệu');
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((entry) {
          final percentage = maxValue > 0 ? (entry.value / maxValue) : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

Widget _buildEmptyState(BuildContext context) {
  return Container(
    margin: const EdgeInsets.all(32),
    child: Column(
      children: [
        Icon(
          Icons.analytics_outlined,
          size: 64,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'Chưa có thống kê',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bắt đầu làm việc để xem thống kê chi tiết',
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

/// Hiển thị dialog giải thích công thức điểm hiệu suất
void _showProductivityScoreDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const _ProductivityScoreDialogContent(),
      );
    },
  );
}

/// Thông báo tính năng xuất PDF đang được chuẩn bị
void _showExportPdfComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Tính năng xuất PDF sẽ sớm có mặt!'),
      duration: Duration(seconds: 2),
    ),
  );
}

/// Nội dung dialog giải thích công thức điểm hiệu suất
class _ProductivityScoreDialogContent extends StatelessWidget {
  const _ProductivityScoreDialogContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.calculate, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'stats_productivity_explain_title'.tr(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DialogSection(
                    title: 'stats_overview'.tr(),
                    content: 'stats_productivity_overview_desc'.tr(),
                  ),
                  _DialogSection(
                    title: 'stats_formula_common'.tr(),
                    content: 'stats_formula_common_desc'.tr(),
                    isFormula: true,
                  ),
                  _DialogSection(
                    title: 'stats_frequency_title'.tr(),
                    content: 'stats_frequency_desc'.tr(),
                    bullets: [
                      'stats_frequency_example1'.tr(),
                      'stats_frequency_example2'.tr(),
                      'stats_frequency_example3'.tr(),
                    ],
                  ),
                  _DialogSection(
                    title: 'stats_time_title'.tr(),
                    content: 'stats_time_desc'.tr(),
                    bullets: [
                      'stats_time_example1'.tr(),
                      'stats_time_example2'.tr(),
                      'stats_time_example3'.tr(),
                    ],
                  ),
                  _DialogSection(
                    title: 'stats_by_day_title'.tr(),
                    content: 'stats_by_day_desc'.tr(),
                    bullets: [
                      'stats_by_day_b1'.tr(),
                      'stats_by_day_b2'.tr(),
                      'stats_by_day_b3'.tr(),
                    ],
                  ),
                  _DialogSection(
                    title: 'stats_by_week_title'.tr(),
                    content: 'stats_by_week_desc'.tr(),
                    bullets: [
                      'stats_by_week_b1'.tr(),
                      'stats_by_week_b2'.tr(),
                      'stats_by_week_b3'.tr(),
                      'stats_by_week_b4'.tr(),
                    ],
                  ),
                  _DialogSection(
                    title: 'stats_by_month_title'.tr(),
                    content: 'stats_by_month_desc'.tr(),
                    bullets: [
                      'stats_by_month_b1'.tr(),
                      'stats_by_month_b2'.tr(),
                      'stats_by_month_b3'.tr(),
                      'stats_by_month_b4'.tr(),
                      'stats_by_month_b5'.tr(),
                    ],
                  ),
                  _DialogSection(
                    title: 'stats_example_title'.tr(),
                    content: 'stats_example_desc'.tr(),
                    bullets: [
                      'stats_example_b1'.tr(),
                      'stats_example_b2'.tr(),
                      'stats_example_b3'.tr(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  const _DialogSection({
    required this.title,
    required this.content,
    this.bullets,
    this.isFormula = false,
  });
  final String title;
  final String content;
  final List<String>? bullets;
  final bool isFormula;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFormula ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFormula ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: isFormula ? Colors.blue.shade800 : Colors.black,
              fontFamily: isFormula ? 'monospace' : null,
            ),
          ),
          if (bullets != null) ...[
            const SizedBox(height: 8),
            ...bullets!.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          b,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
