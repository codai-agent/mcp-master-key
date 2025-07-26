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

      var packageName = _extractPackageName(server);
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
            'installMethod': 'uv tool install (already installed)',
          },
        );
      }

      // 执行安装
      var result = await _installUvxPackage(packageName, server);
      //如果安装失败，可能是package不对，再从启动参数里面去取一次程序名称
      if (!result.success) {
        packageName = _extractRuntimePkgName(server);
        result = await _installUvxPackage(packageName!, server);
      }
      
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
    //兼容uv run xxx
    if (server.installType == McpInstallType.localPython) {
      return true;
    }
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

  /// 从服务器配置中提取包名 uvx的安装包名为 json的root key
  String? _extractPackageName(McpServer server) {
    return server.name;
  }

  /// 从服务器配置中提取uvx的运行时名
  String? _extractRuntimePkgName(McpServer server) {
    String packageName = '';
    List<String> args = server.args;
    if (args.first.startsWith('--')) {
      // 如果第一个参数是--开头
      if (args.length >= 3) {
        // 如果后面至少有两个参数
        final secondParam = args[2];
        // 检查第二个参数是否也是--开头
        if (secondParam.startsWith('--')) {
          // 如果第二个参数也是--开头，继续往后找非--开头的参数
          packageName = args.skip(2).firstWhere(
                (arg) => !arg.startsWith('--'),
            orElse: () => args[1], // 如果找不到，使用第一个--后的参数
          );
        } else {
          packageName = secondParam;
        }
      } else if (args.length >= 2) {
        // 如果只有一个后续参数
        packageName = args[1];
      } else {
        packageName = '';
      }
    } else {
      // 如果第一个参数不是--开头，直接使用它
      packageName = args.first;
    }
    return packageName;
  }

  /// 去除参数中的执行包名
  List<String> _removeRuntimePkgFromArgs(List<String> args) {
    if (args.isEmpty) {
      return [];
    }
    List<String> copyList = [];
    copyList.addAll(args);
    String packageName = '';
    if (args.first.startsWith('--')) {
      // 如果第一个参数是--开头
      if (args.length >= 3) {
        // 如果后面至少有两个参数
        final secondParam = args[2];
        // 检查第二个参数是否也是--开头
        if (secondParam.startsWith('--')) {
          // 如果第二个参数也是--开头，继续往后找非--开头的参数
          packageName = args.skip(2).firstWhere(
                (arg) => !arg.startsWith('--'),
            orElse: () => args[1], // 如果找不到，使用第一个--后的参数
          );
        } else {
          packageName = secondParam;
        }
      } else if (args.length >= 2) {
        // 如果只有一个后续参数
        packageName = args[1];
      } else {
        packageName = '';
      }
    } else {
      // 如果第一个参数不是--开头，直接使用它
      packageName = args.first;
    }
    copyList.remove(packageName);
    return copyList;
  }

  /// 安装UVX包
  Future<_UvxInstallResult> _installUvxPackage(String packageName, McpServer server) async {
    try {
      final uvPath = await _runtimeManager.getUvExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🔧 UV executable: $uvPath');
      print('   📦 Package: $packageName');

      final args = ['tool', 'install', packageName];
      // 检查是否包含--from参数并获取安装源
      if (server.args.contains('--from')) {
        final fromIndex = server.args.indexOf('--from');
        // 确保--from后面还有参数
        if (fromIndex < server.args.length - 1) {
          args.add('--from');
          args.add(server.args[fromIndex + 1]);
        }
      }
      
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

  @override
  Future<InstallResult> installCancellable(
    McpServer server, {
    Function(Process)? onProcessStarted,
  }) async {
    try {
      var packageName = _extractPackageName(server);
      if (packageName == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot determine package name from server configuration',
        );
      }

      print('📦 Installing UVX package (cancellable): $packageName');

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
            'installMethod': 'uv tool install (already installed)',
          },
        );
      }

      // 执行可取消安装
      var result = await _installUvxPackageCancellable(packageName, server, onProcessStarted);
      //如果安装失败，可能是package不对，再从启动参数里面去取一次程序名称
      if (!result.success) {
        packageName = _extractRuntimePkgName(server);
        result = await _installUvxPackageCancellable(packageName!, server, onProcessStarted);
      }
      return InstallResult(
        success: result.success,
        installType: installType,
        output: result.output,
        errorMessage: result.errorMessage,
        installPath: await getInstallPath(server),
        metadata: {
          'packageName': packageName,
          'installMethod': 'uv tool install (cancellable)',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'UVX cancellable installation failed: $e',
      );
    }
  }

  /// 可取消的UVX包安装
  Future<_UvxInstallResult> _installUvxPackageCancellable(
    String packageName, 
    McpServer server,
    Function(Process)? onProcessStarted,
  ) async {
    try {
      final uvPath = await _runtimeManager.getUvExecutable();
      final environment = await getEnvironmentVariables(server);

      final args = ['tool', 'install', packageName, '--force'];
      // 检查是否包含--from参数并获取安装源
      if (server.args.contains('--from') || server.args.contains('--directory')) {
        String param = '--from';
        int fromIndex = server.args.indexOf(param);
        if (fromIndex < 0) {
          param = '--directory';
          fromIndex = server.args.indexOf(param);
        }
        // 确保--from后面还有参数
        if (fromIndex < server.args.length - 1) {
          args.add(param);
          args.add(server.args[fromIndex + 1]);
        }
      }

      // final args = ['tool', 'install',packageName];
      // args.addAll(_removeRuntimePkgFromArgs(server.args));
      
      print('   🔧 UV executable: $uvPath');
      print('   📦 Package: $packageName');
      print('   📋 Command: $uvPath ${args.join(' ')}');

      // 使用Process.start来获得进程控制权
      final process = await Process.start(
        uvPath,
        args,
        environment: environment,
      );

      // 通过回调传递进程实例，允许外部控制
      if (onProcessStarted != null) {
        onProcessStarted(process);
      }

      // 收集输出
      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      // 监听输出流
      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        stdoutBuffer.write(data);
        print('   📝 stdout: ${data.trim()}');
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        stderrBuffer.write(data);
        print('   ❌ stderr: ${data.trim()}');
      });

      // 等待进程完成，5分钟超时
      final exitCode = await process.exitCode.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          print('   ⏰ UVX installation timed out, killing process...');
          InstallManagerInterface.killProcessCrossPlatform(process);
          return -1;
        },
      );

      print('   📊 Exit code: $exitCode');

      return _UvxInstallResult(
        success: exitCode == 0,
        output: stdoutBuffer.toString(),
        errorMessage: exitCode != 0 ? stderrBuffer.toString() : null,
      );
    } catch (e) {
      print('   ❌ Cancellable installation failed: $e');
      return _UvxInstallResult(
        success: false,
        errorMessage: 'Cancellable installation failed: $e',
      );
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