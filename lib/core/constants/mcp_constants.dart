/// MCP协议相关常量定义
class McpConstants {
  // MCP协议版本
  static const String protocolVersion = '2024-11-05';
  
  // MCP消息类型
  static const String messageTypeRequest = 'request';
  static const String messageTypeResponse = 'response';
  static const String messageTypeNotification = 'notification';
  
  // MCP方法名称
  static const String methodInitialize = 'initialize';
  static const String methodInitialized = 'initialized';
  static const String methodListTools = 'tools/list';
  static const String methodCallTool = 'tools/call';
  static const String methodListResources = 'resources/list';
  static const String methodReadResource = 'resources/read';
  static const String methodListPrompts = 'prompts/list';
  static const String methodGetPrompt = 'prompts/get';
  static const String methodPing = 'ping';
  static const String methodShutdown = 'shutdown';
  
  // MCP通知方法
  static const String notificationCancelled = 'notifications/cancelled';
  static const String notificationProgress = 'notifications/progress';
  static const String notificationMessage = 'notifications/message';
  static const String notificationResourcesChanged = 'notifications/resources/list_changed';
  static const String notificationToolsChanged = 'notifications/tools/list_changed';
  static const String notificationPromptsChanged = 'notifications/prompts/list_changed';
  
  // MCP错误代码
  static const int errorCodeParseError = -32700;
  static const int errorCodeInvalidRequest = -32600;
  static const int errorCodeMethodNotFound = -32601;
  static const int errorCodeInvalidParams = -32602;
  static const int errorCodeInternalError = -32603;
  
  // 自定义错误代码
  static const int errorCodeServerNotFound = -32000;
  static const int errorCodeServerNotRunning = -32001;
  static const int errorCodeServerTimeout = -32002;
  static const int errorCodeServerError = -32003;
  static const int errorCodeInvalidConfiguration = -32004;
  static const int errorCodeEnvironmentError = -32005;
  static const int errorCodeInstallationError = -32006;
  
  // MCP传输模式
  static const String transportStdio = 'stdio';
  static const String transportSse = 'sse';
  static const String transportHttp = 'http';
  
  // MCP服务器状态
  static const String statusStopped = 'stopped';
  static const String statusStarting = 'starting';
  static const String statusRunning = 'running';
  static const String statusStopping = 'stopping';
  static const String statusError = 'error';
  
  // MCP服务器类型
  static const String serverTypePython = 'python';
  static const String serverTypeNode = 'node';
  static const String serverTypeLocal = 'local';
  static const String serverTypeRemote = 'remote';
  
  // MCP Hub特定配置
  static const String hubServerName = 'mcp-hub';
  static const String hubServerDescription = 'MCP Hub aggregation server';
  static const String hubServerVersion = '1.0.0';
  
  // 默认端口范围
  static const int defaultPortStart = 8080;
  static const int defaultPortEnd = 8999;
  
  // 超时配置
  static const Duration defaultInitializeTimeout = Duration(seconds: 30);
  static const Duration defaultRequestTimeout = Duration(seconds: 60);
  static const Duration defaultShutdownTimeout = Duration(seconds: 10);
  
  // 重试配置
  static const int defaultMaxRetries = 3;
  static const Duration defaultRetryDelay = Duration(seconds: 1);
  
  // 日志级别
  static const String logLevelDebug = 'debug';
  static const String logLevelInfo = 'info';
  static const String logLevelWarn = 'warn';
  static const String logLevelError = 'error';
  
  // 资源类型
  static const String resourceTypeFile = 'file';
  static const String resourceTypeDirectory = 'directory';
  static const String resourceTypeUrl = 'url';
  static const String resourceTypeDatabase = 'database';
  
  // 工具类型
  static const String toolTypeFunction = 'function';
  static const String toolTypeCommand = 'command';
  static const String toolTypeApi = 'api';
  
  // 内容类型
  static const String contentTypeText = 'text/plain';
  static const String contentTypeJson = 'application/json';
  static const String contentTypeHtml = 'text/html';
  static const String contentTypeMarkdown = 'text/markdown';
  static const String contentTypeBinary = 'application/octet-stream';
} 