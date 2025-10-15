import '../../domain/repositories/session_repository.dart';
import '../models/session_model.dart';
import '../database/database_helper.dart';

/// Implementation của SessionRepository sử dụng SQLite
class SessionRepositoryImpl implements SessionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  @override
  Future<int> createSession(SessionModel session) async {
    return await _databaseHelper.insertSession(session);
  }
  
  @override
  Future<List<SessionModel>> getAllSessions() async {
    return await _databaseHelper.getAllSessions();
  }
  
  @override
  Future<List<SessionModel>> getSessionsByTaskId(int taskId) async {
    return await _databaseHelper.getSessionsByTaskId(taskId);
  }
  
  @override
  Future<SessionModel?> getActiveSession() async {
    return await _databaseHelper.getActiveSession();
  }
  
  @override
  Future<int> updateSession(SessionModel session) async {
    return await _databaseHelper.updateSession(session);
  }
  
  @override
  Future<int> deleteSession(int id) async {
    return await _databaseHelper.deleteSession(id);
  }
  
  @override
  Future<List<SessionModel>> getSessionsByType(SessionType sessionType) async {
    return await _databaseHelper.getSessionsByType(sessionType);
  }
  
  @override
  Future<List<SessionModel>> getTodayCompletedSessions() async {
    return await _databaseHelper.getTodayCompletedSessions();
  }
  
  @override
  Future<int> startSession(int sessionId) async {
    final session = await _getSessionById(sessionId);
    if (session == null) return 0;
    
    final updatedSession = session.copyWith(
      startTime: DateTime.now(),
    );
    
    return await updateSession(updatedSession);
  }
  
  @override
  Future<int> endSession(int sessionId) async {
    final session = await _getSessionById(sessionId);
    if (session == null) return 0;
    
    final now = DateTime.now();
    final actualDuration = session.startTime != null 
        ? now.difference(session.startTime!).inSeconds 
        : 0;
    
    final updatedSession = session.copyWith(
      endTime: now,
      actualDuration: actualDuration,
      isCompleted: true,
    );
    
    return await updateSession(updatedSession);
  }
  
  @override
  Future<Map<String, dynamic>> getStatistics() async {
    return await _databaseHelper.getStatistics();
  }
  
  @override
  Future<Map<String, dynamic>> getTodayStatistics() async {
    return await _databaseHelper.getTodayStatistics();
  }
  
  /// Helper method để lấy session theo ID
  Future<SessionModel?> _getSessionById(int id) async {
    final sessions = await getAllSessions();
    try {
      return sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }
}
