import 'dart:io';
import '../../../core/models/mcp_server.dart';

/// 进程管理器接口
/// 所有进程管理器都必须实现这个接口
abstract class ProcessManagerInterface {
  /// 启动进程
  Future<Process> startProcess(McpServer server);

  /// 获取安装类型
  McpInstallType get installType;

  /// 获取进程管理器名称
  String get name;

  /// 获取支持的平台
  List<String> get supportedPlatforms;

  /// 验证服务器配置是否有效
  Future<bool> validateServerConfig(McpServer server);

  /// 获取可执行文件路径
  Future<String?> getExecutablePath(McpServer server);

  /// 获取启动参数
  Future<List<String>> getStartupArgs(McpServer server);

  /// 获取环境变量
  Future<Map<String, String>> getEnvironmentVariables(McpServer server);

  /// 获取工作目录
  Future<String?> getWorkingDirectory(McpServer server);

  /// 预处理（在启动进程前的准备工作）
  Future<void> preProcess(McpServer server) async {
    // 默认实现：无操作
  }

  /// 后处理（在进程启动后的清理工作）
  Future<void> postProcess(McpServer server, Process process) async {
    // 默认实现：无操作
  }
} 