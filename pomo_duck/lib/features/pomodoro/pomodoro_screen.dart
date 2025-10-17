import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/features/pomodoro/pomodoro_cubit.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';
import 'package:pomo_duck/common/global_bloc/config_pomodoro/config_pomodoro_cubit.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Pomodoro Paused'),
          content: const Text(
              'Your pomodoro session is paused. What would you like to do?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<PomodoroCubit>().resume();
              },
              child: const Text('Resume'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Keep Paused'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleStopAndReset(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Stop Session'),
            ),
          ],
        );
      },
    );
  }

  void _handleStopAndReset(BuildContext context) async {
    await context.read<PomodoroCubit>().pause();
    if (context.mounted) {
      await context.read<PomodoroCubit>().stop();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showTaskCompletionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Task Completed!'),
            ],
          ),
          content: const Text(
            'Congratulations! You have successfully completed all pomodoro sessions for this task.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(); // Go back to home screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Great!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return PomodoroCubit();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  BlocListener<PomodoroCubit, PomodoroState>(
                    listener: (context, state) {
                      if (state is PomodoroTaskCompleted) {
                        _showTaskCompletionDialog(context);
                      }
                    },
                    child: BlocBuilder<PomodoroCubit, PomodoroState>(
                      builder: (context, state) {
                        final mm = (state.remainingSeconds ~/ 60)
                            .toString()
                            .padLeft(2, '0');
                        final ss = (state.remainingSeconds % 60)
                            .toString()
                            .padLeft(2, '0');

                        final title = switch (state.sessionType) {
                          'work' => 'Focus',
                          'shortBreak' => 'Short Break',
                          'longBreak' => 'Long Break',
                          _ => 'Quack!!!',
                        };
                        return Column(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (state.activeCycle != null)
                              BlocBuilder<ConfigPomodoroCubit,
                                  ConfigPomodoroState>(
                                builder: (context, configState) {
                                  final settings = configState.settings;
                                  final totalPomodoros =
                                      settings.effectivePomodoroCycleCount;
                                  return Text(
                                    '${state.activeCycle!.completedPomodoros}/$totalPomodoros Pomodoro',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  );
                                },
                              ),
                            const SizedBox(height: 6),
                            Text(
                              '$mm:$ss',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  20.height,
                  /// Duck Image (switches by session type and selected tag)
                  BlocSelector<PomodoroCubit, PomodoroState, String>(
                    selector: (state) => state.sessionType,
                    builder: (context, sessionType) {
                      if (sessionType == 'work') {
                        return BlocBuilder<ConfigPomodoroCubit, ConfigPomodoroState>(
                          buildWhen: (p, c) => p.selectedTag != c.selectedTag,
                          builder: (context, configState) {
                            final tag = configState.selectedTag.trim().toLowerCase();
                            final dynamicPath = 'assets/images/duck_$tag.png';
                            return Image.asset(
                              dynamicPath,
                              width: 350,
                              height: 350,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Assets.images.duckFocus.image(
                                  width: 350,
                                  height: 350,
                                  fit: BoxFit.cover,
                                );
                              },
                            );
                          },
                        );
                      }
                      return Assets.images.duckRelax.image(
                        width: 350,
                        height: 350,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  40.height,
                  BlocBuilder<PomodoroCubit, PomodoroState>(
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: state.isRunning
                            ? () async {
                                await context
                                    .read<PomodoroCubit>()
                                    .pause()
                                    .then((_) {
                                  if (!context.mounted) return;
                                  _showPauseDialog(context);
                                });
                              }
                            : () => context.read<PomodoroCubit>().resume(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: state.isRunning
                              ? Assets.images.icPause.image(
                                  width: 64,
                                  height: 64,
                                )
                              : Assets.images.icPlay.image(
                                  width: 64,
                                  height: 64,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
