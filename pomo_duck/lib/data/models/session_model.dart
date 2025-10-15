
/// Enum cho loại session
enum SessionType {
  work('work'),
  shortBreak('short_break'),
  longBreak('long_break');

  const SessionType(this.value);
  final String value;

  static SessionType fromString(String value) {
    switch (value) {
      case 'work':
        return SessionType.work;
      case 'short_break':
        return SessionType.shortBreak;
      case 'long_break':
        return SessionType.longBreak;
      default:
        return SessionType.work;
    }
  }
}

/// Model cho Session entity
class SessionModel {
  final int? id;
  final int? taskId; // Có thể null cho break sessions
  final SessionType sessionType;
  final int plannedDuration; // Thời gian dự định (giây)
  final int? actualDuration; // Thời gian thực tế (giây)
  final bool isCompleted;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;

  const SessionModel({
    this.id,
    this.taskId,
    required this.sessionType,
    required this.plannedDuration,
    this.actualDuration,
    this.isCompleted = false,
    this.startTime,
    this.endTime,
    required this.createdAt,
  });

  /// Tạo SessionModel từ Map (từ database)
  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as int?,
      taskId: map['task_id'] as int?,
      sessionType: SessionType.fromString(map['session_type'] as String),
      plannedDuration: map['planned_duration'] as int,
      actualDuration: map['actual_duration'] as int?,
      isCompleted: (map['is_completed'] as int) == 1,
      startTime: map['start_time'] != null 
          ? DateTime.parse(map['start_time'] as String) 
          : null,
      endTime: map['end_time'] != null 
          ? DateTime.parse(map['end_time'] as String) 
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Chuyển SessionModel thành Map (để lưu vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'session_type': sessionType.value,
      'planned_duration': plannedDuration,
      'actual_duration': actualDuration,
      'is_completed': isCompleted ? 1 : 0,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Tạo copy với các field được update
  SessionModel copyWith({
    int? id,
    int? taskId,
    SessionType? sessionType,
    int? plannedDuration,
    int? actualDuration,
    bool? isCompleted,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      sessionType: sessionType ?? this.sessionType,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Tính toán thời gian đã trôi qua (giây)
  int get elapsedSeconds {
    if (startTime == null) return 0;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!).inSeconds;
  }

  /// Kiểm tra session có đang active không
  bool get isActive {
    return startTime != null && endTime == null && !isCompleted;
  }

  @override
  String toString() {
    return 'SessionModel(id: $id, taskId: $taskId, sessionType: $sessionType, plannedDuration: $plannedDuration, actualDuration: $actualDuration, isCompleted: $isCompleted, startTime: $startTime, endTime: $endTime, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionModel &&
        other.id == id &&
        other.taskId == taskId &&
        other.sessionType == sessionType &&
        other.plannedDuration == plannedDuration &&
        other.actualDuration == actualDuration &&
        other.isCompleted == isCompleted &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        taskId.hashCode ^
        sessionType.hashCode ^
        plannedDuration.hashCode ^
        actualDuration.hashCode ^
        isCompleted.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        createdAt.hashCode;
  }
}
