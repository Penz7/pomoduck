import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'history_cubit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return HistoryCubit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('History Screen'),
            ],
          ),
        ),
      ),
    );
  }
}
