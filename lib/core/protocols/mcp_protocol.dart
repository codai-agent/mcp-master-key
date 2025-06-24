import 'dart:convert';

/// MCP协议版本
const String mcpProtocolVersion = '2024-11-05';

/// MCP消息基类
abstract class McpMessage {
  Map<String, dynamic> toJson();
  
  static McpMessage fromJson(Map<String, dynamic> json) {
    if (json.containsKey('method')) {
      if (json.containsKey('id')) {
        return JsonRpcRequest.fromJson(json);
      } else {
        return JsonRpcNotification.fromJson(json);
      }
    } else {
      return JsonRpcResponse.fromJson(json);
    }
  }
}

/// MCP请求类型
typedef McpRequest = JsonRpcRequest;

/// MCP响应类型
typedef McpResponse = JsonRpcResponse;

/// MCP错误响应类型
typedef McpErrorResponse = JsonRpcResponse;

/// MCP错误类型
typedef McpError = JsonRpcError;

/// MCP错误代码类型
typedef McpErrorCode = McpErrorCodes;

/// JSON-RPC 2.0 基础消息
abstract class JsonRpcMessage extends McpMessage {
  final String jsonrpc = '2.0';
}

/// JSON-RPC 请求
class JsonRpcRequest extends JsonRpcMessage {
  final dynamic id;
  final String method;
  final Map<String, dynamic>? params;

  JsonRpcRequest({
    required this.id,
    required this.method,
    this.params,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'jsonrpc': jsonrpc,
      'id': id,
      'method': method,
    };
    
    if (params != null) {
      json['params'] = params;
    }
    
    return json;
  }

  factory JsonRpcRequest.fromJson(Map<String, dynamic> json) {
    return JsonRpcRequest(
      id: json['id'],
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}

/// JSON-RPC 响应
class JsonRpcResponse extends JsonRpcMessage {
  final dynamic id;
  final Map<String, dynamic>? result;
  final JsonRpcError? error;

  JsonRpcResponse({
    required this.id,
    this.result,
    this.error,
  });

  bool get isSuccess => error == null;

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'jsonrpc': jsonrpc,
      'id': id,
    };
    
    if (error != null) {
      json['error'] = error!.toJson();
    } else {
      json['result'] = result;
    }
    
    return json;
  }

  factory JsonRpcResponse.fromJson(Map<String, dynamic> json) {
    return JsonRpcResponse(
      id: json['id'],
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] != null 
          ? JsonRpcError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// JSON-RPC 通知（无需响应的消息）
class JsonRpcNotification extends JsonRpcMessage {
  final String method;
  final Map<String, dynamic>? params;

  JsonRpcNotification({
    required this.method,
    this.params,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'jsonrpc': jsonrpc,
      'method': method,
    };
    
    if (params != null) {
      json['params'] = params;
    }
    
    return json;
  }

  factory JsonRpcNotification.fromJson(Map<String, dynamic> json) {
    return JsonRpcNotification(
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}

/// JSON-RPC 错误
class JsonRpcError {
  final int code;
  final String message;
  final dynamic data;

  JsonRpcError({
    required this.code,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'code': code,
      'message': message,
    };
    
    if (data != null) {
      json['data'] = data;
    }
    
    return json;
  }

  factory JsonRpcError.fromJson(Map<String, dynamic> json) {
    return JsonRpcError(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }
}

/// MCP 工具定义
class McpTool {
  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema;

  McpTool({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'inputSchema': inputSchema,
    };
  }

  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: json['inputSchema'] as Map<String, dynamic>,
    );
  }
}

/// MCP 资源定义
class McpResource {
  final String uri;
  final String? name;
  final String? description;
  final String? mimeType;

  McpResource({
    required this.uri,
    this.name,
    this.description,
    this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'name': name,
      'description': description,
      'mimeType': mimeType,
    };
  }

  factory McpResource.fromJson(Map<String, dynamic> json) {
    return McpResource(
      uri: json['uri'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }
}

/// MCP 服务器能力
class McpServerCapabilities {
  final bool? logging;
  final bool? prompts;
  final bool? resources;
  final bool? tools;

  McpServerCapabilities({
    this.logging,
    this.prompts,
    this.resources,
    this.tools,
  });

  Map<String, dynamic> toJson() {
    return {
      if (logging != null) 'logging': {},
      if (prompts != null) 'prompts': {},
      if (resources != null) 'resources': {},
      if (tools != null) 'tools': {},
    };
  }

  factory McpServerCapabilities.fromJson(Map<String, dynamic> json) {
    return McpServerCapabilities(
      logging: json.containsKey('logging'),
      prompts: json.containsKey('prompts'),
      resources: json.containsKey('resources'),
      tools: json.containsKey('tools'),
    );
  }
}

/// MCP 客户端能力
class McpClientCapabilities {
  final bool? sampling;

  McpClientCapabilities({
    this.sampling,
  });

  Map<String, dynamic> toJson() {
    return {
      if (sampling != null) 'sampling': {},
    };
  }

  factory McpClientCapabilities.fromJson(Map<String, dynamic> json) {
    return McpClientCapabilities(
      sampling: json.containsKey('sampling'),
    );
  }
}

/// MCP 初始化结果
class McpInitializeResult {
  final String protocolVersion;
  final McpServerCapabilities capabilities;
  final Map<String, dynamic>? serverInfo;

  McpInitializeResult({
    required this.protocolVersion,
    required this.capabilities,
    this.serverInfo,
  });

  factory McpInitializeResult.fromJson(Map<String, dynamic> json) {
    return McpInitializeResult(
      protocolVersion: json['protocolVersion'] as String,
      capabilities: McpServerCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>
      ),
      serverInfo: json['serverInfo'] as Map<String, dynamic>?,
    );
  }
}

/// MCP 方法名常量
class McpMethods {
  // 初始化
  static const String initialize = 'initialize';
  static const String initialized = 'initialized';
  
  // 工具相关
  static const String toolsList = 'tools/list';
  static const String toolsCall = 'tools/call';
  
  // 资源相关
  static const String resourcesList = 'resources/list';
  static const String resourcesRead = 'resources/read';
  
  // 提示相关
  static const String promptsList = 'prompts/list';
  static const String promptsGet = 'prompts/get';
  
  // 日志相关
  static const String loggingSetLevel = 'logging/setLevel';
  
  // 通知
  static const String notificationsCancelled = 'notifications/cancelled';
  static const String notificationsProgress = 'notifications/progress';
  static const String notificationsMessage = 'notifications/message';
}

/// MCP 错误代码
class McpErrorCodes {
  static const int parseError = -32700;
  static const int invalidRequest = -32600;
  static const int methodNotFound = -32601;
  static const int invalidParams = -32602;
  static const int internalError = -32603;
  
  // MCP 特定错误
  static const int invalidRange = -32001;
  static const int invalidUri = -32002;
  static const int requestFailed = -32003;
  static const int methodNotAllowed = -32004;
  static const int serverNotFound = -32005;
  static const int connectionFailed = -32006;
  static const int timeout = -32007;
  static const int resourceNotFound = -32008;
  static const int toolNotFound = -32009;
  static const int promptNotFound = -32010;
} 