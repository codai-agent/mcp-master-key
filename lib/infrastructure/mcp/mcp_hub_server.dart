import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../core/protocols/mcp_protocol.dart';
import '../../core/protocols/mcp_client.dart';
import '../../core/models/mcp_server.dart';
import '../repositories/mcp_server_repository.dart';

/// MCP Hub服务器 - 作为MCP协议的中转代理
/// 对外提供MCP服务器接口，对内管理多个子MCP服务器
class McpHubServer {
  static const int defaultPort = 3000;
  
  final McpServerRepository _serverRepository;
  final Map<String, McpClient> _connectedServers = {};
  final Map<String, StreamController<McpMessage>> _clientStreams = {};
  
  HttpServer? _httpServer;
  int _port = defaultPort;
  bool _isRunning = false;

  McpHubServer(this._serverRepository);

  /// 启动MCP Hub服务器
  Future<void> start({int port = defaultPort}) async {
    if (_isRunning) {
      throw StateError('MCP Hub Server is already running');
    }

    _port = port;
    
    // 创建路由
    final router = Router();
    
    // MCP协议端点
    router.post('/mcp', _handleMcpRequest);
    
    // SSE端点（用于实时通信）
    router.get('/mcp/events', _handleSseConnection);
    
    // 健康检查端点
    router.get('/health', _handleHealthCheck);
    
    // 服务器信息端点
    router.get('/servers', _handleServersInfo);

    // 启动HTTP服务器
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(router);

    _httpServer = await serve(handler, InternetAddress.anyIPv4, _port);
    _isRunning = true;
    
    print('🚀 MCP Hub Server started on port $_port');
    
    // 连接到所有已配置的MCP服务器
    await _connectToAllServers();
  }

  /// 停止MCP Hub服务器
  Future<void> stop() async {
    if (!_isRunning) return;

    // 断开所有子服务器连接
    await _disconnectAllServers();
    
    // 关闭HTTP服务器
    await _httpServer?.close();
    _httpServer = null;
    _isRunning = false;
    
    print('🛑 MCP Hub Server stopped');
  }

  /// 处理MCP请求
  Future<Response> _handleMcpRequest(Request request) async {
    try {
      final body = await request.readAsString();
      final mcpRequest = McpMessage.fromJson(jsonDecode(body));
      
      // 路由请求到相应的子服务器
      final response = await _routeRequest(mcpRequest);
      
      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      final errorResponse = JsonRpcResponse(
        id: null,
        error: JsonRpcError(
          code: McpErrorCodes.internalError,
          message: 'Internal server error: $e',
        ),
      );
      
      return Response.internalServerError(
        body: jsonEncode(errorResponse.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 处理SSE连接
  Future<Response> _handleSseConnection(Request request) async {
    final clientId = request.url.queryParameters['clientId'] ?? 'unknown';
    
    final controller = StreamController<McpMessage>();
    _clientStreams[clientId] = controller;
    
    final stream = controller.stream.map((message) {
      return 'data: ${jsonEncode(message.toJson())}\n\n';
    });
    
    // 清理连接（简化处理）
    Timer(const Duration(hours: 1), () {
      _clientStreams.remove(clientId);
      if (!controller.isClosed) {
        controller.close();
      }
    });
    
    return Response.ok(
      stream,
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    );
  }

  /// 健康检查
  Response _handleHealthCheck(Request request) {
    final status = {
      'status': 'healthy',
      'port': _port,
      'connectedServers': _connectedServers.length,
      'activeClients': _clientStreams.length,
      'uptime': DateTime.now().toIso8601String(),
    };
    
    return Response.ok(
      jsonEncode(status),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// 获取服务器信息
  Future<Response> _handleServersInfo(Request request) async {
    try {
      final servers = await _serverRepository.getAllServers();
      final serverInfo = servers.map((server) => {
        'id': server.id,
        'name': server.name,
        'installType': server.installType.name,
        'status': server.status.name,
        'connected': _connectedServers.containsKey(server.id),
      }).toList();
      
      return Response.ok(
        jsonEncode({'servers': serverInfo}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get server info: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 路由请求到相应的子服务器
  Future<McpMessage> _routeRequest(McpMessage request) async {
    // 从请求中提取目标服务器ID
    final targetServerId = _extractTargetServer(request);
    
    if (targetServerId == null) {
      // 如果没有指定目标服务器，返回可用服务器列表
      return await _handleListServers(request);
    }
    
    // 获取目标服务器的连接
    final client = _connectedServers[targetServerId];
    if (client == null) {
      final requestId = request is JsonRpcRequest ? request.id : null;
      return JsonRpcResponse(
        id: requestId,
        error: JsonRpcError(
          code: McpErrorCodes.methodNotFound,
          message: 'Server not found or not connected: $targetServerId',
        ),
      );
    }
    
    // 转发请求到子服务器
    try {
      if (request is JsonRpcRequest) {
        final response = await client.callTool(request.method, request.params ?? {});
        
        final jsonResponse = JsonRpcResponse(
          id: request.id,
          result: response,
        );
        
        // 广播响应给所有连接的客户端
        _broadcastToClients(jsonResponse);
        
        return jsonResponse;
      } else {
        throw UnsupportedError('Only JsonRpcRequest is supported');
      }
    } catch (e) {
      final requestId = request is JsonRpcRequest ? request.id : null;
      return JsonRpcResponse(
        id: requestId,
        error: JsonRpcError(
          code: McpErrorCodes.requestFailed,
          message: 'Request failed: $e',
        ),
      );
    }
  }

  /// 从请求中提取目标服务器ID
  String? _extractTargetServer(McpMessage request) {
    // 可以从请求参数、路径或头部提取服务器ID
    // 这里简化处理，从请求参数中提取
    if (request is JsonRpcRequest) {
      final params = request.params as Map<String, dynamic>?;
      return params?['targetServer'] as String?;
    }
    return null;
  }

  /// 处理列出服务器的请求
  Future<McpMessage> _handleListServers(McpMessage request) async {
    try {
      final servers = await _serverRepository.getAllServers();
      final serverList = servers.map((server) => {
        'id': server.id,
        'name': server.name,
        'installType': server.installType.name,
        'status': server.status.name,
        'description': server.description,
      }).toList();
      
      final requestId = request is JsonRpcRequest ? request.id : null;
      return JsonRpcResponse(
        id: requestId,
        result: {'servers': serverList},
      );
    } catch (e) {
      final requestId = request is JsonRpcRequest ? request.id : null;
      return JsonRpcResponse(
        id: requestId,
        error: JsonRpcError(
          code: McpErrorCodes.internalError,
          message: 'Failed to list servers: $e',
        ),
      );
    }
  }

  /// 连接到所有已配置的MCP服务器
  Future<void> _connectToAllServers() async {
    try {
      final servers = await _serverRepository.getAllServers();
      
      for (final server in servers) {
        if (server.status == McpServerStatus.running) {
          await _connectToServer(server);
        }
      }
    } catch (e) {
      print('Error connecting to servers: $e');
    }
  }

  /// 连接到单个MCP服务器
  Future<void> _connectToServer(McpServer server) async {
    try {
      // 启动进程
      final process = await Process.start(
        server.command,
        server.args,
        workingDirectory: server.workingDirectory,
        environment: server.env,
      );
      
      final client = McpClient(
        serverId: server.id,
        process: process,
      );
      
      // 建立连接
      await client.connect();
      
      _connectedServers[server.id] = client;
      print('✅ Connected to server: ${server.name}');
      
    } catch (e) {
      print('❌ Failed to connect to server ${server.name}: $e');
    }
  }

  /// 断开所有服务器连接
  Future<void> _disconnectAllServers() async {
    for (final entry in _connectedServers.entries) {
      try {
        // 关闭进程
        entry.value.process.kill();
        print('🔌 Disconnected from server: ${entry.key}');
      } catch (e) {
        print('Error disconnecting from server ${entry.key}: $e');
      }
    }
    _connectedServers.clear();
  }

  /// 广播消息给所有连接的客户端
  void _broadcastToClients(McpMessage message) {
    for (final controller in _clientStreams.values) {
      if (!controller.isClosed) {
        controller.add(message);
      }
    }
  }

  /// CORS中间件
  Middleware _corsMiddleware() {
    return (handler) {
      return (request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        
        final response = await handler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  Map<String, String> get _corsHeaders => {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  /// 添加新的服务器连接
  Future<void> addServer(McpServer server) async {
    if (server.status == McpServerStatus.running) {
      await _connectToServer(server);
    }
  }

  /// 移除服务器连接
  Future<void> removeServer(String serverId) async {
    final client = _connectedServers.remove(serverId);
    if (client != null) {
      client.process.kill();
      print('🗑️ Removed server connection: $serverId');
    }
  }

  /// 重新连接服务器
  Future<void> reconnectServer(String serverId) async {
    await removeServer(serverId);
    
    final server = await _serverRepository.getServerById(serverId);
    if (server != null && server.status == McpServerStatus.running) {
      await _connectToServer(server);
    }
  }

  // Getters
  bool get isRunning => _isRunning;
  int get port => _port;
  int get connectedServersCount => _connectedServers.length;
  int get activeClientsCount => _clientStreams.length;
  List<String> get connectedServerIds => _connectedServers.keys.toList();
} 