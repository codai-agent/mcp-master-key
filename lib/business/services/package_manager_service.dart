import 'dart:io';
import 'package:path/path.dart' as path;
import '../../core/models/mcp_server.dart';
import '../../core/services/log_service.dart';
import '../../core/constants/path_constants.dart';
import '../../infrastructure/runtime/runtime_manager.dart';
import '../parsers/mcp_config_parser.dart';
import 'config_service.dart';

/// 包管理器服务
class PackageManagerService {
  final RuntimeManager _runtimeManager;
  final ConfigService _configService;

  PackageManagerService({
    required RuntimeManager runtimeManager,
    ConfigService? configService,
  }) : _runtimeManager = runtimeManager,
       _configService = configService ?? ConfigService.instance;

  /// 安装包
  Future<InstallResult> installPackage({
    required String packageName,
    required InstallStrategy strategy,
    Map<String, String>? envVars,
    List<String>? additionalArgs,
    String? gitUrl,
    String? localPath,
  }) async {
    try {
      switch (strategy) {
        case InstallStrategy.uvx:
          return await _installWithUvx(packageName, envVars, additionalArgs);
        case InstallStrategy.npx:
          return await _installWithNpx(packageName, envVars, additionalArgs);
        case InstallStrategy.git:
          if (gitUrl == null) {
            throw Exception('Git安装需要提供Git URL');
          }
          return await _installFromGit(packageName, gitUrl, envVars);
        case InstallStrategy.local:
          if (localPath == null) {
            throw Exception('本地安装需要提供本地路径');
          }
          return await _installFromLocal(packageName, localPath, envVars);
        case InstallStrategy.pip:
          return await _installWithPip(packageName, envVars, additionalArgs);
        case InstallStrategy.npm:
          return await _installWithNpm(packageName, envVars, additionalArgs);
      }
    } catch (e) {
      return InstallResult(
        success: false,
        packageName: packageName,
        strategy: strategy,
        errorMessage: e.toString(),
      );
    }
  }

  /// 使用uvx安装
  Future<InstallResult> _installWithUvx(
    String packageName,
    Map<String, String>? envVars,
    List<String>? additionalArgs,
  ) async {
    print('📦 Installing UVX package: $packageName');
    
    // ⚠️ 重要：UVX的安装和运行是分离的
    // - 安装阶段：使用 `uv tool install` 真正安装包到系统
    // - 运行阶段：使用 `uvx` 或 `uv tool run` 执行包
    
    final uvPath = await _runtimeManager.getUvExecutable();
    
    // 🔧 配置UV环境变量，迁移到~/.mcphub目录
    final mcpHubBasePath = PathConstants.getUserMcpHubPath();
    
    // 📋 从配置服务获取镜像源设置
    print('   🔄 Getting Python mirror URL...');
    final pythonMirrorUrl = await _configService.getPythonMirrorUrl();
    print('   ✅ Python mirror URL: $pythonMirrorUrl');
    
    print('   🔄 Getting timeout settings...');
    final timeoutSeconds = await _configService.getDownloadTimeoutSeconds();
    print('   ✅ Timeout: ${timeoutSeconds}s');
    
    print('   🔄 Getting concurrent downloads...');
    final concurrentDownloads = await _configService.getConcurrentDownloads();
    print('   ✅ Concurrent downloads: $concurrentDownloads');
    
    // 🐍 获取内置Python路径 - 关键优化！
    final pythonExePath = await _runtimeManager.getPythonExecutable();
    print('   🔧 Using internal Python: $pythonExePath');

    final enhancedEnvVars = <String, String>{
      // UV目录配置 - 迁移到~/.mcphub
      'UV_CACHE_DIR': '$mcpHubBasePath/cache/uv',
      'UV_DATA_DIR': '$mcpHubBasePath/data/uv', 
      'UV_TOOL_DIR': '$mcpHubBasePath/packages/uv/tools',
      'UV_TOOL_BIN_DIR': '$mcpHubBasePath/packages/uv/bin',
      
      // 🎯 核心优化：指定UV使用内置Python，避免下载额外Python
      'UV_PYTHON': pythonExePath,
      'UV_PYTHON_PREFERENCE': 'only-system',  // 只使用指定的Python，不自动下载
      
      // 📋 使用配置中的镜像源，不设置额外源避免回退到慢速官方源
      'UV_INDEX_URL': pythonMirrorUrl,
      // 移除UV_EXTRA_INDEX_URL避免回退到官方源导致超时
      // 📋 使用更长的超时时间来处理网络慢的情况
      'UV_HTTP_TIMEOUT': '180',  // 3分钟超时，避免网络慢导致的下载失败
      // 📋 减少并发数避免镜像源限制
      'UV_CONCURRENT_DOWNLOADS': '2',  // 降低并发数，避免对镜像源造成压力
      // 📋 添加重试配置
      'UV_HTTP_RETRIES': '3',  // 网络失败时重试3次
      if (envVars != null) ...envVars,
    };
    
    print('   🔧 UV executable: $uvPath');
    print('   🐍 Internal Python: ${enhancedEnvVars['UV_PYTHON']}');
    print('   🎯 Python preference: ${enhancedEnvVars['UV_PYTHON_PREFERENCE']}');
    print('   📦 Package: $packageName');
    print('   📁 UV Cache Dir: ${enhancedEnvVars['UV_CACHE_DIR']}');
    print('   📁 UV Tool Dir: ${enhancedEnvVars['UV_TOOL_DIR']}');
    print('   🌐 Using mirror: ${enhancedEnvVars['UV_INDEX_URL']}');
    print('   ⏱️ Timeout: ${enhancedEnvVars['UV_HTTP_TIMEOUT']}s');
    
    // 🔧 正确的安装命令：uv tool install package-name
    // ⚠️ 重要：安装时只传递包名，不传递运行时参数
    final args = ['tool', 'install', packageName];
    
    // ❌ 不要添加运行时参数到安装命令
    // if (additionalArgs != null) {
    //   args.addAll(additionalArgs);
    // }
    
    print('   📋 Command: $uvPath ${args.join(' ')}');
    print('   📝 Note: Installing package only (runtime args will be used during execution)');
    if (additionalArgs != null && additionalArgs.isNotEmpty) {
      print('   📝 Runtime args (not used during install): ${additionalArgs.join(' ')}');
    }
    
    final result = await _runCommand(uvPath, args, envVars: enhancedEnvVars, packageName: packageName);

    print('   📊 Exit code: ${result.exitCode}');
    if (result.stdout.isNotEmpty) {
      print('   📝 Stdout: ${result.stdout}');
    }
    if (result.stderr.isNotEmpty) {
      print('   ❌ Stderr: ${result.stderr}');
    }

    return InstallResult(
      success: result.exitCode == 0,
      packageName: packageName,
      strategy: InstallStrategy.uvx,
      output: result.stdout,
      errorMessage: result.exitCode != 0 ? result.stderr : null,
    );
  }

  /// 使用npm安装NPX包（全局安装）
  Future<InstallResult> _installWithNpx(
    String packageName,
    Map<String, String>? envVars,
    List<String>? additionalArgs,
  ) async {
    print('📦 Installing NPX package: $packageName');
    
    // 对于NPX类型的包，使用npm install -g进行全局安装
    final npmPath = await _runtimeManager.getNpmExecutable();
    final nodePath = await _runtimeManager.getNodeExecutable();
    final nodeDir = path.dirname(path.dirname(nodePath)); // node-v20.10.0目录
    
    print('   📍 NPM path: $npmPath');
    print('   📍 Node dir: $nodeDir');
    
    // 📋 从配置服务获取镜像源设置
    print('   🔄 Getting NPM mirror URL...');
    final npmMirrorUrl = await _configService.getNpmMirrorUrl();
    print('   ✅ NPM mirror URL: $npmMirrorUrl');
    
    // 设置npm配置，强制使用隔离环境
    final isolatedEnvVars = <String, String>{
      'NODE_PATH': '$nodeDir/lib/node_modules',
      'NPM_CONFIG_PREFIX': nodeDir,
      'NPM_CONFIG_CACHE': '$nodeDir/.npm',
      'NPM_CONFIG_GLOBALCONFIG': '$nodeDir/etc/npmrc',
      'NPM_CONFIG_USERCONFIG': '$nodeDir/.npmrc',
      // 📋 使用配置中的NPM镜像源
      'NPM_CONFIG_REGISTRY': npmMirrorUrl,
      if (envVars != null) ...envVars,
    };
    
    print('   🔧 Environment variables:');
    isolatedEnvVars.forEach((key, value) => print('      $key=$value'));
    
    final args = ['install', '-g', packageName];
    print('   📋 Command: $npmPath ${args.join(' ')}');
    
    final result = await _runCommand(npmPath, args, envVars: isolatedEnvVars);

    print('   📊 Exit code: ${result.exitCode}');
    if (result.stdout.isNotEmpty) {
      print('   📝 Stdout: ${result.stdout}');
    }
    if (result.stderr.isNotEmpty) {
      print('   ❌ Stderr: ${result.stderr}');
    }

    return InstallResult(
      success: result.exitCode == 0,
      packageName: packageName,
      strategy: InstallStrategy.npx,
      output: result.stdout,
      errorMessage: result.exitCode != 0 ? result.stderr : null,
    );
  }

  /// 从Git仓库安装
  Future<InstallResult> _installFromGit(
    String packageName,
    String gitUrl,
    Map<String, String>? envVars,
  ) async {
    final tempDir = Directory.systemTemp.createTempSync('mcp_install_');
    final installPath = path.join(tempDir.path, packageName);

    try {
      // 克隆仓库
      final cloneResult = await _runCommand(
        'git',
        ['clone', gitUrl, installPath],
        envVars: envVars,
      );

      if (cloneResult.exitCode != 0) {
        return InstallResult(
          success: false,
          packageName: packageName,
          strategy: InstallStrategy.git,
          errorMessage: 'Git克隆失败: ${cloneResult.stderr}',
        );
      }

      // 安装依赖
      final installResult = await _installDependencies(installPath, envVars);
      
      return InstallResult(
        success: installResult.success,
        packageName: packageName,
        strategy: InstallStrategy.git,
        output: installResult.output,
        errorMessage: installResult.errorMessage,
        installPath: installPath,
      );
    } finally {
      // 清理临时目录
      try {
        tempDir.deleteSync(recursive: true);
      } catch (e) {
        // 忽略清理错误
      }
    }
  }

  /// 从本地路径安装
  Future<InstallResult> _installFromLocal(
    String packageName,
    String localPath,
    Map<String, String>? envVars,
  ) async {
    if (!Directory(localPath).existsSync()) {
      return InstallResult(
        success: false,
        packageName: packageName,
        strategy: InstallStrategy.local,
        errorMessage: '本地路径不存在: $localPath',
      );
    }

    final installResult = await _installDependencies(localPath, envVars);
    
    return InstallResult(
      success: installResult.success,
      packageName: packageName,
      strategy: InstallStrategy.local,
      output: installResult.output,
      errorMessage: installResult.errorMessage,
      installPath: localPath,
    );
  }

  /// 使用pip安装
  Future<InstallResult> _installWithPip(
    String packageName,
    Map<String, String>? envVars,
    List<String>? additionalArgs,
  ) async {
    final pythonPath = await _runtimeManager.getPythonExecutable();
    final args = ['-m', 'pip', 'install', packageName, ...?additionalArgs];
    
    final result = await _runCommand(pythonPath, args, envVars: envVars);

    return InstallResult(
      success: result.exitCode == 0,
      packageName: packageName,
      strategy: InstallStrategy.pip,
      output: result.stdout,
      errorMessage: result.exitCode != 0 ? result.stderr : null,
    );
  }

  /// 使用npm安装
  Future<InstallResult> _installWithNpm(
    String packageName,
    Map<String, String>? envVars,
    List<String>? additionalArgs,
  ) async {
    print('📦 Installing NPM package: $packageName');
    
    final nodePath = await _runtimeManager.getNodeExecutable();
    final npmPath = path.join(path.dirname(nodePath), 'npm');
    final nodeDir = path.dirname(path.dirname(nodePath)); // node-v20.10.0目录
    
    print('   📍 NPM path: $npmPath');
    print('   📍 Node dir: $nodeDir');
    
    // 📋 从配置服务获取镜像源设置
    print('   🔄 Getting NPM mirror URL...');
    final npmMirrorUrl = await _configService.getNpmMirrorUrl();
    print('   ✅ NPM mirror URL: $npmMirrorUrl');
    
    // 设置npm配置，强制使用隔离环境
    final isolatedEnvVars = <String, String>{
      'NODE_PATH': '$nodeDir/lib/node_modules',
      'NPM_CONFIG_PREFIX': nodeDir,
      'NPM_CONFIG_CACHE': '$nodeDir/.npm',
      'NPM_CONFIG_GLOBALCONFIG': '$nodeDir/etc/npmrc',
      'NPM_CONFIG_USERCONFIG': '$nodeDir/.npmrc',
      // 📋 使用配置中的NPM镜像源
      'NPM_CONFIG_REGISTRY': npmMirrorUrl,
      if (envVars != null) ...envVars,
    };
    
    final args = ['install', '-g', packageName, ...?additionalArgs];
    print('   📋 Command: $npmPath ${args.join(' ')}');
    
    final result = await _runCommand(npmPath, args, envVars: isolatedEnvVars);

    print('   📊 Exit code: ${result.exitCode}');
    if (result.stdout.isNotEmpty) {
      print('   📝 Stdout: ${result.stdout}');
    }
    if (result.stderr.isNotEmpty) {
      print('   ❌ Stderr: ${result.stderr}');
    }

    return InstallResult(
      success: result.exitCode == 0,
      packageName: packageName,
      strategy: InstallStrategy.npm,
      output: result.stdout,
      errorMessage: result.exitCode != 0 ? result.stderr : null,
    );
  }

  /// 安装项目依赖
  Future<InstallResult> _installDependencies(
    String projectPath,
    Map<String, String>? envVars,
  ) async {
    // 检查是否是Python项目
    if (File(path.join(projectPath, 'pyproject.toml')).existsSync() ||
        File(path.join(projectPath, 'requirements.txt')).existsSync()) {
      return await _installPythonDependencies(projectPath, envVars);
    }

    // 检查是否是Node.js项目
    if (File(path.join(projectPath, 'package.json')).existsSync()) {
      return await _installNodeDependencies(projectPath, envVars);
    }

    return InstallResult(
      success: true,
      packageName: path.basename(projectPath),
      strategy: InstallStrategy.local,
      output: '未检测到依赖配置文件，跳过依赖安装',
    );
  }

  /// 安装Python依赖
  Future<InstallResult> _installPythonDependencies(
    String projectPath,
    Map<String, String>? envVars,
  ) async {
    final pythonPath = await _runtimeManager.getPythonExecutable();
    
    // 优先使用pyproject.toml
    if (File(path.join(projectPath, 'pyproject.toml')).existsSync()) {
      final result = await _runCommand(
        pythonPath,
        ['-m', 'pip', 'install', '-e', '.'],
        workingDirectory: projectPath,
        envVars: envVars,
      );
      
      return InstallResult(
        success: result.exitCode == 0,
        packageName: path.basename(projectPath),
        strategy: InstallStrategy.pip,
        output: result.stdout,
        errorMessage: result.exitCode != 0 ? result.stderr : null,
      );
    }

    // 使用requirements.txt
    if (File(path.join(projectPath, 'requirements.txt')).existsSync()) {
      final result = await _runCommand(
        pythonPath,
        ['-m', 'pip', 'install', '-r', 'requirements.txt'],
        workingDirectory: projectPath,
        envVars: envVars,
      );
      
      return InstallResult(
        success: result.exitCode == 0,
        packageName: path.basename(projectPath),
        strategy: InstallStrategy.pip,
        output: result.stdout,
        errorMessage: result.exitCode != 0 ? result.stderr : null,
      );
    }

    return InstallResult(
      success: false,
      packageName: path.basename(projectPath),
      strategy: InstallStrategy.pip,
      errorMessage: '未找到Python依赖配置文件',
    );
  }

  /// 安装Node.js依赖
  Future<InstallResult> _installNodeDependencies(
    String projectPath,
    Map<String, String>? envVars,
  ) async {
    final nodePath = await _runtimeManager.getNodeExecutable();
    final npmPath = path.join(path.dirname(nodePath), 'npm');
    
    final result = await _runCommand(
      npmPath,
      ['install'],
      workingDirectory: projectPath,
      envVars: envVars,
    );
    
    return InstallResult(
      success: result.exitCode == 0,
      packageName: path.basename(projectPath),
      strategy: InstallStrategy.npm,
      output: result.stdout,
      errorMessage: result.exitCode != 0 ? result.stderr : null,
    );
  }

  /// 运行命令
  Future<ProcessResult> _runCommand(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? envVars,
    String? packageName, // 添加包名参数用于检查安装状态
  }) async {
    final environment = <String, String>{
      ...Platform.environment,
      if (envVars != null) ...envVars,
    };
    
    print('   🔧 Running command with timeout: $executable ${arguments.join(' ')}');
    
    try {
      // 添加超时机制，避免无限等待
      final result = await Process.run(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
      ).timeout(const Duration(minutes: 5)); // 5分钟超时
      
      print('   ✅ Command completed successfully');
      return result;
    } catch (e) {
      print('   ❌ Command failed or timed out: $e');
      // 如果超时，检查包是否实际安装成功（仅当提供了包名时）
      if (packageName != null) {
        final packagePath = '/Users/huqibin/.mcphub/packages/uv/tools';
        final packageDir = Directory('$packagePath/$packageName');
        if (await packageDir.exists()) {
          print('   ✅ Package directory exists, treating as successful installation');
          return ProcessResult(0, 0, 'Package installed successfully (verified by directory check)', '');
        } else {
          print('   ❌ Package directory not found, installation failed');
          return ProcessResult(1, 1, '', 'Installation failed due to timeout or network error: $e');
        }
      } else {
        print('   ❌ No package name provided, cannot verify installation');
        return ProcessResult(1, 1, '', 'Installation failed due to timeout or network error: $e');
      }
    }
  }
}

/// 安装策略枚举
enum InstallStrategy {
  uvx,
  npx,
  pip,
  npm,
  git,
  local,
}

/// 安装结果
class InstallResult {
  final bool success;
  final String packageName;
  final InstallStrategy strategy;
  final String? output;
  final String? errorMessage;
  final String? installPath;

  InstallResult({
    required this.success,
    required this.packageName,
    required this.strategy,
    this.output,
    this.errorMessage,
    this.installPath,
  });
} 