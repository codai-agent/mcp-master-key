import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';

/// NPX安装管理器 - 管理原始Node.js包的安装
class NpxInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;

  @override
  McpInstallType get installType => McpInstallType.npx;

  @override
  String get name => 'NPX Node.js Package Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<InstallResult> install(McpServer server) async {
    print('📦 Installing NPX package for server: ${server.name}');
    
    try {
      // 验证配置
      final isValid = await validateServerConfig(server);
      if (!isValid) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Invalid server configuration for NPX installation',
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

      // 检查包是否已安装
      final alreadyInstalled = await isInstalled(server);
      if (alreadyInstalled) {
        print('   ✅ Package already installed: $packageName');
        return InstallResult(
          success: true,
          installType: installType,
          output: 'Package already installed',
          installPath: await getInstallPath(server),
          metadata: {
            'packageName': packageName,
            'installMethod': 'npm install -g (already installed)',
          },
        );
      }

      // 执行安装
      final result = await _installNpxPackage(packageName, server);
      
      return InstallResult(
        success: result.success,
        installType: installType,
        output: result.output,
        errorMessage: result.errorMessage,
        installPath: await getInstallPath(server),
        metadata: {
          'packageName': packageName,
          'installMethod': 'npm install -g',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'NPX installation failed: $e',
      );
    }
  }

  @override
  Future<bool> isInstalled(McpServer server) async {
    try {
      final packageName = _extractPackageName(server);
      if (packageName == null) return false;

      // 检查npm全局包目录
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeBasePath = path.dirname(path.dirname(nodeExe));
      
      String nodeModulesPath;
      if (Platform.isWindows) {
        nodeModulesPath = path.join(nodeBasePath, 'node_modules', packageName);
      } else {
        nodeModulesPath = path.join(nodeBasePath, 'lib', 'node_modules', packageName);
      }
      
      return await Directory(nodeModulesPath).exists();
    } catch (e) {
      print('❌ Error checking NPX installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      final packageName = _extractPackageName(server);
      if (packageName == null) return false;

      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      final result = await Process.run(
        npmPath,
        ['uninstall', '-g', packageName],
        environment: environment,
      );

      if (result.exitCode == 0) {
        print('✅ NPX package uninstalled: $packageName');
        return true;
      } else {
        print('❌ NPX uninstall failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('❌ Error uninstalling NPX package: $e');
      return false;
    }
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    // 检查是否为NPX类型
    if (server.installType != McpInstallType.npx) {
      return false;
    }

    // 检查是否有有效的包名
    final packageName = _extractPackageName(server);
    if (packageName == null || packageName.isEmpty) {
      return false;
    }

    // 检查npm是否可用
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      return await File(npmPath).exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    try {
      final packageName = _extractPackageName(server);
      if (packageName == null) return null;

      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeBasePath = path.dirname(path.dirname(nodeExe));
      
      if (Platform.isWindows) {
        return path.join(nodeBasePath, 'node_modules', packageName);
      } else {
        return path.join(nodeBasePath, 'lib', 'node_modules', packageName);
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    try {
      if (Platform.isWindows) {
        // Windows上使用node直接执行
        return await _runtimeManager.getNodeExecutable();
      } else {
        // 其他平台使用Node.js
        return await _runtimeManager.getNodeExecutable();
      }
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

      if (Platform.isWindows) {
        // Windows上使用直接文件执行
        final installPath = await getInstallPath(server);
        if (installPath != null) {
          final entryFile = path.join(installPath, 'build', 'index.js');
          return [entryFile];
        }
      } else {
        // 其他平台使用Node.js spawn方式
        final nodeExe = await _runtimeManager.getNodeExecutable();
        final workingDir = path.dirname(path.dirname(nodeExe));
        final binDir = path.join(workingDir, 'bin');
        
        // 从包名中提取可执行文件名
        String executableName = packageName;
        if (executableName.contains('/')) {
          executableName = executableName.split('/').last;
        }
        
        // 构建JavaScript代码
        final jsCode = '''
process.chdir("${workingDir.replaceAll('\\', '\\\\')}");
process.env.PATH = "${binDir.replaceAll('\\', '\\\\')}:" + (process.env.PATH || "");
require("child_process").spawn("$executableName", process.argv.slice(1), {stdio: "inherit"});
'''.trim();
        
        return ['-e', jsCode];
      }
      
      return server.args;
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeDir = path.dirname(path.dirname(nodeExe));
      final npmMirrorUrl = await _configService.getNpmMirrorUrl();

      String nodeModulesPath;
      String npmCacheDir;
      
      if (Platform.isWindows) {
        nodeModulesPath = path.join(nodeDir, 'node_modules');
        npmCacheDir = path.join(nodeDir, 'npm-cache');
      } else {
        nodeModulesPath = path.join(nodeDir, 'lib', 'node_modules');
        npmCacheDir = path.join(nodeDir, '.npm');
      }

      final envVars = {
        'NODE_PATH': nodeModulesPath,
        'NPM_CONFIG_PREFIX': nodeDir,
        'NPM_CONFIG_CACHE': npmCacheDir,
        'NPM_CONFIG_GLOBALCONFIG': path.join(nodeDir, 'etc', 'npmrc'),
        'NPM_CONFIG_USERCONFIG': path.join(nodeDir, '.npmrc'),
        'NPM_CONFIG_REGISTRY': npmMirrorUrl,
        ...server.env,
      };

      if (Platform.isWindows) {
        envVars['USERPROFILE'] = Platform.environment['USERPROFILE'] ?? 
                                 Platform.environment['HOME'] ?? 
                                 'C:\\Users\\mcphub';
      } else {
        envVars['HOME'] = Platform.environment['HOME'] ?? '/tmp';
      }

      return envVars;
    } catch (e) {
      print('❌ Error building environment variables: $e');
      return server.env;
    }
  }

  /// 从服务器配置中提取包名
  String? _extractPackageName(McpServer server) {
    // 从args中提取包名（跳过-y等参数）
    for (int i = 0; i < server.args.length; i++) {
      final arg = server.args[i];
      if (arg == '-y' || arg == '--yes') {
        if (i + 1 < server.args.length) {
          return server.args[i + 1];
        }
      } else if (!arg.startsWith('-')) {
        // 第一个不以-开头的参数通常是包名
        return arg;
      }
    }
    return server.installSource;
  }

  /// 安装NPX包
  Future<_NpxInstallResult> _installNpxPackage(String packageName, McpServer server) async {
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🔧 NPM executable: $npmPath');
      print('   📦 Package: $packageName');

      List<String> args;
      if (Platform.isWindows) {
        args = ['install', '-g', '--no-package-lock', packageName];
      } else {
        args = ['install', '-g', packageName];
      }
      
      print('   📋 Command: $npmPath ${args.join(' ')}');

      final result = await Process.run(
        npmPath,
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

      return _NpxInstallResult(
        success: result.exitCode == 0,
        output: result.stdout.toString(),
        errorMessage: result.exitCode != 0 ? result.stderr.toString() : null,
      );
    } catch (e) {
      print('   ❌ Installation failed: $e');
      return _NpxInstallResult(
        success: false,
        errorMessage: 'Installation failed: $e',
      );
    }
  }
}

/// NPX安装结果
class _NpxInstallResult {
  final bool success;
  final String? output;
  final String? errorMessage;

  _NpxInstallResult({
    required this.success,
    this.output,
    this.errorMessage,
  });
} 