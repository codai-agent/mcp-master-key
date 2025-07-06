import 'package:freezed_annotation/freezed_annotation.dart';

part 'mcp_server.freezed.dart';
part 'mcp_server.g.dart';

/// MCP服务器状态枚举
enum McpServerStatus {
  /// 未安装
  notInstalled,
  /// 已安装但未启动
  installed,
  /// 正在启动
  starting,
  /// 运行中
  running,
  /// 正在停止
  stopping,
  /// 已停止
  stopped,
  /// 错误状态
  error,
  /// 正在安装
  installing,
  /// 正在卸载
  uninstalling,
}

/// MCP服务器状态枚举扩展方法（提供name属性兼容性）
extension McpServerStatusExtension on McpServerStatus {
  String get name {
    switch (this) {
      case McpServerStatus.notInstalled:
        return 'notInstalled';
      case McpServerStatus.installed:
        return 'installed';
      case McpServerStatus.starting:
        return 'starting';
      case McpServerStatus.running:
        return 'running';
      case McpServerStatus.stopping:
        return 'stopping';
      case McpServerStatus.stopped:
        return 'stopped';
      case McpServerStatus.error:
        return 'error';
      case McpServerStatus.installing:
        return 'installing';
      case McpServerStatus.uninstalling:
        return 'uninstalling';
    }
  }
}

/// MCP服务器连接类型
enum McpConnectionType {
  /// STDIO连接
  stdio,
  /// HTTP/SSE连接
  sse,
}

/// MCP服务器连接类型扩展方法
extension McpConnectionTypeExtension on McpConnectionType {
  String get name {
    switch (this) {
      case McpConnectionType.stdio:
        return 'stdio';
      case McpConnectionType.sse:
        return 'sse';
    }
  }
}

/// MCP服务器安装类型
enum McpInstallType {
  /// npx命令安装（原始node包）
  npx,
  /// uvx命令安装（python包）
  uvx,
  /// smithery CLI管理的包
  smithery,
  /// 本地路径Python包
  localPython,
  /// 本地路径JAR包
  localJar,
  /// 本地路径可执行程序
  localExecutable,
  /// GitHub仓库
  github,
  /// 预安装命令
  preInstalled,
}

/// MCP服务器安装类型扩展方法
extension McpInstallTypeExtension on McpInstallType {
  String get name {
    switch (this) {
      case McpInstallType.npx:
        return 'npx';
      case McpInstallType.uvx:
        return 'uvx';
      case McpInstallType.smithery:
        return 'smithery';
      case McpInstallType.localPython:
        return 'localPython';
      case McpInstallType.localJar:
        return 'localJar';
      case McpInstallType.localExecutable:
        return 'localExecutable';
      case McpInstallType.github:
        return 'github';
      case McpInstallType.preInstalled:
        return 'preInstalled';
    }
  }
}

/// MCP服务器数据模型
@freezed
class McpServer with _$McpServer {
  const factory McpServer({
    /// 服务器ID（唯一标识）
    required String id,
    /// 服务器名称
    required String name,
    /// 服务器描述
    String? description,
    /// 服务器状态
    @Default(McpServerStatus.notInstalled) McpServerStatus status,
    /// 连接类型
    @Default(McpConnectionType.stdio) McpConnectionType connectionType,
    /// 安装类型
    required McpInstallType installType,
    /// 安装命令或路径
    required String command,
    /// 命令参数
    @Default([]) List<String> args,
    /// 环境变量
    @Default({}) Map<String, String> env,
    /// 工作目录
    String? workingDirectory,
    /// 安装源（GitHub URL、npm包名等）
    String? installSource,
    /// 版本信息
    String? version,
    /// 配置参数
    @Default({}) Map<String, dynamic> config,
    /// 进程ID（运行时）
    int? processId,
    /// 端口号（SSE模式）
    int? port,
    /// 创建时间
    required DateTime createdAt,
    /// 更新时间
    required DateTime updatedAt,
    /// 最后启动时间
    DateTime? lastStartedAt,
    /// 最后停止时间
    DateTime? lastStoppedAt,
    /// 是否自动启动
    @Default(false) bool autoStart,
    /// 错误信息
    String? errorMessage,
    /// 日志级别
    @Default('info') String logLevel,
  }) = _McpServer;

  factory McpServer.fromJson(Map<String, dynamic> json) =>
      _$McpServerFromJson(json);
}

/// MCP服务器生命周期事件类型
enum McpLifecycleEventType {
  /// 安装开始
  installStarted,
  /// 安装成功
  installCompleted,
  /// 安装失败
  installFailed,
  /// 启动开始
  startStarted,
  /// 启动成功
  startCompleted,
  /// 启动失败
  startFailed,
  /// 停止开始
  stopStarted,
  /// 停止成功
  stopCompleted,
  /// 停止失败
  stopFailed,
  /// 配置更新
  configUpdated,
  /// 状态变更
  statusChanged,
  /// 错误发生
  errorOccurred,
  /// 重启
  restarted,
  /// 卸载开始
  uninstallStarted,
  /// 卸载完成
  uninstallCompleted,
  /// 卸载失败
  uninstallFailed,
  /// 健康检查
  healthCheck,
}

/// MCP服务器生命周期事件类型扩展方法
extension McpLifecycleEventTypeExtension on McpLifecycleEventType {
  String get name {
    switch (this) {
      case McpLifecycleEventType.installStarted:
        return 'installStarted';
      case McpLifecycleEventType.installCompleted:
        return 'installCompleted';
      case McpLifecycleEventType.installFailed:
        return 'installFailed';
      case McpLifecycleEventType.startStarted:
        return 'startStarted';
      case McpLifecycleEventType.startCompleted:
        return 'startCompleted';
      case McpLifecycleEventType.startFailed:
        return 'startFailed';
      case McpLifecycleEventType.stopStarted:
        return 'stopStarted';
      case McpLifecycleEventType.stopCompleted:
        return 'stopCompleted';
      case McpLifecycleEventType.stopFailed:
        return 'stopFailed';
      case McpLifecycleEventType.configUpdated:
        return 'configUpdated';
      case McpLifecycleEventType.statusChanged:
        return 'statusChanged';
      case McpLifecycleEventType.errorOccurred:
        return 'errorOccurred';
      case McpLifecycleEventType.restarted:
        return 'restarted';
      case McpLifecycleEventType.uninstallStarted:
        return 'uninstallStarted';
      case McpLifecycleEventType.uninstallCompleted:
        return 'uninstallCompleted';
      case McpLifecycleEventType.uninstallFailed:
        return 'uninstallFailed';
      case McpLifecycleEventType.healthCheck:
        return 'healthCheck';
    }
  }
}

/// MCP服务器生命周期事件
@freezed
class McpLifecycleEvent with _$McpLifecycleEvent {
  const factory McpLifecycleEvent({
    /// 事件ID
    required String id,
    /// 服务器ID
    required String serverId,
    /// 事件类型
    required McpLifecycleEventType type,
    /// 事件描述
    required String description,
    /// 事件详情
    @Default({}) Map<String, dynamic> details,
    /// 事件时间
    required DateTime timestamp,
    /// 是否成功
    @Default(true) bool success,
    /// 错误信息
    String? errorMessage,
    /// 持续时间（毫秒）
    int? duration,
  }) = _McpLifecycleEvent;

  factory McpLifecycleEvent.fromJson(Map<String, dynamic> json) =>
      _$McpLifecycleEventFromJson(json);
}

/// MCP服务器日志条目
@freezed
class McpLogEntry with _$McpLogEntry {
  const factory McpLogEntry({
    /// 日志ID
    required String id,
    /// 服务器ID
    required String serverId,
    /// 日志级别
    required String level,
    /// 日志消息
    required String message,
    /// 日志时间
    required DateTime timestamp,
    /// 日志来源（stdout/stderr）
    @Default('stdout') String source,
    /// 额外数据
    @Default({}) Map<String, dynamic> metadata,
  }) = _McpLogEntry;

  factory McpLogEntry.fromJson(Map<String, dynamic> json) =>
      _$McpLogEntryFromJson(json);
}

/// MCP请求记录
@freezed
class McpRequestRecord with _$McpRequestRecord {
  const factory McpRequestRecord({
    /// 请求ID
    required String id,
    /// 服务器ID
    required String serverId,
    /// 请求方法
    required String method,
    /// 请求参数
    @Default({}) Map<String, dynamic> params,
    /// 响应数据
    Map<String, dynamic>? response,
    /// 请求时间
    required DateTime requestTime,
    /// 响应时间
    DateTime? responseTime,
    /// 是否成功
    bool? success,
    /// 错误信息
    String? errorMessage,
    /// 响应时间（毫秒）
    int? duration,
  }) = _McpRequestRecord;

  factory McpRequestRecord.fromJson(Map<String, dynamic> json) =>
      _$McpRequestRecordFromJson(json);
} 