import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mutex/mutex.dart';
import 'package:mcp_dart/mcp_dart.dart' hide McpServer;
import 'package:mcp_dart/mcp_dart.dart' as mcp_dart show McpServer;

import '../../core/models/mcp_server.dart' as models;
import '../../core/constants/app_constants.dart';
import '../../infrastructure/repositories/mcp_server_repository.dart';
import '../../infrastructure/runtime/runtime_manager.dart';
import '../../infrastructure/mcp/mcp_tools_aggregator.dart';
import '../../infrastructure/mcp/streamable_mcp_hub.dart';
import '../managers/mcp_process_manager.dart';
import 'mcp_server_service.dart';
import 'config_service.dart';

/// 子服务器连接信息
class ChildServerInfo {
  final String id;
  final String name;
  final String command;
  final List<String> args;
  final Map<String, String> env;
  final DateTime connectedAt;
  bool isConnected;
  Client? client;
  List<Tool> tools;
  List<Resource> resources;
  
  // 进程跟踪信息
  String? actualCommand;  // 实际执行的命令
  List<String>? actualArgs;  // 实际执行的参数
  String? workingDirectory;  // 工作目录

  ChildServerInfo({
    required this.id,
    required this.name,
    required this.command,
    required this.args,
    this.env = const {},
    required this.connectedAt,
    this.isConnected = false,
    this.client,
    this.tools = const [],
    this.resources = const [],
    this.actualCommand,
    this.actualArgs,
    this.workingDirectory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'command': command,
      'args': args,
      'env': env,
      'connected_at': connectedAt.toIso8601String(),
      'is_connected': isConnected,
      'tools_count': tools.length,
      'resources_count': resources.length,
      'actual_command': actualCommand,
      'actual_args': actualArgs,
      'working_directory': workingDirectory,
    };
  }
}

/// MCP Hub服务器
/// 使用mcp_dart包实现标准MCP协议，并支持请求路由到子服务器
class McpHubService {
  static McpHubService? _instance;
  static McpHubService get instance => _instance ??= McpHubService._();
  
  McpHubService._();

  mcp_dart.McpServer? _mcpServer;
  HttpServer? _httpServer;
  SseServerManager? _sseManager;
  StreamableMcpHub? _streamableHub;
  bool _isRunning = false;
  int _port = 3000;
  String _serverMode = 'sse'; // 'sse' 或 'streamable'
  
  // 子服务器管理
  final Map<String, ChildServerInfo> _childServers = {};
  final StreamController<String> _serverEvents = StreamController<String>.broadcast();

  // 数据库状态监控
  Timer? _statusMonitorTimer;
  Set<String> _lastRunningServerIds = <String>{};
  bool _isInitializationComplete = false; // 标记初始化是否完成
  final Mutex _monitorLock = Mutex(); // 监控锁
  final Map<String, DateTime> _lastProcessedTime = {}; // 记录服务器最后处理时间
  final Set<String> _userInitiatedOperations = <String>{}; // 记录用户手动启动的服务器

  /// 启动MCP Hub服务器
  Future<void> startHub({int port = 3000}) async {
    if (_isRunning) {
      print('⚠️ MCP Hub is already running');
      return;
    }

    try {
      print('🚀 Starting MCP Hub Server...');
      
      // 首先清理服务器状态（应用重启时的状态恢复）
      await _cleanupServerStatesOnStartup();
      
      // 获取配置的服务器模式
      final configService = ConfigService.instance;
      _serverMode = await configService.getMcpServerMode();
      
      if (_serverMode == 'streamable') {
        // 启动Streamable模式
        await _startStreamableMode(port);
        _isRunning = true;
      } else {
        // 启动SSE模式（默认）
        await _startSseMode(port);
        _isRunning = true;
      }
      // 加载预配置的子服务器
      _loadPreconfiguredServers();
      
      // 启动数据库状态监控（替代原来的自动连接）
      _startDatabaseStatusMonitoring();
      
    } catch (e, stackTrace) {
      print('❌ Failed to start MCP Hub Server: $e');
      print('Stack trace: $stackTrace');
      _isRunning = false;
      rethrow;
    }
  }

  /// 启动SSE模式
  Future<void> _startSseMode(int port) async {
    _port = port;
    
    // 初始化HTTP服务器
    _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, port);
    
    // 创建MCP服务器实例
    _mcpServer = mcp_dart.McpServer(
      Implementation(name: "mcp-hub", version: AppVersion.hubVersion),
      options: ServerOptions(
        capabilities: ServerCapabilities(
          tools: ServerCapabilitiesTools(),
          resources: ServerCapabilitiesResources(),
          prompts: ServerCapabilitiesPrompts(),
        ),
      ),
    );

    // 注册工具和资源
    _registerTools();
    _registerResources();
    
    // 初始化SSE管理器
    _sseManager = SseServerManager(_mcpServer!);
    
    // 处理HTTP请求
    _httpServer!.listen((request) {
      _handleHttpRequest(request);
    });
    
    print('✅ MCP Hub Server (SSE mode) started successfully on port $port');
    print('🌐 Hub URL: http://localhost:$port');
    print('📡 SSE Endpoint: http://localhost:$port/sse');
    print('❤️ Health Check: http://localhost:$port/health');
  }

  /// 启动Streamable模式
  Future<void> _startStreamableMode(int port) async {
    try {
      final configService = ConfigService.instance;
      final streamablePort = await configService.getStreamablePort();
      
      _port = streamablePort;
      
      // 初始化Streamable Hub
      _streamableHub = StreamableMcpHub.instance;
      await _streamableHub!.startHub(port: streamablePort);
      
      print('✅ MCP Hub Server (Streamable mode) started successfully on port $streamablePort');
      print('🌐 Streamable Hub URL: http://localhost:$streamablePort/mcp');
      print('🔄 Multiple clients supported with session management');
      print('📊 Shared server pool for efficient resource usage');
    } catch (e, stackTrace) {
      print('❌ ERROR in _startStreamableMode: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 应用启动时恢复服务器状态和自动启动
  Future<void> _cleanupServerStatesOnStartup() async {
    try {
      print('🔄 Restoring server states on startup...');
      
      final repository = McpServerRepository.instance;
      final allServers = await repository.getAllServers();
      
      int restoredCount = 0;
      int autoStartCount = 0;
      List<models.McpServer> serversToStart = [];
      
      for (final server in allServers) {
        // 处理需要恢复的服务器状态
        if (server.status == models.McpServerStatus.running) {
          // 之前运行的服务器：标记为需要重新启动
          print('🔄 Preparing to restore server: ${server.name} (was running)');
          serversToStart.add(server);
          restoredCount++;
        } else if (server.status == models.McpServerStatus.starting || 
                   server.status == models.McpServerStatus.stopping) {
          // 清理中间状态，但对于starting状态的服务器，如果之前是运行的，应该恢复
          print('🧹 Cleaning intermediate state: ${server.name} (${server.status.name})');
          
          // 如果是starting状态，说明可能是应用关闭时正在启动，应该尝试恢复
          if (server.status == models.McpServerStatus.starting) {
            print('🔄 Attempting to restore server that was starting: ${server.name}');
            serversToStart.add(server);
            restoredCount++;
          } else {
            // stopping状态设为stopped
            final updatedServer = server.copyWith(
              status: models.McpServerStatus.stopped,
              updatedAt: DateTime.now(),
            );
            await repository.updateServer(updatedServer);
          }
        } else if (server.autoStart && 
                   (server.status == models.McpServerStatus.stopped || 
                    server.status == models.McpServerStatus.installed)) {
          // 自动启动的服务器
          print('🚀 Preparing to auto-start server: ${server.name}');
          serversToStart.add(server);
          autoStartCount++;
        }
      }
      
      // 启动需要恢复和自动启动的服务器
      if (serversToStart.isNotEmpty) {
        print('🚀 Starting ${serversToStart.length} servers (${restoredCount} restored, ${autoStartCount} auto-start)...');
        
        // 延迟启动，确保监控系统先完成（避免状态冲突）
        Timer(const Duration(seconds: 5), () {
          _processServerStartupQueue(serversToStart, repository);
        });
      }
      
      print('✅ Server state restoration completed');
      if (restoredCount > 0) {
        print('   🔄 Restored ${restoredCount} previously running servers');
      }
      if (autoStartCount > 0) {
        print('   🚀 Queued ${autoStartCount} auto-start servers');
      }
      
    } catch (e) {
      print('❌ Failed to restore server states: $e');
    }
  }

  /// 处理服务器启动队列（独立的异步方法，避免Timer回调中的异常）
  Future<void> _processServerStartupQueue(List<models.McpServer> serversToStart, dynamic repository) async {
    try {
      print('🔄 Processing server startup queue...');
      for (final server in serversToStart) {
        try {
          // 重新查询服务器当前状态（可能已被监控系统更新）
          final currentServer = await repository.getServerById(server.id);
          if (currentServer == null) {
            print('⚠️ Server ${server.name} not found, skipping');
            continue;
          }
          
          print('🚀 Auto-starting server: ${currentServer.name} (current status: ${_getStatusName(currentServer.status)})');
          
          // 检查服务器是否已经在运行中（避免状态冲突）
          if (currentServer.status == models.McpServerStatus.running) {
            print('✅ Server ${currentServer.name} is already running, skipping startup queue');
            continue;
          }
          
          // 只有当状态不是starting时才更新状态
          if (currentServer.status != models.McpServerStatus.starting) {
            final startingServer = currentServer.copyWith(
              status: models.McpServerStatus.starting,
              updatedAt: DateTime.now(),
            );
            await repository.updateServer(startingServer);
            print('📋 Updated status to starting for ${currentServer.name}');
          } else {
            print('📋 Server ${currentServer.name} already in starting state');
          }
          
          // 实际启动将由监控系统处理
          print('✅ Queued for startup: ${currentServer.name}');
          
        } catch (e) {
          print('❌ Failed to queue server ${server.name} for startup: $e');
          // 启动失败时设置为error状态
          try {
            // 重新获取最新状态进行错误更新
            final latestServer = await repository.getServerById(server.id);
            if (latestServer != null) {
              final errorServer = latestServer.copyWith(
                status: models.McpServerStatus.error,
                errorMessage: 'Auto-start failed: $e',
                updatedAt: DateTime.now(),
              );
              await repository.updateServer(errorServer);
            }
          } catch (updateError) {
            print('❌ Failed to update error status: $updateError');
          }
        }
      }
      print('✅ Server startup queue processing completed');
    } catch (e) {
      print('❌ Critical error in server startup queue processing: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  /// 获取状态名称的辅助方法（解决.name兼容性问题）
  String _getStatusName(models.McpServerStatus status) {
    switch (status) {
      case models.McpServerStatus.notInstalled:
        return 'notInstalled';
      case models.McpServerStatus.installed:
        return 'installed';
      case models.McpServerStatus.starting:
        return 'starting';
      case models.McpServerStatus.running:
        return 'running';
      case models.McpServerStatus.stopping:
        return 'stopping';
      case models.McpServerStatus.stopped:
        return 'stopped';
      case models.McpServerStatus.error:
        return 'error';
      case models.McpServerStatus.installing:
        return 'installing';
      case models.McpServerStatus.uninstalling:
        return 'uninstalling';
    }
  }

  /// 停止MCP Hub服务器
  Future<void> stopHub() async {
    if (!_isRunning) {
      print('⚠️ MCP Hub is not running');
      return;
    }

    try {
      print('🛑 Stopping MCP Hub Server...');
      
      // 停止数据库状态监控
      _stopDatabaseStatusMonitoring();
      
      // 断开所有子服务器连接
      await _disconnectAllChildServers();
      
      if (_serverMode == 'streamable' && _streamableHub != null) {
        // 停止Streamable模式
        await _streamableHub!.stopHub();
        _streamableHub = null;
      } else {
        // 停止SSE模式
        await _httpServer?.close();
        _httpServer = null;
        _mcpServer = null;
        _sseManager = null;
      }
      
      _isRunning = false;
      
      print('✅ MCP Hub Server stopped successfully');
      
    } catch (e) {
      print('❌ Failed to stop MCP Hub Server: $e');
      rethrow;
    }
  }

  /// 开始数据库状态监控
  Future<void> _startDatabaseStatusMonitoring() async {
    print('🔍 Starting database status monitoring...');
    
    _isInitializationComplete = true;
    print('✅ Hub initialization completed, monitoring enabled');
    
    // 立即执行一次检查（处理启动时已有的starting状态服务器）
    print('🔄 Performing immediate monitoring check...');
    try {
      await _monitorDatabaseStatus();
      print('✅ Immediate monitoring check completed');
    } catch (e) {
      print('❌ Immediate monitoring check failed: $e');
    }
    
    // 延迟3秒后再次检查（处理恢复流程中新设置的starting状态服务器）
    Timer(const Duration(seconds: 3), () async {
      print('🔄 Performing follow-up monitoring check...');
      try {
        await _monitorDatabaseStatus();
        print('✅ Follow-up monitoring check completed');
      } catch (e) {
        print('❌ Follow-up monitoring check failed: $e');
      }
    });
    
    // 延迟8秒后开始定期监控
    Timer(const Duration(seconds: 8), () {
      _statusMonitorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _monitorDatabaseStatus();
      });
      print('✅ Periodic database status monitoring started');
    });
    
    print('✅ Database status monitoring initialized');
  }

  /// 停止数据库状态监控
  void _stopDatabaseStatusMonitoring() {
    _statusMonitorTimer?.cancel();
    _statusMonitorTimer = null;
    _lastRunningServerIds.clear();
    _lastProcessedTime.clear();
    _userInitiatedOperations.clear();
    print('🛑 Database status monitoring stopped');
  }

  /// 监控数据库状态变化 - 统一架构：Hub管理所有子服务器
  Future<void> _monitorDatabaseStatus() async {
    await _monitorLock.protect(() async {
      try {
        // 获取数据库中所有服务器状态
        final repository = McpServerRepository.instance;
        final allServers = await repository.getAllServers();
        
        bool hasActions = false;
        
        // 1. 处理需要启动的服务器 (starting状态)
        final startingServers = allServers
            .where((server) => server.status == models.McpServerStatus.starting)
            .toList();
        
        print('🔍 Monitor: Found ${allServers.length} total servers, ${startingServers.length} starting servers');
        if (_userInitiatedOperations.isNotEmpty) {
          print('🔍 Monitor: User-initiated operations in progress: ${_userInitiatedOperations.join(', ')}');
        }
        
        if (startingServers.isNotEmpty) {
          hasActions = true;
          for (final server in startingServers) {
            // 检查服务器是否已经连接但状态未更新
            if (_childServers.containsKey(server.id)) {
              final existingServer = _childServers[server.id]!;
              if (existingServer.isConnected) {
                print('✅ Hub: Server ${server.name} already connected, updating status to running');
                await _updateServerStatus(server.id, models.McpServerStatus.running);
                // 移除用户操作标记
                _userInitiatedOperations.remove(server.id);
                continue;
              }
            }
            
            // 检查是否是用户手动启动的操作，如果是则跳过监控处理
            if (_userInitiatedOperations.contains(server.id)) {
              print('⏳ Hub: Skipping ${server.name} - user-initiated operation in progress');
              continue;
            }
            
            // 检查是否最近刚处理过这个服务器
            final lastProcessed = _lastProcessedTime[server.id];
            if (lastProcessed != null && 
                DateTime.now().difference(lastProcessed).inSeconds < 10) {
              print('⏳ Hub: Skipping ${server.name} - processed recently');
              continue;
            }
            
            print('🚀 Hub: Starting server ${server.name} (${server.id})');
            _lastProcessedTime[server.id] = DateTime.now();
            await _hubStartServer(server);
          }
        }
        
        // 2. 处理需要连接的服务器 (running状态但未连接)
        final runningServers = allServers
            .where((server) => server.status == models.McpServerStatus.running)
            .where((server) {
              // 只处理确实未连接的服务器
              if (!_childServers.containsKey(server.id)) {
                return true; // 服务器不在内存中，需要连接
              }
              final existingServer = _childServers[server.id]!;
              // 更严格的连接检查：既要标记为连接，又要有有效的客户端
              return !existingServer.isConnected || existingServer.client == null;
            })
            .toList();
        
        if (runningServers.isNotEmpty) {
          hasActions = true;
          for (final server in runningServers) {
            // 检查是否最近刚处理过这个服务器（避免重复处理）
            final lastProcessed = _lastProcessedTime[server.id];
            if (lastProcessed != null && 
                DateTime.now().difference(lastProcessed).inSeconds < 10) {
              print('⏳ Hub: Skipping ${server.name} - processed recently');
              continue;
            }
            
            print('🔗 Hub: Connecting to running server ${server.name} (${server.id}) - not currently connected');
            _lastProcessedTime[server.id] = DateTime.now();
            await _hubConnectToServer(server);
          }
        }
        
        // 3. 处理需要停止的服务器 (stopping状态)
        final stoppingServers = allServers
            .where((server) => server.status == models.McpServerStatus.stopping)
            .toList();
        
        if (stoppingServers.isNotEmpty) {
          hasActions = true;
          for (final server in stoppingServers) {
            // 检查是否是用户手动停止的操作，如果是则跳过监控处理
            if (_userInitiatedOperations.contains(server.id)) {
              print('⏳ Hub: Skipping ${server.name} - user-initiated stop operation in progress');
              continue;
            }
            
            print('🛑 Hub: Stopping server ${server.name} (${server.id})');
            await _hubStopServer(server);
          }
        }
        
        // 4. 检查已断开的服务器（只断开明确停止的服务器）"servers": {
        //       "command": "npx",
        //       "args": [
        //         "-y",
        //         "@smithery/cli@latest",
        //         "run",
        //         "@jlia0/servers",
        //         "--key",
        //         "65ac15b1-287a-4235-b968-cdc6e7b01548"
        //       ]
        //     }
        final connectedServerIds = _childServers.keys.toSet();
        final explicitlyStoppedIds = allServers
            .where((server) => server.status == models.McpServerStatus.stopped ||
                               server.status == models.McpServerStatus.error)
            .map((server) => server.id)
            .toSet();
        
        final shouldDisconnect = connectedServerIds.intersection(explicitlyStoppedIds);
        if (shouldDisconnect.isNotEmpty) {
          hasActions = true;
          for (final serverId in shouldDisconnect) {
            print('🔌 Hub: Disconnecting from explicitly stopped server ${serverId}');
            await _hubDisconnectFromServer(serverId);
          }
        }
        
        // 只在有实际操作时打印监控状态
        if (hasActions) {
          print('📊 Hub: Monitoring cycle completed with actions taken');
        }
        
      } catch (e) {
        print('❌ Error monitoring database status: $e');
      }
    });
  }

  /// 根据服务器连接类型创建传输层
  Future<dynamic> _createTransportForServer(
    models.McpServer server, 
    String actualCommand, 
    List<String> actualArgs, 
    Map<String, String> environment, 
    String workingDirectory
  ) async {
    switch (server.connectionType) {
      case models.McpConnectionType.stdio:
        print('🔗 Creating STDIO transport for ${server.name}');
        final serverParams = StdioServerParameters(
          command: actualCommand,
          args: actualArgs,
          environment: environment,
          workingDirectory: workingDirectory,
          stderrMode: ProcessStartMode.normal,
        );
        return StdioClientTransport(serverParams);
        
      case models.McpConnectionType.sse://huqb
        print('🌐 Creating SSE transport for ${server.name}');
        // 对于SSE模式，我们需要服务器的URL
        // 这里假设服务器在端口上运行，或者从配置中获取URL
        final port = server.port ?? 3000; // 默认端口
        final url = 'http://localhost:$port/sse';
        print('   📡 SSE URL: $url');
        
        // 注意：这里需要根据mcp_dart包的实际SSE传输实现来调整
        // 目前先抛出异常提示需要实现
        throw UnimplementedError('SSE transport not yet implemented. Please use stdio mode.');
        
      default:
        throw Exception('Unsupported connection type: ${server.connectionType.name}');
    }
  }

    /// Hub统一启动并连接服务器（一体化操作）
  Future<void> _hubStartServer(models.McpServer server) async {
    try {
      print('🚀 Hub: Starting and connecting to server ${server.name} (${server.id})');
      
      // 检查是否已经连接
      if (_childServers.containsKey(server.id)) {
        final existing = _childServers[server.id]!;
        if (existing.isConnected) {
          print('⚠️ Hub: Server ${server.id} is already connected');
          return;
        }
      }

      // 获取实际的命令和参数（使用进程管理器的逻辑）
      final processManager = McpProcessManager.instance;
      final actualCommand = await processManager.getExecutablePathForServer(server);
      final actualArgs = await processManager.getArgsForServer(server);
      final workingDirectory = await processManager.getServerWorkingDirectory(server);
      final environment = await processManager.getServerEnvironment(server);
      
      print('🔧 Hub: Server configuration:');
      print('   - Command: $actualCommand');
      print('   - Args: ${actualArgs.join(' ')}');
      print('   - Working directory: $workingDirectory');
      print('   - Environment variables: ${environment.length}');
      print('   - Connection type: ${server.connectionType.name}');

      // 根据连接类型创建不同的传输层
      final transport = await _createTransportForServer(server, actualCommand, actualArgs, environment, workingDirectory);

      // 创建MCP客户端
      final client = Client(
        Implementation(name: AppVersion.appName, version: AppVersion.version),
        options: ClientOptions(
          capabilities: ClientCapabilities(),
        ),
      );

      // 设置传输错误和关闭处理程序
      transport.onerror = (error) {
        print('❌ Hub: Transport error for ${server.name}: $error');
      };

      transport.onclose = () {
        print('🔌 Hub: Transport closed for ${server.name}');
      };

      print('🔗 Hub: Connecting to server (this will start the process)...');
      
      // 连接到服务器（这会自动启动进程）
      await client.connect(transport);
      print('✅ Hub: Connected to MCP server: ${server.name}');

      // 获取服务器的工具和资源列表
      final tools = await _getServerTools(client);
      final resources = await _getServerResources(client);

      final serverInfo = ChildServerInfo(
        id: server.id,
        name: server.name,
        command: server.command,
        args: server.args,
        env: server.env ?? {},
        connectedAt: DateTime.now(),
        isConnected: true,
        client: client,
        tools: tools,
        resources: resources,
        actualCommand: actualCommand,
        actualArgs: actualArgs,
        workingDirectory: workingDirectory,
      );

      _childServers[server.id] = serverInfo;

      // 立即更新Hub的工具列表
      await _updateHubToolsAfterConnection();

      // 发送服务器连接事件
      _emitServerEvent('server_connected', {
        'server_id': server.id,
        'name': server.name,
        'tools_count': tools.length,
        'resources_count': resources.length,
      });

      print('✅ Hub: Successfully started and connected to server: ${server.id} (${server.name})');
      print('   📋 Tools: ${tools.length}, Resources: ${resources.length}');
      
      // 成功连接后，更新数据库状态为running
      await _updateServerStatus(server.id, models.McpServerStatus.running);
      
    } catch (e) {
      print('❌ Hub: Failed to start and connect server ${server.name}: $e');
      // 启动失败时，更新状态为error
      await _updateServerStatus(server.id, models.McpServerStatus.error);
    }
  }

  /// 检查服务器连接是否有效（轻量级检查）
  bool _isServerConnectionValid(ChildServerInfo serverInfo) {
    return serverInfo.isConnected && 
           serverInfo.client != null && 
           serverInfo.tools.isNotEmpty; // 如果有工具说明连接是有效的
  }

  /// Hub统一连接到已启动的服务器（保留，用于运行时检测）
  Future<void> _hubConnectToServer(models.McpServer server) async {
    try {
      print('🔗 Hub: Attempting to connect to running server ${server.name}');
      
      // 检查是否已经连接并且健康
      if (_childServers.containsKey(server.id)) {
        final existing = _childServers[server.id]!;
        if (_isServerConnectionValid(existing)) {
          print('✅ Hub: Server ${server.id} is already connected and healthy');
          return;
        } else {
          print('🔄 Hub: Server ${server.id} exists but disconnected, removing and restarting');
          await _hubDisconnectFromServer(server.id);
        }
      }
      
      // 对于统一架构，需要重新启动来连接
      // 因为MCP的StdioClientTransport就是设计为一体化的
      print('🔄 Hub: Using unified start+connect for ${server.name}');
      await _hubStartServer(server);
      
    } catch (e) {
      print('❌ Hub: Failed to connect to server ${server.name}: $e');
      await _updateServerStatus(server.id, models.McpServerStatus.error);
    }
  }

  /// Hub统一停止服务器
  Future<void> _hubStopServer(models.McpServer server) async {
    try {
      print('🛑 Hub: Stopping server ${server.name}');
      
      // 1. 先断开连接（这会关闭StdioClientTransport管理的进程）
      if (_childServers.containsKey(server.id)) {
        await _hubDisconnectFromServer(server.id);
        print('✅ Hub: Successfully disconnected and stopped server: ${server.name}');
      } else {
        print('⚠️ Hub: Server ${server.id} was not connected, marking as stopped anyway');
      }
      
      // 2. 更新状态为stopped
      await _updateServerStatus(server.id, models.McpServerStatus.stopped);
      
      print('✅ Hub: Server stopped successfully: ${server.name}');
      
    } catch (e) {
      print('❌ Hub: Error stopping server ${server.name}: $e');
      await _updateServerStatus(server.id, models.McpServerStatus.error);
      rethrow;
    }
  }

  /// Hub统一断开连接
  Future<void> _hubDisconnectFromServer(String serverId) async {
    try {
      final serverInfo = _childServers[serverId];
      if (serverInfo == null) {
        print('⚠️ Hub: Server $serverId not found in connected servers');
        return;
      }

      print('🔌 Hub: Disconnecting from server: ${serverInfo.name} ($serverId)');

      // 1. 关闭客户端连接
      try {
        await serverInfo.client?.close();
        print('✅ Hub: MCP client connection closed');
      } catch (e) {
        print('⚠️ Hub: Error closing client connection: $e');
      }

      // 2. 强制终止底层进程
      await _forceKillServerProcess(serverInfo);

      // 3. 从连接列表中移除
      _childServers.remove(serverId);

      // 4. 立即更新Hub的工具列表
      await _updateHubToolsAfterDisconnection();

      // 5. 发送服务器断开事件
      _emitServerEvent('server_disconnected', {
        'server_id': serverId,
        'name': serverInfo.name,
      });

      print('✅ Hub: Successfully disconnected from server: $serverId (${serverInfo.name})');
      
    } catch (e) {
      print('❌ Hub: Failed to disconnect from server $serverId: $e');
    }
  }

  /// 强制终止服务器进程
  Future<void> _forceKillServerProcess(ChildServerInfo serverInfo) async {
    try {
      print('🔪 Hub: Force killing process for ${serverInfo.name}...');
      
      // 构建进程查找模式
      String? searchPattern;
      
      if (serverInfo.actualCommand != null && serverInfo.actualArgs != null) {
        // 使用实际的命令和参数
        final fullCommand = '${serverInfo.actualCommand} ${serverInfo.actualArgs!.join(' ')}';
        searchPattern = fullCommand;
      } else {
        // 回退到原始命令
        final fullCommand = '${serverInfo.command} ${serverInfo.args.join(' ')}';
        searchPattern = fullCommand;
      }
      
      print('   🔍 Searching for process: $searchPattern');
      
      // 查找并杀死匹配的进程
      final result = await Process.run('pkill', ['-f', searchPattern]);
      
      if (result.exitCode == 0) {
        print('✅ Hub: Successfully killed server process');
      } else {
        print('⚠️ Hub: pkill exit code: ${result.exitCode} (process may already be dead)');
        if (result.stderr.toString().isNotEmpty) {
          print('   stderr: ${result.stderr}');
        }
      }
      
      // 额外安全措施：根据包名杀死进程（针对npm包）
      if (serverInfo.args.isNotEmpty) {
        final packageName = serverInfo.args.first;
        if (packageName.contains('/')) {
          final result2 = await Process.run('pkill', ['-f', packageName]);
          if (result2.exitCode == 0) {
            print('✅ Hub: Also killed process by package name: $packageName');
          }
        }
      }
      
    } catch (e) {
      print('❌ Hub: Error force killing process: $e');
    }
  }

  /// 更新服务器状态的辅助方法
  Future<void> _updateServerStatus(String serverId, models.McpServerStatus status) async {
    try {
      final repository = McpServerRepository.instance;
      final server = await repository.getServerById(serverId);
      if (server == null) {
        print('❌ Hub: Cannot update status: Server $serverId not found');
        return;
      }
      
      final updatedServer = server.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      
      await repository.updateServer(updatedServer);
      print('📋 Hub: Status updated: ${server.name} -> ${status.name}');
      
    } catch (e) {
      print('❌ Hub: Failed to update server status: $e');
    }
  }

  /// 旧方法保留（已由统一架构替代）
  Future<void> _connectToRunningServer(models.McpServer server) async {
    try {
      // 检查是否已经连接
      if (_childServers.containsKey(server.id)) {
        final existing = _childServers[server.id]!;
        if (existing.isConnected) {
          print('⚠️ Server ${server.id} is already connected');
          return;
        }
      }

      // 如果初始化未完成，跳过连接
      if (!_isInitializationComplete) {
        print('⏰ Hub initialization not complete, skipping connection: ${server.name}');
        return;
      }

      // 运行时检测到新的running状态的服务器
      print('🔗 Runtime: Detected new running server: ${server.name}');
      print('   ID: ${server.id}');
      print('   📝 Hub will connect to user-started MCP process');
      
      // 等待用户进程完全稳定
      print('⏰ Waiting for user process to stabilize before connecting...');
      await Future.delayed(const Duration(seconds: 8));
      
             // 检查进程是否还在运行
      final isRunning = await McpProcessManager.instance.isServerRunning(server.id);
      if (!isRunning) {
        print('❌ User process no longer running, aborting connection');
        throw Exception('Process terminated before Hub connection');
      }

      // 创建MCP客户端
      final client = Client(
        Implementation(name: AppVersion.appName, version: AppVersion.version),
        options: ClientOptions(
          capabilities: ClientCapabilities(),
        ),
      );

      // 获取实际的命令和参数（与进程管理器中的逻辑一致）
      String actualCommand = server.command;
      List<String> actualArgs = server.args;
      
      // 处理NPX命令转换
      if (server.installType == models.McpInstallType.npx && server.command == 'npx') {
        // NPX会被转换为npm exec
        final runtimeManager = RuntimeManager.instance;
        actualCommand = await runtimeManager.getNpmExecutable();
        actualArgs = ['exec', ...server.args];
      }
      
      print('   🔧 Connecting with command: $actualCommand');
      print('   🔧 Connecting with args: ${actualArgs.join(' ')}');

      // 获取与进程管理器相同的环境变量和工作目录
      final processManager = McpProcessManager.instance;
      final workingDirectory = await processManager.getServerWorkingDirectory(server);
      final environment = await processManager.getServerEnvironment(server);
      
      print('🔧 Connecting with environment variables:');
      environment.forEach((key, value) {
        if (key.startsWith('NODE_') || key.startsWith('NPM_') || key == 'PATH') {
          print('   - $key: $value');
        }
      });
      print('🔧 Working directory: $workingDirectory');
      
      // 创建传输层 - 连接到已运行的进程
      final transport = StdioClientTransport(
        StdioServerParameters(
          command: actualCommand,
          args: actualArgs,
          environment: environment,
          workingDirectory: workingDirectory,
        ),
      );
      
      // 连接到服务器
      await client.connect(transport);
      print('✅ Connected to running MCP server: ${server.name}');

      // 获取服务器的工具和资源列表
      final tools = await _getServerTools(client);
      final resources = await _getServerResources(client);

      final serverInfo = ChildServerInfo(
        id: server.id,
        name: server.name,
        command: server.command,
        args: server.args,
        env: server.env ?? {},
        connectedAt: DateTime.now(),
        isConnected: true,
        client: client,
        tools: tools,
        resources: resources,
        actualCommand: actualCommand,
        actualArgs: actualArgs,
        workingDirectory: workingDirectory,
      );

      _childServers[server.id] = serverInfo;

      // 立即更新Hub的工具列表
      await _updateHubToolsAfterConnection();

      // 发送服务器连接事件
      _emitServerEvent('server_connected', {
        'server_id': server.id,
        'name': server.name,
        'tools_count': tools.length,
        'resources_count': resources.length,
      });

      print('✅ Successfully connected to server: ${server.id} (${server.name})');
      print('   📋 Tools: ${tools.length}, Resources: ${resources.length}');
      
      // 打印发现的工具
      if (tools.isNotEmpty) {
        print('   🔧 Available tools:');
        for (final tool in tools) {
          print('      - ${tool.name}: ${tool.description}');
        }
      }
      
    } catch (e) {
      print('❌ Failed to connect to running server ${server.id}: $e');
      
             // 连接失败时，将数据库中的状态改回installed
       try {
         final mcpServerService = McpServerService.instance;
         await mcpServerService.updateServerStatus(server.id, models.McpServerStatus.installed);
         print('🔄 Reset server status to installed due to connection failure');
       } catch (updateError) {
         print('❌ Failed to update server status: $updateError');
       }
    }
  }

  /// 断开与服务器的连接
  Future<void> _disconnectFromServer(String serverId) async {
    try {
      final serverInfo = _childServers[serverId];
      if (serverInfo == null) {
        print('⚠️ Server $serverId not found in connected servers');
        return;
      }

      print('🔌 Disconnecting from server: ${serverInfo.name} ($serverId)');

             // 关闭客户端连接
       try {
         await serverInfo.client?.close();
      } catch (e) {
        print('⚠️ Error closing client connection: $e');
      }

      // 从连接列表中移除
      _childServers.remove(serverId);

      // 立即更新Hub的工具列表
      await _updateHubToolsAfterDisconnection();

      // 发送服务器断开事件
      _emitServerEvent('server_disconnected', {
        'server_id': serverId,
        'name': serverInfo.name,
      });

      print('✅ Successfully disconnected from server: $serverId (${serverInfo.name})');
      
    } catch (e) {
      print('❌ Failed to disconnect from server $serverId: $e');
    }
  }

    /// 在服务器连接后更新Hub工具列表
  Future<void> _updateHubToolsAfterConnection() async {
    try {
      print('🔄 Updating Hub tools after server connection...');
      
      // 重新创建MCP服务器来刷新工具列表
      _recreateMcpServer();
      
      // 更新工具聚合器
      final toolsAggregator = McpToolsAggregator.instance;
      for (final serverInfo in _childServers.values) {
        if (serverInfo.isConnected) {
          toolsAggregator.updateServerTools(
            serverInfo.id, 
            serverInfo.tools, 
            serverInfo.resources
          );
        }
      }
      
      final totalTools = _getTotalToolsCount();
      print('✅ Hub tools updated. Total tools: $totalTools');
      
    } catch (e) {
      print('❌ Failed to update Hub tools after connection: $e');
    }
  }

  /// 在服务器断开后更新Hub工具列表
  Future<void> _updateHubToolsAfterDisconnection() async {
    try {
      print('🔄 Updating Hub tools after server disconnection...');
      
      // 重新创建MCP服务器来刷新工具列表
      _recreateMcpServer();
      
      // 更新工具聚合器
      final toolsAggregator = McpToolsAggregator.instance;
      for (final serverId in _childServers.keys.toList()) {
        final serverInfo = _childServers[serverId];
        if (serverInfo == null || !serverInfo.isConnected) {
          toolsAggregator.removeServerTools(serverId);
        }
      }
      
      final totalTools = _getTotalToolsCount();
      print('✅ Hub tools updated. Total tools: $totalTools');
      
    } catch (e) {
      print('❌ Failed to update Hub tools after disconnection: $e');
    }
  }

  /// 处理HTTP请求
  void _handleHttpRequest(HttpRequest request) {
    try {
      final uri = request.uri;
      
      // 设置CORS头
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
      
      if (request.method == 'OPTIONS') {
        request.response.statusCode = 200;
        request.response.close();
        return;
      }
      
      switch (uri.path) {
        case '/':
          _handleRootRequest(request);
          break;
        case '/sse':
          _handleSseRequest(request);
          break;
        case '/message':
          _handleMcpMessageRequest(request);
          break;
        case '/health':
          _handleHealthRequest(request);
          break;
        case '/servers':
          _handleServersRequest(request);
          break;
        case '/servers/register':
          _handleServerRegistrationRequest(request);
          break;
        case '/servers/discover':
          _handleServerDiscoveryRequest(request);
          break;
        case '/events':
          _handleEventsRequest(request);
          break;
        case '/tools':
          _handleToolsRequest(request);
          break;
        case '/stats':
          _handleStatsRequest(request);
          break;
        case '/mcp':
          _handleMcpProtocolRequest(request);
          break;
        default:
          if (uri.path.startsWith('/servers/')) {
            _handleServerManagementRequest(request);
          } else if (uri.path.startsWith('/tools/')) {
            _handleToolManagementRequest(request);
          } else if (uri.path.startsWith('/messages')) {
            // 处理动态的 /messages?sessionId=... 端点
            _handleMcpMessageRequest(request);
          } else {
            print('404 Not Found: ${uri.path}');
            request.response.statusCode = 404;
            request.response.write('Not Found');
            request.response.close();
          }
      }
    } catch (e) {
      print('Error handling HTTP request: $e');
      request.response.statusCode = 500;
      request.response.write('Internal Server Error');
      request.response.close();
    }
  }

  /// 处理根路径请求
  void _handleRootRequest(HttpRequest request) {
    final info = {
      'name': 'MCP Hub',
      'version': '1.0.0',
      'description': 'MCP Hub Server for managing and routing MCP servers',
      'protocol_version': latestProtocolVersion,
      'capabilities': {
        'tools': true,
        'resources': true,
        'prompts': true,
        'server_management': true,
        'tool_routing': true,
      },
      'endpoints': {
        'sse': '/sse',
        'health': '/health',
        'servers': '/servers',
        'events': '/events',
      },
      'statistics': {
        'connected_servers': _childServers.values.where((s) => s.isConnected).length,
        'total_tools': _getTotalToolsCount(),
        'total_resources': _getTotalResourcesCount(),
      }
    };
    
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(info));
    request.response.close();
  }

  /// 处理SSE请求
  void _handleSseRequest(HttpRequest request) {
    print('Received request: ${request.method} ${request.uri.path}');
    
    if (_sseManager != null) {
      _sseManager!.handleRequest(request);
    } else {
      print('SSE Manager not available');
      request.response.statusCode = 503;
      request.response.write('Service Unavailable');
      request.response.close();
    }
  }

  /// 处理MCP消息请求 (POST /message)
  void _handleMcpMessageRequest(HttpRequest request) async {
    print('Received MCP message request: ${request.method} ${request.uri.path}');
    
    if (request.method != 'POST') {
      request.response.statusCode = 405;
      request.response.write('Method Not Allowed');
      request.response.close();
      return;
    }

    if (_sseManager != null) {
      // 让SSE管理器处理POST消息
      _sseManager!.handleRequest(request);
    } else {
      print('SSE Manager not available for message handling');
      request.response.statusCode = 503;
      request.response.write('Service Unavailable');
      request.response.close();
    }
  }

  /// 处理健康检查请求
  void _handleHealthRequest(HttpRequest request) {
    final connectedServers = _childServers.values.where((s) => s.isConnected).length;
    final totalServers = _childServers.length;
    
    final status = {
      'status': 'healthy',
      'port': _port,
      'uptime': DateTime.now().toIso8601String(),
      'servers': {
        'connected': connectedServers,
        'total': totalServers,
        'health_ratio': totalServers > 0 ? connectedServers / totalServers : 1.0,
      },
      'capabilities': {
        'tools': _getTotalToolsCount(),
        'resources': _getTotalResourcesCount(),
      }
    };
    
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(status));
    request.response.close();
  }

  /// 处理服务器信息请求
  void _handleServersRequest(HttpRequest request) {
    final servers = _childServers.values.map((server) => server.toJson()).toList();
    
    final serverInfo = {
      'servers': servers,
      'count': servers.length,
      'connected_count': servers.where((s) => s['is_connected'] == true).length,
    };
    
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(serverInfo));
    request.response.close();
  }

  /// 处理事件流请求
  void _handleEventsRequest(HttpRequest request) {
    request.response.headers.set('Content-Type', 'text/event-stream');
    request.response.headers.set('Cache-Control', 'no-cache');
    request.response.headers.set('Connection', 'keep-alive');
    
    // 发送初始事件
    request.response.write('data: {"type": "connected", "timestamp": "${DateTime.now().toIso8601String()}"}\n\n');
    
    // 监听服务器事件
    late StreamSubscription subscription;
    subscription = _serverEvents.stream.listen((event) {
      request.response.write('data: $event\n\n');
    });
    
    // 客户端断开连接时清理
    request.response.done.then((_) {
      subscription.cancel();
    });
  }

  /// 注册MCP工具
  void _registerTools() {
    // 只注册基础的ping工具，其他工具通过动态注册
    _registerBasicTools();
    
    // 注册当前已连接的子服务器工具
    _registerChildServerTools();
  }

  /// 注册基础工具（只保留ping）
  void _registerBasicTools() {
    // Ping工具 - 唯一的Hub自身工具
    _mcpServer!.tool(
      "ping",
      description: 'Test connectivity to MCP Hub',
      inputSchemaProperties: {},
      callback: ({args, extra}) async {
        return CallToolResult(
          content: [
            TextContent(text: 'pong - MCP Hub is running with ${_childServers.length} connected servers'),
          ],
        );
      },
    );
  }

  /// 动态注册子服务器工具
  void _registerChildServerTools() {
    for (final serverInfo in _childServers.values) {
      if (serverInfo.isConnected) {
        _registerServerTools(serverInfo);
      }
    }
  }

  /// 注册单个服务器的工具
  void _registerServerTools(ChildServerInfo serverInfo) {
    for (final tool in serverInfo.tools) {
      // 🔧 使用 servername::toolname 格式注册工具
      final serverName = _normalizeServerName(serverInfo.name);
      final wrappedToolName = '${serverName}::${tool.name}';
      
      // 为每个子服务器工具创建代理
      _mcpServer!.tool(
        wrappedToolName,
        description: '${tool.description} (来自: ${serverInfo.name})',
        inputSchemaProperties: tool.inputSchema.properties,
        callback: ({args, extra}) async {
          return await _callChildServerTool(serverInfo.id, tool.name, args ?? {});
        },
      );
      
      print('🔧 Registered wrapped tool: $wrappedToolName from ${serverInfo.name}');
    }
  }

  /// 调用子服务器工具
  Future<CallToolResult> _callChildServerTool(String serverId, String toolName, Map<String, dynamic> args) async {
    final serverInfo = _childServers[serverId];
    if (serverInfo == null || !serverInfo.isConnected || serverInfo.client == null) {
      throw Exception('Server $serverId is not connected');
    }

    try {
      print('🔄 Calling tool $toolName on server $serverId with args: $args');
      
      // 调用子服务器的工具，设置60秒超时
      final callParams = CallToolRequestParams(
        name: toolName,
        arguments: args,
      );
      
      final result = await serverInfo.client!.callTool(callParams).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏰ Tool $toolName timed out after 60 seconds');
          return CallToolResult(
            content: [TextContent(text: 'Tool execution timed out after 60 seconds')],
            isError: true,
          );
        },
      );
      
      print('✅ Tool $toolName completed successfully');
      print('📋 Result content: ${result.content.length} items');
      
      // 打印结果的前几个字符用于调试
      if (result.content.isNotEmpty) {
        for (int i = 0; i < result.content.length; i++) {
          final content = result.content[i];
          if (content is TextContent) {
            final text = content.text;
            final preview = text.length > 200 ? '${text.substring(0, 200)}...' : text;
            print('📄 Content $i: $preview');
          } else {
            print('📄 Content $i: ${content.runtimeType}');
          }
        }
      }
      
      return result;
    } catch (e) {
      print('❌ Tool $toolName failed: $e');
      return CallToolResult(
        content: [TextContent(text: 'Tool execution failed: $e')],
        isError: true,
      );
    }
  }

  /// 清除已注册的工具（当服务器断开时）
  void _clearRegisteredTools() {
    // 注意：mcp_dart可能不支持动态取消注册工具
    // 这里我们需要重新创建MCP服务器实例来清理工具
    print('🧹 Clearing registered tools...');
    
    // 重新创建MCP服务器实例（这是清理工具的唯一方式）
    _recreateMcpServer();
  }

  /// 重新创建MCP服务器实例
  void _recreateMcpServer() {
    if (_mcpServer == null) return;
    
    print('🔄 Recreating MCP server to refresh tools...');
    
    // 创建新的MCP服务器实例
    _mcpServer = mcp_dart.McpServer(
      Implementation(name: "mcp-hub", version: AppVersion.hubVersion),
      options: ServerOptions(
        capabilities: ServerCapabilities(
          tools: ServerCapabilitiesTools(),
          resources: ServerCapabilitiesResources(),
          prompts: ServerCapabilitiesPrompts(),
        ),
      ),
    );

    // 重新注册工具和资源
    _registerTools();
    _registerResources();
    
    // 更新SSE管理器
    if (_sseManager != null) {
      _sseManager = SseServerManager(_mcpServer!);
    }
    
    print('✅ MCP server recreated with current tools');
  }

  /// 标准化服务器名称，用于工具名称前缀
  String _normalizeServerName(String serverName) {
    return serverName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), ''); // 只保留字母、数字和下划线
  }

  /// 注册资源
  void _registerResources() {
    // TODO: 实现资源注册
    // 由于mcp_dart的资源API可能不同，暂时跳过资源注册
    // 可以在后续版本中实现
  }

  /// 连接到子服务器
  Future<void> _connectToChildServer(
    String serverId,
    String name,
    String command,
    List<String> args,
    Map<String, String> env,
  ) async {
    if (_childServers.containsKey(serverId)) {
      final existing = _childServers[serverId]!;
      if (existing.isConnected) {
        throw Exception('Server $serverId is already connected');
      }
    }

    try {
      final client = Client(
        Implementation(name: AppVersion.appName, version: AppVersion.version),
        options: ClientOptions(
          capabilities: ClientCapabilities(),
        ),
      );

             final transport = StdioClientTransport(
         StdioServerParameters(
           command: command,
           args: args,
         ),
       );

      await client.connect(transport);

      // 获取服务器的工具和资源列表
      final tools = await _getServerTools(client);
      final resources = await _getServerResources(client);

      final serverInfo = ChildServerInfo(
        id: serverId,
        name: name,
        command: command,
        args: args,
        env: env,
        connectedAt: DateTime.now(),
        isConnected: true,
        client: client,
        tools: tools,
        resources: resources,
        actualCommand: command,
        actualArgs: args,
        workingDirectory: null,
      );

      _childServers[serverId] = serverInfo;

      // 发送服务器连接事件
      _emitServerEvent('server_connected', {
        'server_id': serverId,
        'name': name,
        'tools_count': tools.length,
        'resources_count': resources.length,
      });

      print('✅ Connected to child server: $serverId ($name)');
      print('   Tools: ${tools.length}, Resources: ${resources.length}');
    } catch (e) {
      print('❌ Failed to connect to server $serverId: $e');
      rethrow;
    }
  }

  /// 断开子服务器连接
  Future<void> _disconnectFromChildServer(String serverId) async {
    final server = _childServers[serverId];
    if (server == null) {
      throw Exception('Server $serverId not found');
    }

    if (!server.isConnected) {
      throw Exception('Server $serverId is not connected');
    }

    try {
      await server.client?.close();
      server.isConnected = false;
      server.client = null;
      server.tools = [];
      server.resources = [];

      // 发送服务器断开事件
      _emitServerEvent('server_disconnected', {
        'server_id': serverId,
        'name': server.name,
      });

      print('✅ Disconnected from child server: $serverId');
    } catch (e) {
      print('❌ Error disconnecting from server $serverId: $e');
      rethrow;
    }
  }

  /// 断开所有子服务器连接
  Future<void> _disconnectAllChildServers() async {
    final connectedServers = _childServers.values
        .where((s) => s.isConnected)
        .toList();

    for (final server in connectedServers) {
      try {
        await _disconnectFromChildServer(server.id);
      } catch (e) {
        print('❌ Error disconnecting server ${server.id}: $e');
      }
    }
  }

  /// 调用子服务器工具（公共方法）
  Future<CallToolResult> callChildServerTool(
    String serverId,
    String toolName,
    Map<String, dynamic> toolArgs,
  ) async {
    return await _callChildTool(serverId, toolName, toolArgs);
  }

  /// 调用子服务器工具
  Future<CallToolResult> _callChildTool(
    String serverId,
    String toolName,
    Map<String, dynamic> toolArgs,
  ) async {
    final server = _childServers[serverId];
    if (server == null || !server.isConnected || server.client == null) {
      throw Exception('Server $serverId is not connected');
    }

    try {
      print('🔧 Calling tool $toolName on server $serverId with args: $toolArgs');
      
      // 使用mcp_dart的API调用子服务器工具，设置60秒超时
      final callParams = CallToolRequestParams(
        name: toolName,
        arguments: toolArgs,
      );
      
      final result = await server.client!.callTool(callParams).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏰ Tool $toolName timed out after 60 seconds');
          return CallToolResult(
            content: [TextContent(text: 'Tool execution timed out after 60 seconds')],
            isError: true,
          );
        },
      );
      
      print('✅ Tool $toolName executed successfully on server $serverId');
      print('📋 Result content: ${result.content.length} items');
      
      // 打印结果的前几个字符用于调试
      if (result.content.isNotEmpty) {
        for (int i = 0; i < result.content.length; i++) {
          final content = result.content[i];
          if (content is TextContent) {
            final text = content.text;
            final preview = text.length > 200 ? '${text.substring(0, 200)}...' : text;
            print('📄 Content $i: $preview');
          } else {
            print('📄 Content $i: ${content.runtimeType}');
          }
        }
      } else {
        print('⚠️ Tool returned empty content');
      }
      
      return result;
    } catch (e) {
      print('❌ Error calling tool $toolName on server $serverId: $e');
      rethrow;
    }
  }

  /// 获取服务器工具列表
  Future<List<Tool>> _getServerTools(Client client) async {
    try {
      print('📋 Getting tools from child server...');
      
      // 使用mcp_dart的API获取工具列表
      final listToolsResult = await client.listTools();
      print('✅ Found ${listToolsResult.tools.length} tools from child server');
      
      return listToolsResult.tools;
    } catch (e) {
      print('❌ Error getting tools from server: $e');
      return [];
    }
  }

  /// 获取服务器资源列表
  Future<List<Resource>> _getServerResources(Client client) async {
    try {
      print('📋 Getting resources from child server...');
      
      // 使用mcp_dart的API获取资源列表
      final listResourcesResult = await client.listResources();
      print('✅ Found ${listResourcesResult.resources.length} resources from child server');
      
      return listResourcesResult.resources;
    } catch (e) {
      // 有些MCP服务器可能不支持resources方法，这是正常的
      if (e.toString().contains('Method not found')) {
        print('📋 Child server does not support resources (this is normal)');
      } else {
        print('❌ Error getting resources from server: $e');
      }
      return [];
    }
  }

  /// 发送服务器事件
  void _emitServerEvent(String eventType, Map<String, dynamic> data) {
    final event = {
      'type': eventType,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };
    _serverEvents.add(jsonEncode(event));
  }

  /// 加载预配置的服务器
  void _loadPreconfiguredServers() {
    // TODO: 从配置文件或数据库加载预配置的服务器
    // 这里可以添加一些示例服务器配置
    print('📋 Loading preconfigured servers...');
    
    // 示例：连接到一个模拟的计算器服务器
    // 在实际应用中，这些配置应该来自配置文件或数据库
  }

  /// 获取总工具数量
  int _getTotalToolsCount() {
    int count = 0;
    // Hub自身只有ping工具
    count += 1;
    
    // 子服务器的工具
    for (final server in _childServers.values) {
      if (server.isConnected) {
        count += server.tools.length;
      }
    }
    return count;
  }

  /// 获取总资源数量
  int _getTotalResourcesCount() {
    int count = 0; // Hub自身的资源数量
    for (final server in _childServers.values) {
      if (server.isConnected) {
        count += server.resources.length;
      }
    }
    return count;
  }

  /// 获取服务器状态
  Map<String, dynamic> getStatus() {
    // 检查两种模式的运行状态
    bool isActuallyRunning = false;
    
    if (_serverMode == 'streamable') {
      // Streamable模式：检查_isRunning和streamableHub状态
      isActuallyRunning = _isRunning && _streamableHub != null && _streamableHub!.isRunning;
    } else {
      // SSE模式：检查_isRunning和httpServer状态
      isActuallyRunning = _isRunning && _httpServer != null;
    }
    
    if (!isActuallyRunning) {
      return {
        'running': false,
        'port': null,
        'connected_servers': 0,
        'total_tools': 0,
        'total_resources': 0,
        'server_mode': _serverMode,
        'debug_info': {
          '_isRunning': _isRunning,
          '_httpServer_exists': _httpServer != null,
          '_streamableHub_exists': _streamableHub != null,
          '_streamableHub_running': _streamableHub?.isRunning ?? false,
          'mode_check': _serverMode == 'streamable' ? 'streamable_mode' : 'sse_mode',
        },
      };
    }

    final connectedServers = _childServers.values.where((s) => s.isConnected).length;

    return {
      'running': true,
      'port': _port,
      'connected_servers': connectedServers,
      'total_servers': _childServers.length,
      'total_tools': _getTotalToolsCount(),
      'total_resources': _getTotalResourcesCount(),
      'url': 'http://localhost:$_port',
      'sse_endpoint': 'http://localhost:$_port/sse',
      'health_endpoint': 'http://localhost:$_port/health',
      'protocol_version': latestProtocolVersion,
      'server_mode': _serverMode,
      'child_servers': _childServers.values.map((s) => s.toJson()).toList(),
    };
  }

  /// 检查服务器是否正在运行
  bool get isRunning => _isRunning;
  
  /// 获取当前端口
  int get port => _port;
  
  /// 获取连接的子服务器数量
  int get connectedServersCount => _childServers.values.where((s) => s.isConnected).length;
  
  /// 获取子服务器列表
  List<ChildServerInfo> get childServers => _childServers.values.toList();

  /// 设置标识
  void setDirectlyId(models.McpServer server) {
    // 标记这是用户手动启动的操作
    _userInitiatedOperations.add(server.id);
  }

  /// 直接启动服务器（用于用户手动启动）
  Future<void> startServerDirectly(models.McpServer server) async {
    print('🚀 Direct start request: ${server.name} (${server.id})');
    try {
      await _hubStartServer(server);
    } finally {
      // 操作完成后移除标记
      _userInitiatedOperations.remove(server.id);
    }
  }

  /// 直接停止服务器（用于用户手动停止）
  Future<void> stopServerDirectly(models.McpServer server) async {
    print('🛑 Direct stop request: ${server.name} (${server.id})');
    
    // 标记这是用户手动停止的操作
    _userInitiatedOperations.add(server.id);
    
    try {
      await _hubStopServer(server);
    } finally {
      // 操作完成后移除标记
      _userInitiatedOperations.remove(server.id);
    }
  }

  /// 处理工具列表请求
  void _handleToolsRequest(HttpRequest request) {
    try {
      final allTools = <Map<String, dynamic>>[];
      
      // 添加Hub自身的ping工具
      allTools.add({
        'name': 'ping',
        'description': 'Test connectivity to MCP Hub',
        'server_id': 'hub',
        'server_name': 'MCP Hub',
        'source': 'hub',
      });

      // 添加子服务器的工具
      for (final server in _childServers.values) {
        if (server.isConnected) {
          for (final tool in server.tools) {
            allTools.add({
              'name': tool.name,
              'description': '${tool.description} (via ${server.name})',
              'server_id': server.id,
              'server_name': server.name,
              'source': 'child_server',
            });
          }
        }
      }

      final response = {
        'tools': allTools,
        'count': allTools.length,
        'hub_tools': 1,
        'child_tools': allTools.length - 1,
      };

      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(response));
      request.response.close();
    } catch (e) {
      request.response.statusCode = 500;
      request.response.write('Error getting tools: $e');
      request.response.close();
    }
  }

  /// 处理统计信息请求
  void _handleStatsRequest(HttpRequest request) {
    try {
      final stats = {
        'connected_servers': _childServers.values.where((s) => s.isConnected).length,
        'total_servers': _childServers.length,
        'total_tools': _getTotalToolsCount(),
        'total_resources': _getTotalResourcesCount(),
        'hub_tools': 1,
        'child_server_tools': _getTotalToolsCount() - 1,
        'uptime_seconds': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'server_details': _childServers.values.map((s) => {
          'id': s.id,
          'name': s.name,
          'connected': s.isConnected,
          'tools_count': s.tools.length,
          'resources_count': s.resources.length,
        }).toList(),
      };

      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(stats));
      request.response.close();
    } catch (e) {
      request.response.statusCode = 500;
      request.response.write('Error getting stats: $e');
      request.response.close();
    }
  }

  /// 处理MCP协议请求
  void _handleMcpProtocolRequest(HttpRequest request) async {
    try {
      if (request.method != 'POST') {
        request.response.statusCode = 405;
        request.response.write('Method Not Allowed');
        request.response.close();
        return;
      }

             final body = await utf8.decoder.bind(request).join();
       final mcpRequest = jsonDecode(body);

      // 处理MCP初始化请求
      if (mcpRequest['method'] == 'initialize') {
        final response = {
          'jsonrpc': '2.0',
          'id': mcpRequest['id'],
          'result': {
            'protocolVersion': latestProtocolVersion,
            'capabilities': {
              'tools': {'listChanged': true},
              'resources': {'listChanged': true},
              'prompts': {'listChanged': true},
            },
            'serverInfo': {
              'name': 'MCP Hub',
              'version': '1.0.0',
            },
          },
        };

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(response));
        request.response.close();
      } 
      // 处理工具列表请求 - 这是关键功能！
      else if (mcpRequest['method'] == 'tools/list') {
        final allTools = await _getAllAggregatedTools();
        
        final response = {
          'jsonrpc': '2.0',
          'id': mcpRequest['id'],
          'result': {
            'tools': allTools,
          },
        };

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(response));
        request.response.close();
      }
      // 处理工具调用请求
      else if (mcpRequest['method'] == 'tools/call') {
        final params = mcpRequest['params'] as Map<String, dynamic>? ?? {};
        final toolName = params['name'] as String;
        final arguments = params['arguments'] as Map<String, dynamic>? ?? {};
        
        try {
          final result = await _callAggregatedTool(toolName, arguments);
          
          final response = {
            'jsonrpc': '2.0',
            'id': mcpRequest['id'],
            'result': result.toJson(),
          };

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(response));
          request.response.close();
        } catch (e) {
          final errorResponse = {
            'jsonrpc': '2.0',
            'id': mcpRequest['id'],
            'error': {
              'code': -32603,
              'message': 'Tool call failed: $e',
            },
          };

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(errorResponse));
          request.response.close();
        }
      }
      // 处理资源列表请求
      else if (mcpRequest['method'] == 'resources/list') {
        final allResources = await _getAllAggregatedResources();
        
        final response = {
          'jsonrpc': '2.0',
          'id': mcpRequest['id'],
          'result': {
            'resources': allResources,
          },
        };

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(response));
        request.response.close();
      }
      else {
        // 其他MCP请求返回未实现
        final errorResponse = {
          'jsonrpc': '2.0',
          'id': mcpRequest['id'],
          'error': {
            'code': -32601,
            'message': 'Method not found: ${mcpRequest['method']}',
          },
        };

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(errorResponse));
        request.response.close();
      }
    } catch (e) {
      request.response.statusCode = 500;
      request.response.write('Error processing MCP request: $e');
      request.response.close();
    }
  }

  /// 处理服务器管理请求
  void _handleServerManagementRequest(HttpRequest request) async {
    try {
      final uri = request.uri;
      
      if (uri.path == '/servers/connect' && request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final connectRequest = jsonDecode(body);
        
        final serverId = connectRequest['server_id'] as String;
        final name = connectRequest['name'] as String;
        final command = connectRequest['command'] as String;
        final args = List<String>.from(connectRequest['args'] ?? []);
        final env = Map<String, String>.from(connectRequest['env'] ?? {});

        try {
          await _connectToChildServer(serverId, name, command, args, env);
          
          final response = {
            'success': true,
            'message': 'Server connection initiated',
            'server_id': serverId,
          };

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(response));
          request.response.close();
        } catch (e) {
          final errorResponse = {
            'success': false,
            'error': e.toString(),
          };

          request.response.statusCode = 400;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(errorResponse));
          request.response.close();
        }
      } else if (uri.path == '/servers/disconnect' && request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final disconnectRequest = jsonDecode(body);
        
        final serverId = disconnectRequest['server_id'] as String;

        try {
          await _disconnectFromChildServer(serverId);
          
          final response = {
            'success': true,
            'message': 'Server disconnected',
            'server_id': serverId,
          };

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(response));
          request.response.close();
        } catch (e) {
          final errorResponse = {
            'success': false,
            'error': e.toString(),
          };

          request.response.statusCode = 400;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(errorResponse));
          request.response.close();
        }
      } else {
        request.response.statusCode = 404;
        request.response.write('Not Found');
        request.response.close();
      }
    } catch (e) {
      request.response.statusCode = 500;
      request.response.write('Error processing server management request: $e');
      request.response.close();
    }
  }

  /// 处理工具管理请求
  void _handleToolManagementRequest(HttpRequest request) async {
    try {
      final uri = request.uri;
      
      if (uri.path == '/tools/call' && request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final callRequest = jsonDecode(body);
        
        final toolName = callRequest['tool_name'] as String;
        final args = Map<String, dynamic>.from(callRequest['args'] ?? {});
        final serverId = callRequest['server_id'] as String?;

        try {
          CallToolResult result;
          
          if (serverId == null || serverId == 'hub') {
            // 调用Hub工具
            result = await _callHubTool(toolName, args);
          } else {
            // 调用子服务器工具
            result = await _callChildTool(serverId, toolName, args);
          }

          final response = {
            'success': true,
            'result': result.content.map((content) => {
              'type': content.runtimeType.toString(),
              'text': content is TextContent ? content.text : content.toString(),
            }).toList(),
          };

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(response));
          request.response.close();
        } catch (e) {
          final errorResponse = {
            'success': false,
            'error': e.toString(),
          };

          request.response.statusCode = 400;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(errorResponse));
          request.response.close();
        }
      } else {
        request.response.statusCode = 404;
        request.response.write('Not Found');
        request.response.close();
      }
    } catch (e) {
      request.response.statusCode = 500;
      request.response.write('Error processing tool management request: $e');
      request.response.close();
    }
  }

  /// 调用Hub工具
  Future<CallToolResult> _callHubTool(String toolName, Map<String, dynamic> args) async {
    switch (toolName) {
      case 'ping':
        return CallToolResult(
          content: [TextContent(text: 'pong')],
        );
      
      case 'get_status':
        final status = getStatus();
        return CallToolResult(
          content: [TextContent(text: jsonEncode(status))],
        );
      
      case 'calculate':
        final a = args['a'] as num? ?? 0;
        final b = args['b'] as num? ?? 0;
        final operation = args['operation'] as String? ?? 'add';
        
        num result;
        switch (operation) {
          case 'add':
            result = a + b;
            break;
          case 'subtract':
            result = a - b;
            break;
          case 'multiply':
            result = a * b;
            break;
          case 'divide':
            result = b != 0 ? a / b : double.nan;
            break;
          default:
            throw Exception('Unknown operation: $operation');
        }
        
        return CallToolResult(
          content: [TextContent(text: 'Result: $result')],
        );
      
      case 'list_servers':
        final servers = _childServers.values.map((s) => s.toJson()).toList();
        return CallToolResult(
          content: [TextContent(text: jsonEncode(servers))],
        );
      
      default:
        throw Exception('Unknown hub tool: $toolName');
    }
  }

  /// 处理服务器注册请求
  void _handleServerRegistrationRequest(HttpRequest request) async {
    if (request.method != 'POST') {
      request.response.statusCode = 405;
      request.response.write('Method Not Allowed');
      request.response.close();
      return;
    }

    try {
      final body = await utf8.decoder.bind(request).join();
      final registrationData = jsonDecode(body);
      
      final serverId = registrationData['server_id'] as String?;
      final name = registrationData['name'] as String?;
      final command = registrationData['command'] as String?;
      final args = (registrationData['args'] as List?)?.cast<String>() ?? [];
      final env = Map<String, String>.from(registrationData['env'] ?? {});
      final port = registrationData['port'] as int?;
      final host = registrationData['host'] as String? ?? 'localhost';
      
      if (serverId == null || name == null || command == null) {
        request.response.statusCode = 400;
        request.response.write('Missing required fields: server_id, name, command');
        request.response.close();
        return;
      }

      print('📝 Received server registration request: $serverId ($name)');

      try {
        // 尝试连接到注册的服务器
        await _connectToChildServer(serverId, name, command, args, env);
        
        // 发送注册成功响应
        final response = {
          'success': true,
          'message': 'Server registered and connected successfully',
          'server_id': serverId,
          'hub_info': {
            'hub_url': 'http://localhost:$_port',
            'hub_endpoints': {
              'tools': '/tools',
              'stats': '/stats',
              'events': '/events',
            }
          }
        };

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(response));
        request.response.close();
        
        print('✅ Server $serverId registered and connected successfully');
        
      } catch (e) {
        print('❌ Failed to connect to registered server $serverId: $e');
        
        final errorResponse = {
          'success': false,
          'error': 'Failed to connect to server: $e',
          'server_id': serverId,
        };

        request.response.statusCode = 400;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(errorResponse));
        request.response.close();
      }
      
    } catch (e) {
      print('❌ Error processing server registration: $e');
      
      request.response.statusCode = 500;
      request.response.write('Error processing registration: $e');
      request.response.close();
    }
  }

  /// 处理服务器发现请求
  void _handleServerDiscoveryRequest(HttpRequest request) async {
    if (request.method != 'POST') {
      request.response.statusCode = 405;
      request.response.write('Method Not Allowed');
      request.response.close();
      return;
    }

    try {
      print('🔍 Starting server discovery...');
      
      // 从数据库加载配置的服务器
      final discoveredServers = await _discoverConfiguredServers();
      
      int connectedCount = 0;
      final results = <Map<String, dynamic>>[];
      
      for (final serverConfig in discoveredServers) {
        try {
          final serverId = serverConfig['id'] as String;
          final name = serverConfig['name'] as String;
          final command = serverConfig['command'] as String;
          final args = (serverConfig['args'] as List?)?.cast<String>() ?? [];
          final env = Map<String, String>.from(serverConfig['env'] ?? {});
          
          // 检查服务器是否已经连接
          if (_childServers.containsKey(serverId) && _childServers[serverId]!.isConnected) {
            results.add({
              'server_id': serverId,
              'name': name,
              'status': 'already_connected',
              'message': 'Server already connected',
            });
            continue;
          }
          
          // 尝试连接服务器
          await _connectToChildServer(serverId, name, command, args, env);
          connectedCount++;
          
          results.add({
            'server_id': serverId,
            'name': name,
            'status': 'connected',
            'message': 'Successfully connected',
          });
          
          print('✅ Auto-connected to server: $serverId ($name)');
          
        } catch (e) {
          final serverId = serverConfig['id'] as String;
          final name = serverConfig['name'] as String;
          
          results.add({
            'server_id': serverId,
            'name': name,
            'status': 'failed',
            'message': 'Connection failed: $e',
          });
          
          print('❌ Failed to connect to server $serverId: $e');
        }
      }
      
      final response = {
        'success': true,
        'message': 'Server discovery completed',
        'discovered_count': discoveredServers.length,
        'connected_count': connectedCount,
        'results': results,
      };

      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(response));
      request.response.close();
      
      print('🔍 Server discovery completed: $connectedCount/$discoveredServers.length servers connected');
      
    } catch (e) {
      print('❌ Error during server discovery: $e');
      
      final errorResponse = {
        'success': false,
        'error': 'Discovery failed: $e',
      };

      request.response.statusCode = 500;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(errorResponse));
      request.response.close();
    }
  }

  /// 从数据库发现配置的服务器
  Future<List<Map<String, dynamic>>> _discoverConfiguredServers() async {
    try {
      // 导入MCP服务器仓库
      final repository = McpServerRepository.instance;
      
      // 获取所有已保存的服务器配置
      final servers = await repository.getAllServers();
      
      final configuredServers = <Map<String, dynamic>>[];
      
      for (final server in servers) {
        // 只自动连接状态为已安装或运行中的服务器
        if (server.status == models.McpServerStatus.installed || 
            server.status == models.McpServerStatus.running) {
          
          configuredServers.add({
            'id': server.id,
            'name': server.name,
            'command': server.command,
            'args': server.args,
            'env': server.env ?? {},
            'working_directory': server.workingDirectory,
          });
        }
      }
      
      print('📋 Found ${configuredServers.length} configured servers for auto-connection');
      return configuredServers;
      
    } catch (e) {
      print('❌ Error discovering configured servers: $e');
      return [];
    }
  }

  /// 获取所有聚合的工具列表（Hub工具 + 子服务器工具）
  Future<List<Map<String, dynamic>>> _getAllAggregatedTools() async {
    final allTools = <Map<String, dynamic>>[];
    
    // 1. 添加Hub自身的工具
    final hubTools = [
      {
        'name': 'ping',
        'description': 'Test connectivity to MCP Hub',
        'inputSchema': {
          'type': 'object',
          'properties': {},
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
      {
        'name': 'get_status',
        'description': 'Get comprehensive MCP Hub server status',
        'inputSchema': {
          'type': 'object',
          'properties': {},
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
      {
        'name': 'calculate',
        'description': 'Perform basic arithmetic operations',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'expression': {
              'type': 'string',
              'description': 'Mathematical expression to evaluate',
            },
          },
          'required': ['expression'],
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
      {
        'name': 'list_servers',
        'description': 'List all registered child MCP servers',
        'inputSchema': {
          'type': 'object',
          'properties': {},
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
      {
        'name': 'connect_server',
        'description': 'Connect to a child MCP server',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'server_id': {'type': 'string', 'description': 'Server identifier'},
            'name': {'type': 'string', 'description': 'Server display name'},
            'command': {'type': 'string', 'description': 'Command to start the server'},
            'args': {'type': 'array', 'items': {'type': 'string'}, 'description': 'Command arguments'},
            'env': {'type': 'object', 'description': 'Environment variables'},
          },
          'required': ['server_id', 'name', 'command'],
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
      {
        'name': 'disconnect_server',
        'description': 'Disconnect from a child MCP server',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'server_id': {'type': 'string', 'description': 'Server identifier'},
          },
          'required': ['server_id'],
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
      {
        'name': 'get_server_info',
        'description': 'Get detailed information about a specific child server',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'server_id': {'type': 'string', 'description': 'Server identifier'},
          },
          'required': ['server_id'],
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
      {
        'name': 'list_all_tools',
        'description': 'List all available tools from all connected servers',
        'inputSchema': {
          'type': 'object',
          'properties': {},
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
      {
        'name': 'call_child_tool',
        'description': 'Call a tool on a connected child server',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'server_id': {'type': 'string', 'description': 'Server identifier'},
            'tool_name': {'type': 'string', 'description': 'Name of the tool to call'},
            'tool_args': {'type': 'object', 'description': 'Arguments for the tool'},
          },
          'required': ['server_id', 'tool_name'],
        },
        '_meta': {
          'source': 'hub',
          'server_id': 'hub',
          'server_name': 'MCP Hub',
        },
      },
    ];
    
    allTools.addAll(hubTools);
    
    // 2. 添加子服务器的工具
    for (final server in _childServers.values) {
      if (server.isConnected && server.tools.isNotEmpty) {
        for (final tool in server.tools) {
          // 🔧 使用 servername::toolname 格式
          final serverName = _normalizeServerName(server.name);
          final wrappedToolName = '${serverName}::${tool.name}';
          
          allTools.add({
            'name': wrappedToolName,
            'description': '${tool.description} (来自: ${server.name})',
            'inputSchema': tool.inputSchema.toJson(),
            '_meta': {
              'source': 'child_server',
              'server_id': server.id,
              'server_name': server.name,
              'original_tool_name': tool.name,
            },
          });
        }
      }
    }
    
    print('🔧 聚合工具总数: ${allTools.length} (Hub: ${hubTools.length}, 子服务器: ${allTools.length - hubTools.length})');
    
    return allTools;
  }

  /// 获取所有聚合的资源列表
  Future<List<Map<String, dynamic>>> _getAllAggregatedResources() async {
    final allResources = <Map<String, dynamic>>[];
    
    // 添加子服务器的资源
    for (final server in _childServers.values) {
      if (server.isConnected && server.resources.isNotEmpty) {
        for (final resource in server.resources) {
          allResources.add({
            'uri': resource.uri,
            'name': resource.name,
            'description': resource.description,
            'mimeType': resource.mimeType,
            '_meta': {
              'source': 'child_server',
              'server_id': server.id,
              'server_name': server.name,
            },
          });
        }
      }
    }
    
    return allResources;
  }

  /// 调用聚合工具（智能路由到Hub或子服务器）
  Future<CallToolResult> _callAggregatedTool(String toolName, Map<String, dynamic> arguments) async {
    // 1. 检查是否是Hub工具
    final hubToolNames = [
      'ping', 'get_status', 'calculate', 'list_servers', 'connect_server', 
      'disconnect_server', 'get_server_info', 'list_all_tools', 'call_child_tool'
    ];
    
    if (hubToolNames.contains(toolName)) {
      return await _callHubTool(toolName, arguments);
    }
    
    // 2. 检查是否是包装后的工具名称
    if (toolName.contains('::')) {
      final parts = toolName.split('::');
      if (parts.length == 2) {
        final normalizedServerName = parts[0];
        final originalToolName = parts[1];
        
        print('🔍 解析包装工具名称: $toolName');
        print('   ├─ 标准化服务器名: $normalizedServerName');
        print('   └─ 原始工具名: $originalToolName');
        
        // 查找对应的子服务器
        for (final server in _childServers.values) {
          if (server.isConnected && _normalizeServerName(server.name) == normalizedServerName) {
            // 验证工具是否存在
            final toolExists = server.tools.any((tool) => tool.name == originalToolName);
            if (toolExists) {
              print('🎯 找到目标服务器: ${server.name}，调用工具: $originalToolName');
              return await _callChildTool(server.id, originalToolName, arguments);
            }
          }
        }
        
        throw Exception('Wrapped tool not found: $toolName (server: $normalizedServerName, tool: $originalToolName)');
      }
    }
    
    // 3. 尝试直接查找工具（兼容性）
    for (final server in _childServers.values) {
      if (server.isConnected) {
        for (final tool in server.tools) {
          if (tool.name == toolName) {
            return await _callChildTool(server.id, toolName, arguments);
          }
        }
      }
    }
    
    // 4. 工具未找到
    throw Exception('Tool not found: $toolName');
  }

  // ===== Additional Getters =====
  
  /// 获取服务器模式
  String get serverMode => _serverMode;
  
  /// 获取详细的Hub状态
  Map<String, dynamic> get detailedHubStatus => {
    'running': _isRunning,
    'port': _port,
    'mode': _serverMode,
    'child_servers': _childServers.length,
    'connected_servers': _childServers.values.where((s) => s.isConnected).length,
    'total_tools': _getTotalToolsCount(),
    'total_resources': _getTotalResourcesCount(),
    if (_serverMode == 'streamable' && _streamableHub != null) ...{
      'streamable_status': _streamableHub!.getStatus(),
    },
  };
  

} 