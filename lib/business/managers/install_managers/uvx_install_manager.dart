import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../core/constants/path_constants.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';

/// UVX安装管理器 - 管理Python包的安装
class UvxInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;

  @override
  McpInstallType get installType => McpInstallType.uvx;

  @override
  String get name => 'UVX Python Package Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<InstallResult> install(McpServer server) async {
    print('📦 Installing UVX package for server: ${server.name}');
    
    try {
      // 验证配置
      final isValid = await validateServerConfig(server);
      if (!isValid) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Invalid server configuration for UVX installation',
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

      // 执行安装
      final result = await _installUvxPackage(packageName, server);
      
      return InstallResult(
        success: result.success,
        installType: installType,
        output: result.output,
        errorMessage: result.errorMessage,
        installPath: await getInstallPath(server),
        metadata: {
          'packageName': packageName,
          'installMethod': 'uv tool install',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'UVX installation failed: $e',
      );
    }
  }

  @override
  Future<bool> isInstalled(McpServer server) async {
    try {
      final packageName = _extractPackageName(server);
      if (packageName == null) return false;

      // 检查UVX tools目录中是否存在包
      final mcpHubBasePath = PathConstants.getUserMcpHubPath();
      final toolsDir = '$mcpHubBasePath/packages/uv/tools/$packageName';
      
      return await Directory(toolsDir).exists();
    } catch (e) {
      print('❌ Error checking UVX installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      final packageName = _extractPackageName(server);
      if (packageName == null) return false;

      final uvPath = await _runtimeManager.getUvExecutable();
      final environment = await getEnvironmentVariables(server);

      final result = await Process.run(
        uvPath,
        ['tool', 'uninstall', packageName],
        environment: environment,
      );

      if (result.exitCode == 0) {
        print('✅ UVX package uninstalled: $packageName');
        return true;
      } else {
        print('❌ UVX uninstall failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('❌ Error uninstalling UVX package: $e');
      return false;
    }
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    // 检查是否为UVX类型
    if (server.installType != McpInstallType.uvx) {
      return false;
    }

    // 检查是否有有效的包名
    final packageName = _extractPackageName(server);
    if (packageName == null || packageName.isEmpty) {
      return false;
    }

    // 检查UV是否可用
    try {
      final uvPath = await _runtimeManager.getUvExecutable();
      return await File(uvPath).exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    try {
      final packageName = _extractPackageName(server);
      if (packageName == null) return null;

      final mcpHubBasePath = PathConstants.getUserMcpHubPath();
      return '$mcpHubBasePath/packages/uv/tools/$packageName';
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    try {
      final packageName = _extractPackageName(server);
      if (packageName == null) return null;

      // 首先尝试找到已安装的可执行文件
      final executablePath = await _findUvxExecutable(packageName);
      if (executablePath != null) {
        return executablePath;
      }

      // 如果没找到可执行文件，回退到Python执行
      return await _runtimeManager.getPythonExecutable();
    } catch (e) {
      print('❌ Error getting executable path: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    try {
      final packageName = _extractPackageName(server);
      if (packageName == null) return server.args;

      // 检查是否有可执行文件
      final executablePath = await _findUvxExecutable(packageName);
      if (executablePath != null) {
        // 使用可执行文件时，跳过第一个参数（包名）
        return server.args.skip(1).toList();
      }

      // 回退到Python模块执行
      final remainingArgs = server.args.skip(1).toList();
      return ['-m', packageName.replaceAll('-', '_'), ...remainingArgs];
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      final mcpHubBasePath = PathConstants.getUserMcpHubPath();
      final pythonMirrorUrl = await _configService.getPythonMirrorUrl();
      final timeoutSeconds = await _configService.getDownloadTimeoutSeconds();
      final concurrentDownloads = await _configService.getConcurrentDownloads();
      final pythonExePath = await _runtimeManager.getPythonExecutable();

      return {
        'UV_CACHE_DIR': '$mcpHubBasePath/cache/uv',
        'UV_DATA_DIR': '$mcpHubBasePath/data/uv',
        'UV_TOOL_DIR': '$mcpHubBasePath/packages/uv/tools',
        'UV_TOOL_BIN_DIR': '$mcpHubBasePath/packages/uv/bin',
        'UV_PYTHON': pythonExePath,
        'UV_PYTHON_PREFERENCE': 'only-system',
        'UV_INDEX_URL': pythonMirrorUrl,
        'UV_HTTP_TIMEOUT': '$timeoutSeconds',
        'UV_CONCURRENT_DOWNLOADS': '$concurrentDownloads',
        'UV_HTTP_RETRIES': '3',
        ...server.env,
      };
    } catch (e) {
      print('❌ Error building environment variables: $e');
      return server.env;
    }
  }

  /// 从服务器配置中提取包名
  String? _extractPackageName(McpServer server) {
    if (server.args.isNotEmpty) {
      return server.args.first;
    }
    return server.installSource;
  }

  /// 安装UVX包
  Future<_UvxInstallResult> _installUvxPackage(String packageName, McpServer server) async {
    try {
      final uvPath = await _runtimeManager.getUvExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🔧 UV executable: $uvPath');
      print('   📦 Package: $packageName');

      final args = ['tool', 'install', packageName];
      print('   📋 Command: $uvPath ${args.join(' ')}');

      final result = await Process.run(
        uvPath,
        args,
        environment: environment,
      ).timeout(const Duration(minutes: 5));

      print('   📊 Exit code: ${result.exitCode}');
      if (result.stdout.toString().isNotEmpty) {
        print('   📝 Stdout: ${result.stdout}');
      }
      if (result.stderr.toString().isNotEmpty) {
        print('   ❌ Stderr: ${result.stderr}');
      }

      return _UvxInstallResult(
        success: result.exitCode == 0,
        output: result.stdout.toString(),
        errorMessage: result.exitCode != 0 ? result.stderr.toString() : null,
      );
    } catch (e) {
      print('   ❌ Installation failed: $e');
      
      // 如果超时，检查包是否实际安装成功
      final packagePath = await getInstallPath(server);
      if (packagePath != null && await Directory(packagePath).exists()) {
        print('   ✅ Package directory exists, treating as successful');
        return _UvxInstallResult(
          success: true,
          output: 'Package installed successfully (verified by directory check)',
        );
      }
      
      return _UvxInstallResult(
        success: false,
        errorMessage: 'Installation failed: $e',
      );
    }
  }

  /// 查找UVX已安装的可执行文件
  Future<String?> _findUvxExecutable(String packageName) async {
    try {
      final mcpHubBasePath = PathConstants.getUserMcpHubPath();
      final uvToolsDir = '$mcpHubBasePath/packages/uv/tools/$packageName';

      String executablePath;
      if (Platform.isWindows) {
        // Windows: Scripts目录，.exe后缀
        executablePath = '$uvToolsDir/Scripts/$packageName.exe';
        if (await File(executablePath).exists()) {
          return executablePath;
        }
        // 尝试没有.exe后缀的版本
        executablePath = '$uvToolsDir/Scripts/$packageName';
        if (await File(executablePath).exists()) {
          return executablePath;
        }
      } else {
        // Unix/Linux/macOS: bin目录，无后缀
        executablePath = '$uvToolsDir/bin/$packageName';
        if (await File(executablePath).exists()) {
          return executablePath;
        }
      }

      return null;
    } catch (e) {
      print('   ❌ Error finding UVX executable: $e');
      return null;
    }
  }
}

/// UVX安装结果
class _UvxInstallResult {
  final bool success;
  final String? output;
  final String? errorMessage;

  _UvxInstallResult({
    required this.success,
    this.output,
    this.errorMessage,
  });
} 