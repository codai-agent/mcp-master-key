import 'dart:async';
import 'dart:io';

import '../models/mcp_server.dart';
import '../../business/managers/enhanced_mcp_process_manager.dart';

/// 重启策略
enum RestartStrategy {
  /// 立即重启
  immediate,
  /// 延迟重启
  delayed,
  /// 指数退避重启
  exponentialBackoff,
  /// 禁用自动重启
  disabled,
}

/// 重启配置
class RestartConfig {
  final RestartStrategy strategy;
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool restartOnCrash;
  final bool restartOnError;
  final List<int> ignoredExitCodes;

  const RestartConfig({
    this.strategy = RestartStrategy.exponentialBackoff,
    this.maxRetries = 5,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 5),
    this.backoffMultiplier = 2.0,
    this.restartOnCrash = true,
    this.restartOnError = true,
    this.ignoredExitCodes = const [0], // 正常退出不重启
  });
}

/// 重启记录
class RestartRecord {
  final String serverId;
  final DateTime timestamp;
  final String reason;
  final int attemptNumber;
  final bool success;
  final String? errorMessage;

  RestartRecord({
    required this.serverId,
    required this.timestamp,
    required this.reason,
    required this.attemptNumber,
    required this.success,
    this.errorMessage,
  });
}

/// 自动重启服务
class AutoRestartService {
  static AutoRestartService? _instance;
  final EnhancedMcpProcessManager _processManager = EnhancedMcpProcessManager.instance;
  
  // 服务器重启配置
  final Map<String, RestartConfig> _serverConfigs = {};
  
  // 重启状态跟踪
  final Map<String, int> _restartCounts = {};
  final Map<String, DateTime> _lastRestartTime = {};
  final Map<String, Timer> _restartTimers = {};
  final List<RestartRecord> _restartHistory = [];
  
  // 事件流
  final StreamController<RestartRecord> _restartController = StreamController.broadcast();
  
  // 监控订阅
  StreamSubscription? _monitorSubscription;

  AutoRestartService._internal();

  /// 获取单例实例
  static AutoRestartService get instance {
    _instance ??= AutoRestartService._internal();
    return _instance!;
  }

  /// 重启事件流
  Stream<RestartRecord> get restartStream => _restartController.stream;

  /// 初始化服务
  void initialize() {
    // 监听服务器状态变化
    _monitorSubscription = _processManager.monitorStream.listen(_handleServerStateChange);
    print('🔄 自动重启服务已启动');
  }

  /// 设置服务器重启配置
  void setRestartConfig(String serverId, RestartConfig config) {
    _serverConfigs[serverId] = config;
    print('📋 服务器 $serverId 重启配置已更新: ${config.strategy.name}');
  }

  /// 获取服务器重启配置
  RestartConfig getRestartConfig(String serverId) {
    return _serverConfigs[serverId] ?? const RestartConfig();
  }

  /// 手动触发重启
  Future<bool> manualRestart(McpServer server, {String reason = '手动重启'}) async {
    final serverId = server.id;
    final config = getRestartConfig(serverId);
    
    if (config.strategy == RestartStrategy.disabled) {
      print('⚠️ 服务器 $serverId 的自动重启已禁用');
      return false;
    }

    return await _performRestart(server, reason, isManual: true);
  }

  /// 获取重启统计
  Map<String, dynamic> getRestartStats(String serverId) {
    final history = _restartHistory.where((r) => r.serverId == serverId).toList();
    final successCount = history.where((r) => r.success).length;
    final failureCount = history.where((r) => !r.success).length;
    
    return {
      'serverId': serverId,
      'totalRestarts': history.length,
      'successfulRestarts': successCount,
      'failedRestarts': failureCount,
      'currentRetryCount': _restartCounts[serverId] ?? 0,
      'lastRestartTime': _lastRestartTime[serverId],
      'recentHistory': history.take(10).toList(),
    };
  }

  /// 重置重启计数
  void resetRestartCount(String serverId) {
    _restartCounts.remove(serverId);
    _lastRestartTime.remove(serverId);
    print('🔄 服务器 $serverId 重启计数已重置');
  }

  /// 清除重启历史
  void clearRestartHistory([String? serverId]) {
    if (serverId != null) {
      _restartHistory.removeWhere((r) => r.serverId == serverId);
    } else {
      _restartHistory.clear();
    }
    print('🧹 重启历史已清除${serverId != null ? ' (服务器: $serverId)' : ''}');
  }

  /// 停止服务器的重启监控
  void stopRestartMonitoring(String serverId) {
    _restartTimers[serverId]?.cancel();
    _restartTimers.remove(serverId);
    _serverConfigs.remove(serverId);
    _restartCounts.remove(serverId);
    _lastRestartTime.remove(serverId);
    print('🛑 服务器 $serverId 重启监控已停止');
  }

  /// 释放资源
  void dispose() {
    _monitorSubscription?.cancel();
    
    for (final timer in _restartTimers.values) {
      timer.cancel();
    }
    _restartTimers.clear();
    
    _restartController.close();
    print('🔄 自动重启服务已停止');
  }

  // 私有方法

  void _handleServerStateChange(ServerMonitorInfo monitor) {
    final serverId = monitor.serverId;
    final config = getRestartConfig(serverId);
    
    if (config.strategy == RestartStrategy.disabled) {
      return;
    }

    // 检查是否需要重启
    bool shouldRestart = false;
    String reason = '';

    switch (monitor.state) {
      case ServerRunningState.crashed:
        if (config.restartOnCrash) {
          shouldRestart = true;
          reason = '进程崩溃';
        }
        break;
      
      case ServerRunningState.error:
        if (config.restartOnError) {
          shouldRestart = true;
          reason = '服务器错误';
        }
        break;
      
      case ServerRunningState.stopped:
        // 检查是否是意外停止（非手动停止）
        final lastLog = monitor.recentLogs.isNotEmpty ? monitor.recentLogs.last : '';
        if (lastLog.contains('unexpected') || lastLog.contains('crash')) {
          shouldRestart = true;
          reason = '意外停止';
        }
        break;
      
      default:
        // 其他状态不需要重启
        break;
    }

    if (shouldRestart) {
      _scheduleRestart(serverId, reason);
    }
  }

  void _scheduleRestart(String serverId, String reason) {
    final config = getRestartConfig(serverId);
    final currentCount = _restartCounts[serverId] ?? 0;
    
    // 检查是否超过最大重试次数
    if (currentCount >= config.maxRetries) {
      print('❌ 服务器 $serverId 重启次数已达上限 ($currentCount/${config.maxRetries})');
      _recordRestart(serverId, reason, currentCount + 1, false, '超过最大重试次数');
      return;
    }

    // 取消之前的重启定时器
    _restartTimers[serverId]?.cancel();

    // 计算延迟时间
    final delay = _calculateRestartDelay(config, currentCount);
    
    print('⏰ 计划在 ${delay.inSeconds} 秒后重启服务器 $serverId (原因: $reason, 第 ${currentCount + 1} 次尝试)');

    // 设置重启定时器
    _restartTimers[serverId] = Timer(delay, () async {
      await _executeScheduledRestart(serverId, reason);
    });
  }

  Duration _calculateRestartDelay(RestartConfig config, int attemptCount) {
    switch (config.strategy) {
      case RestartStrategy.immediate:
        return Duration.zero;
      
      case RestartStrategy.delayed:
        return config.initialDelay;
      
      case RestartStrategy.exponentialBackoff:
        final delay = config.initialDelay * (attemptCount == 0 ? 1 : 
            (config.backoffMultiplier * attemptCount));
        return delay > config.maxDelay ? config.maxDelay : delay;
      
      case RestartStrategy.disabled:
        return Duration.zero; // 不会被调用
    }
  }

  Future<void> _executeScheduledRestart(String serverId, String reason) async {
    // 获取服务器信息
    final monitor = _processManager.getServerMonitor(serverId);
    if (monitor == null) {
      print('❌ 找不到服务器 $serverId 的监控信息');
      return;
    }

    // 这里需要获取完整的McpServer对象
    // 暂时创建一个简化版本用于演示
    final server = McpServer(
      id: serverId,
      name: 'Server $serverId',
      installType: McpInstallType.npx,
      command: 'npx',
      args: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _performRestart(server, reason);
  }

  Future<bool> _performRestart(McpServer server, String reason, {bool isManual = false}) async {
    final serverId = server.id;
    final currentCount = _restartCounts[serverId] ?? 0;
    final newCount = currentCount + 1;
    
    print('🔄 开始重启服务器 $serverId (原因: $reason, 第 $newCount 次尝试)');

    try {
      // 执行重启
      final success = await _processManager.restartServer(server);
      
      if (success) {
        // 重启成功
        _restartCounts[serverId] = 0; // 重置计数
        _lastRestartTime[serverId] = DateTime.now();
        
        _recordRestart(serverId, reason, newCount, true);
        print('✅ 服务器 $serverId 重启成功');
        return true;
      } else {
        // 重启失败
        _restartCounts[serverId] = newCount;
        _recordRestart(serverId, reason, newCount, false, '重启失败');
        
        // 如果不是手动重启，继续尝试
        if (!isManual) {
          _scheduleRestart(serverId, '$reason (重试)');
        }
        
        print('❌ 服务器 $serverId 重启失败');
        return false;
      }
    } catch (error) {
      _restartCounts[serverId] = newCount;
      _recordRestart(serverId, reason, newCount, false, error.toString());
      
      if (!isManual) {
        _scheduleRestart(serverId, '$reason (异常重试)');
      }
      
      print('❌ 服务器 $serverId 重启异常: $error');
      return false;
    }
  }

  void _recordRestart(String serverId, String reason, int attemptNumber, bool success, [String? errorMessage]) {
    final record = RestartRecord(
      serverId: serverId,
      timestamp: DateTime.now(),
      reason: reason,
      attemptNumber: attemptNumber,
      success: success,
      errorMessage: errorMessage,
    );
    
    _restartHistory.add(record);
    
    // 保持历史记录数量限制
    if (_restartHistory.length > 1000) {
      _restartHistory.removeRange(0, _restartHistory.length - 1000);
    }
    
    // 发送事件
    _restartController.add(record);
  }
} 