import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';

/// 本地可执行程序安装管理器 - 管理本地路径的可执行程序
class LocalExecutableInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;

  @override
  McpInstallType get installType => McpInstallType.localExecutable;

  @override
  String get name => 'Local Executable Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<InstallResult> install(McpServer server) async {
    print('📦 Installing local executable for server: ${server.name}');
    
    try {
      // 验证配置
      final isValid = await validateServerConfig(server);
      if (!isValid) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Invalid server configuration for local executable installation',
        );
      }

      final executablePath = _extractExecutablePath(server);
      if (executablePath == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot extract executable path from server configuration',
        );
      }

      // TODO: 实现本地可执行程序安装逻辑
      // 1. 验证可执行文件存在且有执行权限
      // 2. 检查文件类型和架构兼容性
      // 3. 设置执行权限（Unix系统）
      
      print('   🚧 Local executable installation not yet implemented');
      print('   📁 Executable path: $executablePath');
      
      // 检查可执行文件是否存在
      if (!await File(executablePath).exists()) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Executable file does not exist: $executablePath',
        );
      }
      
      // 检查执行权限（Unix系统）
      if (!Platform.isWindows) {
        final stat = await File(executablePath).stat();
        final hasExecutePermission = (stat.mode & 0x49) != 0; // 检查用户和组的执行权限
        if (!hasExecutePermission) {
          print('   ⚠️ Warning: File may not have execute permission: $executablePath');
        }
      }
      
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Local executable installation not yet implemented',
        installPath: executablePath,
        metadata: {
          'executablePath': executablePath,
          'installMethod': 'local executable setup (TODO)',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Local executable installation failed: $e',
      );
    }
  }

  @override
  Future<bool> isInstalled(McpServer server) async {
    try {
      final executablePath = _extractExecutablePath(server);
      if (executablePath == null) return false;

      // 基本检查：可执行文件存在
      final exists = await File(executablePath).exists();
      print('   🔍 Local executable exists: $exists ($executablePath)');
      
      return exists;
    } catch (e) {
      print('❌ Error checking local executable installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      // 对于本地可执行文件，通常不需要卸载
      // 只是停止使用该文件
      final executablePath = _extractExecutablePath(server);
      print('   ℹ️ Local executable uninstall (no action needed): $executablePath');
      return true;
    } catch (e) {
      print('❌ Error uninstalling local executable: $e');
      return false;
    }
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    // 检查是否为本地可执行程序类型
    if (server.installType != McpInstallType.localExecutable) {
      return false;
    }

    // 检查是否有有效的可执行文件路径
    final executablePath = _extractExecutablePath(server);
    if (executablePath == null || executablePath.isEmpty) {
      return false;
    }

    // 基本路径验证
    return _isExecutablePath(executablePath);
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    final executablePath = _extractExecutablePath(server);
    if (executablePath != null) {
      return path.dirname(executablePath);
    }
    return null;
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    return _extractExecutablePath(server);
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    try {
      // 对于本地可执行文件，直接使用配置的参数
      return server.args;
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      final envVars = <String, String>{...server.env};

      // 添加可执行文件目录到PATH（可选）
      final executablePath = _extractExecutablePath(server);
      if (executablePath != null) {
        final executableDir = path.dirname(executablePath);
        final existingPath = envVars['PATH'] ?? Platform.environment['PATH'] ?? '';
        
        if (!existingPath.split(Platform.pathSeparator).contains(executableDir)) {
          if (existingPath.isNotEmpty) {
            envVars['PATH'] = '$executableDir${Platform.pathSeparator}$existingPath';
          } else {
            envVars['PATH'] = executableDir;
          }
          print('   🔧 Added executable directory to PATH: $executableDir');
        }
      }
      
      return envVars;
    } catch (e) {
      print('❌ Error building environment variables: $e');
      return server.env;
    }
  }

  /// 从服务器配置中提取可执行文件路径
  String? _extractExecutablePath(McpServer server) {
    // 可执行文件路径通常在command字段中
    if (server.command.isNotEmpty && _isExecutablePath(server.command)) {
      return server.command;
    }
    
    // 或者在installSource中
    if (server.installSource != null && _isExecutablePath(server.installSource!)) {
      return server.installSource;
    }
    
    // 或者在args中的第一个参数
    if (server.args.isNotEmpty && _isExecutablePath(server.args.first)) {
      return server.args.first;
    }
    
    return null;
  }

  /// 检查是否为可执行文件路径
  bool _isExecutablePath(String path) {
    // 检查是否为本地路径
    final isLocalPath = path.contains('/') || path.contains('\\') || 
                       path.startsWith('./') || path.startsWith('../') ||
                       path.startsWith('~') || path.startsWith('C:') ||
                       (path.length > 1 && path[1] == ':'); // Windows驱动器路径
    
    if (!isLocalPath) {
      return false;
    }
    
    // 检查是否为常见的可执行文件扩展名（Windows）
    if (Platform.isWindows) {
      final lowerPath = path.toLowerCase();
      return lowerPath.endsWith('.exe') || 
             lowerPath.endsWith('.bat') || 
             lowerPath.endsWith('.cmd') ||
             lowerPath.endsWith('.com');
    }
    
    // Unix系统：任何本地路径都可能是可执行文件
    return true;
  }

  @override
  Future<InstallResult> installCancellable(McpServer server, {Function(Process p1)?  onProcessStarted}) {
    // // TODO: implement installCancellable
    // throw UnimplementedError();
    return install(server);
  }
} 