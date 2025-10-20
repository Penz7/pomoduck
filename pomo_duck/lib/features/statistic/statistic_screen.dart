import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pomo_duck/features/statistic/statistic_cubit.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      return StatisticCubit();
    }, child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(LocaleKeys.statistic.tr()),
        actions: [
          IconButton(
            onPressed: () => context.read<StatisticCubit>().loadAll(),
            icon: const Icon(Icons.refresh),
          )
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<StatisticCubit>().loadAll(),
                    child: Text(LocaleKeys.retry.tr()),
                  )
                ],
              ),
            );
          }

          final loaded = state as StatisticLoaded;
          return RefreshIndicator(
            onRefresh: () => context.read<StatisticCubit>().loadAll(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(title: LocaleKeys.today_stats.tr(), child: _KeyValueGrid(map: loaded.todayStats)),
                const SizedBox(height: 12),
                _Section(title: LocaleKeys.realtime_metrics.tr(), child: _KeyValueGrid(map: loaded.realtime)),
                const SizedBox(height: 12),
                _Section(title: LocaleKeys.overall_stats.tr(), child: _KeyValueGrid(map: loaded.overallStats)),
                const SizedBox(height: 12),
                _Section(title: LocaleKeys.analytics_basic.tr(), child: _KeyValueGrid(map: loaded.analytics['basic'] as Map<String, dynamic>? ?? {})),
                const SizedBox(height: 12),
                _ToggleSection(
                  title: LocaleKeys.patterns.tr(),
                  map: loaded.analytics['patterns'] as Map<String, dynamic>? ?? {},
                ),
                const SizedBox(height: 12),
                _ToggleSection(
                  title: LocaleKeys.performance.tr(),
                  map: loaded.analytics['performance'] as Map<String, dynamic>? ?? {},
                ),
                const SizedBox(height: 12),
                _ToggleSection(
                  title: LocaleKeys.focus_analysis.tr(),
                  map: loaded.analytics['focus'] as Map<String, dynamic>? ?? {},
                ),
                const SizedBox(height: 12),
                _Section(title: LocaleKeys.predictions.tr(), child: _KeyValueGrid(map: loaded.predictions)),
              ],
            ),
          );
        },
      ),
    ),);
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
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ],
    );
  }
}

class _KeyValueGrid extends StatelessWidget {
  const _KeyValueGrid({required this.map});
  final Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) {
      return Text(LocaleKeys.no_data.tr());
    }
    final entries = map.entries.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.8,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final e = entries[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              Text('${e.value}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
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
                        widthFactor: maxVal > 0 ? (e.value / maxVal).clamp(0.0, 1.0) : 0.0,
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
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Row(children: [
              Text(LocaleKeys.grid.tr(), style: const TextStyle(fontSize: 12)),
              Switch(
                value: showChart,
                onChanged: (v) => setState(() => showChart = v),
              ),
              Text(LocaleKeys.chart.tr(), style: const TextStyle(fontSize: 12)),
            ])
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.all(12),
          child: showChart ? _BarChart(map: widget.map) : _KeyValueGrid(map: widget.map),
        ),
      ],
    );
  }
}
