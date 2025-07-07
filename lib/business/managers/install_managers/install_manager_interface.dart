import 'dart:async';
import 'dart:io';
import '../../../core/models/mcp_server.dart';
import '../../services/install_service.dart';

/// 安装管理器接口
/// 所有安装管理器都必须实现这个接口
abstract class InstallManagerInterface {
  /// 安装服务器
  Future<InstallResult> install(McpServer server);

  /// 可取消安装服务器
  Future<InstallResult> installCancellable(
    McpServer server, {
    Function(Process)? onProcessStarted,
  }) async {
    // 默认实现：调用普通安装方法
    return await install(server);
  }

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

  /// 跨平台进程终止辅助方法
  static void killProcessCrossPlatform(Process process) {
    try {
      print('🔪 Killing process ${process.pid}...');
      
      if (Platform.isWindows) {
        // Windows: 使用taskkill命令
        Process.run('taskkill', ['/F', '/PID', '${process.pid}']);
      } else {
        // Unix系统: 使用kill命令
        process.kill(ProcessSignal.sigterm);
        
        // 如果进程仍在运行，强制杀死
        Future.delayed(const Duration(seconds: 3), () {
          try {
            process.kill(ProcessSignal.sigkill);
          } catch (e) {
            // 进程可能已经结束
          }
        });
      }
      
      print('✅ Process kill signal sent');
    } catch (e) {
      print('❌ Failed to kill process: $e');
    }
  }

  /// 跨平台通过PID杀死进程
  static void killProcessByPid(int pid) {
    try {
      print('🔪 Killing process by PID: $pid...');
      
      if (Platform.isWindows) {
        Process.run('taskkill', ['/F', '/PID', '$pid']);
      } else {
        Process.run('kill', ['-TERM', '$pid']).then((_) {
          Future.delayed(const Duration(seconds: 3), () {
            Process.run('kill', ['-KILL', '$pid']).catchError((e) {
              return ProcessResult(0, 1, '', e.toString());
            });
          });
        });
      }
      
      print('✅ Process kill signal sent');
    } catch (e) {
      print('❌ Failed to kill process: $e');
    }
  }
} 