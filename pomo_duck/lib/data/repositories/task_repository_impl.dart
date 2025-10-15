import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../database/database_helper.dart';

/// Implementation của TaskRepository sử dụng SQLite
class TaskRepositoryImpl implements TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  @override
  Future<int> createTask(TaskModel task) async {
    return await _databaseHelper.insertTask(task);
  }
  
  @override
  Future<List<TaskModel>> getAllTasks() async {
    return await _databaseHelper.getAllTasks();
  }
  
  @override
  Future<TaskModel?> getTaskById(int id) async {
    return await _databaseHelper.getTaskById(id);
  }
  
  @override
  Future<int> updateTask(TaskModel task) async {
    return await _databaseHelper.updateTask(task);
  }
  
  @override
  Future<int> deleteTask(int id) async {
    return await _databaseHelper.deleteTask(id);
  }
  
  @override
  Future<List<TaskModel>> getIncompleteTasks() async {
    return await _databaseHelper.getIncompleteTasks();
  }
  
  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    return await _databaseHelper.getCompletedTasks();
  }
  
  @override
  Future<int> markTaskCompleted(int taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) return 0;
    
    final updatedTask = task.copyWith(
      isCompleted: true,
      updatedAt: DateTime.now(),
    );
    
    return await updateTask(updatedTask);
  }
  
  @override
  Future<int> markTaskIncomplete(int taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) return 0;
    
    final updatedTask = task.copyWith(
      isCompleted: false,
      updatedAt: DateTime.now(),
    );
    
    return await updateTask(updatedTask);
  }
  
  @override
  Future<int> incrementCompletedPomodoros(int taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) return 0;
    
    final updatedTask = task.copyWith(
      completedPomodoros: task.completedPomodoros + 1,
      updatedAt: DateTime.now(),
    );
    
    return await updateTask(updatedTask);
  }
}
