import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';

/// Smithery CLI安装管理器 - 管理通过@smithery/cli管理的包
class SmitheryInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;

  @override
  McpInstallType get installType => McpInstallType.smithery;

  @override
  String get name => 'Smithery CLI Package Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<InstallResult> install(McpServer server) async {
    print('📦 Installing Smithery package for server: ${server.name}');
    
    try {
      // 验证配置
      final isValid = await validateServerConfig(server);
      if (!isValid) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Invalid server configuration for Smithery installation',
        );
      }

      final packageName = _extractPackageName(server);
      if (packageName == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot extract package name from server configuration',
        );
      }

      // TODO: 实现Smithery CLI安装逻辑
      // 1. 确保@smithery/cli已安装
      // 2. 使用smithery install命令安装包
      // 3. 管理包的生命周期
      
      print('   🚧 Smithery installation not yet implemented');
      print('   📦 Package to install: $packageName');
      
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Smithery CLI installation not yet implemented',
        metadata: {
          'packageName': packageName,
          'installMethod': 'smithery install (TODO)',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Smithery installation failed: $e',
      );
    }
  }

  @override
  Future<bool> isInstalled(McpServer server) async {
    try {
      // TODO: 实现Smithery包安装检查
      final packageName = _extractPackageName(server);
      if (packageName == null) return false;

      print('   🚧 Smithery installation check not yet implemented for: $packageName');
      return false;
    } catch (e) {
      print('❌ Error checking Smithery installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      // TODO: 实现Smithery包卸载
      final packageName = _extractPackageName(server);
      if (packageName == null) return false;

      print('   🚧 Smithery uninstall not yet implemented for: $packageName');
      return false;
    } catch (e) {
      print('❌ Error uninstalling Smithery package: $e');
      return false;
    }
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    // 检查是否为Smithery类型
    if (server.installType != McpInstallType.smithery) {
      return false;
    }

    // 检查是否有有效的包名
    final packageName = _extractPackageName(server);
    if (packageName == null || packageName.isEmpty) {
      return false;
    }

    // TODO: 检查@smithery/cli是否可用
    return true; // 暂时返回true，待实现
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    try {
      // TODO: 获取Smithery包的安装路径
      final packageName = _extractPackageName(server);
      if (packageName == null) return null;

      print('   🚧 Smithery install path not yet implemented for: $packageName');
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    try {
      // TODO: 获取Smithery包的可执行文件路径
      // 可能需要通过smithery命令来查询
      print('   🚧 Smithery executable path not yet implemented');
      return null;
    } catch (e) {
      print('❌ Error getting executable path: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    try {
      // TODO: 构建Smithery包的启动参数
      // 可能需要使用smithery run命令
      print('   🚧 Smithery startup args not yet implemented');
      return server.args;
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      // TODO: 构建Smithery包的环境变量
      // 可能需要Node.js环境支持
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeDir = path.dirname(path.dirname(nodeExe));
      final npmMirrorUrl = await _configService.getNpmMirrorUrl();

      final envVars = {
        'NODE_PATH': Platform.isWindows 
          ? path.join(nodeDir, 'node_modules')
          : path.join(nodeDir, 'lib', 'node_modules'),
        'NPM_CONFIG_REGISTRY': npmMirrorUrl,
        ...server.env,
      };

      return envVars;
    } catch (e) {
      print('❌ Error building environment variables: $e');
      return server.env;
    }
  }

  /// 从服务器配置中提取包名
  String? _extractPackageName(McpServer server) {
    // 对于Smithery包，需要从@smithery/cli run命令中提取实际的包名
    // 例如：@smithery/cli run package-name -> package-name
    
    for (int i = 0; i < server.args.length; i++) {
      final arg = server.args[i];
      if (arg == 'run' && i + 1 < server.args.length) {
        return server.args[i + 1];
      }
      // 如果没有run命令，可能直接是包名
      if (!arg.startsWith('-') && !arg.startsWith('@smithery')) {
        return arg;
      }
    }
    
    return server.installSource;
  }

  @override
  Future<InstallResult> installCancellable(McpServer server, {Function(Process p1)? onProcessStarted}) {
    // TODO: implement installCancellable
    throw UnimplementedError();
  }
} 