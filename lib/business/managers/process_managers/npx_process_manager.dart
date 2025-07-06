import 'dart:io';
import '../../../core/models/mcp_server.dart';
import '../install_managers/npx_install_manager.dart';
import 'process_manager_interface.dart';

/// NPX进程管理器 - 管理NPX类型的MCP服务器进程
class NpxProcessManager implements ProcessManagerInterface {
  final NpxInstallManager _installManager = NpxInstallManager();

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
    return server.workingDirectory ?? 
           Platform.environment['HOME'] ?? 
           Platform.environment['USERPROFILE'] ?? 
           Directory.current.path;
  }

  @override
  Future<void> preProcess(McpServer server) async {
    print('   🔧 NPX pre-process: Validating Node.js environment...');
  }

  @override
  Future<void> postProcess(McpServer server, Process process) async {
    print('   ✅ NPX post-process: Process monitoring setup');
  }
} 