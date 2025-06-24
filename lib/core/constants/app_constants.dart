/// 应用核心常量定义
class AppConstants {
  // 应用信息
  static const String appName = 'MCP Hub';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A cross-platform desktop application for managing MCP servers';
  
  // 运行时版本
  static const String pythonVersion = '3.12.6';
  static const String uvVersion = '0.7.13';
  static const String nodeVersion = '20.10.0';
  
  // 数据库版本
  static const int databaseVersion = 5;
  static const String databaseName = 'mcp_hub.db';
  
  // 默认配置
  static const int defaultHttpPort = 8080;
  static const int defaultLogRetentionDays = 30;
  static const int defaultStatsRetentionDays = 90;
  static const int defaultHeartbeatIntervalSeconds = 30;
  static const int dataRetentionDays = 30;
  
  // 应用配置
  static const String configFileName = 'mcp_hub_config.json';
  static const String serversConfigFileName = 'mcp_servers.json';
  
  // 目录名称
  static const String runtimesDir = 'runtimes';
  static const String environmentsDir = 'environments';
  static const String logsDir = 'logs';
  static const String dataDir = 'data';
  
  // 文件扩展名
  static const String pythonExt = '.py';
  static const String jsExt = '.js';
  static const String tsExt = '.ts';
  static const String jsonExt = '.json';
  static const String yamlExt = '.yaml';
  static const String ymlExt = '.yml';
  
  // Git相关
  static const String githubBaseUrl = 'https://github.com';
  static const String githubApiBaseUrl = 'https://api.github.com';
  
  // MCP协议
  static const String mcpProtocolVersion = '2024-11-05';
  static const String mcpUserAgent = 'MCP-Hub/1.0.0';
  
  // 超时配置
  static const Duration defaultCommandTimeout = Duration(minutes: 5);
  static const Duration defaultNetworkTimeout = Duration(seconds: 30);
  static const Duration defaultStartupTimeout = Duration(seconds: 60);
  
  // 限制配置
  static const int maxLogFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxConcurrentServers = 50;
  static const int maxRetryAttempts = 3;
} 