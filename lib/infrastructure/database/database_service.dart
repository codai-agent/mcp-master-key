import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/path_constants.dart';
import '../../data/database/database_schema.dart';

/// 数据库服务类
class DatabaseService {
  static DatabaseService? _instance;
  Database? _database;

  DatabaseService._internal();

  /// 获取单例实例
  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    print('🗄️ Initializing database...');

    // 初始化FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // 获取数据库路径
    final dbPath = await _getDatabasePath();
    print('📍 Database path: $dbPath');

    // 打开数据库
    final database = await openDatabase(
      dbPath,
      version: AppConstants.databaseVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
      onOpen: (db) async {
        // 启用外键约束
        await db.execute('PRAGMA foreign_keys = ON');
        print('✅ Database opened successfully');
      },
    );

    return database;
  }

  /// 获取数据库文件路径（使用用户主目录）
  Future<String> _getDatabasePath() async {
    final dbDir = Directory(PathConstants.getUserMcpHubPath());
    
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    return path.join(dbDir.path, AppConstants.databaseName);
  }

  /// 创建数据表
  Future<void> _createTables(Database db, int version) async {
    print('📋 Creating database tables...');

    // 使用新的数据库模式创建所有表
    for (final script in DatabaseSchema.createTableScripts) {
      await db.execute(script);
    }

    // 创建索引
    await _createIndexes(db);

    print('✅ Database tables created successfully');
  }

  /// 创建索引
  Future<void> _createIndexes(Database db) async {
    print('📊 Creating database indexes...');

    // 使用新的数据库模式创建所有索引
    for (final script in DatabaseIndexes.createIndexScripts) {
      await db.execute(script);
    }

    print('✅ Database indexes created successfully');
  }

  /// 升级数据库
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from version $oldVersion to $newVersion...');
    
    // 从版本1升级到版本2：添加install_source列
    if (oldVersion < 2) {
      print('📝 Adding install_source column to mcp_servers table...');
      await db.execute('ALTER TABLE mcp_servers ADD COLUMN install_source TEXT');
      print('✅ install_source column added');
    }
    
    // 从版本2升级到版本3：添加error_message和log_level列，创建新表
    if (oldVersion < 3) {
      print('📝 Adding error_message and log_level columns to mcp_servers table...');
      await db.execute('ALTER TABLE mcp_servers ADD COLUMN error_message TEXT');
      await db.execute('ALTER TABLE mcp_servers ADD COLUMN log_level TEXT NOT NULL DEFAULT \'info\'');
      print('✅ error_message and log_level columns added');
      
      // 创建新的表（如果不存在）
      print('📝 Creating new tables for version 3...');
      final newTables = [
        DatabaseSchema.createServerLifecycleEventsTable,
        DatabaseSchema.createServerRuntimeStatsTable,
        DatabaseSchema.createServerLogsTable,
        DatabaseSchema.createMcpRequestsTable,
        DatabaseSchema.createSystemEventsTable,
      ];
      
      for (final tableScript in newTables) {
        try {
          await db.execute(tableScript);
        } catch (e) {
          // 表可能已经存在，忽略错误
          print('⚠️ Table creation skipped (may already exist): $e');
        }
      }
      
      // 创建新的索引
      print('📊 Creating new indexes for version 3...');
      for (final indexScript in DatabaseIndexes.createIndexScripts) {
        try {
          await db.execute(indexScript);
        } catch (e) {
          // 索引可能已经存在，忽略错误
          print('⚠️ Index creation skipped (may already exist): $e');
        }
      }
      print('✅ New tables and indexes created');
    }
    
    // 从版本3升级到版本4：确保表名一致性
    if (oldVersion < 4) {
      print('📝 Ensuring database schema consistency for version 4...');
      
      // 检查是否存在旧的mcp_log_entries表，如果有则删除
      try {
        await db.execute('DROP TABLE IF EXISTS mcp_log_entries');
        print('🗑️ Dropped legacy mcp_log_entries table');
      } catch (e) {
        print('⚠️ Could not drop legacy table: $e');
      }
      
      // 确保所有必需的表都存在
      for (final tableScript in DatabaseSchema.createTableScripts) {
        try {
          await db.execute(tableScript);
        } catch (e) {
          print('⚠️ Table creation skipped (may already exist): $e');
        }
      }
      
      // 确保所有索引都存在
      for (final indexScript in DatabaseIndexes.createIndexScripts) {
        try {
          await db.execute(indexScript);
        } catch (e) {
          print('⚠️ Index creation skipped (may already exist): $e');
        }
      }
      
      print('✅ Database schema consistency ensured');
    }
    
    print('✅ Database upgrade completed');
  }

  /// 清理旧数据
  Future<void> cleanupOldData() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final retentionPeriod = AppConstants.dataRetentionDays * 24 * 60 * 60 * 1000;
    final cutoffTime = now - retentionPeriod;

    print('🧹 Cleaning up old data (older than ${AppConstants.dataRetentionDays} days)...');

    // 清理旧的生命周期事件
    final lifecycleDeleted = await db.delete(
      'server_lifecycle_events',
      where: 'timestamp < ?',
      whereArgs: [cutoffTime],
    );

    // 清理旧的运行时统计
    final statsDeleted = await db.delete(
      'server_runtime_stats',
      where: 'timestamp < ?',
      whereArgs: [cutoffTime],
    );

    // 清理旧的日志
    final logsDeleted = await db.delete(
      'server_logs',
      where: 'timestamp < ?',
      whereArgs: [cutoffTime],
    );

    // 清理旧的请求记录
    final requestsDeleted = await db.delete(
      'mcp_requests',
      where: 'start_time < ?',
      whereArgs: [cutoffTime],
    );

    // 清理旧的系统事件
    final systemEventsDeleted = await db.delete(
      'system_events',
      where: 'timestamp < ?',
      whereArgs: [cutoffTime],
    );

    print('🗑️ Cleanup completed:');
    print('   📊 Lifecycle events: $lifecycleDeleted');
    print('   📈 Runtime stats: $statsDeleted');
    print('   📝 Logs: $logsDeleted');
    print('   📨 Requests: $requestsDeleted');
    print('   ⚙️ System events: $systemEventsDeleted');
  }

  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getDatabaseStats() async {
    final db = await database;
    
    final servers = await db.rawQuery('SELECT COUNT(*) as count FROM mcp_servers');
    final events = await db.rawQuery('SELECT COUNT(*) as count FROM server_lifecycle_events');
    final stats = await db.rawQuery('SELECT COUNT(*) as count FROM server_runtime_stats');
    final logs = await db.rawQuery('SELECT COUNT(*) as count FROM server_logs');
    final requests = await db.rawQuery('SELECT COUNT(*) as count FROM mcp_requests');
    final systemEvents = await db.rawQuery('SELECT COUNT(*) as count FROM system_events');

    return {
      'servers': servers.first['count'],
      'lifecycle_events': events.first['count'],
      'runtime_stats': stats.first['count'],
      'logs': logs.first['count'],
      'request_records': requests.first['count'],
      'system_events': systemEvents.first['count'],
    };
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('🔒 Database closed');
    }
  }
} 