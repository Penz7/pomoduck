import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/features/pomodoro/pomodoro_cubit.dart';
import 'package:pomo_duck/core/data_coordinator/hybrid_data_coordinator.dart';
import 'package:pomo_duck/data/models/pomodoro_cycle_model.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

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
                            : (state.sessionType == 'shortBreak'
                                ? 'Short Break'
                                : 'Long Break'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      4.height,
                      FutureBuilder<PomodoroCycleModel?>(
                        future: HybridDataCoordinator.instance.getActiveCycle(),
                        builder: (context, AsyncSnapshot<PomodoroCycleModel?> snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const SizedBox.shrink();
                          }
                          final PomodoroCycleModel cycle = snapshot.data!;
                          return Text(
                            '${cycle.completedPomodoros}/${cycle.totalPomodoros} Pomodoro',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          );
                        },
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
