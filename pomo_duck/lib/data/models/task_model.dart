
/// Model cho Task entity
class TaskModel {
  final int? id;
  final String title;
  final String description;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.estimatedPomodoros,
    this.completedPomodoros = 0,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo TaskModel từ Map (từ database)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      estimatedPomodoros: map['estimated_pomodoros'] as int,
      completedPomodoros: map['completed_pomodoros'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Chuyển TaskModel thành Map (để lưu vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimated_pomodoros': estimatedPomodoros,
      'completed_pomodoros': completedPomodoros,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Tạo copy với các field được update
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    int? estimatedPomodoros,
    int? completedPomodoros,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, estimatedPomodoros: $estimatedPomodoros, completedPomodoros: $completedPomodoros, isCompleted: $isCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.estimatedPomodoros == estimatedPomodoros &&
        other.completedPomodoros == completedPomodoros &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        estimatedPomodoros.hashCode ^
        completedPomodoros.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
