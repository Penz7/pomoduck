import 'package:bloc/bloc.dart';
import 'package:pomo_duck/data/models/index.dart';
import 'package:pomo_duck/data/database/database_helper.dart';

import '../../core/base_state.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {

  HomeCubit() : super(HomeState()) {
    loadTasks();
  }

  /// Load tất cả tasks từ database
  Future<void> loadTasks({
    bool isLoading = true,
  }) async {
    if (isLoading) {
      emit(state.copyWith(status: BlocStatus.loading));
    }
    
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      emit(state.copyWith(
        status: BlocStatus.success,
        data: tasks,
        message: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.error,
        message: 'Error loading tasks: $e',
      ));
    }
  }

  /// Thêm test task mới
  Future<void> addTestTask() async {
    emit(state.copyWith(status: BlocStatus.loading));
    
    try {
      final task = TaskModel(
        title: 'Test Task ${DateTime.now().millisecondsSinceEpoch}',
        description: 'This is a test task',
        estimatedPomodoros: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await DatabaseHelper.instance.insertTask(task);
      
      // Reload tasks sau khi thêm thành công (không hiển thị loading)
      await loadTasks(isLoading: false);
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.error,
        message: 'Error adding task: $e',
      ));
    }
  }

  /// Refresh tasks list
  Future<void> refreshTasks() async {
    await loadTasks(isLoading: false);
  }
}
