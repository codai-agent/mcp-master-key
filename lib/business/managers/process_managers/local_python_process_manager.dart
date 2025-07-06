import 'dart:io';
import '../../../core/models/mcp_server.dart';
import '../install_managers/local_python_install_manager.dart';
import 'process_manager_interface.dart';

/// 本地Python进程管理器
class LocalPythonProcessManager implements ProcessManagerInterface {
  final LocalPythonInstallManager _installManager = LocalPythonInstallManager();

  @override
  McpInstallType get installType => McpInstallType.localPython;

  @override
  String get name => 'Local Python Process Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<Process> startProcess(McpServer server) async {
    // TODO: 实现本地Python进程启动逻辑
    throw UnimplementedError('Local Python process management not yet implemented');
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
    return server.workingDirectory ?? Directory.current.path;
  }

  @override
  Future<void> preProcess(McpServer server) async {
    print('   🚧 Local Python pre-process: TODO');
  }

  @override
  Future<void> postProcess(McpServer server, Process process) async {
    print('   🚧 Local Python post-process: TODO');
  }
} 