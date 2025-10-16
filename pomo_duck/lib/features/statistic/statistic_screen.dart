import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/features/statistic/statistic_cubit.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      return StatisticCubit();
    }, child: Scaffold(
      appBar: AppBar(
        title: const Text('Statistic'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Statistic Screen'),
          ],
        ),
      ),
    ),);
  }
}
