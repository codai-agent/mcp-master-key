import 'dart:async';
import 'dart:io';
import '../../core/models/mcp_server.dart';
import '../managers/install_managers/install_manager_interface.dart';
import '../managers/install_managers/uvx_install_manager.dart';
import '../managers/install_managers/npx_install_manager.dart';
import '../managers/install_managers/smithery_install_manager.dart';
import '../managers/install_managers/local_python_install_manager.dart';
import '../managers/install_managers/local_jar_install_manager.dart';
import '../managers/install_managers/local_executable_install_manager.dart';
import '../managers/install_managers/local_node_install_manager.dart';

/// 安装服务 - 统一管理所有类型的安装策略
class InstallService {
  static InstallService? _instance;
  final Map<McpInstallType, InstallManagerInterface> _installManagers = {};

  InstallService._internal() {
    _initializeManagers();
  }

  static InstallService get instance {
    _instance ??= InstallService._internal();
    return _instance!;
  }

  /// 初始化各种安装管理器
  void _initializeManagers() {
    _installManagers[McpInstallType.uvx] = UvxInstallManager();
    _installManagers[McpInstallType.npx] = NpxInstallManager();
    _installManagers[McpInstallType.smithery] = SmitheryInstallManager();
    _installManagers[McpInstallType.localPython] = LocalPythonInstallManager();
    _installManagers[McpInstallType.localJar] = LocalJarInstallManager();
    _installManagers[McpInstallType.localExecutable] = LocalExecutableInstallManager();
    _installManagers[McpInstallType.localNode] = LocalNodeInstallManager();
  }

  /// 安装服务器
  Future<InstallResult> installServer(McpServer server) async {
    print('📦 Installing server: ${server.name} (type: ${server.installType.name})');
    
    final manager = _installManagers[server.installType];
    if (manager == null) {
      return InstallResult(
        success: false,
        installType: server.installType,
        errorMessage: 'Unsupported install type: ${server.installType.name}',
      );
    }

    try {
      return await manager.install(server);
    } catch (e) {
      print('❌ Installation failed for ${server.name}: $e');
      return InstallResult(
        success: false,
        installType: server.installType,
        errorMessage: 'Installation failed: $e',
      );
    }
  }

  /// 可取消安装服务器
  Future<InstallResult> installServerCancellable(
    McpServer server, {
    Function(Process)? onProcessStarted,
  }) async {
    print('📦 Installing server (cancellable): ${server.name} (type: ${server.installType.name})');
    
    final manager = _installManagers[server.installType];
    if (manager == null) {
      return InstallResult(
        success: false,
        installType: server.installType,
        errorMessage: 'Unsupported install type: ${server.installType.name}',
      );
    }

    try {
      return await manager.installCancellable(server, onProcessStarted: onProcessStarted);
    } catch (e) {
      print('❌ Cancellable installation failed for ${server.name}: $e');
      return InstallResult(
        success: false,
        installType: server.installType,
        errorMessage: 'Installation failed: $e',
      );
    }
  }

  /// 验证服务器是否已安装
  Future<bool> isServerInstalled(McpServer server) async {
    final manager = _installManagers[server.installType];
    if (manager == null) {
      return false;
    }

    try {
      return await manager.isInstalled(server);
    } catch (e) {
      print('❌ Error checking installation status for ${server.name}: $e');
      return false;
    }
  }

  /// 卸载服务器
  Future<bool> uninstallServer(McpServer server) async {
    final manager = _installManagers[server.installType];
    if (manager == null) {
      return false;
    }

    try {
      return await manager.uninstall(server);
    } catch (e) {
      print('❌ Uninstallation failed for ${server.name}: $e');
      return false;
    }
  }

  /// 获取支持的安装类型
  List<McpInstallType> getSupportedInstallTypes() {
    return _installManagers.keys.toList();
  }

  /// 注册新的安装管理器（用于扩展）
  void registerInstallManager(McpInstallType type, InstallManagerInterface manager) {
    _installManagers[type] = manager;
    print('✅ Registered install manager for type: ${type.name}');
  }
}

/// 安装结果
class InstallResult {
  final bool success;
  final McpInstallType installType;
  final String? output;
  final String? errorMessage;
  final String? installPath;
  final Map<String, dynamic>? metadata;

  InstallResult({
    required this.success,
    required this.installType,
    this.output,
    this.errorMessage,
    this.installPath,
    this.metadata,
  });

  @override
  String toString() {
    return 'InstallResult(success: $success, installType: $installType, error: $errorMessage)';
  }
}
