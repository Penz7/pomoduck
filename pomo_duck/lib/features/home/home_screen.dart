import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/router_extension.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';

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
      ],
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   title: Text(LocaleKeys.home.tr()),
        //   actions: [
        //     // Timer button
        //     IconButton(
        //       icon: const Icon(Icons.timer),
        //       onPressed: () {
        //         context.goWithPath('/settings');
        //       },
        //     ),
        //     // Add button change language
        //     IconButton(
        //       icon: const Icon(Icons.language),
        //       onPressed: () {
        //         final current = context.read<LanguageCubit>().state.locale;
        //         final next = current.languageCode == 'vi'
        //             ? const Locale('en', 'US')
        //             : const Locale('vi', 'VN');
        //         context.setLocale(next);
        //         context.read<LanguageCubit>().setNewLanguage(next);
        //       },
        //     ),
        //   ],
        // ),
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
                      const Text(
                        'Pomo Duck',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
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
                                Text(
                                  selectTag,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                10.width,
                                Text(
                                  '$mm:$ss',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                              const Text(
                                'Start',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
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
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pomodoro Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              16.height,
              BlocBuilder<ConfigPomodoroCubit, ConfigPomodoroState>(
                builder: (context, state) {
                  final s = state.settings;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tag'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in state.tags)
                            ChoiceChip(
                              label: Text(tag),
                              selected: state.selectedTag == tag,
                              onSelected: (_) => context
                                  .read<ConfigPomodoroCubit>()
                                  .selectTag(tag),
                            ),
                          const _AddTagChip(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Auto-start toggles
                      SwitchListTile(
                        value: s.autoStartBreaks,
                        onChanged: (v) => context
                            .read<ConfigPomodoroCubit>()
                            .setAutoStartBreaks(v),
                        title: const Text('Auto-start breaks'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        value: s.autoStartPomodoros,
                        onChanged: (v) => context
                            .read<ConfigPomodoroCubit>()
                            .setAutoStartPomodoros(v),
                        title: const Text('Auto-start next Pomodoro'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      // Durations
                      const Text('Work Duration (minutes)'),
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
                      const Text('Short Break Duration (minutes)'),
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
                      const Text('Long Break Duration (minutes)'),
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
  final settings = cfg.settings;
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
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
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
                    const Text(
                      'Start Session',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                16.height,
                TextFormField(
                  controller: titleCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Please enter task title';
                    if (value.length > 100) {
                      return 'Title is too long (max 100)';
                    }
                    return null;
                  },
                ),
                20.height,
                const Text('Durations'),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _durationTile('Work', settings.workDuration),
                    _durationTile('Short', settings.shortBreakDuration),
                    _durationTile('Long', settings.longBreakDuration),
                  ],
                ),
                20.height,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final task = TaskModel(
                            title: titleCtrl.text.trim(),
                            estimatedPomodoros: 1,
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
                        child: const Text('Start'),
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

Widget _durationTile(String label, int seconds) {
  final mm = (seconds ~/ 60).toString().padLeft(2, '0');
  final ss = (seconds % 60).toString().padLeft(2, '0');
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text('$mm:$ss'),
    ],
  );
}

class _AddTagChip extends StatelessWidget {
  const _AddTagChip({this.onAdded});

  final void Function(String)? onAdded;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: const Text('+ Add tag'),
      onPressed: () async {
        final controller = TextEditingController();
        await showDialog(
          context: context,
          builder: (dCtx) {
            return AlertDialog(
              title: const Text('Add new tag'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter tag name',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dCtx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final t = controller.text.trim();
                    if (t.isNotEmpty) {
                      context.read<ConfigPomodoroCubit>().addTag(t);
                      onAdded?.call(t);
                    }
                    Navigator.of(dCtx).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
