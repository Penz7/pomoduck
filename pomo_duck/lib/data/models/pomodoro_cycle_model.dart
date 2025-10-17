/// Model cho Pomodoro Cycle - lưu trong SQLite
/// Track complete pomodoro cycles (4 pomodoros + breaks)
class PomodoroCycleModel {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int completedPomodoros; // 0-4
  final int totalPomodoros; // usually 4
  final bool isCompleted;
  final String sessionIds; // JSON array: "[1,2,3,4,5]"
  final DateTime createdAt;

  const PomodoroCycleModel({
    this.id,
    required this.startTime,
    this.endTime,
    this.completedPomodoros = 0,
    this.totalPomodoros = 4,
    this.isCompleted = false,
    this.sessionIds = '[]',
    required this.createdAt,
  });

  /// Tạo PomodoroCycleModel từ Map (từ database)
  factory PomodoroCycleModel.fromMap(Map<String, dynamic> map) {
    return PomodoroCycleModel(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null 
          ? DateTime.parse(map['end_time'] as String) 
          : null,
      completedPomodoros: map['completed_pomodoros'] as int,
      totalPomodoros: map['total_pomodoros'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
      sessionIds: map['session_ids'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Chuyển PomodoroCycleModel thành Map (để lưu vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'completed_pomodoros': completedPomodoros,
      'total_pomodoros': totalPomodoros,
      'is_completed': isCompleted ? 1 : 0,
      'session_ids': sessionIds,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Tạo copy với các field được update
  PomodoroCycleModel copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? completedPomodoros,
    int? totalPomodoros,
    bool? isCompleted,
    String? sessionIds,
    DateTime? createdAt,
  }) {
    return PomodoroCycleModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      totalPomodoros: totalPomodoros ?? this.totalPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      sessionIds: sessionIds ?? this.sessionIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Parse session IDs từ JSON string
  List<int> get sessionIdList {
    try {
      if (sessionIds.isEmpty || sessionIds == '[]') return [];
      final List<dynamic> parsed = 
          sessionIds.replaceAll('[', '').replaceAll(']', '').split(',');
      return parsed
          .where((id) => id.toString().trim().isNotEmpty)
          .map((id) => int.parse(id.toString().trim()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add session ID to cycle
  PomodoroCycleModel addSessionId(int sessionId) {
    final currentIds = sessionIdList;
    currentIds.add(sessionId);
    return copyWith(sessionIds: '[${currentIds.join(',')}]');
  }

  /// Remove session ID from cycle
  PomodoroCycleModel removeSessionId(int sessionId) {
    final currentIds = sessionIdList;
    currentIds.remove(sessionId);
    return copyWith(sessionIds: '[${currentIds.join(',')}]');
  }

  /// Getter để check xem cycle có hoàn thành không
  bool get isFullyCompleted {
    return isCompleted && completedPomodoros >= totalPomodoros;
  }

  /// Getter để check xem cycle có đang active không
  bool get isActive {
    return !isCompleted && endTime == null;
  }

  /// Getter để tính thời gian cycle
  Duration get cycleDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Getter để tính progress percentage
  double get progressPercentage {
    if (totalPomodoros == 0) return 0.0;
    return (completedPomodoros / totalPomodoros).clamp(0.0, 1.0);
  }

  /// Getter để check xem có nên take long break không
  /// Note: This should be checked against settings.longBreakInterval, not hardcoded
  bool shouldTakeLongBreak(int longBreakInterval) {
    return completedPomodoros > 0 && completedPomodoros % longBreakInterval == 0;
  }

  /// Getter để lấy số pomodoro còn lại
  int get remainingPomodoros {
    return totalPomodoros - completedPomodoros;
  }

  /// Complete cycle
  PomodoroCycleModel complete() {
    return copyWith(
      isCompleted: true,
      endTime: DateTime.now(),
    );
  }

  /// Increment completed pomodoros
  PomodoroCycleModel incrementPomodoros() {
    final newCount = completedPomodoros + 1;
    final shouldComplete = newCount >= totalPomodoros;
    
    return copyWith(
      completedPomodoros: newCount,
      isCompleted: shouldComplete,
      endTime: shouldComplete ? DateTime.now() : null,
    );
  }

  /// Start new cycle
  PomodoroCycleModel startNew() {
    return PomodoroCycleModel(
      startTime: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Get cycle statistics
  Map<String, dynamic> getStatistics(int longBreakInterval) {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completedPomodoros': completedPomodoros,
      'totalPomodoros': totalPomodoros,
      'isCompleted': isCompleted,
      'isActive': isActive,
      'progressPercentage': progressPercentage,
      'cycleDuration': cycleDuration.inMinutes,
      'sessionCount': sessionIdList.length,
      'shouldTakeLongBreak': shouldTakeLongBreak(longBreakInterval),
    };
  }

  @override
  String toString() {
    return 'PomodoroCycleModel(id: $id, startTime: $startTime, endTime: $endTime, completedPomodoros: $completedPomodoros, totalPomodoros: $totalPomodoros, isCompleted: $isCompleted, sessionIds: $sessionIds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PomodoroCycleModel &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.completedPomodoros == completedPomodoros &&
        other.totalPomodoros == totalPomodoros &&
        other.isCompleted == isCompleted &&
        other.sessionIds == sessionIds &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        completedPomodoros.hashCode ^
        totalPomodoros.hashCode ^
        isCompleted.hashCode ^
        sessionIds.hashCode ^
        createdAt.hashCode;
  }
}
