import 'dart:async';
import '../../../core/models/mcp_server.dart';
import '../../services/install_service.dart';

/// 安装管理器接口
/// 所有安装管理器都必须实现这个接口
abstract class InstallManagerInterface {
  /// 安装服务器
  Future<InstallResult> install(McpServer server);

  /// 检查服务器是否已安装
  Future<bool> isInstalled(McpServer server);

  /// 卸载服务器
  Future<bool> uninstall(McpServer server);

  /// 获取安装类型
  McpInstallType get installType;

  /// 获取安装管理器名称
  String get name;

  /// 获取支持的平台
  List<String> get supportedPlatforms;

  /// 验证服务器配置是否有效
  Future<bool> validateServerConfig(McpServer server);

  /// 获取安装路径
  Future<String?> getInstallPath(McpServer server);

  /// 获取可执行文件路径
  Future<String?> getExecutablePath(McpServer server);

  /// 获取启动参数
  Future<List<String>> getStartupArgs(McpServer server);

  /// 获取环境变量
  Future<Map<String, String>> getEnvironmentVariables(McpServer server);
} 