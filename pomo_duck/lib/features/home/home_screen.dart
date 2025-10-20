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
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(create: (context) => ConfigPomodoroCubit()),
      ],
      child: Scaffold(
        extendBody: true,
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
                      LCText.bold(
                        LocaleKeys.app_title,
                        textAlign: TextAlign.center,
                        fontSize: 35,
                      ),
                      50.height,
                      Assets.images.duck.image(
                        width: 300,
                        height: 300,
                      ),
                      10.height,
                      // Show config of pomodoro app
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
        child: SingleChildScrollView(
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
                            ChoiceChip(
                              label: LCText.medium(
                                tag,
                                color: state.selectedTag == tag
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              checkmarkColor: state.selectedTag == tag
                                  ? Colors.white
                                  : Colors.black,
                              selected: state.selectedTag == tag,
                              onSelected: (_) => context
                                  .read<ConfigPomodoroCubit>()
                                  .selectTag(tag),
                              selectedColor: Colors.black,
                            ),
                          const _AddTagChip(),
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
                          label: (s.shortBreakDuration / 60).round().toString(),
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
                          label: (s.longBreakDuration / 60).round().toString(),
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
                  textInputAction: TextInputAction.next,
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
                          // Lấy pomodoroCycleCount từ cài đặt hiện tại
                          final configState = context.read<ConfigPomodoroCubit>().state;
                          final estimatedPomodoros = configState.settings.effectivePomodoroCycleCount;
                          
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

class _AddTagChip extends StatelessWidget {
  const _AddTagChip();

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: LCText.medium(LocaleKeys.add_tag),
      onPressed: () async {
        final controller = TextEditingController();
        await showDialog(
          context: context,
          builder: (dCtx) {
            return AlertDialog(
              title: Text(LocaleKeys.add_new_tag.tr()),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: LocaleKeys.enter_tag_name.tr(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dCtx).pop(),
                  child: Text(LocaleKeys.cancel.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    final t = controller.text.trim();
                    if (t.isNotEmpty) {
                      context.read<ConfigPomodoroCubit>().addTag(t);
                    }
                    Navigator.of(dCtx).pop();
                  },
                  child: Text(LocaleKeys.add.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
