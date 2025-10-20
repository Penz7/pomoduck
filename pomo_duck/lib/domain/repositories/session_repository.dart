import '../../data/models/session_model.dart';

/// Abstract repository interface cho Session operations
abstract class SessionRepository {
  /// Tạo session mới
  Future<int> createSession(SessionModel session);
  
  /// Lấy tất cả sessions
  Future<List<SessionModel>> getAllSessions();
  
  /// Lấy sessions theo task ID
  Future<List<SessionModel>> getSessionsByTaskId(int taskId);
  
  /// Lấy session đang active
  Future<SessionModel?> getActiveSession();
  
  /// Cập nhật session
  Future<int> updateSession(SessionModel session);
  
  /// Xóa session
  Future<int> deleteSession(int id);
  
  /// Lấy sessions theo loại
  Future<List<SessionModel>> getSessionsByType(SessionType sessionType);
  
  /// Lấy sessions hoàn thành hôm nay
  Future<List<SessionModel>> getTodayCompletedSessions();
  
  /// Bắt đầu session
  Future<int> startSession(int sessionId);
  
  /// Kết thúc session
  Future<int> endSession(int sessionId);
  
}
