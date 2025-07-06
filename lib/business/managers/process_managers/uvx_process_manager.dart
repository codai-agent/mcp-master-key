import 'dart:io';
import '../../../core/models/mcp_server.dart';
import '../install_managers/uvx_install_manager.dart';
import 'process_manager_interface.dart';

/// UVX进程管理器 - 管理UVX类型的MCP服务器进程
class UvxProcessManager implements ProcessManagerInterface {
  final UvxInstallManager _installManager = UvxInstallManager();

  @override
  McpInstallType get installType => McpInstallType.uvx;

  @override
  String get name => 'UVX Process Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<Process> startProcess(McpServer server) async {
    print('🚀 Starting UVX process for server: ${server.name}');
    
    // 预处理
    await preProcess(server);

    // 获取执行参数
    final executable = await getExecutablePath(server);
    final args = await getStartupArgs(server);
    final environment = await getEnvironmentVariables(server);
    final workingDirectory = await getWorkingDirectory(server);

    if (executable == null) {
      throw Exception('Cannot determine executable path for UVX server');
    }

    print('   🔧 Executable: $executable');
    print('   📋 Args: ${args.join(' ')}');
    print('   📁 Working directory: $workingDirectory');

    // 验证可执行文件
    if (!await File(executable).exists()) {
      // 尝试在系统PATH中查找
      try {
        final whichResult = await Process.run(
          Platform.isWindows ? 'where' : 'which', 
          [executable]
        );
        if (whichResult.exitCode != 0) {
          throw Exception('Executable not found: $executable');
        }
      } catch (e) {
        throw Exception('Executable not found and cannot verify: $executable');
      }
    }

    // 启动进程
    final process = await Process.start(
      executable,
      args,
      workingDirectory: workingDirectory,
      environment: environment,
      mode: ProcessStartMode.normal,
    );

    // 后处理
    await postProcess(server, process);

    print('   ✅ UVX process started (PID: ${process.pid})');
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
    
    // 添加通用进程环境变量
    final processEnv = <String, String>{
      ...Platform.environment,
      ...baseEnv,
    };

    // 确保基本的PATH设置
    if (!processEnv.containsKey('PATH')) {
      processEnv['PATH'] = Platform.environment['PATH'] ?? '';
    }

    return processEnv;
  }

  @override
  Future<String?> getWorkingDirectory(McpServer server) async {
    // 使用服务器配置的工作目录，或者安装路径的父目录
    if (server.workingDirectory != null) {
      return server.workingDirectory;
    }

    final installPath = await _installManager.getInstallPath(server);
    if (installPath != null) {
      final dir = Directory(installPath);
      if (await dir.exists()) {
        return installPath;
      }
    }

    // 默认使用用户主目录
    return Platform.environment['HOME'] ?? 
           Platform.environment['USERPROFILE'] ?? 
           Directory.current.path;
  }

  @override
  Future<void> preProcess(McpServer server) async {
    // UVX特定的预处理
    print('   🔧 UVX pre-process: Validating environment...');
    
    // 确保UV工具目录存在
    final env = await getEnvironmentVariables(server);
    final uvToolDir = env['UV_TOOL_DIR'];
    if (uvToolDir != null) {
      final dir = Directory(uvToolDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        print('   📁 Created UV tool directory: $uvToolDir');
      }
    }
  }

  @override
  Future<void> postProcess(McpServer server, Process process) async {
    // UVX特定的后处理
    print('   ✅ UVX post-process: Process monitoring setup');
    
    // 可以在这里设置特定的日志处理或监控
  }
} 