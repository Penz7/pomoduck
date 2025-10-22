import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/task_model.dart';
import '../models/session_model.dart';
import '../models/pomodoro_cycle_model.dart';
import '../models/statistics_model.dart';
import '../models/shop_item_model.dart';
import '../../generated/locale_keys.g.dart';

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
  static const String _shopItemsTable = 'shop_items';
  
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
    
    // Tạo bảng shop_items
    await db.execute('''
      CREATE TABLE $_shopItemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price INTEGER NOT NULL,
        item_type TEXT NOT NULL,
        icon_path TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        purchased_at TEXT,
        expires_at TEXT,
        created_at TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0
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
    await db.execute('CREATE INDEX idx_shop_items_item_type ON $_shopItemsTable (item_type)');
    await db.execute('CREATE INDEX idx_shop_items_is_active ON $_shopItemsTable (is_active)');
    await db.execute('CREATE INDEX idx_shop_items_created_at ON $_shopItemsTable (created_at)');
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

  // ==================== ADVANCED STATISTICS OPERATIONS ====================

  /// Lấy thống kê chi tiết theo khoảng thời gian
  Future<StatisticsModel> getDetailedStatistics({
    required DateTime startDate,
    required DateTime endDate,
    String periodType = 'custom',
  }) async {
    final db = await database;
    
    // Tổng số tasks trong khoảng thời gian
    final totalTasksResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $_tasksTable 
      WHERE created_at >= ? AND created_at <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final totalTasks = totalTasksResult.first['count'] as int;
    
    // Tasks đã hoàn thành trong khoảng thời gian
    final completedTasksResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $_tasksTable 
      WHERE is_completed = 1 AND updated_at >= ? AND updated_at <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final completedTasks = completedTasksResult.first['count'] as int;
    
    // Tổng số sessions trong khoảng thời gian
    final totalSessionsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $_sessionsTable 
      WHERE created_at >= ? AND created_at <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final totalSessions = totalSessionsResult.first['count'] as int;
    
    // Sessions đã hoàn thành trong khoảng thời gian
    final completedSessionsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $_sessionsTable 
      WHERE is_completed = 1 AND end_time >= ? AND end_time <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final completedSessions = completedSessionsResult.first['count'] as int;
    
    // Tổng thời gian làm việc (work sessions)
    final workTimeResult = await db.rawQuery('''
      SELECT SUM(actual_duration) as total FROM $_sessionsTable 
      WHERE session_type = 'work' AND is_completed = 1 
      AND end_time >= ? AND end_time <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final totalWorkTime = workTimeResult.first['total'] as int? ?? 0;
    
    // Tổng thời gian nghỉ (break sessions)
    final breakTimeResult = await db.rawQuery('''
      SELECT SUM(actual_duration) as total FROM $_sessionsTable 
      WHERE session_type IN ('short_break', 'long_break') AND is_completed = 1 
      AND end_time >= ? AND end_time <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final totalBreakTime = breakTimeResult.first['total'] as int? ?? 0;
    
    // Tính tỷ lệ hoàn thành
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
    
    // Tính điểm hiệu suất (dựa trên tần suất và thời gian)
    final days = endDate.difference(startDate).inDays + 1;
    final averageSessionsPerDay = completedSessions / days;
    final averageWorkTimePerDay = (totalWorkTime / 60) / days; // phút
    final productivityScore = ((averageSessionsPerDay / 8) * 50 + (averageWorkTimePerDay / 240) * 50).clamp(0, 100);
    
    return StatisticsModel(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      totalSessions: totalSessions,
      completedSessions: completedSessions,
      totalWorkTime: totalWorkTime,
      totalBreakTime: totalBreakTime,
      completionRate: completionRate.toDouble(),
      productivityScore: productivityScore.toDouble(),
      periodStart: startDate,
      periodEnd: endDate,
      periodType: periodType,
    );
  }

  /// Lấy thống kê theo ngày trong khoảng thời gian
  Future<List<DailyStatisticsModel>> getDailyStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await database;
    final List<DailyStatisticsModel> dailyStats = [];
    
    // Lấy dữ liệu sessions theo ngày
    final sessionsResult = await db.rawQuery('''
      SELECT 
        DATE(end_time) as date,
        COUNT(*) as sessions_completed,
        SUM(CASE WHEN session_type = 'work' THEN actual_duration ELSE 0 END) as work_time,
        SUM(CASE WHEN session_type IN ('short_break', 'long_break') THEN actual_duration ELSE 0 END) as break_time
      FROM $_sessionsTable 
      WHERE is_completed = 1 AND end_time >= ? AND end_time <= ?
      GROUP BY DATE(end_time)
      ORDER BY date
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Lấy dữ liệu tasks theo ngày
    final tasksResult = await db.rawQuery('''
      SELECT 
        DATE(updated_at) as date,
        COUNT(*) as tasks_completed
      FROM $_tasksTable 
      WHERE is_completed = 1 AND updated_at >= ? AND updated_at <= ?
      GROUP BY DATE(updated_at)
      ORDER BY date
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Tạo map cho tasks
    final tasksMap = <String, int>{};
    for (final task in tasksResult) {
      tasksMap[task['date'] as String] = task['tasks_completed'] as int;
    }
    
    // Tạo daily statistics
    for (final session in sessionsResult) {
      final date = DateTime.parse(session['date'] as String);
      final sessionsCompleted = session['sessions_completed'] as int;
      final workTime = session['work_time'] as int? ?? 0;
      final breakTime = session['break_time'] as int? ?? 0;
      final tasksCompleted = tasksMap[session['date'] as String] ?? 0;
      
      // Tính điểm hiệu suất cho ngày
      final productivityScore = _calculateDailyProductivityScore(
        sessionsCompleted, workTime, tasksCompleted,
      );
      
      dailyStats.add(DailyStatisticsModel(
        date: date,
        sessionsCompleted: sessionsCompleted,
        workTime: workTime,
        breakTime: breakTime,
        tasksCompleted: tasksCompleted,
        productivityScore: productivityScore,
      ));
    }
    
    return dailyStats;
  }

  /// Lấy thống kê theo tuần trong khoảng thời gian
  Future<List<WeeklyStatisticsModel>> getWeeklyStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await database;
    final List<WeeklyStatisticsModel> weeklyStats = [];
    
    // Lấy dữ liệu sessions theo tuần
    final sessionsResult = await db.rawQuery('''
      SELECT 
        strftime('%Y-%W', end_time) as week,
        COUNT(*) as sessions_completed,
        SUM(CASE WHEN session_type = 'work' THEN actual_duration ELSE 0 END) as work_time,
        SUM(CASE WHEN session_type IN ('short_break', 'long_break') THEN actual_duration ELSE 0 END) as break_time,
        COUNT(DISTINCT DATE(end_time)) as active_days
      FROM $_sessionsTable 
      WHERE is_completed = 1 AND end_time >= ? AND end_time <= ?
      GROUP BY strftime('%Y-%W', end_time)
      ORDER BY week
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Lấy dữ liệu tasks theo tuần
    final tasksResult = await db.rawQuery('''
      SELECT 
        strftime('%Y-%W', updated_at) as week,
        COUNT(*) as tasks_completed
      FROM $_tasksTable 
      WHERE is_completed = 1 AND updated_at >= ? AND updated_at <= ?
      GROUP BY strftime('%Y-%W', updated_at)
      ORDER BY week
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Tạo map cho tasks
    final tasksMap = <String, int>{};
    for (final task in tasksResult) {
      tasksMap[task['week'] as String] = task['tasks_completed'] as int;
    }
    
    // Tạo weekly statistics
    for (final session in sessionsResult) {
      final weekStr = session['week'] as String;
      final year = int.parse(weekStr.split('-')[0]);
      final week = int.parse(weekStr.split('-')[1]);
      
      // Tính ngày đầu và cuối tuần
      final weekStart = _getWeekStart(year, week);
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      final sessionsCompleted = session['sessions_completed'] as int;
      final workTime = session['work_time'] as int? ?? 0;
      final breakTime = session['break_time'] as int? ?? 0;
      final tasksCompleted = tasksMap[weekStr] ?? 0;
      final activeDays = session['active_days'] as int;
      
      // Tính điểm hiệu suất trung bình cho tuần
      final averageProductivityScore = _calculateWeeklyProductivityScore(
        sessionsCompleted, workTime, tasksCompleted, activeDays,
      );
      
      weeklyStats.add(WeeklyStatisticsModel(
        weekStart: weekStart,
        weekEnd: weekEnd,
        sessionsCompleted: sessionsCompleted,
        workTime: workTime,
        breakTime: breakTime,
        tasksCompleted: tasksCompleted,
        averageProductivityScore: averageProductivityScore,
        activeDays: activeDays,
      ));
    }
    
    return weeklyStats;
  }

  /// Lấy thống kê theo tháng trong khoảng thời gian
  Future<List<MonthlyStatisticsModel>> getMonthlyStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await database;
    final List<MonthlyStatisticsModel> monthlyStats = [];
    
    // Lấy dữ liệu sessions theo tháng
    final sessionsResult = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', end_time) as month,
        COUNT(*) as sessions_completed,
        SUM(CASE WHEN session_type = 'work' THEN actual_duration ELSE 0 END) as work_time,
        SUM(CASE WHEN session_type IN ('short_break', 'long_break') THEN actual_duration ELSE 0 END) as break_time,
        COUNT(DISTINCT DATE(end_time)) as active_days,
        COUNT(DISTINCT strftime('%Y-%W', end_time)) as active_weeks
      FROM $_sessionsTable 
      WHERE is_completed = 1 AND end_time >= ? AND end_time <= ?
      GROUP BY strftime('%Y-%m', end_time)
      ORDER BY month
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Lấy dữ liệu tasks theo tháng
    final tasksResult = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', updated_at) as month,
        COUNT(*) as tasks_completed
      FROM $_tasksTable 
      WHERE is_completed = 1 AND updated_at >= ? AND updated_at <= ?
      GROUP BY strftime('%Y-%m', updated_at)
      ORDER BY month
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Tạo map cho tasks
    final tasksMap = <String, int>{};
    for (final task in tasksResult) {
      tasksMap[task['month'] as String] = task['tasks_completed'] as int;
    }
    
    // Tạo monthly statistics
    for (final session in sessionsResult) {
      final monthStr = session['month'] as String;
      final year = int.parse(monthStr.split('-')[0]);
      final month = int.parse(monthStr.split('-')[1]);
      
      // Tính ngày đầu và cuối tháng
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0);
      
      final sessionsCompleted = session['sessions_completed'] as int;
      final workTime = session['work_time'] as int? ?? 0;
      final breakTime = session['break_time'] as int? ?? 0;
      final tasksCompleted = tasksMap[monthStr] ?? 0;
      final activeDays = session['active_days'] as int;
      final activeWeeks = session['active_weeks'] as int;
      
      // Tính điểm hiệu suất trung bình cho tháng
      final averageProductivityScore = _calculateMonthlyProductivityScore(
        sessionsCompleted, workTime, tasksCompleted, activeDays, activeWeeks,
      );
      
      monthlyStats.add(MonthlyStatisticsModel(
        monthStart: monthStart,
        monthEnd: monthEnd,
        sessionsCompleted: sessionsCompleted,
        workTime: workTime,
        breakTime: breakTime,
        tasksCompleted: tasksCompleted,
        averageProductivityScore: averageProductivityScore,
        activeDays: activeDays,
        activeWeeks: activeWeeks,
      ));
    }
    
    return monthlyStats;
  }

  /// Lấy patterns của sessions
  Future<SessionPatternsModel> getSessionPatterns({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await database;
    
    // Thống kê thời gian session
    final sessionDurationResult = await db.rawQuery('''
      SELECT 
        AVG(actual_duration) as avg_duration,
        actual_duration as duration,
        COUNT(*) as count
      FROM $_sessionsTable 
      WHERE session_type = 'work' AND is_completed = 1 
      AND end_time >= ? AND end_time <= ?
      GROUP BY actual_duration
      ORDER BY count DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Thống kê thời gian nghỉ
    final breakDurationResult = await db.rawQuery('''
      SELECT 
        session_type,
        AVG(actual_duration) as avg_duration
      FROM $_sessionsTable 
      WHERE session_type IN ('short_break', 'long_break') AND is_completed = 1 
      AND end_time >= ? AND end_time <= ?
      GROUP BY session_type
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Thống kê theo giờ trong ngày
    final hourlyResult = await db.rawQuery('''
      SELECT 
        strftime('%H', end_time) as hour,
        COUNT(*) as count
      FROM $_sessionsTable 
      WHERE is_completed = 1 AND end_time >= ? AND end_time <= ?
      GROUP BY strftime('%H', end_time)
      ORDER BY count DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Thống kê theo ngày trong tuần
    final dailyResult = await db.rawQuery('''
      SELECT 
        strftime('%w', end_time) as day_of_week,
        COUNT(*) as count
      FROM $_sessionsTable 
      WHERE is_completed = 1 AND end_time >= ? AND end_time <= ?
      GROUP BY strftime('%w', end_time)
      ORDER BY count DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Tính toán kết quả
    final averageSessionDuration = sessionDurationResult.isNotEmpty 
        ? (sessionDurationResult.first['avg_duration'] as num).toInt()
        : 0;
    
    final mostCommonSessionDuration = sessionDurationResult.isNotEmpty
        ? sessionDurationResult.first['duration'] as int
        : 0;
    
    int averageShortBreakDuration = 0;
    int averageLongBreakDuration = 0;
    
    for (final breakData in breakDurationResult) {
      if (breakData['session_type'] == 'short_break') {
        averageShortBreakDuration = (breakData['avg_duration'] as num).toInt();
      } else if (breakData['session_type'] == 'long_break') {
        averageLongBreakDuration = (breakData['avg_duration'] as num).toInt();
      }
    }
    
    // Tạo distribution maps
    final sessionDurationDistribution = <String, int>{};
    for (final session in sessionDurationResult) {
      final duration = session['duration'] as int;
      final count = session['count'] as int;
      sessionDurationDistribution['${duration ~/ 60} ${LocaleKeys.minutes.tr()}'] = count;
    }
    
    final breakDurationDistribution = <String, int>{};
    for (final breakData in breakDurationResult) {
      final sessionType = breakData['session_type'] as String;
      final avgDuration = (breakData['avg_duration'] as num).toInt();
      breakDurationDistribution[sessionType == 'short_break' ? LocaleKeys.short_break_label.tr() : LocaleKeys.long_break_label.tr()] = avgDuration;
    }
    
    // Tìm giờ và ngày hiệu suất cao nhất
    final mostProductiveHour = hourlyResult.isNotEmpty 
        ? '${hourlyResult.first['hour']}:00'
        : '09:00';
    
    final mostProductiveDay = dailyResult.isNotEmpty 
        ? _getDayName(int.parse(dailyResult.first['day_of_week'] as String))
        : 'Thứ 2';
    
    return SessionPatternsModel(
      averageSessionDuration: averageSessionDuration,
      mostCommonSessionDuration: mostCommonSessionDuration,
      averageShortBreakDuration: averageShortBreakDuration,
      averageLongBreakDuration: averageLongBreakDuration,
      sessionDurationDistribution: sessionDurationDistribution,
      breakDurationDistribution: breakDurationDistribution,
      mostProductiveHour: mostProductiveHour,
      mostProductiveDay: mostProductiveDay,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Tính điểm hiệu suất cho ngày
  double _calculateDailyProductivityScore(int sessions, int workTime, int tasks) {
    final sessionScore = (sessions / 8) * 40; // 8 sessions = 40 điểm
    final timeScore = (workTime / 14400) * 40; // 4 giờ = 40 điểm (14400 giây)
    final taskScore = (tasks / 5) * 20; // 5 tasks = 20 điểm
    
    return (sessionScore + timeScore + taskScore).clamp(0, 100);
  }

  /// Tính điểm hiệu suất cho tuần
  double _calculateWeeklyProductivityScore(int sessions, int workTime, int tasks, int activeDays) {
    final sessionScore = (sessions / 40) * 30; // 40 sessions/tuần = 30 điểm
    final timeScore = (workTime / 100800) * 30; // 28 giờ/tuần = 30 điểm
    final taskScore = (tasks / 25) * 20; // 25 tasks/tuần = 20 điểm
    final consistencyScore = (activeDays / 7) * 20; // 7 ngày/tuần = 20 điểm
    
    return (sessionScore + timeScore + taskScore + consistencyScore).clamp(0, 100);
  }

  /// Tính điểm hiệu suất cho tháng
  double _calculateMonthlyProductivityScore(int sessions, int workTime, int tasks, int activeDays, int activeWeeks) {
    final sessionScore = (sessions / 160) * 25; // 160 sessions/tháng = 25 điểm
    final timeScore = (workTime / 403200) * 25; // 112 giờ/tháng = 25 điểm
    final taskScore = (tasks / 100) * 20; // 100 tasks/tháng = 20 điểm
    final consistencyScore = (activeDays / 30) * 15; // 30 ngày/tháng = 15 điểm
    final weeklyConsistencyScore = (activeWeeks / 4) * 15; // 4 tuần/tháng = 15 điểm
    
    return (sessionScore + timeScore + taskScore + consistencyScore + weeklyConsistencyScore).clamp(0, 100);
  }

  /// Lấy ngày đầu tuần
  DateTime _getWeekStart(int year, int week) {
    final jan1 = DateTime(year, 1, 1);
    final daysToAdd = (week - 1) * 7;
    return jan1.add(Duration(days: daysToAdd));
  }

  /// Lấy tên ngày trong tuần
  String _getDayName(int dayOfWeek) {
    final days = [
      LocaleKeys.sunday.tr(),
      LocaleKeys.monday.tr(),
      LocaleKeys.tuesday.tr(),
      LocaleKeys.wednesday.tr(),
      LocaleKeys.thursday.tr(),
      LocaleKeys.friday.tr(),
      LocaleKeys.saturday.tr(),
    ];
    return days[dayOfWeek];
  }

  // ==================== SHOP ITEMS OPERATIONS ====================
  
  /// Tạo shop item mới
  Future<int> insertShopItem(ShopItemModel item) async {
    final db = await database;
    return await db.insert(_shopItemsTable, item.toMap());
  }
  
  /// Lấy tất cả shop items
  Future<List<ShopItemModel>> getAllShopItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _shopItemsTable,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => ShopItemModel.fromMap(map)).toList();
  }
  
  /// Lấy shop item theo ID
  Future<ShopItemModel?> getShopItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _shopItemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ShopItemModel.fromMap(maps.first);
    }
    return null;
  }
  
  /// Lấy shop items theo loại
  Future<List<ShopItemModel>> getShopItemsByType(String itemType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _shopItemsTable,
      where: 'item_type = ?',
      whereArgs: [itemType],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => ShopItemModel.fromMap(map)).toList();
  }
  
  /// Lấy shop items đang active
  Future<List<ShopItemModel>> getActiveShopItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _shopItemsTable,
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => ShopItemModel.fromMap(map)).toList();
  }
  
  /// Cập nhật shop item
  Future<int> updateShopItem(ShopItemModel item) async {
    final db = await database;
    return await db.update(
      _shopItemsTable,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
  
  /// Xóa shop item
  Future<int> deleteShopItem(int id) async {
    final db = await database;
    return await db.delete(
      _shopItemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Khởi tạo shop items mặc định
  Future<void> initializeDefaultShopItems() async {
    final existingItems = await getAllShopItems();
    if (existingItems.isNotEmpty) return; // Đã có items rồi
    
    final defaultItems = [
      ShopItemModel(
        name: 'Khiên Bảo Vệ',
        description: 'Được thêm cơ hội nếu khi dừng task đang làm giữa chừng thì không bị mất streak',
        price: 1500,
        itemType: 'shield',
        iconPath: 'assets/icons/shield.png',
        createdAt: DateTime.now(),
      ),
      ShopItemModel(
        name: 'Kiếm Thời Gian',
        description: 'Được -5 phút mỗi khi đang làm việc (số phút sẽ được trừ thẳng vào thời gian đang đếm ngược)',
        price: 1000,
        itemType: 'sword',
        iconPath: 'assets/icons/sword.png',
        createdAt: DateTime.now(),
      ),
      ShopItemModel(
        name: 'Cà Phê Năng Lượng',
        description: 'Được tăng thời gian nghỉ ngơi của task đang làm lên 5 phút',
        price: 500,
        itemType: 'coffee',
        iconPath: 'assets/icons/coffee.png',
        createdAt: DateTime.now(),
      ),
    ];
    
    for (final item in defaultItems) {
      await insertShopItem(item);
    }
  }

  // ==================== CLEAR DATA OPERATIONS ====================

  /// Xóa toàn bộ dữ liệu trong database
  Future<void> clearAllData() async {
    final db = await database;
    
    // Xóa tất cả dữ liệu từ các bảng
    await db.delete(_pomodoroCyclesTable);
    await db.delete(_sessionsTable);
    await db.delete(_tasksTable);
    await db.delete(_shopItemsTable);
  }
}
