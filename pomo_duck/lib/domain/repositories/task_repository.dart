import '../../data/models/task_model.dart';

/// Abstract repository interface cho Task operations
abstract class TaskRepository {
  /// Tạo task mới
  Future<int> createTask(TaskModel task);
  
  /// Lấy tất cả tasks
  Future<List<TaskModel>> getAllTasks();
  
  /// Lấy task theo ID
  Future<TaskModel?> getTaskById(int id);
  
  /// Cập nhật task
  Future<int> updateTask(TaskModel task);
  
  /// Xóa task
  Future<int> deleteTask(int id);
  
  /// Lấy tasks chưa hoàn thành
  Future<List<TaskModel>> getIncompleteTasks();
  
  /// Lấy tasks đã hoàn thành
  Future<List<TaskModel>> getCompletedTasks();
  
  /// Đánh dấu task hoàn thành
  Future<int> markTaskCompleted(int taskId);
  
  /// Đánh dấu task chưa hoàn thành
  Future<int> markTaskIncomplete(int taskId);
  
  /// Tăng số pomodoro đã hoàn thành
  Future<int> incrementCompletedPomodoros(int taskId);
}
