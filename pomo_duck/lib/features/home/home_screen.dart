import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/context_extension.dart';
import 'package:pomo_duck/common/extensions/router_extension.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/common/utils/font_size.dart';
import 'package:pomo_duck/common/widgets/text.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';
import 'package:pomo_duck/core/audio/audio_service.dart';
import 'package:pomo_duck/common/widgets/score_display.dart';
import 'package:pomo_duck/common/widgets/tag_chip.dart';
import 'package:pomo_duck/common/global_bloc/score/score_bloc.dart';
import 'package:pomo_duck/core/services/score_service.dart';

// import '../../common/global_bloc/language/language_cubit.dart';
// import '../../generated/locale_keys.g.dart';
import 'home_cubit.dart';
// import '../../core/local_storage/hive_data_manager.dart';
// import '../../data/models/pomodoro_settings.dart';
import '../../common/global_bloc/config_pomodoro/config_pomodoro_cubit.dart';
import '../../core/data_coordinator/hybrid_data_coordinator.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _showPomodoroSettingsSheet(BuildContext context) async {
    await showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: ctx.bottomPadding,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.8,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Row(
                  children: [
                    Assets.images.duckTag.image(
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                    10.width,
                    LCText.bold(
                      LocaleKeys.pomodoro_settings,
                      fontSize: FontSizes.big,
                    ),
                  ],
                ),
                16.height,
                BlocBuilder<ConfigPomodoroCubit, ConfigPomodoroState>(
                  builder: (context, state) {
                    final s = state.settings;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LCText.medium(
                          LocaleKeys.tag,
                        ),
                        10.height,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final tag in state.tags)
                              TagChip(
                                tag: tag,
                                isSelected: state.selectedTag == tag,
                                onTap: () => context
                                    .read<ConfigPomodoroCubit>()
                                    .selectTag(tag),
                                onDelete: () => context
                                    .read<ConfigPomodoroCubit>()
                                    .removeTag(tag),
                              ),
                            const AddTagChip(),
                          ],
                        ),
                        16.height,
                        SwitchListTile(
                          value: s.isStandardMode,
                          onChanged: (v) => context
                              .read<ConfigPomodoroCubit>()
                              .setStandardMode(v),
                          title: LCText.medium(
                            LocaleKeys.standard_pomodoro_mode,
                          ),
                          subtitle: LCText.medium(
                            s.isStandardMode
                                ? LocaleKeys.standard_mode_description
                                : LocaleKeys.custom_mode_description,
                            fontSize: FontSizes.extraSmall,
                            color: Colors.grey.shade600,
                            maxLines: 5,
                          ),
                          activeColor: Colors.black,
                          contentPadding: EdgeInsets.zero,
                        ),
                        16.height,
                        if (!s.isStandardMode) ...[
                          LCText.medium(
                            LocaleKeys.pomodoro_cycle_count,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: s.pomodoroCycleCount.toDouble(),
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  label: '${s.pomodoroCycleCount} pomodoros',
                                  onChanged: (value) => context
                                      .read<ConfigPomodoroCubit>()
                                      .updatePomodoroCycleCount(value.toInt()),
                                  activeColor: Colors.black,
                                  inactiveColor: Colors.grey,
                                  secondaryActiveColor: Colors.black,
                                ),
                              ),
                              LCText.medium(
                                '${s.pomodoroCycleCount}',
                              ),
                            ],
                          ),
                          LCText.medium(
                            LocaleKeys.task_will_complete.tr(namedArgs: {
                              'count': s.pomodoroCycleCount.toString()
                            }),
                            fontSize: FontSizes.small,
                            color: Colors.grey.shade600,
                          ),
                        ],
                        16.height,
                        if (!s.isStandardMode) ...[
                          LCText.medium(
                            LocaleKeys.work_duration,
                          ),
                          Slider(
                            value: (s.workDuration / 60).clamp(5.0, 200.0),
                            min: 5,
                            max: 200,
                            divisions: 39,
                            label: (s.workDuration / 60).round().toString(),
                            onChanged: (value) => context
                                .read<ConfigPomodoroCubit>()
                                .updateWorkMinutes(value.round()),
                            activeColor: Colors.black,
                            inactiveColor: Colors.grey,
                            secondaryActiveColor: Colors.black,
                          ),
                          LCText.medium(
                            LocaleKeys.short_break_duration,
                          ),
                          Slider(
                            value: (s.shortBreakDuration / 60).clamp(1.0, 30.0),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label:
                                (s.shortBreakDuration / 60).round().toString(),
                            onChanged: (value) => context
                                .read<ConfigPomodoroCubit>()
                                .updateShortBreakMinutes(value.round()),
                            activeColor: Colors.black,
                            inactiveColor: Colors.grey,
                            secondaryActiveColor: Colors.black,
                          ),
                          LCText.medium(
                            LocaleKeys.long_break_duration,
                          ),
                          Slider(
                            value: (s.longBreakDuration / 60).clamp(5.0, 60.0),
                            min: 5,
                            max: 60,
                            divisions: 11,
                            label:
                                (s.longBreakDuration / 60).round().toString(),
                            onChanged: (value) => context
                                .read<ConfigPomodoroCubit>()
                                .updateLongBreakMinutes(value.round()),
                            activeColor: Colors.black,
                            inactiveColor: Colors.grey,
                            secondaryActiveColor: Colors.black,
                          ),
                          LCText.medium(
                            LocaleKeys.long_break_interval,
                          ),
                          Slider(
                            value: s.longBreakInterval.toDouble(),
                            min: 2,
                            max: 10,
                            divisions: 8,
                            label: 'Every ${s.longBreakInterval} pomodoros',
                            onChanged: (value) => context
                                .read<ConfigPomodoroCubit>()
                                .updateLongBreakInterval(value.round()),
                            activeColor: Colors.black,
                            inactiveColor: Colors.grey,
                            secondaryActiveColor: Colors.black,
                          ),
                        ],
                        Row(
                          children: [
                            Assets.images.duckTag.image(
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                            8.width,
                            LCText.bold(
                              'Điểm số dự kiến',
                              fontSize: FontSizes.medium,
                            ),
                          ],
                        ),
                        8.height,
                        BlocBuilder<ConfigPomodoroCubit, ConfigPomodoroState>(
                          builder: (context, state) {
                            final settings = state.settings;
                            final scoreService = ScoreService();

                            final expectedPoints =
                                scoreService.calculateSessionPoints(
                              isStandardMode: settings.isStandardMode,
                              workDuration: settings.workDuration,
                              shortBreakDuration: settings.shortBreakDuration,
                              longBreakDuration: settings.longBreakDuration,
                              sessionsCompleted:
                                  settings.effectivePomodoroCycleCount,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LCText.medium(
                                  'Hoàn thành pomodoro sẽ nhận được:',
                                  fontSize: FontSizes.small,
                                  color: Colors.grey.shade700,
                                ),
                                4.height,
                                LCText.bold(
                                  '+$expectedPoints điểm',
                                  fontSize: FontSizes.big,
                                ),
                                8.height,
                                if (settings.isStandardMode) ...[
                                  LCText.medium(
                                    '• Chế độ chuẩn: 150 điểm cố định',
                                    fontSize: FontSizes.extraSmall,
                                    color: Colors.grey.shade600,
                                  ),
                                ] else ...[
                                  LCText.medium(
                                    '• Chế độ tùy chỉnh: ${settings.effectivePomodoroCycleCount} phiên × 10 điểm',
                                    fontSize: FontSizes.extraSmall,
                                    color: Colors.grey.shade600,
                                  ),
                                  2.height,
                                  LCText.medium(
                                    '• Thời gian học: ${(settings.workDuration / 60).round()} phút × 1 điểm',
                                    fontSize: FontSizes.extraSmall,
                                    color: Colors.grey.shade600,
                                  ),
                                  2.height,
                                  LCText.medium(
                                    '• Short break: ${(settings.shortBreakDuration / 60).round()} phút (tối đa 20 điểm)',
                                    fontSize: FontSizes.extraSmall,
                                    color: Colors.grey.shade600,
                                  ),
                                  2.height,
                                  LCText.medium(
                                    '• Long break: ${(settings.longBreakDuration / 60).round()} phút (tối đa 50 điểm)',
                                    fontSize: FontSizes.extraSmall,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        12.height,
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  8.width,
                                  LCText.medium(
                                    'Streak Bonus',
                                    fontSize: FontSizes.small,
                                  ),
                                ],
                              ),
                              4.height,
                              LCText.medium(
                                '• Mỗi 5 task liên tiếp: +200 điểm',
                                fontSize: FontSizes.extraSmall,
                                color: Colors.grey.shade600,
                              ),
                              2.height,
                              LCText.medium(
                                '• Streak 30 ngày: +1000 điểm đặc biệt',
                                fontSize: FontSizes.extraSmall,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showStartTaskSheet(BuildContext context) async {
    final cfg = context.read<ConfigPomodoroCubit>().state;
    String selectedTag = cfg.selectedTag;

    final titleCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: ctx.bottomPadding,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Assets.images.duckTag.image(
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                      10.width,
                      LCText.bold(
                        LocaleKeys.start_session,
                        fontSize: FontSizes.big,
                      ),
                    ],
                  ),
                  16.height,
                  TextFormField(
                    controller: titleCtrl,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: FontSizes.medium,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      // Tự động submit khi nhấn Enter
                      if (formKey.currentState!.validate()) {
                        // Logic submit sẽ được thực hiện trong button
                      }
                    },
                    decoration: InputDecoration(
                      labelText: LocaleKeys.task_title.tr(),
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      focusColor: Colors.black,
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return LocaleKeys.task_title.tr();
                      if (value.length > 100) {
                        return 'Title is too long (max 100)';
                      }
                      return null;
                    },
                  ),
                  40.height,
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: LCText.bold(
                            LocaleKeys.cancel,
                          ),
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            // Phát âm thanh quack khi bấm start
                            _audioService.playQuack();

                            // Lấy pomodoroCycleCount từ cài đặt hiện tại
                            final configState =
                                context.read<ConfigPomodoroCubit>().state;
                            final estimatedPomodoros = configState
                                .settings.effectivePomodoroCycleCount;

                            final task = TaskModel(
                              title: titleCtrl.text.trim(),
                              estimatedPomodoros: estimatedPomodoros,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              tag: selectedTag,
                            );
                            final taskId =
                                await DatabaseHelper.instance.insertTask(task);
                            await HybridDataCoordinator.instance
                                .startPomodoroSession(
                              taskId: taskId,
                              sessionType: 'work',
                            );
                            if (ctx.mounted) {
                              // Refresh điểm số sau khi tạo task
                              context.read<ScoreBloc>().updateScore();
                              Navigator.of(ctx).pop();
                              ctx.goWithPath('/home/pomodoro');
                            }
                          },
                          child: LCText.bold(
                            LocaleKeys.start,
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.height,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state.isError && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.bottomCenter,
                    image: Assets.images.background.image().image,
                    fit: BoxFit.contain,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const PointsDisplay(),
                            Expanded(
                              child: LCText.bold(
                                LocaleKeys.app_title,
                                textAlign: TextAlign.center,
                                fontSize: 35,
                              ),
                            ),
                            const StreakDisplay(),
                          ],
                        ),
                      ),
                      20.height,
                      GestureDetector(
                        onTap: () {
                          _audioService.playQuack();
                        },
                        child: Assets.images.duck.image(
                          width: 300,
                          height: 300,
                        ),
                      ),
                      10.height,
                      InkWell(
                        onTap: () async {
                          await _showPomodoroSettingsSheet(context);
                        },
                        child: BlocBuilder<ConfigPomodoroCubit,
                            ConfigPomodoroState>(
                          builder: (context, state) {
                            final s = state.settings;
                            final selectTag = state.selectedTag;
                            final mm = (s.workDuration ~/ 60)
                                .toString()
                                .padLeft(2, '0');
                            final ss = (s.workDuration % 60)
                                .toString()
                                .padLeft(2, '0');
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.images.duckTag.image(
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                                10.width,
                                LCText.medium(
                                  selectTag,
                                ),
                                10.width,
                                LCText.medium('$mm:$ss'),
                                Assets.images.icRight.image(
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      30.height,
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            _audioService.playQuack();
                            await _showStartTaskSheet(context);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Assets.images.borderButton.image(
                                width: 400,
                                height: 50,
                              ),
                              LCText.bold(
                                LocaleKeys.start,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

