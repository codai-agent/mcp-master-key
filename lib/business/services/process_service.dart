import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../../core/models/mcp_server.dart';
import '../managers/process_managers/process_manager_interface.dart';
import '../managers/process_managers/uvx_process_manager.dart';
import '../managers/process_managers/npx_process_manager.dart';
import '../managers/process_managers/smithery_process_manager.dart';
import '../managers/process_managers/local_python_process_manager.dart';
import '../managers/process_managers/local_jar_process_manager.dart';
import '../managers/process_managers/local_executable_process_manager.dart';
import 'install_service.dart';

/// 进程管理服务 - 统一管理所有类型的MCP服务器进程
class ProcessService {
  static ProcessService? _instance;
  final Map<McpInstallType, ProcessManagerInterface> _processManagers = {};
  final Map<String, Process> _runningProcesses = {};
  final Map<String, StreamSubscription> _processSubscriptions = {};

  ProcessService._internal() {
    _initializeManagers();
  }

  static ProcessService get instance {
    _instance ??= ProcessService._internal();
    return _instance!;
  }

  /// 初始化各种进程管理器
  void _initializeManagers() {
    _processManagers[McpInstallType.uvx] = UvxProcessManager();
    _processManagers[McpInstallType.npx] = NpxProcessManager();
    _processManagers[McpInstallType.smithery] = SmitheryProcessManager();
    _processManagers[McpInstallType.localPython] = LocalPythonProcessManager();
    _processManagers[McpInstallType.localJar] = LocalJarProcessManager();
    _processManagers[McpInstallType.localExecutable] = LocalExecutableProcessManager();
  }

  /// 启动服务器进程
  Future<ProcessResult> startServer(McpServer server) async {
    print('🚀 Starting server: ${server.name} (type: ${server.installType.name})');
    
    // 检查是否已在运行
    if (_runningProcesses.containsKey(server.id)) {
      print('⚠️ Server ${server.name} is already running');
      return ProcessResult(
        success: false,
        serverId: server.id,
        errorMessage: 'Server is already running',
      );
    }

    final manager = _processManagers[server.installType];
    if (manager == null) {
      return ProcessResult(
        success: false,
        serverId: server.id,
        errorMessage: 'Unsupported install type: ${server.installType.name}',
      );
    }

    try {
      // 确保服务器已安装
      final installService = InstallService.instance;
      final isInstalled = await installService.isServerInstalled(server);
      if (!isInstalled) {
        print('📦 Server not installed, installing first...');
        final installResult = await installService.installServer(server);
        if (!installResult.success) {
          return ProcessResult(
            success: false,
            serverId: server.id,
            errorMessage: 'Installation failed: ${installResult.errorMessage}',
          );
        }
      }

      // 启动进程
      final process = await manager.startProcess(server);
      _runningProcesses[server.id] = process;

      // 设置进程监听
      _setupProcessMonitoring(server, process);

      print('✅ Server ${server.name} started successfully (PID: ${process.pid})');
      
      return ProcessResult(
        success: true,
        serverId: server.id,
        processId: process.pid,
        metadata: {
          'startTime': DateTime.now().toIso8601String(),
          'installType': server.installType.name,
        },
      );
    } catch (e) {
      print('❌ Failed to start server ${server.name}: $e');
      return ProcessResult(
        success: false,
        serverId: server.id,
        errorMessage: 'Failed to start server: $e',
      );
    }
  }

  /// 停止服务器进程
  Future<ProcessResult> stopServer(McpServer server) async {
    print('🛑 Stopping server: ${server.name}');
    
    final process = _runningProcesses[server.id];
    if (process == null) {
      print('⚠️ Server ${server.name} is not running');
      return ProcessResult(
        success: true,
        serverId: server.id,
        errorMessage: 'Server is not running',
      );
    }

    try {
      // 清理监听
      await _processSubscriptions[server.id]?.cancel();
      _processSubscriptions.remove(server.id);

      // 优雅停止进程
      process.kill(ProcessSignal.sigterm);
      
      // 等待进程结束，最多5秒
      final exitCode = await process.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏰ Process didn\'t exit gracefully, force killing...');
          process.kill(ProcessSignal.sigkill);
          return -1;
        },
      );

      _runningProcesses.remove(server.id);
      
      print('✅ Server ${server.name} stopped (exit code: $exitCode)');
      
      return ProcessResult(
        success: true,
        serverId: server.id,
        metadata: {
          'stopTime': DateTime.now().toIso8601String(),
          'exitCode': exitCode,
        },
      );
    } catch (e) {
      print('❌ Failed to stop server ${server.name}: $e');
      return ProcessResult(
        success: false,
        serverId: server.id,
        errorMessage: 'Failed to stop server: $e',
      );
    }
  }

  /// 重启服务器进程
  Future<ProcessResult> restartServer(McpServer server) async {
    print('🔄 Restarting server: ${server.name}');
    
    // 先停止
    final stopResult = await stopServer(server);
    if (!stopResult.success) {
      return stopResult;
    }

    // 等待一秒确保进程完全停止
    await Future.delayed(const Duration(seconds: 1));

    // 再启动
    return await startServer(server);
  }

  /// 检查服务器是否运行中
  bool isServerRunning(String serverId) {
    return _runningProcesses.containsKey(serverId);
  }

  /// 获取运行中的服务器列表
  List<String> getRunningServerIds() {
    return _runningProcesses.keys.toList();
  }

  /// 获取服务器的进程ID
  int? getServerProcessId(String serverId) {
    return _runningProcesses[serverId]?.pid;
  }

  /// 停止所有服务器
  Future<void> stopAllServers() async {
    print('🛑 Stopping all running servers...');
    
    final futures = <Future>[];
    for (final serverId in _runningProcesses.keys.toList()) {
      final server = McpServer(
        id: serverId,
        name: 'Unknown',
        command: '',
        args: [],
        installType: McpInstallType.npx, // 临时值
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      futures.add(stopServer(server));
    }

    await Future.wait(futures);
    print('✅ All servers stopped');
  }

  /// 设置进程监听
  void _setupProcessMonitoring(McpServer server, Process process) {
    // 监听标准输出
    final stdoutSubscription = process.stdout
        .transform(const Utf8Decoder(allowMalformed: true))
        .listen(
      (data) {
        print('[${server.name}] STDOUT: ${data.trim()}');
      },
      onError: (error) {
        print('[${server.name}] STDOUT error: $error');
      },
    );

    // 监听标准错误
    final stderrSubscription = process.stderr
        .transform(const Utf8Decoder(allowMalformed: true))
        .listen(
      (data) {
        print('[${server.name}] STDERR: ${data.trim()}');
      },
      onError: (error) {
        print('[${server.name}] STDERR error: $error');
      },
    );

    // 监听进程退出
    final exitSubscription = process.exitCode.asStream().listen(
      (exitCode) {
        print('[${server.name}] Process exited with code: $exitCode');
        _runningProcesses.remove(server.id);
        _processSubscriptions.remove(server.id);
      },
      onError: (error) {
        print('[${server.name}] Exit code error: $error');
        _runningProcesses.remove(server.id);
        _processSubscriptions.remove(server.id);
      },
    );

    // 合并所有订阅（简化处理）
    _processSubscriptions[server.id] = stdoutSubscription;
  }

  /// 注册新的进程管理器（用于扩展）
  void registerProcessManager(McpInstallType type, ProcessManagerInterface manager) {
    _processManagers[type] = manager;
    print('✅ Registered process manager for type: ${type.name}');
  }

  /// 获取支持的安装类型
  List<McpInstallType> getSupportedInstallTypes() {
    return _processManagers.keys.toList();
  }

  /// 释放资源
  Future<void> dispose() async {
    await stopAllServers();
    
    for (final subscription in _processSubscriptions.values) {
      await subscription.cancel();
    }
    _processSubscriptions.clear();
  }
}

/// 进程操作结果
class ProcessResult {
  final bool success;
  final String serverId;
  final int? processId;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  ProcessResult({
    required this.success,
    required this.serverId,
    this.processId,
    this.errorMessage,
    this.metadata,
  });

  @override
  String toString() {
    return 'ProcessResult(success: $success, serverId: $serverId, processId: $processId, error: $errorMessage)';
  }
} 