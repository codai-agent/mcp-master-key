import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/models/mcp_server.dart';
import '../database/database_service.dart';

/// MCP服务器仓库类
class McpServerRepository {
  static McpServerRepository? _instance;
  final DatabaseService _databaseService = DatabaseService.instance;

  McpServerRepository._internal();

  /// 获取单例实例
  static McpServerRepository get instance {
    _instance ??= McpServerRepository._internal();
    return _instance!;
  }

  /// 获取所有MCP服务器
  Future<List<McpServer>> getAllServers() async {
    final db = await _databaseService.database;
    final maps = await db.query('mcp_servers', orderBy: 'created_at DESC');
    
    return maps.map((map) => _mapToMcpServer(map)).toList();
  }

  /// 根据ID获取MCP服务器
  Future<McpServer?> getServerById(String id) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'mcp_servers',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return _mapToMcpServer(maps.first);
  }

  /// 插入MCP服务器
  Future<void> insertServer(McpServer server) async {
    final db = await _databaseService.database;
    await db.insert('mcp_servers', _mcpServerToMap(server));
  }

  /// 更新MCP服务器
  Future<void> updateServer(McpServer server) async {
    final db = await _databaseService.database;
    await db.update(
      'mcp_servers',
      _mcpServerToMap(server),
      where: 'id = ?',
      whereArgs: [server.id],
    );
  }

  /// 删除MCP服务器
  Future<void> deleteServer(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      'mcp_servers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据状态获取服务器
  Future<List<McpServer>> getServersByStatus(McpServerStatus status) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'mcp_servers',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => _mapToMcpServer(map)).toList();
  }

  /// 获取自动启动的服务器
  Future<List<McpServer>> getAutoStartServers() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'mcp_servers',
      where: 'auto_start = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => _mapToMcpServer(map)).toList();
  }

  /// 将数据库映射转换为McpServer对象
  McpServer _mapToMcpServer(Map<String, dynamic> map) {
    return McpServer(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      status: McpServerStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => McpServerStatus.notInstalled,
      ),
      connectionType: McpConnectionType.values.firstWhere(
        (type) => type.name == map['connection_type'],
        orElse: () => McpConnectionType.stdio,
      ),
      installType: McpInstallType.values.firstWhere(
        (type) => type.name == map['install_type'],
      ),
      command: map['command'] as String,
      args: List<String>.from(jsonDecode(map['args'] as String)),
      env: Map<String, String>.from(jsonDecode(map['env'] as String)),
      workingDirectory: map['working_directory'] as String?,
      installSource: map['install_source'] as String?,
      version: map['version'] as String?,
      config: Map<String, dynamic>.from(jsonDecode(map['config'] as String)),
      processId: map['process_id'] as int?,
      port: map['port'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      lastStartedAt: map['last_started_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_started_at'] as int)
          : null,
      lastStoppedAt: map['last_stopped_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_stopped_at'] as int)
          : null,
      autoStart: (map['auto_start'] as int) == 1,
      errorMessage: map['error_message'] as String?,
      logLevel: map['log_level'] as String? ?? 'info',
    );
  }

  /// 插入日志条目
  Future<void> insertLogEntry(McpLogEntry logEntry) async {
    final db = await _databaseService.database;
    await db.insert('server_logs', {
      'id': logEntry.id,
      'server_id': logEntry.serverId,
      'session_id': null, // 暂时设为null，未来可扩展支持会话ID
      'level': logEntry.level,
      'message': logEntry.message,
      'timestamp': logEntry.timestamp.millisecondsSinceEpoch,
      'source': logEntry.source,
      'metadata': jsonEncode(logEntry.metadata),
    });
  }

  /// 清除服务器日志
  Future<void> clearServerLogs(String serverId) async {
    final db = await _databaseService.database;
    await db.delete(
      'server_logs',
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
  }

  /// 获取服务器日志
  Future<List<McpLogEntry>> getServerLogs(String serverId, {int? limit}) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'server_logs',
      where: 'server_id = ?',
      whereArgs: [serverId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    
    return maps.map((map) => _mapToLogEntry(map)).toList();
  }

  /// 将数据库映射转换为日志条目
  McpLogEntry _mapToLogEntry(Map<String, dynamic> map) {
    return McpLogEntry(
      id: map['id'] as String,
      serverId: map['server_id'] as String,
      level: map['level'] as String,
      message: map['message'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      source: map['source'] as String,
      metadata: Map<String, dynamic>.from(jsonDecode(map['metadata'] as String)),
    );
  }

  /// 将McpServer对象转换为数据库映射
  Map<String, dynamic> _mcpServerToMap(McpServer server) {
    return {
      'id': server.id,
      'name': server.name,
      'description': server.description,
      'status': server.status.name,
      'connection_type': server.connectionType.name,
      'install_type': server.installType.name,
      'command': server.command,
      'args': jsonEncode(server.args),
      'env': jsonEncode(server.env),
      'working_directory': server.workingDirectory,
      'install_source': server.installSource,
      'version': server.version,
      'config': jsonEncode(server.config),
      'process_id': server.processId,
      'port': server.port,
      'created_at': server.createdAt.millisecondsSinceEpoch,
      'updated_at': server.updatedAt.millisecondsSinceEpoch,
      'last_started_at': server.lastStartedAt?.millisecondsSinceEpoch,
      'last_stopped_at': server.lastStoppedAt?.millisecondsSinceEpoch,
      'auto_start': server.autoStart ? 1 : 0,
      'error_message': server.errorMessage,
      'log_level': server.logLevel,
    };
  }
} 