import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'mcp_protocol.dart';

/// MCP客户端状态
enum McpClientState {
  disconnected,
  connecting,
  connected,
  initialized,
  error,
}

/// MCP客户端
class McpClient {
  final String serverId;
  final Process process;
  
  McpClientState _state = McpClientState.disconnected;
  McpInitializeResult? _initializeResult;
  
  // 请求ID生成器
  int _requestIdCounter = 0;
  
  // 待处理的请求
  final Map<dynamic, Completer<JsonRpcResponse>> _pendingRequests = {};
  
  // 事件流
  final StreamController<McpClientState> _stateController = StreamController.broadcast();
  final StreamController<JsonRpcNotification> _notificationController = StreamController.broadcast();
  final StreamController<String> _logController = StreamController.broadcast();
  
  // 输入输出流
  late StreamSubscription _stdoutSubscription;
  late StreamSubscription _stderrSubscription;
  
  McpClient({
    required this.serverId,
    required this.process,
  });

  // Getters
  McpClientState get state => _state;
  McpInitializeResult? get initializeResult => _initializeResult;
  
  // 事件流
  Stream<McpClientState> get stateStream => _stateController.stream;
  Stream<JsonRpcNotification> get notificationStream => _notificationController.stream;
  Stream<String> get logStream => _logController.stream;

  /// 开始连接
  Future<void> connect() async {
    if (_state != McpClientState.disconnected) {
      throw StateError('客户端已连接或正在连接');
    }
    
    _setState(McpClientState.connecting);
    
    try {
      // 监听标准输出（JSON-RPC消息）
      _stdoutSubscription = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _handleStdoutLine,
            onError: (error) => _handleError('标准输出错误: $error'),
          );
      
      // 监听标准错误（日志消息）
      _stderrSubscription = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _handleStderrLine,
            onError: (error) => _handleError('标准错误输出错误: $error'),
          );
      
      // 监听进程退出
      process.exitCode.then((exitCode) {
        _handleProcessExit(exitCode);
      });
      
      _setState(McpClientState.connected);
      
      // 自动初始化
      await initialize();
      
    } catch (error) {
      _handleError('连接失败: $error');
    }
  }

  /// 初始化MCP连接
  Future<McpInitializeResult> initialize() async {
    if (_state != McpClientState.connected) {
      throw StateError('客户端未连接');
    }
    
    final request = JsonRpcRequest(
      id: _generateRequestId(),
      method: McpMethods.initialize,
      params: {
        'protocolVersion': mcpProtocolVersion,
        'capabilities': McpClientCapabilities().toJson(),
        'clientInfo': {
          'name': 'MCP Hub',
          'version': '1.0.0',
        },
      },
    );
    
    final response = await _sendRequest(request);
    
    if (!response.isSuccess) {
      throw Exception('初始化失败: ${response.error?.message}');
    }
    
    _initializeResult = McpInitializeResult.fromJson(response.result!);
    
    // 发送初始化完成通知
    await _sendNotification(JsonRpcNotification(
      method: McpMethods.initialized,
    ));
    
    _setState(McpClientState.initialized);
    
    return _initializeResult!;
  }

  /// 获取工具列表
  Future<List<McpTool>> listTools() async {
    _ensureInitialized();
    
    final request = JsonRpcRequest(
      id: _generateRequestId(),
      method: McpMethods.toolsList,
    );
    
    final response = await _sendRequest(request);
    
    if (!response.isSuccess) {
      throw Exception('获取工具列表失败: ${response.error?.message}');
    }
    
    final tools = response.result!['tools'] as List<dynamic>;
    return tools.map((tool) => McpTool.fromJson(tool as Map<String, dynamic>)).toList();
  }

  /// 调用工具
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    _ensureInitialized();
    
    final request = JsonRpcRequest(
      id: _generateRequestId(),
      method: McpMethods.toolsCall,
      params: {
        'name': toolName,
        'arguments': arguments,
      },
    );
    
    final response = await _sendRequest(request);
    
    if (!response.isSuccess) {
      throw Exception('调用工具失败: ${response.error?.message}');
    }
    
    return response.result!;
  }

  /// 获取资源列表
  Future<List<McpResource>> listResources() async {
    _ensureInitialized();
    
    final request = JsonRpcRequest(
      id: _generateRequestId(),
      method: McpMethods.resourcesList,
    );
    
    final response = await _sendRequest(request);
    
    if (!response.isSuccess) {
      throw Exception('获取资源列表失败: ${response.error?.message}');
    }
    
    final resources = response.result!['resources'] as List<dynamic>;
    return resources.map((resource) => McpResource.fromJson(resource as Map<String, dynamic>)).toList();
  }

  /// 读取资源
  Future<Map<String, dynamic>> readResource(String uri) async {
    _ensureInitialized();
    
    final request = JsonRpcRequest(
      id: _generateRequestId(),
      method: McpMethods.resourcesRead,
      params: {
        'uri': uri,
      },
    );
    
    final response = await _sendRequest(request);
    
    if (!response.isSuccess) {
      throw Exception('读取资源失败: ${response.error?.message}');
    }
    
    return response.result!;
  }

  /// 发送请求到MCP服务器
  Future<JsonRpcResponse> sendRequest(JsonRpcRequest request) async {
    _ensureInitialized();
    
    return await _sendRequest(request);
  }

  /// 发送请求（内部方法）
  Future<JsonRpcResponse> _sendRequest(JsonRpcRequest request) async {
    final completer = Completer<JsonRpcResponse>();
    _pendingRequests[request.id] = completer;
    
    try {
      // 发送请求到子进程
      final requestJson = jsonEncode(request.toJson());
      process.stdin.writeln(requestJson);
      
      // 等待响应（设置超时）
      final response = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _pendingRequests.remove(request.id);
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );
      
      return response;
    } catch (e) {
      _pendingRequests.remove(request.id);
      rethrow;
    }
  }

  /// 发送通知（无需响应）
  Future<void> _sendNotification(JsonRpcNotification notification) async {
    final notificationJson = jsonEncode(notification.toJson());
    process.stdin.writeln(notificationJson);
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (_state == McpClientState.disconnected) return;
    
    try {
      // 取消所有待处理的请求
      for (final completer in _pendingRequests.values) {
        if (!completer.isCompleted) {
          completer.completeError(StateError('Connection closed'));
        }
      }
      _pendingRequests.clear();
      
      // 关闭流订阅
      await _stdoutSubscription.cancel();
      await _stderrSubscription.cancel();
      
      // 关闭进程
      process.kill();
      
      _setState(McpClientState.disconnected);
      
    } catch (e) {
      _handleError('断开连接时出错: $e');
    }
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _stateController.close();
    _notificationController.close();
    _logController.close();
  }

  // 私有方法

  void _setState(McpClientState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(_state);
    }
  }

  void _log(String message) {
    _logController.add('[${DateTime.now()}] $message');
  }

  void _handleError(String error) {
    _log('错误: $error');
    _setState(McpClientState.error);
  }

  void _handleProcessExit(int exitCode) {
    _log('进程退出，退出码: $exitCode');
    _setState(McpClientState.disconnected);
  }

  void _handleStdoutLine(String line) {
    if (line.trim().isEmpty) return;
    
    try {
      final json = jsonDecode(line) as Map<String, dynamic>;
      _handleJsonRpcMessage(json);
    } catch (error) {
      _log('解析JSON-RPC消息失败: $error, 原始消息: $line');
    }
  }

  void _handleStderrLine(String line) {
    if (line.trim().isNotEmpty) {
      _log('服务器日志: $line');
    }
  }

  void _handleJsonRpcMessage(Map<String, dynamic> json) {
    // 检查是否是响应
    if (json.containsKey('id') && (json.containsKey('result') || json.containsKey('error'))) {
      _handleResponse(JsonRpcResponse.fromJson(json));
    }
    // 检查是否是通知
    else if (!json.containsKey('id') && json.containsKey('method')) {
      _handleNotification(JsonRpcNotification.fromJson(json));
    }
    // 其他情况记录日志
    else {
      _log('收到未知消息格式: $json');
    }
  }

  void _handleResponse(JsonRpcResponse response) {
    final completer = _pendingRequests.remove(response.id);
    if (completer != null) {
      completer.complete(response);
    } else {
      _log('收到未匹配的响应: ${response.id}');
    }
  }

  void _handleNotification(JsonRpcNotification notification) {
    _log('收到通知: ${notification.method}');
    _notificationController.add(notification);
  }

  dynamic _generateRequestId() {
    return ++_requestIdCounter;
  }

  void _ensureInitialized() {
    if (_state != McpClientState.initialized) {
      throw StateError('客户端未初始化');
    }
  }
} 