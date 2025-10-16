import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';
import '../models/session_model.dart';
import '../models/pomodoro_cycle_model.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  
  // Private constructor
  DatabaseHelper._internal();
  
  static Database? _database;
  
  // Database configuration
  static const String _databaseName = 'pomoduck.db';
  static const int _databaseVersion = 1;
  
  // Table names
  static const String _tasksTable = 'tasks';
  static const String _sessionsTable = 'sessions';
  static const String _pomodoroCyclesTable = 'pomodoro_cycles';
  
  /// Getter cho database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Khởi tạo database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }
  
  /// Tạo database và tables
  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng tasks
    await db.execute('''
      CREATE TABLE $_tasksTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        estimated_pomodoros INTEGER NOT NULL DEFAULT 1,
        completed_pomodoros INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        tag TEXT
      )
    ''');
    
    // Tạo bảng sessions
    await db.execute('''
      CREATE TABLE $_sessionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        session_type TEXT NOT NULL,
        planned_duration INTEGER NOT NULL,
        actual_duration INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        start_time TEXT,
        end_time TEXT,
        created_at TEXT NOT NULL,
        tag TEXT,
        FOREIGN KEY (task_id) REFERENCES $_tasksTable (id) ON DELETE SET NULL
      )
    ''');
    
    // Tạo bảng pomodoro_cycles
    await db.execute('''
      CREATE TABLE $_pomodoroCyclesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        completed_pomodoros INTEGER NOT NULL DEFAULT 0,
        total_pomodoros INTEGER NOT NULL DEFAULT 4,
        is_completed INTEGER NOT NULL DEFAULT 0,
        session_ids TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL
      )
    ''');
    
    // Tạo indexes để tối ưu performance
    await db.execute('CREATE INDEX idx_tasks_created_at ON $_tasksTable (created_at)');
    await db.execute('CREATE INDEX idx_tasks_is_completed ON $_tasksTable (is_completed)');
    await db.execute('CREATE INDEX idx_sessions_task_id ON $_sessionsTable (task_id)');
    await db.execute('CREATE INDEX idx_sessions_created_at ON $_sessionsTable (created_at)');
    await db.execute('CREATE INDEX idx_sessions_session_type ON $_sessionsTable (session_type)');
    await db.execute('CREATE INDEX idx_pomodoro_cycles_start_time ON $_pomodoroCyclesTable (start_time)');
    await db.execute('CREATE INDEX idx_pomodoro_cycles_is_completed ON $_pomodoroCyclesTable (is_completed)');
    await db.execute('CREATE INDEX idx_pomodoro_cycles_created_at ON $_pomodoroCyclesTable (created_at)');
  }
  
  /// Upgrade database không còn sử dụng (schema đã đầy đủ ngay từ onCreate)
  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}
  
  /// Đóng database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
  
  // ==================== TASK OPERATIONS ====================
  
  /// Tạo task mới
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert(_tasksTable, task.toMap());
  }
  
  /// Lấy tất cả tasks
  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }
  
  /// Lấy task theo ID
  Future<TaskModel?> getTaskById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TaskModel.fromMap(maps.first);
    }
    return null;
  }
  
  /// Cập nhật task
  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      _tasksTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
  
  /// Xóa task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      _tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Lấy tasks chưa hoàn thành
  Future<List<TaskModel>> getIncompleteTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'is_completed = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }
  
  /// Lấy tasks đã hoàn thành
  Future<List<TaskModel>> getCompletedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  /// Tăng số pomodoro đã hoàn thành
  Future<int> incrementCompletedPomodoros(int taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) return 0;
    
    final updatedTask = task.copyWith(
      completedPomodoros: task.completedPomodoros + 1,
      updatedAt: DateTime.now(),
    );
    
    return await updateTask(updatedTask);
  }
  
  // ==================== SESSION OPERATIONS ====================
  
  /// Tạo session mới
  Future<int> insertSession(SessionModel session) async {
    final db = await database;
    return await db.insert(_sessionsTable, session.toMap());
  }
  
  /// Lấy tất cả sessions
  Future<List<SessionModel>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _sessionsTable,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SessionModel.fromMap(map)).toList();
  }
  
  /// Lấy sessions theo task ID
  Future<List<SessionModel>> getSessionsByTaskId(int taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _sessionsTable,
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SessionModel.fromMap(map)).toList();
  }

  /// Lấy session theo ID
  Future<SessionModel?> getSessionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _sessionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SessionModel.fromMap(maps.first);
    }
    return null;
  }
  
  /// Lấy session đang active
  Future<SessionModel?> getActiveSession() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _sessionsTable,
      where: 'start_time IS NOT NULL AND end_time IS NULL AND is_completed = ?',
      whereArgs: [0],
      orderBy: 'start_time DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return SessionModel.fromMap(maps.first);
    }
    return null;
  }
  
  /// Cập nhật session
  Future<int> updateSession(SessionModel session) async {
    final db = await database;
    return await db.update(
      _sessionsTable,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }
  
  /// Xóa session
  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete(
      _sessionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Lấy sessions theo loại
  Future<List<SessionModel>> getSessionsByType(SessionType sessionType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _sessionsTable,
      where: 'session_type = ?',
      whereArgs: [sessionType.value],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SessionModel.fromMap(map)).toList();
  }
  
  /// Lấy sessions hoàn thành hôm nay
  Future<List<SessionModel>> getTodayCompletedSessions() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      _sessionsTable,
      where: 'is_completed = ? AND end_time >= ? AND end_time < ?',
      whereArgs: [1, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'end_time DESC',
    );
    return maps.map((map) => SessionModel.fromMap(map)).toList();
  }
  
  // ==================== ANALYTICS OPERATIONS ====================
  
  /// Lấy thống kê tổng quan
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    // Tổng số tasks
    final totalTasksResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tasksTable');
    final totalTasks = totalTasksResult.first['count'] as int;
    
    // Tasks đã hoàn thành
    final completedTasksResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tasksTable WHERE is_completed = 1'
    );
    final completedTasks = completedTasksResult.first['count'] as int;
    
    // Tổng số sessions hoàn thành
    final completedSessionsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_sessionsTable WHERE is_completed = 1'
    );
    final completedSessions = completedSessionsResult.first['count'] as int;
    
    // Tổng thời gian tập trung (work sessions)
    final workTimeResult = await db.rawQuery(
      'SELECT SUM(actual_duration) as total FROM $_sessionsTable WHERE session_type = ? AND is_completed = 1',
      ['work']
    );
    final totalWorkTime = workTimeResult.first['total'] as int? ?? 0;
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'completedSessions': completedSessions,
      'totalWorkTime': totalWorkTime,
      'completionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
    };
  }
  
  /// Lấy thống kê theo ngày
  Future<Map<String, dynamic>> getTodayStatistics() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // Sessions hoàn thành hôm nay
    final todaySessionsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_sessionsTable WHERE is_completed = 1 AND end_time >= ? AND end_time < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
    );
    final todaySessions = todaySessionsResult.first['count'] as int;
    
    // Thời gian tập trung hôm nay
    final todayWorkTimeResult = await db.rawQuery(
      'SELECT SUM(actual_duration) as total FROM $_sessionsTable WHERE session_type = ? AND is_completed = 1 AND end_time >= ? AND end_time < ?',
      ['work', startOfDay.toIso8601String(), endOfDay.toIso8601String()]
    );
    final todayWorkTime = todayWorkTimeResult.first['total'] as int? ?? 0;
    
    return {
      'todaySessions': todaySessions,
      'todayWorkTime': todayWorkTime,
    };
  }

  // ==================== POMODORO CYCLE OPERATIONS ====================

  /// Tạo pomodoro cycle mới
  Future<int> insertPomodoroCycle(PomodoroCycleModel cycle) async {
    final db = await database;
    return await db.insert(_pomodoroCyclesTable, cycle.toMap());
  }

  /// Lấy tất cả pomodoro cycles
  Future<List<PomodoroCycleModel>> getAllPomodoroCycles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _pomodoroCyclesTable,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PomodoroCycleModel.fromMap(map)).toList();
  }

  /// Lấy pomodoro cycle theo ID
  Future<PomodoroCycleModel?> getPomodoroCycleById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _pomodoroCyclesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PomodoroCycleModel.fromMap(maps.first);
    }
    return null;
  }

  /// Lấy pomodoro cycle đang active
  Future<PomodoroCycleModel?> getActivePomodoroCycle() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _pomodoroCyclesTable,
      where: 'is_completed = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return PomodoroCycleModel.fromMap(maps.first);
    }
    return null;
  }

  /// Cập nhật pomodoro cycle
  Future<int> updatePomodoroCycle(PomodoroCycleModel cycle) async {
    final db = await database;
    return await db.update(
      _pomodoroCyclesTable,
      cycle.toMap(),
      where: 'id = ?',
      whereArgs: [cycle.id],
    );
  }

  /// Xóa pomodoro cycle
  Future<int> deletePomodoroCycle(int id) async {
    final db = await database;
    return await db.delete(
      _pomodoroCyclesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Lấy pomodoro cycles hoàn thành
  Future<List<PomodoroCycleModel>> getCompletedPomodoroCycles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _pomodoroCyclesTable,
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PomodoroCycleModel.fromMap(map)).toList();
  }

  /// Lấy pomodoro cycles hôm nay
  Future<List<PomodoroCycleModel>> getTodayPomodoroCycles() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      _pomodoroCyclesTable,
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PomodoroCycleModel.fromMap(map)).toList();
  }

  /// Lấy thống kê pomodoro cycles
  Future<Map<String, dynamic>> getPomodoroCycleStatistics() async {
    final db = await database;
    
    // Tổng số cycles
    final totalCyclesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_pomodoroCyclesTable'
    );
    final totalCycles = totalCyclesResult.first['count'] as int;
    
    // Cycles hoàn thành
    final completedCyclesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_pomodoroCyclesTable WHERE is_completed = 1'
    );
    final completedCycles = completedCyclesResult.first['count'] as int;
    
    // Tổng số pomodoros hoàn thành
    final totalPomodorosResult = await db.rawQuery(
      'SELECT SUM(completed_pomodoros) as total FROM $_pomodoroCyclesTable'
    );
    final totalPomodoros = totalPomodorosResult.first['total'] as int? ?? 0;
    
    // Cycles hôm nay
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final todayCyclesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_pomodoroCyclesTable WHERE created_at >= ? AND created_at < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
    );
    final todayCycles = todayCyclesResult.first['count'] as int;
    
    return {
      'totalCycles': totalCycles,
      'completedCycles': completedCycles,
      'totalPomodoros': totalPomodoros,
      'todayCycles': todayCycles,
    };
  }
}
