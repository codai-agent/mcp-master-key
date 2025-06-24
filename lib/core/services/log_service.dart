import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/mcp_server.dart';
import '../../infrastructure/repositories/mcp_server_repository.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warn,
  error,
  fatal,
}

/// 日志条目
class LogEntry {
  final String id;
  final String serverId;
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String source;
  final Map<String, dynamic> metadata;

  LogEntry({
    required this.id,
    required this.serverId,
    required this.level,
    required this.message,
    required this.timestamp,
    this.source = 'stdout',
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'level': level.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'metadata': metadata,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      serverId: json['serverId'] as String,
      level: LogLevel.values.firstWhere((e) => e.name == json['level']),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String? ?? 'stdout',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// 日志过滤器
class LogFilter {
  final String? serverId;
  final LogLevel? minLevel;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? searchText;
  final String? source;

  LogFilter({
    this.serverId,
    this.minLevel,
    this.startTime,
    this.endTime,
    this.searchText,
    this.source,
  });
}

/// 日志统计信息
class LogStats {
  final String serverId;
  final Map<LogLevel, int> levelCounts;
  final DateTime? firstLogTime;
  final DateTime? lastLogTime;
  final int totalCount;

  LogStats({
    required this.serverId,
    required this.levelCounts,
    this.firstLogTime,
    this.lastLogTime,
    required this.totalCount,
  });
}

/// 日志管理服务
class LogService {
  static LogService? _instance;
  final McpServerRepository _repository;
  
  // 内存中的日志缓存
  final Map<String, List<LogEntry>> _logCache = {};
  final int _maxCacheSize = 1000; // 每个服务器最多缓存1000条日志
  
  // 事件流
  final StreamController<LogEntry> _logStreamController = StreamController.broadcast();
  final StreamController<LogStats> _statsStreamController = StreamController.broadcast();
  
  // 日志文件流
  final Map<String, IOSink> _logFiles = {};

  LogService._(this._repository);

  /// 获取单例实例
  static LogService getInstance(McpServerRepository repository) {
    _instance ??= LogService._(repository);
    return _instance!;
  }

  /// 日志事件流
  Stream<LogEntry> get logStream => _logStreamController.stream;
  
  /// 统计事件流
  Stream<LogStats> get statsStream => _statsStreamController.stream;

  /// 添加日志条目
  Future<void> addLog({
    required String serverId,
    required LogLevel level,
    required String message,
    String source = 'stdout',
    Map<String, dynamic> metadata = const {},
  }) async {
    final entry = LogEntry(
      id: _generateLogId(),
      serverId: serverId,
      level: level,
      message: message,
      timestamp: DateTime.now(),
      source: source,
      metadata: metadata,
    );

    // 添加到内存缓存
    _addToCache(entry);

    // 写入数据库
    await _saveToDatabase(entry);

    // 写入日志文件
    await _writeToFile(entry);

    // 发送事件
    _logStreamController.add(entry);

    // 更新统计信息
    await _updateStats(serverId);
  }

  /// 批量添加日志
  Future<void> addLogs(List<LogEntry> entries) async {
    for (final entry in entries) {
      _addToCache(entry);
      await _saveToDatabase(entry);
      await _writeToFile(entry);
      _logStreamController.add(entry);
    }

    // 更新所有涉及服务器的统计信息
    final serverIds = entries.map((e) => e.serverId).toSet();
    for (final serverId in serverIds) {
      await _updateStats(serverId);
    }
  }

  /// 解析并添加原始日志行
  Future<void> parseAndAddLog({
    required String serverId,
    required String rawLine,
    String source = 'stdout',
  }) async {
    final parsed = _parseLogLine(rawLine);
    
    await addLog(
      serverId: serverId,
      level: parsed.level,
      message: parsed.message,
      source: source,
      metadata: parsed.metadata,
    );
  }

  /// 获取日志条目
  Future<List<LogEntry>> getLogs({
    LogFilter? filter,
    int limit = 100,
    int offset = 0,
  }) async {
    // 先从缓存中获取
    List<LogEntry> logs = [];
    
    if (filter?.serverId != null) {
      logs = _logCache[filter!.serverId!] ?? [];
    } else {
      logs = _logCache.values.expand((list) => list).toList();
    }

    // 应用过滤器
    if (filter != null) {
      logs = _applyFilter(logs, filter);
    }

    // 排序（最新的在前）
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // 应用分页
    final start = offset;
    final end = (start + limit).clamp(0, logs.length);
    
    if (start >= logs.length) {
      return [];
    }

    return logs.sublist(start, end);
  }

  /// 获取实时日志流
  Stream<LogEntry> getLogStream({LogFilter? filter}) {
    if (filter == null) {
      return logStream;
    }
    
    return logStream.where((entry) {
      return _matchesFilter(entry, filter);
    });
  }

  /// 获取日志统计信息
  Future<LogStats> getLogStats(String serverId) async {
    final logs = _logCache[serverId] ?? [];
    
    final levelCounts = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      levelCounts[level] = 0;
    }
    
    DateTime? firstLogTime;
    DateTime? lastLogTime;
    
    for (final log in logs) {
      levelCounts[log.level] = (levelCounts[log.level] ?? 0) + 1;
      
      if (firstLogTime == null || log.timestamp.isBefore(firstLogTime)) {
        firstLogTime = log.timestamp;
      }
      
      if (lastLogTime == null || log.timestamp.isAfter(lastLogTime)) {
        lastLogTime = log.timestamp;
      }
    }

    return LogStats(
      serverId: serverId,
      levelCounts: levelCounts,
      firstLogTime: firstLogTime,
      lastLogTime: lastLogTime,
      totalCount: logs.length,
    );
  }

  /// 清除日志
  Future<void> clearLogs(String serverId) async {
    // 清除内存缓存
    _logCache.remove(serverId);

    // 清除数据库记录
    await _repository.clearServerLogs(serverId);

    // 关闭并重新创建日志文件
    await _logFiles[serverId]?.close();
    _logFiles.remove(serverId);

    // 更新统计信息
    await _updateStats(serverId);
  }

  /// 导出日志
  Future<String> exportLogs({
    LogFilter? filter,
    String format = 'json',
  }) async {
    final logs = await getLogs(filter: filter, limit: 10000);
    
    switch (format.toLowerCase()) {
      case 'json':
        return jsonEncode(logs.map((log) => log.toJson()).toList());
      
      case 'txt':
        return logs.map((log) => 
          '[${log.timestamp}] [${log.level.name.toUpperCase()}] [${log.serverId}] ${log.message}'
        ).join('\n');
      
      case 'csv':
        final header = 'Timestamp,Level,Server,Source,Message';
        final rows = logs.map((log) => 
          '${log.timestamp},${log.level.name},${log.serverId},${log.source},"${log.message.replaceAll('"', '""')}"'
        ).join('\n');
        return '$header\n$rows';
      
      default:
        throw ArgumentError('不支持的导出格式: $format');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    // 关闭所有日志文件
    for (final sink in _logFiles.values) {
      await sink.close();
    }
    _logFiles.clear();

    // 关闭事件流
    await _logStreamController.close();
    await _statsStreamController.close();

    // 清除缓存
    _logCache.clear();
  }

  // 私有方法

  String _generateLogId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
  }

  void _addToCache(LogEntry entry) {
    final logs = _logCache.putIfAbsent(entry.serverId, () => <LogEntry>[]);
    logs.add(entry);

    // 保持缓存大小限制
    if (logs.length > _maxCacheSize) {
      logs.removeRange(0, logs.length - _maxCacheSize);
    }
  }

  Future<void> _saveToDatabase(LogEntry entry) async {
    try {
      final mcpLogEntry = McpLogEntry(
        id: entry.id,
        serverId: entry.serverId,
        level: entry.level.name,
        message: entry.message,
        timestamp: entry.timestamp,
        source: entry.source,
        metadata: entry.metadata,
      );
      
      await _repository.insertLogEntry(mcpLogEntry);
    } catch (error) {
      print('保存日志到数据库失败: $error');
    }
  }

  Future<void> _writeToFile(LogEntry entry) async {
    try {
      final sink = await _getLogFileSink(entry.serverId);
      final line = '[${entry.timestamp}] [${entry.level.name.toUpperCase()}] [${entry.source}] ${entry.message}';
      sink.writeln(line);
      await sink.flush();
    } catch (error) {
      print('写入日志文件失败: $error');
    }
  }

  Future<IOSink> _getLogFileSink(String serverId) async {
    if (_logFiles.containsKey(serverId)) {
      return _logFiles[serverId]!;
    }

    // 创建日志文件
    final logDir = Directory('logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    final logFile = File('logs/mcp_server_$serverId.log');
    final sink = logFile.openWrite(mode: FileMode.append);
    _logFiles[serverId] = sink;

    return sink;
  }

  ParsedLog _parseLogLine(String line) {
    // 尝试解析结构化日志
    try {
      final json = jsonDecode(line) as Map<String, dynamic>;
      return ParsedLog(
        level: _parseLogLevel(json['level'] as String?),
        message: json['message'] as String? ?? line,
        metadata: json,
      );
    } catch (_) {
      // 解析失败，作为普通文本处理
      return ParsedLog(
        level: _inferLogLevel(line),
        message: line,
        metadata: {},
      );
    }
  }

  LogLevel _parseLogLevel(String? levelStr) {
    if (levelStr == null) return LogLevel.info;
    
    switch (levelStr.toLowerCase()) {
      case 'debug':
      case 'trace':
        return LogLevel.debug;
      case 'info':
      case 'information':
        return LogLevel.info;
      case 'warn':
      case 'warning':
        return LogLevel.warn;
      case 'error':
        return LogLevel.error;
      case 'fatal':
      case 'critical':
        return LogLevel.fatal;
      default:
        return LogLevel.info;
    }
  }

  LogLevel _inferLogLevel(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('error') || lowerMessage.contains('failed') || lowerMessage.contains('exception')) {
      return LogLevel.error;
    } else if (lowerMessage.contains('warn') || lowerMessage.contains('warning')) {
      return LogLevel.warn;
    } else if (lowerMessage.contains('debug') || lowerMessage.contains('trace')) {
      return LogLevel.debug;
    } else {
      return LogLevel.info;
    }
  }

  List<LogEntry> _applyFilter(List<LogEntry> logs, LogFilter filter) {
    return logs.where((log) => _matchesFilter(log, filter)).toList();
  }

  bool _matchesFilter(LogEntry log, LogFilter filter) {
    if (filter.serverId != null && log.serverId != filter.serverId) {
      return false;
    }

    if (filter.minLevel != null && log.level.index < filter.minLevel!.index) {
      return false;
    }

    if (filter.startTime != null && log.timestamp.isBefore(filter.startTime!)) {
      return false;
    }

    if (filter.endTime != null && log.timestamp.isAfter(filter.endTime!)) {
      return false;
    }

    if (filter.searchText != null && 
        !log.message.toLowerCase().contains(filter.searchText!.toLowerCase())) {
      return false;
    }

    if (filter.source != null && log.source != filter.source) {
      return false;
    }

    return true;
  }

  Future<void> _updateStats(String serverId) async {
    try {
      final stats = await getLogStats(serverId);
      _statsStreamController.add(stats);
    } catch (error) {
      print('更新日志统计失败: $error');
    }
  }
}

/// 解析后的日志信息
class ParsedLog {
  final LogLevel level;
  final String message;
  final Map<String, dynamic> metadata;

  ParsedLog({
    required this.level,
    required this.message,
    required this.metadata,
  });
} 