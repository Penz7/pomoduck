import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/features/pomodoro/pomodoro_cubit.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pomodoro Paused'),
          content:   Assets.images.duckPause.image(
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<PomodoroCubit>().resume();
              },
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleStopAndReset(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Stop'),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return PomodoroCubit();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              10.height,
              Row(
                children: [
                  10.width,
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              BlocBuilder<PomodoroCubit, PomodoroState>(
                builder: (context, state) {
                  final mm =
                      (state.remainingSeconds ~/ 60).toString().padLeft(2, '0');
                  final ss =
                      (state.remainingSeconds % 60).toString().padLeft(2, '0');
                  return Column(
                    children: [
                      Text(
                        state.sessionType == 'work'
                            ? 'Focus'
                            : (state.sessionType == 'shortBreak'
                                ? 'Short Break'
                                : 'Long Break'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      4.height,
                      if (state.activeCycle != null)
                        Text(
                          '${state.activeCycle!.completedPomodoros}/${state.activeCycle!.totalPomodoros} Pomodoro',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                      6.height,
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
              20.height,
              Assets.images.duckFocus.image(
                width: 350,
                height: 350,
                fit: BoxFit.cover,
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
    );
  }
}
