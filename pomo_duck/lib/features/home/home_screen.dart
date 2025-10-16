import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/router_extension.dart';

import '../../common/global_bloc/language/language_cubit.dart';
import '../../generated/locale_keys.g.dart';
import 'home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(LocaleKeys.home.tr()),
          actions: [
            // Timer button
            IconButton(
              icon: const Icon(Icons.timer),
              onPressed: () {
                context.goWithPath('/settings');
              },
            ),
            // Add button change language
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () {
                final current = context.read<LanguageCubit>().state.locale;
                final next = current.languageCode == 'vi'
                    ? const Locale('en', 'US')
                    : const Locale('vi', 'VN');
                context.setLocale(next);
                context.read<LanguageCubit>().setNewLanguage(next);
              },
            ),
          ],
        ),
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
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            final data = state.data;
            if (data == null || data.isEmpty) {
              return Column(
                children: [
                  const Text('PomoDuck - SQLite Database Test'),
                  const SizedBox(height: 20),
                  
                  // Database test section
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Database Status:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Total Tasks: ${data?.length ?? 0}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<HomeCubit>().addTestTask();
                          },
                          child: const Text('Add Test Task'),
                        ),
                      ],
                    ),
                  ),
                  
                  const Expanded(
                    child: Center(
                      child: Text('No tasks found. Add a test task!'),
                    ),
                  ),
                ],
              );
            }
            
            return Column(
              children: [
                const Text('PomoDuck - SQLite Database Test'),
                const SizedBox(height: 20),
                
                // Database test section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Database Status:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Total Tasks: ${data.length}'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeCubit>().addTestTask();
                        },
                        child: const Text('Add Test Task'),
                      ),
                    ],
                  ),
                ),
                
                // Tasks list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<HomeCubit>().refreshTasks(),
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final task = data[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Text(task.description),
                            trailing: Text(
                              '${task.completedPomodoros}/${task.estimatedPomodoros}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
            },
          ),
        ),
      ),
    );
  }
}