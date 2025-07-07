import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';

/// 本地JAR包安装管理器 - 管理本地路径的JAR包
class LocalJarInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;

  @override
  McpInstallType get installType => McpInstallType.localJar;

  @override
  String get name => 'Local JAR Package Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<InstallResult> install(McpServer server) async {
    print('📦 Installing local JAR package for server: ${server.name}');
    
    try {
      // 验证配置
      final isValid = await validateServerConfig(server);
      if (!isValid) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Invalid server configuration for local JAR installation',
        );
      }

      final jarPath = _extractJarPath(server);
      if (jarPath == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot extract JAR path from server configuration',
        );
      }

      // TODO: 实现本地JAR包安装逻辑
      // 1. 验证JAR文件存在且有效
      // 2. 检查Java运行时是否可用
      // 3. 验证JAR文件的Main-Class或可执行性
      
      print('   🚧 Local JAR installation not yet implemented');
      print('   📁 JAR path: $jarPath');
      
      // 检查JAR文件是否存在
      if (!await File(jarPath).exists()) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'JAR file does not exist: $jarPath',
        );
      }
      
      // 检查文件扩展名
      if (!jarPath.toLowerCase().endsWith('.jar')) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'File is not a JAR file: $jarPath',
        );
      }
      
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Local JAR installation not yet implemented',
        installPath: jarPath,
        metadata: {
          'jarPath': jarPath,
          'installMethod': 'local jar setup (TODO)',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Local JAR installation failed: $e',
      );
    }
  }

  @override
  Future<bool> isInstalled(McpServer server) async {
    try {
      final jarPath = _extractJarPath(server);
      if (jarPath == null) return false;

      // 基本检查：JAR文件存在
      final exists = await File(jarPath).exists();
      print('   🔍 Local JAR file exists: $exists ($jarPath)');
      
      return exists;
    } catch (e) {
      print('❌ Error checking local JAR installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      // 对于本地JAR文件，通常不需要卸载
      // 只是停止使用该文件
      final jarPath = _extractJarPath(server);
      print('   ℹ️ Local JAR uninstall (no action needed): $jarPath');
      return true;
    } catch (e) {
      print('❌ Error uninstalling local JAR package: $e');
      return false;
    }
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    // 检查是否为本地JAR类型
    if (server.installType != McpInstallType.localJar) {
      return false;
    }

    // 检查是否有有效的JAR路径
    final jarPath = _extractJarPath(server);
    if (jarPath == null || jarPath.isEmpty) {
      return false;
    }

    // 检查Java是否可用
    try {
      final result = await Process.run('java', ['-version']);
      return result.exitCode == 0;
    } catch (e) {
      print('❌ Java not available: $e');
      return false;
    }
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    return _extractJarPath(server);
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    try {
      // 本地JAR包使用Java执行
      return 'java'; // 假设java在系统PATH中
    } catch (e) {
      print('❌ Error getting Java executable path: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    try {
      final jarPath = _extractJarPath(server);
      if (jarPath == null) return server.args;

      // TODO: 构建JAR包的启动参数
      // 标准格式：java [JVM选项] -jar jarfile [应用参数]
      
      final javaArgs = <String>[];
      
      // 添加JVM选项（如果有）
      // TODO: 从server.config中提取JVM选项
      
      // 添加-jar参数
      javaArgs.addAll(['-jar', jarPath]);
      
      // 添加应用参数
      javaArgs.addAll(server.args);
      
      print('   ☕ Java args: ${javaArgs.join(' ')}');
      return javaArgs;
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      final envVars = <String, String>{...server.env};

      // TODO: 设置Java相关的环境变量
      // 例如：JAVA_HOME, CLASSPATH等
      
      final jarPath = _extractJarPath(server);
      if (jarPath != null) {
        // 添加JAR文件目录到CLASSPATH
        final jarDir = path.dirname(jarPath);
        final existingClasspath = envVars['CLASSPATH'] ?? '';
        if (existingClasspath.isNotEmpty) {
          envVars['CLASSPATH'] = '$jarDir${Platform.pathSeparator}$existingClasspath';
        } else {
          envVars['CLASSPATH'] = jarDir;
        }
        
        print('   ☕ Set CLASSPATH: ${envVars['CLASSPATH']}');
      }
      
      return envVars;
    } catch (e) {
      print('❌ Error building environment variables: $e');
      return server.env;
    }
  }

  /// 从服务器配置中提取JAR路径
  String? _extractJarPath(McpServer server) {
    // JAR路径通常在command字段中
    if (server.command.isNotEmpty && _isJarPath(server.command)) {
      return server.command;
    }
    
    // 或者在installSource中
    if (server.installSource != null && _isJarPath(server.installSource!)) {
      return server.installSource;
    }
    
    // 或者在args中查找.jar文件
    for (final arg in server.args) {
      if (_isJarPath(arg)) {
        return arg;
      }
    }
    
    return null;
  }

  /// 检查是否为JAR路径
  bool _isJarPath(String path) {
    return path.toLowerCase().endsWith('.jar') && 
           (path.contains('/') || path.contains('\\') || 
            path.startsWith('./') || path.startsWith('../') ||
            path.startsWith('~') || path.startsWith('C:') ||
            path.length > 1 && path[1] == ':'); // Windows驱动器路径
  }

  @override
  Future<InstallResult> installCancellable(McpServer server, {Function(Process p1)? onProcessStarted}) {
    // // TODO: implement installCancellable
    // throw UnimplementedError();
    return install(server);
  }
} 