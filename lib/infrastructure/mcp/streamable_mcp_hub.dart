import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:collection';
import 'package:mcp_dart/mcp_dart.dart';
import '../../business/services/mcp_hub_service.dart';

/// 生成UUID的辅助函数 (参考官方示例)
String generateUUID() {
  final random = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
}

/// 工具请求信息
class ToolRequest {
  final String sessionId;
  final String toolName;
  final Map<String, dynamic> args;
  final DateTime timestamp;
  final Completer<CallToolResult> completer;

  ToolRequest({
    required this.sessionId,
    required this.toolName,
    required this.args,
    required this.timestamp,
    required this.completer,
  });
}

/// 共享子服务器池信息
class SharedServerInfo {
  final String serverId;
  final String name;
  final List<String> toolNames;
  final Queue<ToolRequest> requestQueue = Queue<ToolRequest>();
  bool isProcessing = false;

  SharedServerInfo({
    required this.serverId,
    required this.name,
    required this.toolNames,
  });
}

/// Streamable模式的MCP Hub
class StreamableMcpHub {
  static StreamableMcpHub? _instance;
  static StreamableMcpHub get instance => _instance ??= StreamableMcpHub._();
  
  StreamableMcpHub._();

  HttpServer? _httpServer;
  bool _isRunning = false;
  int _port = 3001; // 使用不同端口避免冲突
  
  // Transport管理 (参考示例代码)
  final Map<String, StreamableHTTPServerTransport> _transports = {};
  
  // 共享子服务器池
  final Map<String, SharedServerInfo> _sharedServerPool = {};
  final Map<String, String> _toolToServerMap = {}; // 工具名 -> 服务器ID 映射
  
  // MCP服务器实例（需要在初始化后保持引用以支持动态工具注册）
  McpServer? _mcpServerInstance;
  
  // 清理任务
  Timer? _cleanupTimer;
  
  // 子服务器状态监听
  Timer? _serverMonitorTimer;

  /// 启动Streamable Hub
  Future<void> startHub({int port = 3001}) async {
    if (_isRunning) {
      print('⚠️ Streamable MCP Hub is already running');
      return;
    }

    try {
      print('🚀 Starting Streamable MCP Hub...');
      
      _port = port;
      
      // 初始化共享子服务器池
      await _initializeSharedServerPool();
      
      // 创建HTTP服务器 (参考示例代码结构)
      _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, port);
      print('MCP Streamable Hub listening on port $port');

      // 设置非阻塞的请求处理
      _httpServer!.listen((request) async {
        if (request.uri.path != '/mcp') {
          // 非MCP端点
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Not Found')
            ..close();
          return;
        }

        switch (request.method) {
          case 'POST':
            await _handlePostRequest(request);
            break;
          case 'GET':
            await _handleGetRequest(request);
            break;
          case 'DELETE':
            await _handleDeleteRequest(request);
            break;
          default:
            request.response
              ..statusCode = HttpStatus.methodNotAllowed
              ..headers.set(HttpHeaders.allowHeader, 'GET, POST, DELETE')
              ..write('Method Not Allowed')
              ..close();
        }
      });
      
      _isRunning = true;
      
    } catch (e, stackTrace) {
      print('❌ Failed to start Streamable MCP Hub: $e');
      print('Stack trace: $stackTrace');
      _isRunning = false;
      rethrow;
    }
  }

  /// 停止Hub
  Future<void> stopHub() async {
    if (!_isRunning) return;

    try {
      print('🛑 Stopping Streamable MCP Hub...');
      
      // 停止服务器监控
      _serverMonitorTimer?.cancel();
      _serverMonitorTimer = null;
      
      // 清理所有transport
      for (final transport in _transports.values) {
        try {
          // 假设transport有close方法
          if (transport.onclose != null) {
            transport.onclose!();
          }
        } catch (e) {
          print('Error closing transport: $e');
        }
      }
      _transports.clear();
      
      // 停止清理任务
      _cleanupTimer?.cancel();
      
      // 清理MCP服务器实例
      _mcpServerInstance = null;
      
      await _httpServer?.close();
      _httpServer = null;
      _isRunning = false;
      
      print('✅ Streamable MCP Hub stopped successfully');
      
    } catch (e) {
      print('❌ Failed to stop Streamable MCP Hub: $e');
      rethrow;
    }
  }

  /// 初始化共享子服务器池
  Future<void> _initializeSharedServerPool() async {
    print('🔧 Initializing shared server pool...');
    
    // 从Hub服务获取已连接的子服务器信息
    final hubService = McpHubService.instance;
    final childServers = hubService.childServers;
    
    for (final childServer in childServers) {
      if (childServer.isConnected) {
        final serverInfo = SharedServerInfo(
          serverId: childServer.id,
          name: childServer.name,
          toolNames: childServer.tools.map((tool) => tool.name).toList(),
        );
        
        _sharedServerPool[childServer.id] = serverInfo;
        
        // 建立工具名到服务器ID的映射
        for (final toolName in serverInfo.toolNames) {
          _toolToServerMap[toolName] = childServer.id;
        }
        
        print('📋 Added server to pool: ${childServer.name} (${serverInfo.toolNames.length} tools)');
      }
    }
    
    print('✅ Shared server pool initialized with ${_sharedServerPool.length} servers');
    
    // 启动会话清理任务
    _startSessionCleanup();
    _isRunning = true;
  }

  /// 创建MCP服务器实例 (参考示例的getServer函数)
  McpServer _createMcpServer() {
    // 如果已有实例，直接返回（支持动态工具注册）
    if (_mcpServerInstance != null) {
      return _mcpServerInstance!;
    }
    
    final server = McpServer(
      Implementation(name: 'streamable-mcp-hub', version: '1.0.0'),
      options: ServerOptions(
        capabilities: ServerCapabilities(
          tools: ServerCapabilitiesTools(),
          resources: ServerCapabilitiesResources(),
          prompts: ServerCapabilitiesPrompts(),
        ),
      ),
    );

    // 注册Hub自身的ping工具
    server.tool(
      'ping',
      description: 'Test connectivity to Streamable MCP Hub',
      inputSchemaProperties: {},
      callback: ({args, extra}) async {
        return CallToolResult.fromContent(
          content: [
            TextContent(text: 'pong - Streamable Hub with ${_sharedServerPool.length} servers'),
          ],
        );
      },
    );

    // 注册所有共享服务器的工具
    _registerAllServerTools(server);

    // 缓存服务器实例
    _mcpServerInstance = server;
    
    print('📋 Registered ${_toolToServerMap.length + 1} tools (1 hub + ${_toolToServerMap.length} child servers)');
    
    // 启动服务器状态监控
    _startServerMonitoring();
    
    // 延迟3秒后再检查一次服务器池（确保子服务器有时间连接）
    Timer(const Duration(seconds: 3), () {
      print('🔄 Performing delayed server pool update...');
      _updateServerPool();
    });
    
    return server;
  }
  
  /// 注册所有服务器工具
  void _registerAllServerTools(McpServer server) {
    for (final serverInfo in _sharedServerPool.values) {
      for (final toolName in serverInfo.toolNames) {
        _registerProxyTool(server, toolName, serverInfo);
      }
    }
  }
  
  /// 启动服务器状态监控
  void _startServerMonitoring() {
    _serverMonitorTimer?.cancel();
    
    // 立即执行一次检查
    _updateServerPool();
    
    // 然后每5秒检查一次（更频繁的监控）
    _serverMonitorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateServerPool();
    });
  }
  
  /// 更新服务器池（检查新连接的服务器）
  void _updateServerPool() async {
    final hubService = McpHubService.instance;
    final currentChildServers = hubService.childServers;
    
    print('🔄 Updating server pool: checking ${currentChildServers.length} child servers...');
    
    // 检查新连接的服务器
    for (final childServer in currentChildServers) {
      if (childServer.isConnected && !_sharedServerPool.containsKey(childServer.id)) {
        print('🆕 Found new connected server: ${childServer.name} (${childServer.tools.length} tools)');
        await _addServerToPool(childServer);
      }
    }
    
    // 检查断开连接的服务器
    final serversToRemove = <String>[];
    for (final serverId in _sharedServerPool.keys) {
      final childServer = currentChildServers.where((s) => s.id == serverId).firstOrNull;
      if (childServer == null || !childServer.isConnected) {
        serversToRemove.add(serverId);
      }
    }
    
    for (final serverId in serversToRemove) {
      _removeServerFromPool(serverId);
    }
    
    print('📊 Server pool status: ${_sharedServerPool.length} servers, ${_toolToServerMap.length} tools');
  }
  
  /// 添加服务器到池中
  Future<void> _addServerToPool(dynamic childServer) async {
    print('➕ Adding new server to pool: ${childServer.name}');
    
    final serverInfo = SharedServerInfo(
      serverId: childServer.id,
      name: childServer.name,
      toolNames: childServer.tools.map((tool) => tool.name).toList().cast<String>(),
    );
    
    _sharedServerPool[childServer.id] = serverInfo;
    
    // 建立工具名到服务器ID的映射
    for (final toolName in serverInfo.toolNames) {
      _toolToServerMap[toolName] = childServer.id;
    }
    
    // 如果MCP服务器实例已存在，动态注册新工具
    if (_mcpServerInstance != null) {
      for (final toolName in serverInfo.toolNames) {
        _registerProxyTool(_mcpServerInstance!, toolName, serverInfo);
      }
      print('🔄 Dynamically registered ${serverInfo.toolNames.length} tools from ${childServer.name}');
    }
    
    print('📋 Server pool updated: ${_sharedServerPool.length} servers, ${_toolToServerMap.length} tools');
  }
  
  /// 从池中移除服务器
  void _removeServerFromPool(String serverId) {
    final serverInfo = _sharedServerPool[serverId];
    if (serverInfo != null) {
      print('➖ Removing server from pool: ${serverInfo.name}');
      
      // 移除工具映射
      for (final toolName in serverInfo.toolNames) {
        _toolToServerMap.remove(toolName);
      }
      
      _sharedServerPool.remove(serverId);
      
      // 注意：从MCP服务器中移除工具比较复杂，暂时跳过
      // 在实际应用中，可能需要重新创建MCP服务器实例
      
      print('📋 Server pool updated: ${_sharedServerPool.length} servers, ${_toolToServerMap.length} tools');
    }
  }

  /// 注册代理工具
  void _registerProxyTool(
    McpServer mcpServer,
    String toolName,
    SharedServerInfo serverInfo,
  ) {
    mcpServer.tool(
      toolName,
      description: 'Tool $toolName from ${serverInfo.name} (via shared pool)',
      inputSchemaProperties: {}, // 简化实现，实际需要从子服务器获取schema
      callback: ({args, extra}) async {
        // 转发工具调用到共享服务器池
        return await _forwardToolCall(toolName, args ?? {});
      },
    );
  }

  /// 转发工具调用到共享服务器池
  Future<CallToolResult> _forwardToolCall(
    String toolName,
    Map<String, dynamic> args,
  ) async {
    print('🔄 Forwarding tool call: $toolName');

    // 查找对应的服务器
    final serverId = _toolToServerMap[toolName];
    if (serverId == null) {
      return CallToolResult.fromContent(
        content: [
          TextContent(text: 'Error: Tool $toolName not found'),
        ],
      );
    }

    final serverInfo = _sharedServerPool[serverId];
    if (serverInfo == null) {
      return CallToolResult.fromContent(
        content: [
          TextContent(text: 'Error: Server $serverId not available'),
        ],
      );
    }

    // 创建工具请求
    final request = ToolRequest(
      sessionId: 'shared', // 简化实现，使用共享会话ID
      toolName: toolName,
      args: args,
      timestamp: DateTime.now(),
      completer: Completer<CallToolResult>(),
    );

    // 加入请求队列
    serverInfo.requestQueue.add(request);
    
    // 处理队列
    _processRequestQueue(serverInfo);
    
    // 等待结果
    return await request.completer.future;
  }

  /// 处理请求队列
  void _processRequestQueue(SharedServerInfo serverInfo) async {
    if (serverInfo.isProcessing || serverInfo.requestQueue.isEmpty) {
      return;
    }

    serverInfo.isProcessing = true;

    while (serverInfo.requestQueue.isNotEmpty) {
      final request = serverInfo.requestQueue.removeFirst();
      
      try {
        // 通过Hub服务执行实际的工具调用
        final result = await _executeToolOnChildServer(
          serverInfo.serverId,
          request.toolName,
          request.args,
        );
        
        request.completer.complete(result);
        
      } catch (e) {
        final errorResult = CallToolResult.fromContent(
          content: [
            TextContent(text: 'Error executing tool: $e'),
          ],
        );
        request.completer.complete(errorResult);
      }
    }

    serverInfo.isProcessing = false;
  }

  /// 在子服务器上执行工具
  Future<CallToolResult> _executeToolOnChildServer(
    String serverId,
    String toolName,
    Map<String, dynamic> args,
  ) async {
    // 简化实现，直接返回模拟结果
    // 实际实现中需要调用真正的子服务器
    final hubService = McpHubService.instance;
    final childServer = hubService.childServers.firstWhere(
      (server) => server.id == serverId,
      orElse: () => throw Exception('Child server $serverId not found'),
    );

    if (!childServer.isConnected) {
      throw Exception('Child server $serverId is not connected');
    }

    // TODO: 实际调用子服务器的工具
    // 这里需要根据具体的MCP客户端API来实现
    
    return CallToolResult.fromContent(
      content: [
        TextContent(
          text: 'Tool $toolName executed on ${childServer.name} with args: ${jsonEncode(args)}'
        ),
      ],
    );
  }

  // ===== HTTP处理方法 (参考示例代码) =====

  /// 处理POST请求 (参考示例的handlePostRequest)
  Future<void> _handlePostRequest(HttpRequest request) async {
    print('🔄 Received MCP POST request');

    try {
      // 解析请求体
      final bodyBytes = await _collectBytes(request);
      final bodyString = utf8.decode(bodyBytes);
      print('📥 Request body: $bodyString');
      
      dynamic body;
      try {
        body = jsonDecode(bodyString);
      } catch (e) {
        print('❌ JSON decode error: $e');
        print('📄 Raw body: $bodyString');
        throw Exception('Invalid JSON: $e');
      }

      // 检查现有会话ID
      final sessionId = request.headers.value('mcp-session-id');
      print('🔑 Session ID: $sessionId');
      print('🏠 Headers: ${request.headers}');
      
      StreamableHTTPServerTransport? transport;

      if (sessionId != null && _transports.containsKey(sessionId)) {
        // 复用现有transport
        print('♻️ Reusing existing transport for session: $sessionId');
        transport = _transports[sessionId]!;
        
        // 用现有transport处理请求
        await transport.handleRequest(request, body);
        
      } else if (sessionId == null && _isInitializeRequest(body)) {
        print('🆕 Creating new transport for initialization request');
        
        // 新的初始化请求
        final eventStore = _InMemoryEventStore();
        transport = StreamableHTTPServerTransport(
          options: StreamableHTTPServerTransportOptions(
            sessionIdGenerator: () => generateUUID(),
            eventStore: eventStore, // 启用可恢复性
            onsessioninitialized: (sessionId) {
              // 会话初始化时存储transport
              print('✅ Session initialized with ID: $sessionId');
              _transports[sessionId] = transport!;
            },
          ),
        );

        // 设置onclose处理器以清理transport
        transport.onclose = () {
          final sid = transport!.sessionId;
          if (sid != null && _transports.containsKey(sid)) {
            print('🔒 Transport closed for session $sid, removing from transports map');
            _transports.remove(sid);
          }
        };

        // 在处理请求之前将transport连接到MCP服务器
        final server = _createMcpServer();
        print('🔗 Connecting transport to MCP server...');
        await server.connect(transport);
        print('🔗 Transport connected to MCP server successfully');

        print('📤 Calling transport.handleRequest...');
        await transport.handleRequest(request, body);
        print('✅ transport.handleRequest completed');
        
      } else {
        // 无效请求 - 没有会话ID或不是初始化请求
        print('❌ Invalid request - sessionId: $sessionId, isInit: ${_isInitializeRequest(body)}');
        print('📋 Body content: $body');
        
        request.response
          ..statusCode = HttpStatus.badRequest
          ..headers.set(HttpHeaders.contentTypeHeader, 'application/json')
          ..write(jsonEncode({
            'jsonrpc': '2.0',
            'error': {
              'code': -32000,
              'message': 'Bad Request: No valid session ID provided or not an initialization request',
              'data': {
                'sessionId': sessionId,
                'isInitializeRequest': _isInitializeRequest(body),
                'bodyType': body.runtimeType.toString(),
              },
            },
            'id': body is Map<String, dynamic> ? body['id'] : null,
          }))
          ..close();
      }
      
    } catch (error, stackTrace) {
      print('❌ Error handling MCP request: $error');
      print('📚 Stack trace: $stackTrace');
      _sendErrorResponse(request, error);
    }
  }

  /// 处理GET请求用于SSE流 (参考示例的handleGetRequest)
  Future<void> _handleGetRequest(HttpRequest request) async {
    final sessionId = request.headers.value('mcp-session-id');
    if (sessionId == null || !_transports.containsKey(sessionId)) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Invalid or missing session ID')
        ..close();
      return;
    }

    // 检查Last-Event-ID头部以支持可恢复性
    final lastEventId = request.headers.value('Last-Event-ID');
    if (lastEventId != null) {
      print('Client reconnecting with Last-Event-ID: $lastEventId');
    } else {
      print('Establishing new SSE stream for session $sessionId');
    }

    final transport = _transports[sessionId]!;
    await transport.handleRequest(request);
  }

  /// 处理DELETE请求用于会话终止 (参考示例的handleDeleteRequest)
  Future<void> _handleDeleteRequest(HttpRequest request) async {
    final sessionId = request.headers.value('mcp-session-id');
    if (sessionId == null || !_transports.containsKey(sessionId)) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Invalid or missing session ID')
        ..close();
      return;
    }

    print('Received session termination request for session $sessionId');

    try {
      final transport = _transports[sessionId]!;
      await transport.handleRequest(request);
    } catch (error) {
      print('Error handling session termination: $error');
      _sendErrorResponse(request, error);
    }
  }

  // ===== 工具方法 =====

  /// 检查是否为初始化请求 (参考示例的isInitializeRequest)
  bool _isInitializeRequest(dynamic body) {
    if (body is Map<String, dynamic> &&
        body.containsKey('method') &&
        body['method'] == 'initialize') {
      return true;
    }
    return false;
  }

  /// 生成UUID (参考示例的generateUUID)
  String _generateUUID() {
    final random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// 收集HTTP请求字节 (参考示例的collectBytes)
  Future<List<int>> _collectBytes(HttpRequest request) {
    final completer = Completer<List<int>>();
    final bytes = <int>[];

    request.listen(
      bytes.addAll,
      onDone: () => completer.complete(bytes),
      onError: completer.completeError,
      cancelOnError: true,
    );

    return completer.future;
  }

  /// 发送错误响应 (参考官方示例的错误处理)
  void _sendErrorResponse(HttpRequest request, dynamic error) {
    try {
      print('🚨 Sending error response: $error');
      
      // 检查是否已经发送了headers (参考官方示例)
      bool headersSent = false;
      try {
        // 检查response是否已经开始
        final response = request.response;
        headersSent = response.headers.contentType?.toString().startsWith('text/event-stream') ?? false;
        
        print('📊 Response status: headersSent=$headersSent, statusCode=${response.statusCode}');
      } catch (e) {
        print('⚠️ Error checking response headers: $e');
        // 忽略检查headers时的错误
      }

      if (!headersSent) {
        final errorResponse = {
          'jsonrpc': '2.0',
          'error': {
            'code': -32603,
            'message': 'Internal server error: ${error.toString()}',
            'data': {
              'errorType': error.runtimeType.toString(),
              'timestamp': DateTime.now().toIso8601String(),
            },
          },
          'id': null,
        };
        
        print('📤 Error response: ${jsonEncode(errorResponse)}');
        
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..headers.set(HttpHeaders.contentTypeHeader, 'application/json')
          ..write(jsonEncode(errorResponse))
          ..close();
      } else {
        print('⚠️ Headers already sent, cannot send error response');
      }
    } catch (e) {
      print('💥 Critical error sending error response: $e');
      // 最后的尝试 - 简单关闭连接
      try {
        request.response.close();
      } catch (_) {
        print('💀 Failed to close response');
      }
    }
  }

  /// 启动会话清理任务
  void _startSessionCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      // 简化清理逻辑，实际可以根据需要实现更复杂的清理策略
      print('🧹 Session cleanup check: ${_transports.length} active sessions');
    });
  }

  /// 获取状态信息
  Map<String, dynamic> getStatus() {
    return {
      'running': _isRunning,
      'port': _port,
      'mode': 'streamable',
      'sessions': {
        'active': _transports.length,
        'list': _transports.keys.toList(),
      },
      'shared_servers': {
        'count': _sharedServerPool.length,
        'servers': _sharedServerPool.values.map((s) => {
          'id': s.serverId,
          'name': s.name,
          'tools': s.toolNames,
          'queue_size': s.requestQueue.length,
          'is_processing': s.isProcessing,
        }).toList(),
      },
      'tool_mappings': _toolToServerMap,
    };
  }

  // Getters
  bool get isRunning => _isRunning;
  int get port => _port;
  int get activeSessionsCount => _transports.length;
  int get sharedServersCount => _sharedServerPool.length;
}

/// 简化的内存事件存储实现 (参考示例的InMemoryEventStore)
class _InMemoryEventStore implements EventStore {
  final Map<String, List<({String id, JsonRpcMessage message})>> _events = {};
  int _eventCounter = 0;

  @override
  Future<String> storeEvent(String streamId, JsonRpcMessage message) async {
    final eventId = (++_eventCounter).toString();
    _events.putIfAbsent(streamId, () => []);
    _events[streamId]!.add((id: eventId, message: message));
    return eventId;
  }

  @override
  Future<String> replayEventsAfter(
    String lastEventId, {
    required Future<void> Function(String eventId, JsonRpcMessage message) send,
  }) async {
    // 查找包含此事件ID的流
    String? streamId;
    int fromIndex = -1;

    for (final entry in _events.entries) {
      final idx = entry.value.indexWhere((event) => event.id == lastEventId);

      if (idx >= 0) {
        streamId = entry.key;
        fromIndex = idx;
        break;
      }
    }

    if (streamId == null) {
      throw StateError('Event ID not found: $lastEventId');
    }

    // 重放lastEventId之后的所有事件
    for (int i = fromIndex + 1; i < _events[streamId]!.length; i++) {
      final event = _events[streamId]![i];
      await send(event.id, event.message);
    }

    return streamId;
  }
} 