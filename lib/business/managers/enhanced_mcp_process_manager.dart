import 'dart:io';
import 'dart:convert';
import 'dart:async';

import '../../core/models/mcp_server.dart';
import '../../core/protocols/mcp_client.dart';
import '../../core/protocols/mcp_protocol.dart';
import '../../infrastructure/runtime/runtime_manager.dart';

/// 服务器运行状态
enum ServerRunningState {
  stopped,
  starting,
  running,
  connected,
  error,
  crashed,
}

/// 服务器监控信息
class ServerMonitorInfo {
  final String serverId;
  final ServerRunningState state;
  final int? processId;
  final DateTime? startTime;
  final DateTime? lastHeartbeat;
  final McpInitializeResult? initResult;
  final List<McpTool> tools;
  final List<McpResource> resources;
  final List<String> recentLogs;
  final int restartCount;

  ServerMonitorInfo({
    required this.serverId,
    required this.state,
    this.processId,
    this.startTime,
    this.lastHeartbeat,
    this.initResult,
    this.tools = const [],
    this.resources = const [],
    this.recentLogs = const [],
    this.restartCount = 0,
  });

  ServerMonitorInfo copyWith({
    ServerRunningState? state,
    int? processId,
    DateTime? startTime,
    DateTime? lastHeartbeat,
    McpInitializeResult? initResult,
    List<McpTool>? tools,
    List<McpResource>? resources,
    List<String>? recentLogs,
    int? restartCount,
  }) {
    return ServerMonitorInfo(
      serverId: serverId,
      state: state ?? this.state,
      processId: processId ?? this.processId,
      startTime: startTime ?? this.startTime,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      initResult: initResult ?? this.initResult,
      tools: tools ?? this.tools,
      resources: resources ?? this.resources,
      recentLogs: recentLogs ?? this.recentLogs,
      restartCount: restartCount ?? this.restartCount,
    );
  }
}

/// 增强版MCP进程管理器
class EnhancedMcpProcessManager {
  static EnhancedMcpProcessManager? _instance;
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  
  // 运行中的进程和客户端
  final Map<String, Process> _runningProcesses = {};
  final Map<String, McpClient> _mcpClients = {};
  final Map<String, ServerMonitorInfo> _serverMonitors = {};
  
  // 监控定时器
  final Map<String, Timer> _heartbeatTimers = {};
  final Map<String, Timer> _healthCheckTimers = {};
  
  // 事件流
  final StreamController<ServerMonitorInfo> _monitorController = StreamController.broadcast();
  final StreamController<String> _logController = StreamController.broadcast();
  
  // 配置
  final Duration heartbeatInterval = const Duration(seconds: 30);
  final Duration healthCheckInterval = const Duration(seconds: 10);
  final int maxRestartCount = 3;
  final int maxLogEntries = 100;

  EnhancedMcpProcessManager._internal();

  /// 获取单例实例
  static EnhancedMcpProcessManager get instance {
    _instance ??= EnhancedMcpProcessManager._internal();
    return _instance!;
  }

  // 事件流
  Stream<ServerMonitorInfo> get monitorStream => _monitorController.stream;
  Stream<String> get logStream => _logController.stream;

  /// 获取服务器监控信息
  ServerMonitorInfo? getServerMonitor(String serverId) {
    return _serverMonitors[serverId];
  }

  /// 获取所有服务器监控信息
  List<ServerMonitorInfo> getAllServerMonitors() {
    return _serverMonitors.values.toList();
  }

  /// 启动服务器（带监控）
  Future<bool> startServerWithMonitoring(McpServer server) async {
    final serverId = server.id;
    
    // 检查是否已经在运行
    if (_runningProcesses.containsKey(serverId)) {
      _log('⚠️ 服务器 ${server.name} 已经在运行');
      return true;
    }

    _log('🚀 启动服务器: ${server.name}');
    
    // 初始化监控信息
    _serverMonitors[serverId] = ServerMonitorInfo(
      serverId: serverId,
      state: ServerRunningState.starting,
      startTime: DateTime.now(),
    );
    _notifyMonitorUpdate(serverId);

    try {
      // 启动进程
      final process = await _startProcess(server);
      _runningProcesses[serverId] = process;
      
      // 更新监控信息
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        state: ServerRunningState.running,
        processId: process.pid,
      ));

      // 创建MCP客户端
      final client = McpClient(
        serverId: serverId,
        process: process,
      );
      _mcpClients[serverId] = client;

      // 设置客户端事件监听
      _setupClientEventListeners(serverId, client);

      // 启动客户端连接
      await client.connect();

      // 启动监控
      _startMonitoring(serverId);

      _log('✅ 服务器 ${server.name} 启动成功 (PID: ${process.pid})');
      return true;

    } catch (error) {
      _log('❌ 启动服务器失败: $error');
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        state: ServerRunningState.error,
      ));
      return false;
    }
  }

  /// 停止服务器
  Future<bool> stopServer(String serverId) async {
    _log('🛑 停止服务器: $serverId');

    // 停止监控
    _stopMonitoring(serverId);

    // 断开MCP客户端
    final client = _mcpClients.remove(serverId);
    if (client != null) {
      await client.disconnect();
      client.dispose();
    }

    // 停止进程
    final process = _runningProcesses.remove(serverId);
    if (process != null) {
      try {
        process.kill(ProcessSignal.sigterm);
        
        final exitCode = await process.exitCode.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            process.kill(ProcessSignal.sigkill);
            return -1;
          },
        );
        
        _log('✅ 服务器停止 (退出码: $exitCode)');
      } catch (error) {
        _log('❌ 停止服务器时发生错误: $error');
      }
    }

    // 更新监控信息
    _updateMonitorInfo(serverId, (info) => info.copyWith(
      state: ServerRunningState.stopped,
      processId: null,
    ));

    return true;
  }

  /// 重启服务器
  Future<bool> restartServer(McpServer server) async {
    final serverId = server.id;
    final monitor = _serverMonitors[serverId];
    
    if (monitor != null && monitor.restartCount >= maxRestartCount) {
      _log('❌ 服务器 ${server.name} 重启次数超过限制 (${monitor.restartCount})');
      return false;
    }

    _log('🔄 重启服务器: ${server.name}');

    // 停止服务器
    await stopServer(serverId);
    
    // 等待一秒
    await Future.delayed(const Duration(seconds: 1));
    
    // 增加重启计数
    _updateMonitorInfo(serverId, (info) => info.copyWith(
      restartCount: (monitor?.restartCount ?? 0) + 1,
    ));

    // 重新启动
    return await startServerWithMonitoring(server);
  }

  /// 获取服务器工具列表
  Future<List<McpTool>> getServerTools(String serverId) async {
    final client = _mcpClients[serverId];
    if (client == null || client.state != McpClientState.initialized) {
      throw StateError('服务器未连接或未初始化');
    }

    try {
      final tools = await client.listTools();
      
      // 更新监控信息
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        tools: tools,
        lastHeartbeat: DateTime.now(),
      ));
      
      return tools;
    } catch (error) {
      _log('❌ 获取工具列表失败: $error');
      rethrow;
    }
  }

  /// 调用服务器工具
  Future<Map<String, dynamic>> callServerTool(
    String serverId,
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    final client = _mcpClients[serverId];
    if (client == null || client.state != McpClientState.initialized) {
      throw StateError('服务器未连接或未初始化');
    }

    try {
      final result = await client.callTool(toolName, arguments);
      
      // 更新心跳时间
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        lastHeartbeat: DateTime.now(),
      ));
      
      _log('✅ 工具调用成功: $toolName');
      return result;
    } catch (error) {
      _log('❌ 工具调用失败: $toolName - $error');
      rethrow;
    }
  }

  /// 获取服务器资源列表
  Future<List<McpResource>> getServerResources(String serverId) async {
    final client = _mcpClients[serverId];
    if (client == null || client.state != McpClientState.initialized) {
      throw StateError('服务器未连接或未初始化');
    }

    try {
      final resources = await client.listResources();
      
      // 更新监控信息
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        resources: resources,
        lastHeartbeat: DateTime.now(),
      ));
      
      return resources;
    } catch (error) {
      _log('❌ 获取资源列表失败: $error');
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    // 停止所有服务器
    for (final serverId in _runningProcesses.keys.toList()) {
      stopServer(serverId);
    }
    
    // 关闭事件流
    _monitorController.close();
    _logController.close();
  }

  // 私有方法

  Future<Process> _startProcess(McpServer server) async {
    // 获取工作目录
    final workingDir = server.workingDirectory ?? 
        '/tmp/mcp_servers/${server.id}'; // 临时目录
    
    // 确保工作目录存在
    final dir = Directory(workingDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 获取环境变量
    final environment = Map<String, String>.from(Platform.environment);
    environment.addAll(server.env);

    // 启动进程
    final process = await Process.start(
      server.command,
      server.args,
      workingDirectory: workingDir,
      environment: environment,
      mode: ProcessStartMode.normal,
    );

    return process;
  }

  void _setupClientEventListeners(String serverId, McpClient client) {
    // 监听客户端状态变化
    client.stateStream.listen((state) {
      ServerRunningState runningState;
      switch (state) {
        case McpClientState.disconnected:
          runningState = ServerRunningState.stopped;
          break;
        case McpClientState.connecting:
          runningState = ServerRunningState.starting;
          break;
        case McpClientState.connected:
          runningState = ServerRunningState.running;
          break;
        case McpClientState.initialized:
          runningState = ServerRunningState.connected;
          break;
        case McpClientState.error:
          runningState = ServerRunningState.error;
          break;
      }
      
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        state: runningState,
        lastHeartbeat: DateTime.now(),
        initResult: client.initializeResult,
      ));
    });

    // 监听客户端日志
    client.logStream.listen((log) {
      _addLogToMonitor(serverId, log);
    });

    // 监听通知
    client.notificationStream.listen((notification) {
      _log('📢 收到通知 [$serverId]: ${notification.method}');
    });
  }

  void _startMonitoring(String serverId) {
    // 启动心跳检测
    _heartbeatTimers[serverId] = Timer.periodic(heartbeatInterval, (timer) {
      _performHeartbeat(serverId);
    });

    // 启动健康检查
    _healthCheckTimers[serverId] = Timer.periodic(healthCheckInterval, (timer) {
      _performHealthCheck(serverId);
    });
  }

  void _stopMonitoring(String serverId) {
    _heartbeatTimers.remove(serverId)?.cancel();
    _healthCheckTimers.remove(serverId)?.cancel();
  }

  void _performHeartbeat(String serverId) async {
    final client = _mcpClients[serverId];
    if (client == null || client.state != McpClientState.initialized) {
      return;
    }

    try {
      // 尝试获取工具列表作为心跳检测
      await client.listTools();
      
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        lastHeartbeat: DateTime.now(),
      ));
    } catch (error) {
      _log('💔 心跳检测失败 [$serverId]: $error');
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        state: ServerRunningState.error,
      ));
    }
  }

  void _performHealthCheck(String serverId) {
    final process = _runningProcesses[serverId];
    final monitor = _serverMonitors[serverId];
    
    if (process == null || monitor == null) {
      return;
    }

    // 检查进程是否还活着
    try {
      process.kill(ProcessSignal.sigusr1); // 发送无害信号测试进程状态
    } catch (error) {
      // 进程已死亡
      _log('💀 进程已死亡 [$serverId]');
      _updateMonitorInfo(serverId, (info) => info.copyWith(
        state: ServerRunningState.crashed,
      ));
      
      // 可以选择自动重启
      // _autoRestartIfNeeded(serverId);
    }

    // 检查心跳超时
    final lastHeartbeat = monitor.lastHeartbeat;
    if (lastHeartbeat != null) {
      final timeSinceLastHeartbeat = DateTime.now().difference(lastHeartbeat);
      if (timeSinceLastHeartbeat > const Duration(minutes: 2)) {
        _log('⏰ 心跳超时 [$serverId]: ${timeSinceLastHeartbeat.inSeconds}秒');
        _updateMonitorInfo(serverId, (info) => info.copyWith(
          state: ServerRunningState.error,
        ));
      }
    }
  }

  void _updateMonitorInfo(String serverId, ServerMonitorInfo Function(ServerMonitorInfo) updater) {
    final current = _serverMonitors[serverId];
    if (current != null) {
      _serverMonitors[serverId] = updater(current);
      _notifyMonitorUpdate(serverId);
    }
  }

  void _notifyMonitorUpdate(String serverId) {
    final monitor = _serverMonitors[serverId];
    if (monitor != null) {
      _monitorController.add(monitor);
    }
  }

  void _addLogToMonitor(String serverId, String log) {
    _updateMonitorInfo(serverId, (info) {
      final newLogs = List<String>.from(info.recentLogs);
      newLogs.add('[${DateTime.now()}] $log');
      
      // 保持日志数量限制
      if (newLogs.length > maxLogEntries) {
        newLogs.removeRange(0, newLogs.length - maxLogEntries);
      }
      
      return info.copyWith(recentLogs: newLogs);
    });
  }

  void _log(String message) {
    print(message);
    _logController.add(message);
  }
} 