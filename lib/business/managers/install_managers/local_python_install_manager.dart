import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';
import 'uvx_install_manager.dart'; // 新增导入

/// Python使用场景
enum PythonScenarioType {
  uvRunLocal,        // uv run /a/b/xxx.py
  uvRunModule,    //uv run xxxx
  pythonScript, // python /a/b/xxx.py
  pythonModule, // python -m xxx
}

/// Python场景信息
class PythonScenario {
  final PythonScenarioType type;
  final String? scriptPath;
  final String? moduleName;
  
  PythonScenario({
    required this.type,
    this.scriptPath,
    this.moduleName,
  });
  
  @override
  String toString() {
    return 'PythonScenario(type: $type, scriptPath: $scriptPath, moduleName: $moduleName)';
  }
}

/// 本地Python包安装管理器 - 管理本地路径的Python包
class LocalPythonInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;
  final UvxInstallManager _uvxInstallManager = UvxInstallManager(); // 新增

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

      final pythonScenario = _identifyPythonScenario(server);
      print('   🔍 Identified Python scenario: ${pythonScenario.type}');
      
      switch (pythonScenario.type) {
        case PythonScenarioType.uvRunLocal:
          return await _installUvRunScenario(server, pythonScenario);
        case PythonScenarioType.uvRunModule:
          return await _uvxInstallManager.install(server);
        case PythonScenarioType.pythonScript:
          return await _installPythonScriptScenario(server, pythonScenario);
        case PythonScenarioType.pythonModule:
          return await _installPythonModuleScenario(server, pythonScenario);
      }
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
      final pythonScenario = _identifyPythonScenario(server);
      
      switch (pythonScenario.type) {
        case PythonScenarioType.uvRunLocal:
        case PythonScenarioType.pythonScript:
          // 检查Python脚本文件是否存在
          if (pythonScenario.scriptPath != null) {
            final exists = await File(pythonScenario.scriptPath!).exists();
            print('   🔍 Python script exists: $exists (${pythonScenario.scriptPath})');
            return exists;
          }
          return false;
          
        case PythonScenarioType.pythonModule:
          // 检查Python模块是否已安装
          if (pythonScenario.moduleName != null) {
            return await _isModuleInstalled(pythonScenario.moduleName!);
          }
          return false;
        case PythonScenarioType.uvRunModule:
          return await _uvxInstallManager.isInstalled(server);
      }
    } catch (e) {
      print('❌ Error checking local Python installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      final pythonScenario = _identifyPythonScenario(server);
      print('   🗑️ Uninstalling Python scenario: ${pythonScenario.type}');
      
      switch (pythonScenario.type) {
        case PythonScenarioType.uvRunLocal:
          return await _uninstallUvRunScenario(server, pythonScenario);
        case PythonScenarioType.pythonScript:
          return await _uninstallPythonScriptScenario(server, pythonScenario);
        case PythonScenarioType.pythonModule:
          return await _uninstallPythonModuleScenario(server, pythonScenario);
        case PythonScenarioType.uvRunModule:
          //TODO //huqb
          return await _uvxInstallManager.uninstall(server);//_uninstallPythonModuleScenario(server, pythonScenario);
      }
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

    final pythonScenario = _identifyPythonScenario(server);
    
    // 验证不同场景的配置
    switch (pythonScenario.type) {
      case PythonScenarioType.uvRunLocal:
        // 检查uv是否可用，脚本路径是否有效
        try {
          await _runtimeManager.getUvExecutable();
          return pythonScenario.scriptPath != null && pythonScenario.scriptPath!.isNotEmpty;
        } catch (e) {
          return false;
        }
        
      case PythonScenarioType.pythonScript:
        // 检查Python是否可用，脚本路径是否有效
        try {
          await _runtimeManager.getPythonExecutable();
          return pythonScenario.scriptPath != null && pythonScenario.scriptPath!.isNotEmpty;
        } catch (e) {
          return false;
        }
        
      case PythonScenarioType.pythonModule:
        // 检查Python是否可用，模块名是否有效
        try {
          await _runtimeManager.getPythonExecutable();
          return pythonScenario.moduleName != null && pythonScenario.moduleName!.isNotEmpty;
        } catch (e) {
          return false;
        }
      case PythonScenarioType.uvRunModule:
        return true;
          //return await _uvxInstallManager.uninstall(server);
    }
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    final pythonScenario = _identifyPythonScenario(server);
    
    switch (pythonScenario.type) {
      case PythonScenarioType.uvRunLocal:
      case PythonScenarioType.pythonScript:
        if (pythonScenario.scriptPath != null) {
          return path.dirname(pythonScenario.scriptPath!);
        }
        return null;
        
      case PythonScenarioType.pythonModule:
        // 对于模块，返回系统Python包安装路径
        try {
          final pythonPath = await _runtimeManager.getPythonExecutable();
          final sitePackagesPath = await _getPythonSitePackagesPath(pythonPath);
          return sitePackagesPath;
        } catch (e) {
          return null;
        }
      case PythonScenarioType.uvRunModule:
        return await _uvxInstallManager.getInstallPath(server);
    }
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    try {
      final pythonScenario = _identifyPythonScenario(server);
      
      switch (pythonScenario.type) {
        case PythonScenarioType.uvRunLocal:
          // uv run 场景使用Python解释器执行
          return await _runtimeManager.getPythonExecutable();
          
        case PythonScenarioType.pythonScript:
          return await _runtimeManager.getPythonExecutable();
        case PythonScenarioType.pythonModule:
          // python -m xxx 这种情况优先查找可执行文件，找不到则使用python
          if (pythonScenario.moduleName != null) {
            final executablePath = await _findPythonModuleExecutable(pythonScenario.moduleName!);
            if (executablePath != null) {
              print('   🚀 Found Python module executable: $executablePath');
              return executablePath;
            }
          }
          print('   🐍 Fallback to Python executable for module execution');
          return await _runtimeManager.getPythonExecutable();

        case PythonScenarioType.uvRunModule:
          return await _uvxInstallManager.getExecutablePath(server);
      }
    } catch (e) {
      print('❌ Error getting Python executable path: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    try {
      final pythonScenario = _identifyPythonScenario(server);
      
      switch (pythonScenario.type) {
        case PythonScenarioType.uvRunLocal:
          // uv run /a/b/xxx.py -> python /a/b/xxx.py
          if (pythonScenario.scriptPath != null) {
            final args = [pythonScenario.scriptPath!];
            // 添加其他参数（跳过 uv, run 和脚本路径）
            final otherArgs = _extractOtherArgs(server.args, ['uv', 'run', pythonScenario.scriptPath!]);
            args.addAll(otherArgs);
            return args;
          }
          return server.args;
          
        case PythonScenarioType.pythonScript:
          // python /a/b/xxx.py -> python /a/b/xxx.py (直接返回)
          return server.args;
          
        case PythonScenarioType.pythonModule:
          // python -m xxx -> 如果有可执行文件则去掉-m和包名，否则保持原样
          if (pythonScenario.moduleName != null) {
            final executablePath = await _findPythonModuleExecutable(pythonScenario.moduleName!);
            if (executablePath != null) {
              // 找到可执行文件，去掉-m和包名，保留其他参数
              final otherArgs = _extractOtherArgs(server.args, ['-m', pythonScenario.moduleName!]);
              print('   🚀 Using Python module executable args: ${otherArgs.join(' ')}');
              return otherArgs;
            }
          }
          // 没找到可执行文件，保持原样使用python -m xxx
          return server.args;
        case PythonScenarioType.uvRunModule:
          return await _uvxInstallManager.getStartupArgs(server);
      }
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      final pythonScenario = _identifyPythonScenario(server);
      final envVars = <String, String>{...server.env};

      // 设置PYTHONPATH包含脚本目录
      if (pythonScenario.scriptPath != null) {
        final scriptDir = path.dirname(pythonScenario.scriptPath!);
        final existingPythonPath = envVars['PYTHONPATH'] ?? '';
        if (existingPythonPath.isNotEmpty) {
          envVars['PYTHONPATH'] = '$scriptDir${Platform.pathSeparator}$existingPythonPath';
        } else {
          envVars['PYTHONPATH'] = scriptDir;
        }
        print('   🐍 Set PYTHONPATH: ${envVars['PYTHONPATH']}');
      }

      // 为uv相关操作添加UV环境变量
      if (pythonScenario.type == PythonScenarioType.uvRunLocal) {
        await _addUvEnvironmentVariables(envVars);
      }

      if (pythonScenario.type == PythonScenarioType.uvRunModule) {
        final uvxEnvVars = await _uvxInstallManager.getEnvironmentVariables(server);
        envVars.addAll(uvxEnvVars);
      }

      return envVars;
    } catch (e) {
      print('❌ Error building environment variables: $e');
      return server.env;
    }
  }

  @override
  Future<InstallResult> installCancellable(McpServer server, {Function(Process p1)? onProcessStarted}) {
    // 对于本地Python，通常安装过程很快，不需要特殊的取消逻辑
    return install(server);
  }

  // 私有方法

  /// 识别Python使用场景
  PythonScenario _identifyPythonScenario(McpServer server) {
    print('   🔍 Analyzing server config to identify Python scenario');
    print('   - Command: ${server.command}');
    print('   - Args: ${server.args}');
    
    // 场景一二: uv run /a/b/xxx.py or uv run xxxx
    if (server.command == 'uv' && server.args.isNotEmpty && server.args[0] == 'run') {
      if (server.args.length >= 2) {
        final scriptPath = server.args[1];
        if (scriptPath.endsWith('.py')) {
          print('   ✅ Identified as UV run scenario: $scriptPath');
          return PythonScenario(
            type: PythonScenarioType.uvRunLocal,
            scriptPath: scriptPath,
          );
        } else {
          print('   ✅ Identified as UV run scenario: $scriptPath');
          return PythonScenario(
            type: PythonScenarioType.uvRunModule,
            scriptPath: scriptPath,
          );
        }
      }
    }
    
    // 场景三: python /a/b/xxx.py
    if ((server.command.endsWith('python') || server.command.endsWith('python3')) && server.args.isNotEmpty) {
      final firstArg = server.args[0];
      if (firstArg.endsWith('.py') && (firstArg.contains('/') || firstArg.contains('\\'))) {
        print('   ✅ Identified as Python script scenario: $firstArg');
        return PythonScenario(
          type: PythonScenarioType.pythonScript,
          scriptPath: firstArg,
        );
      }
    }
    
    // 场景四: python -m xxx
    if ((server.command.endsWith('python') || server.command.endsWith('python3')) &&
        server.args.length >= 2 && server.args[0] == '-m') {
      final moduleName = server.args[1];
      print('   ✅ Identified as Python module scenario: $moduleName');
      return PythonScenario(
        type: PythonScenarioType.pythonModule,
        moduleName: moduleName,
      );
    }
    
    // 默认场景，当作Python脚本处理
    print('   ⚠️ Could not identify specific scenario, defaulting to Python script');
    return PythonScenario(
      type: PythonScenarioType.pythonScript,
      scriptPath: server.args.isNotEmpty ? server.args[0] : null,
    );
  }

  /// 安装 UV run 场景
  Future<InstallResult> _installUvRunScenario(McpServer server, PythonScenario scenario) async {
    if (scenario.scriptPath == null) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'UV run scenario requires a valid script path',
      );
    }

    final scriptPath = scenario.scriptPath!;
    final scriptDir = path.dirname(scriptPath);
    
    print('   📁 Script directory: $scriptDir');
    
    // 检查脚本文件是否存在
    if (!await File(scriptPath).exists()) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Script file does not exist: $scriptPath',
      );
    }
    
    try {
      final uvPath = await _runtimeManager.getUvExecutable();
      
      // 检查是否有 requirements.txt
      final requirementsFile = File(path.join(scriptDir, 'requirements.txt'));
      // 检查是否有 pyproject.toml
      final pyprojectFile = File(path.join(scriptDir, 'pyproject.toml'));
      final setupFile = File(path.join(scriptDir,'setup.py'));

      // 获取镜像源配置
        final pythonMirrorUrl = await _configService.getPythonMirrorUrl();

      if (await requirementsFile.exists()) {
        print('   📋 Found requirements.txt, installing dependencies with uv pip install');
        
        final envVars = <String, String>{};
        await _addUvEnvironmentVariables(envVars);
        
        final result = await Process.run(
          uvPath,
          ['pip', 'install','--index-url', pythonMirrorUrl, '-r', 'requirements.txt'],
          workingDirectory: scriptDir,
          environment: envVars,
        );
        
        if (result.exitCode != 0) {
          print('   ❌ Failed to install requirements.txt: ${result.stderr}');
          return InstallResult(
            success: false,
            installType: installType,
            errorMessage: 'Failed to install requirements.txt: ${result.stderr}',
          );
        }
        
        print('   ✅ Successfully installed requirements.txt');
      } else if (await pyprojectFile.exists() || await setupFile.exists()) {
        print('   📋 Found pyproject.toml/setup.py, installing with uv pip install -e .');
        
        final envVars = <String, String>{};
        await _addUvEnvironmentVariables(envVars);
        
        final result = await Process.run(
          uvPath,
          ['pip', 'install', '--index-url', pythonMirrorUrl, '-e', '.'],
          workingDirectory: scriptDir,
          environment: envVars,
        );
        
        if (result.exitCode != 0) {
          print('   ❌ Failed to install pyproject.toml: ${result.stderr}');
          return InstallResult(
            success: false,
            installType: installType,
            errorMessage: 'Failed to install pyproject.toml: ${result.stderr}',
          );
        }
        
        print('   ✅ Successfully installed pyproject.toml');
      }
      
      return InstallResult(
        success: true,
        installType: installType,
        installPath: scriptDir,
        metadata: {
          'scriptPath': scriptPath,
          'installMethod': 'uv run dependencies',
        },
      );
      
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'UV run installation failed: $e',
      );
    }
  }

  /// 安装 Python 脚本场景
  Future<InstallResult> _installPythonScriptScenario(McpServer server, PythonScenario scenario) async {
    if (scenario.scriptPath == null) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Python script scenario requires a valid script path',
      );
    }

    final scriptPath = scenario.scriptPath!;
    final scriptDir = path.dirname(scriptPath);
    
    print('   📁 Script directory: $scriptDir');
    
    // 检查脚本文件是否存在
    if (!await File(scriptPath).exists()) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Script file does not exist: $scriptPath',
      );
    }
    
    try {
      final pythonPath = await _runtimeManager.getPythonExecutable();
      
      // 检查是否有 requirements.txt
      final requirementsFile = File(path.join(scriptDir, 'requirements.txt'));
      // 检查是否有 pyproject.toml
      final pyprojectFile = File(path.join(scriptDir, 'pyproject.toml'));
      final setupFile = File(path.join(scriptDir,'setup.py'));

      if (await requirementsFile.exists()) {
        print('   📋 Found requirements.txt, installing dependencies with pip');
        
        // 获取镜像源配置和环境变量
        final pythonMirrorUrl = await _configService.getPythonMirrorUrl();
        final envVars = await getEnvironmentVariables(server);
        
        final result = await Process.run(
          pythonPath,
          ['-m', 'pip', 'install', '-i', pythonMirrorUrl, '-r', 'requirements.txt'],
          workingDirectory: scriptDir,
          environment: envVars,
        );
        
        if (result.exitCode != 0) {
          print('   ❌ Failed to install requirements.txt: ${result.stderr}');
          return InstallResult(
            success: false,
            installType: installType,
            errorMessage: 'Failed to install requirements.txt: ${result.stderr}',
          );
        }
        
        print('   ✅ Successfully installed requirements.txt');
      } else if (await pyprojectFile.exists() || await setupFile.exists()) {
        print('   📋 Found pyproject.toml/setup.py, installing with pip install -e .');
        
        // 获取镜像源配置和环境变量
        final pythonMirrorUrl = await _configService.getPythonMirrorUrl();
        final envVars = await getEnvironmentVariables(server);
        
        final result = await Process.run(
          pythonPath,
          ['-m', 'pip', 'install', '-i', pythonMirrorUrl, '-e', '.'],
          workingDirectory: scriptDir,
          environment: envVars,
        );
        
        if (result.exitCode != 0) {
          print('   ❌ Failed to install pyproject.toml: ${result.stderr}');
          return InstallResult(
            success: false,
            installType: installType,
            errorMessage: 'Failed to install pyproject.toml: ${result.stderr}',
          );
        }
        
        print('   ✅ Successfully installed pyproject.toml');
      }
      
      return InstallResult(
        success: true,
        installType: installType,
        installPath: scriptDir,
        metadata: {
          'scriptPath': scriptPath,
          'installMethod': 'python script dependencies',
        },
      );
      
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Python script installation failed: $e',
      );
    }
  }

  /// 安装 Python 模块场景
  Future<InstallResult> _installPythonModuleScenario(McpServer server, PythonScenario scenario) async {
    if (scenario.moduleName == null) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Python module scenario requires a valid module name',
      );
    }

    final moduleName = scenario.moduleName!;
    final executablePath = await _findPythonModuleExecutable(moduleName);
    if (executablePath != null) {
      //已经安装过了：
      return InstallResult(
        success: true,
        installType: installType,
        output: 'Package already installed',
        installPath: executablePath,
        metadata: {
          'packageName': moduleName,
          'installMethod': 'python -m (already installed)',
        },
      );
    }
    
    try {
      final pythonPath = await _runtimeManager.getPythonExecutable();
      
      print('   📦 Installing Python module: $moduleName');
      
      // 获取镜像源配置和环境变量
      final pythonMirrorUrl = await _configService.getPythonMirrorUrl();
      final envVars = await getEnvironmentVariables(server);
      
      final result = await Process.run(
        pythonPath,
        ['-m', 'pip', 'install', '-i', pythonMirrorUrl, moduleName],
        environment: envVars,
      );
      
      if (result.exitCode != 0) {
        print('   ❌ Failed to install module: ${result.stderr}');
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Failed to install module $moduleName: ${result.stderr}',
        );
      }
      
      print('   ✅ Successfully installed module: $moduleName');
      
      return InstallResult(
        success: true,
        installType: installType,
        installPath: await _getPythonSitePackagesPath(pythonPath),
        metadata: {
          'moduleName': moduleName,
          'installMethod': 'python -m pip install',
        },
      );
      
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Python module installation failed: $e',
      );
    }
  }

  /// 卸载 UV run 场景
  Future<bool> _uninstallUvRunScenario(McpServer server, PythonScenario scenario) async {
    // UV run 场景的卸载主要是清理依赖，不删除脚本文件
    print('   🗑️ UV run scenario: cleanup completed (script files preserved)');
    return true;
  }

  /// 卸载 Python 脚本场景
  Future<bool> _uninstallPythonScriptScenario(McpServer server, PythonScenario scenario) async {
    // Python 脚本场景的卸载主要是清理依赖，不删除脚本文件
    print('   🗑️ Python script scenario: cleanup completed (script files preserved)');
    return true;
  }

  /// 卸载 Python 模块场景
  Future<bool> _uninstallPythonModuleScenario(McpServer server, PythonScenario scenario) async {
    if (scenario.moduleName == null) return false;
    
    try {
      final pythonPath = await _runtimeManager.getPythonExecutable();
      final moduleName = scenario.moduleName!;
      
      print('   🗑️ Uninstalling Python module: $moduleName');
      
      final result = await Process.run(
        pythonPath,
        ['-m', 'pip', 'uninstall', '-y', moduleName],
      );
      
      if (result.exitCode != 0) {
        print('   ⚠️ Warning: Failed to uninstall module: ${result.stderr}');
        return false;
      }
      
      print('   ✅ Successfully uninstalled module: $moduleName');
      return true;
      
    } catch (e) {
      print('   ❌ Error uninstalling module: $e');
      return false;
    }
  }

  /// 检查模块是否已安装
  Future<bool> _isModuleInstalled(String moduleName) async {
    try {
      final pythonPath = await _runtimeManager.getPythonExecutable();
      
      final result = await Process.run(
        pythonPath,
        ['-c', 'import $moduleName; print("installed")'],
      );
      
      final isInstalled = result.exitCode == 0;
      print('   🔍 Module $moduleName installed: $isInstalled');
      return isInstalled;
      
    } catch (e) {
      print('   ❌ Error checking module installation: $e');
      return false;
    }
  }

  /// 获取Python site-packages路径
  Future<String?> _getPythonSitePackagesPath(String pythonPath) async {
    try {
      final result = await Process.run(
        pythonPath,
        ['-c', 'import site; print(site.getsitepackages()[0])'],
      );
      
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
      
      return null;
    } catch (e) {
      print('   ❌ Error getting site-packages path: $e');
      return null;
    }
  }

  /// 添加UV环境变量
  Future<void> _addUvEnvironmentVariables(Map<String, String> envVars) async {
    try {
      final pythonPath = await _runtimeManager.getPythonExecutable();
      final pythonMirrorUrl = await _configService.getPythonMirrorUrl();
      final timeoutSeconds = await _configService.getDownloadTimeoutSeconds();
      final concurrentDownloads = await _configService.getConcurrentDownloads();
      
      // 从path_constants中获取McpHub基础路径
      final mcpHubBasePath = path.join(
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '',
        '.mcphub'
      );
      
      envVars.addAll({
        'UV_CACHE_DIR': '$mcpHubBasePath/cache/uv',
        'UV_DATA_DIR': '$mcpHubBasePath/data/uv',
        'UV_PYTHON': pythonPath,
        'UV_PYTHON_PREFERENCE': 'only-system',
        'UV_INDEX_URL': pythonMirrorUrl,
        'UV_HTTP_TIMEOUT': '$timeoutSeconds',
        'UV_CONCURRENT_DOWNLOADS': '$concurrentDownloads',
        'UV_HTTP_RETRIES': '3',
      });
      
      print('   🔧 Added UV environment variables');
    } catch (e) {
      print('   ⚠️ Warning: Failed to add UV environment variables: $e');
    }
  }

  /// 提取其他参数（排除指定的参数）
  List<String> _extractOtherArgs(List<String> args, List<String> toExclude) {
    final result = <String>[];
    
    for (final arg in args) {
      if (!toExclude.contains(arg)) {
        result.add(arg);
      }
    }
    
    return result;
  }

  /// 查找Python模块的可执行文件
  /// 支持跨平台：Windows (.exe), macOS/Linux (无扩展名)
  Future<String?> _findPythonModuleExecutable(String moduleName) async {
    try {
      // 获取Python安装路径
      final pythonPath = await _runtimeManager.getPythonExecutable();
      final pythonDir = path.dirname(pythonPath);
      
      // 候选的可执行文件名
      final candidates = <String>[];
      
      // 常见的命名模式
      final baseNames = [
        moduleName,
        moduleName.replaceAll('_', '-'), // mcp_server_git -> mcp-server-git
        moduleName.replaceAll('-', '_'), // mcp-server-git -> mcp_server_git
      ];
      
      for (final baseName in baseNames) {
        if (Platform.isWindows) {
          // Windows: .exe 扩展名
          candidates.addAll([
            '$baseName.exe',
            '$baseName.cmd',
            '$baseName.bat',
          ]);
        } else {
          // macOS/Linux: 无扩展名
          candidates.add(baseName);
        }
      }
      
      // 可能的搜索路径
      final searchPaths = <String>[
        // Python bin目录（主要路径）
        path.join(pythonDir),
        // Scripts目录（Windows）
        if (Platform.isWindows) path.join(pythonDir, 'Scripts'),
        // 相对路径的bin目录
        path.join(pythonDir, '..', 'bin'),
        // 用户级别的bin目录
        if (!Platform.isWindows) path.join(Platform.environment['HOME'] ?? '', '.local', 'bin'),
      ];
      
      print('   🔍 Searching for Python module executable: $moduleName');
      print('   📁 Search paths: ${searchPaths.join(', ')}');
      print('   📝 Candidates: ${candidates.join(', ')}');
      
      // 遍历所有路径和候选文件名
      for (final searchPath in searchPaths) {
        for (final candidate in candidates) {
          final executablePath = path.join(searchPath, candidate);
          
          if (await File(executablePath).exists()) {
            // 验证文件是否可执行（在Unix系统上）
            if (!Platform.isWindows) {
              try {
                final stat = await File(executablePath).stat();
                // 检查是否有执行权限（简单检查）
                if (stat.mode & 0x49 == 0) { // 没有执行权限
                  continue;
                }
              } catch (e) {
                continue;
              }
            }
            
            print('   ✅ Found executable: $executablePath');
            return executablePath;
          }
        }
      }
      
      print('   ❌ No executable found for module: $moduleName');
      return null;
    } catch (e) {
      print('   ❌ Error searching for Python module executable: $e');
      return null;
    }
  }
} 