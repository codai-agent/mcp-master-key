import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';

/// 本地Python包安装管理器 - 管理本地路径的Python包
class LocalPythonInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;

  @override
  McpInstallType get installType => McpInstallType.localPython;

  @override
  String get name => 'Local Python Package Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<InstallResult> install(McpServer server) async {
    print('📦 Installing local Python package for server: ${server.name}');
    
    try {
      // 验证配置
      final isValid = await validateServerConfig(server);
      if (!isValid) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Invalid server configuration for local Python installation',
        );
      }

      final localPath = _extractLocalPath(server);
      if (localPath == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot extract local path from server configuration',
        );
      }

      // TODO: 实现本地Python包安装逻辑
      // 1. 验证路径存在且包含Python代码
      // 2. 检查是否有requirements.txt或pyproject.toml
      // 3. 安装依赖到虚拟环境
      // 4. 设置PYTHONPATH
      
      print('   🚧 Local Python installation not yet implemented');
      print('   📁 Local path: $localPath');
      
      // 检查路径是否存在
      if (!await Directory(localPath).exists() && !await File(localPath).exists()) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Local path does not exist: $localPath',
        );
      }
      
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Local Python installation not yet implemented',
        installPath: localPath,
        metadata: {
          'localPath': localPath,
          'installMethod': 'local python setup (TODO)',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Local Python installation failed: $e',
      );
    }
  }

  @override
  Future<bool> isInstalled(McpServer server) async {
    try {
      // TODO: 检查本地Python包是否已"安装"（依赖是否已安装）
      final localPath = _extractLocalPath(server);
      if (localPath == null) return false;

      // 基本检查：路径存在
      final exists = await Directory(localPath).exists() || await File(localPath).exists();
      print('   🔍 Local Python path exists: $exists ($localPath)');
      
      return exists;
    } catch (e) {
      print('❌ Error checking local Python installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      // TODO: 实现本地Python包"卸载"（清理虚拟环境等）
      final localPath = _extractLocalPath(server);
      if (localPath == null) return false;

      print('   🚧 Local Python uninstall not yet implemented for: $localPath');
      // 对于本地包，通常不需要真正卸载，只需要清理可能的虚拟环境
      return true;
    } catch (e) {
      print('❌ Error uninstalling local Python package: $e');
      return false;
    }
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    // 检查是否为本地Python类型
    if (server.installType != McpInstallType.localPython) {
      return false;
    }

    // 检查是否有有效的本地路径
    final localPath = _extractLocalPath(server);
    if (localPath == null || localPath.isEmpty) {
      return false;
    }

    // 检查Python是否可用
    try {
      final pythonPath = await _runtimeManager.getPythonExecutable();
      return await File(pythonPath).exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    return _extractLocalPath(server);
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    try {
      // 本地Python包使用Python解释器执行
      return await _runtimeManager.getPythonExecutable();
    } catch (e) {
      print('❌ Error getting Python executable path: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    try {
      final localPath = _extractLocalPath(server);
      if (localPath == null) return server.args;

      // TODO: 构建本地Python包的启动参数
      // 可能的情况：
      // 1. 直接执行Python文件：python script.py
      // 2. 执行Python模块：python -m module_name
      // 3. 执行包中的入口点
      
      if (await File(localPath).exists()) {
        // 如果是文件，直接执行
        return [localPath, ...server.args];
      } else if (await Directory(localPath).exists()) {
        // 如果是目录，查找入口点
        final mainPy = path.join(localPath, '__main__.py');
        if (await File(mainPy).exists()) {
          return ['-m', path.basename(localPath), ...server.args];
        }
        
        // 查找setup.py或pyproject.toml中的入口点
        // TODO: 解析setup.py或pyproject.toml获取入口点
        return [localPath, ...server.args];
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
      final localPath = _extractLocalPath(server);
      final envVars = <String, String>{...server.env};

      // 设置PYTHONPATH包含本地包路径
      if (localPath != null) {
        String pythonPath;
        if (await File(localPath).exists()) {
          // 如果是文件，添加其目录到PYTHONPATH
          pythonPath = path.dirname(localPath);
        } else {
          // 如果是目录，直接添加到PYTHONPATH
          pythonPath = localPath;
        }
        
        final existingPythonPath = envVars['PYTHONPATH'] ?? '';
        if (existingPythonPath.isNotEmpty) {
          envVars['PYTHONPATH'] = '$pythonPath${Platform.pathSeparator}$existingPythonPath';
        } else {
          envVars['PYTHONPATH'] = pythonPath;
        }
        
        print('   🐍 Set PYTHONPATH: ${envVars['PYTHONPATH']}');
      }

      // TODO: 如果有虚拟环境，设置相应的环境变量
      
      return envVars;
    } catch (e) {
      print('❌ Error building environment variables: $e');
      return server.env;
    }
  }

  /// 从服务器配置中提取本地路径
  String? _extractLocalPath(McpServer server) {
    // 本地路径通常在command字段中
    if (server.command.isNotEmpty && _isLocalPath(server.command)) {
      return server.command;
    }
    
    // 或者在installSource中
    if (server.installSource != null && _isLocalPath(server.installSource!)) {
      return server.installSource;
    }
    
    // 或者在args中的第一个参数
    if (server.args.isNotEmpty && _isLocalPath(server.args.first)) {
      return server.args.first;
    }
    
    return null;
  }

  /// 检查是否为本地路径
  bool _isLocalPath(String path) {
    return path.contains('/') || path.contains('\\') || 
           path.startsWith('./') || path.startsWith('../') ||
           path.startsWith('~') || path.startsWith('C:') ||
           path.length > 1 && path[1] == ':'; // Windows驱动器路径
  }
} 