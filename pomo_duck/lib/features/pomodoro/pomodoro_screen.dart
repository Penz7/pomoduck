import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/features/pomodoro/pomodoro_cubit.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';
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
          content: const Text('Your pomodoro session is paused. What would you like to do?'),
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
    await context.read<PomodoroCubit>().stop();
    Navigator.of(context).pop();
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

  Future<void> _showExitConfirmDialog(BuildContext context) async {
    print('Showing exit confirm dialog');
    final currentState = HiveDataManager.getCurrentTimerState();
    final isActive = currentState.isActive;

    if (!isActive) {
      Navigator.of(context).pop();
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Exit Pomodoro Session'),
          content: const Text(
            'You have an active pomodoro session. Are you sure you want to stop and exit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
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

    if (result == true && context.mounted) {
      await _handleStopSession(context);
    }
  }

  Future<void> _handleStopSession(BuildContext context) async {
    final cubit = context.read<PomodoroCubit>();
    await cubit.stop();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.black),
                        onPressed: () {
                          _showExitConfirmDialog(context);
                        },
                      ),
                    ],
                  ),
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
                        return Column(
                          children: [
                            Text(
                              state.sessionType == 'work'
                                  ? 'Focus'
                                  : state.sessionType == 'shortBreak'
                                      ? 'Short Break'
                                      : 'Long Break',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (state.activeCycle != null)
                              BlocBuilder<ConfigPomodoroCubit, ConfigPomodoroState>(
                                builder: (context, configState) {
                                  final settings = configState.settings;
                                  final totalPomodoros = settings.effectivePomodoroCycleCount;
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
                  const SizedBox(height: 20),
                  Assets.images.duckFocus.image(
                    width: 350,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 40),
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
                            : () => context.read<PomodoroCubit>().stop(),
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