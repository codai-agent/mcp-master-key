import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../install_managers/npx_install_manager.dart';
import 'process_manager_interface.dart';

/// NPX进程管理器 - 管理NPX类型的MCP服务器进程
class NpxProcessManager implements ProcessManagerInterface {
  final NpxInstallManager _installManager = NpxInstallManager();
  final RuntimeManager _runtimeManager = RuntimeManager.instance;

  @override
  McpInstallType get installType => McpInstallType.npx;

  @override
  String get name => 'NPX Process Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<Process> startProcess(McpServer server) async {
    print('🚀 Starting NPX process for server: ${server.name}');
    
    await preProcess(server);

    final executable = await getExecutablePath(server);
    final args = await getStartupArgs(server);
    final environment = await getEnvironmentVariables(server);
    final workingDirectory = await getWorkingDirectory(server);

    if (executable == null) {
      throw Exception('Cannot determine executable path for NPX server');
    }

    print('   🔧 Executable: $executable');
    print('   📋 Args: ${args.join(' ')}');

    final process = await Process.start(
      executable,
      args,
      workingDirectory: workingDirectory,
      environment: environment,
      mode: ProcessStartMode.normal,
    );

    await postProcess(server, process);
    print('   ✅ NPX process started (PID: ${process.pid})');
    return process;
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    return await _installManager.validateServerConfig(server);
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    return await _installManager.getExecutablePath(server);
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    return await _installManager.getStartupArgs(server);
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    final baseEnv = await _installManager.getEnvironmentVariables(server);
    return {...Platform.environment, ...baseEnv};
  }

  @override
  Future<String?> getWorkingDirectory(McpServer server) async {
    // 根据文档：对于NPX服务器，使用Node.js运行时目录作为工作目录
    if (server.workingDirectory != null) {
      return server.workingDirectory;
    }
    
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeBasePath = path.dirname(path.dirname(nodeExe)); // 上两级目录
      print('   📍 Using Node.js runtime directory as working directory: $nodeBasePath');
      return nodeBasePath;
    } catch (e) {
      print('   ⚠️ Warning: Failed to get Node.js runtime directory, using default: $e');
      return Platform.environment['HOME'] ?? 
             Platform.environment['USERPROFILE'] ?? 
             Directory.current.path;
    }
  }

  @override
  Future<void> preProcess(McpServer server) async {
    print('   🔧 NPX pre-process: Platform-specific setup...');
    
    if (Platform.isWindows) {
      // Windows平台：确保本地包安装
      // 根据文档：需要确保包在本地工作目录也安装了
      final packageName = _extractPackageName(server);
      if (packageName != null) {
        await _ensureLocalPackageInstalled(server, packageName);
      }
    } else {
      // macOS/Linux平台：不需要特殊预处理
      // 根据文档：使用spawn方式，通过软链接执行
      print('   ✅ macOS/Linux: No special preprocessing needed');
    }
  }

  /// 提取包名（Windows预处理需要）
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
    
    // 如果从args中找不到，使用installSource
    return server.installSource;
  }

  /// 确保本地包安装（Windows特有）
  Future<void> _ensureLocalPackageInstalled(McpServer server, String packageName) async {
    try {
      final workingDir = await getWorkingDirectory(server);
      if (workingDir == null) {
        print('   ⚠️ Cannot get working directory for local package installation');
        return;
      }
      
      // 检查本地包是否已安装
      final localPackageDir = path.join(workingDir, 'node_modules', packageName);
      if (await Directory(localPackageDir).exists()) {
        print('   ✅ Local package already installed: $packageName');
        return;
      }
      
      print('   📦 Installing local package: $packageName');
      
      // 创建package.json（如果不存在）
      final packageJsonFile = File(path.join(workingDir, 'package.json'));
      if (!await packageJsonFile.exists()) {
        final packageJsonContent = {
          'name': 'mcp-local-workspace',
          'version': '1.0.0',
          'description': 'Local workspace for MCP packages',
          'private': true,
          'dependencies': {}
        };
        await packageJsonFile.writeAsString(jsonEncode(packageJsonContent));
        print('   📄 Created package.json');
      }
      
      // 安装包和依赖
      final npmExe = await _runtimeManager.getNpmExecutable();
      final installArgs = ['install', '--save', packageName, '@modelcontextprotocol/sdk'];
      
      print('   🔧 Running: $npmExe ${installArgs.join(' ')}');
      
      final result = await Process.run(
        npmExe,
        installArgs,
        workingDirectory: workingDir,
        environment: {
          'NPM_CONFIG_REGISTRY': 'https://registry.npm.taobao.org/',
          'NPM_CONFIG_CACHE': path.join(workingDir, '.npm'),
        },
      );
      
      if (result.exitCode == 0) {
        print('   ✅ Local package installed successfully');
      } else {
        print('   ⚠️ Local package installation warning: ${result.stderr}');
      }
      
    } catch (e) {
      print('   ⚠️ Error ensuring local package installation: $e');
    }
  }

  @override
  Future<void> postProcess(McpServer server, Process process) async {
    print('   ✅ NPX post-process: Process monitoring setup');
  }
} 