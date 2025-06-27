import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/models/mcp_server.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/path_constants.dart';
import '../../core/protocols/mcp_client.dart';
import '../../core/protocols/mcp_protocol.dart';
import '../../infrastructure/runtime/runtime_manager.dart';
import '../services/config_service.dart';

/// MCP进程管理器
class McpProcessManager {
  static McpProcessManager? _instance;
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;
  final Map<String, Process> _runningProcesses = {};
  late final String _environmentsBasePath;

  McpProcessManager._internal();

  /// 获取单例实例
  static McpProcessManager get instance {
    _instance ??= McpProcessManager._internal();
    return _instance!;
  }

  /// 初始化管理器（使用用户主目录）
  Future<void> initialize() async {
    _environmentsBasePath = PathConstants.getUserServersPath();
    
    // 确保环境目录存在
    final envDir = Directory(_environmentsBasePath);
    if (!await envDir.exists()) {
      await envDir.create(recursive: true);
    }

    print('🏗️ MCP Process Manager initialized');
    print('   📁 Environments path: $_environmentsBasePath');
  }

  /// 安装MCP服务器
  Future<bool> installServer(McpServer server) async {
    print('📦 Installing MCP server: ${server.name}');
    print('   🔧 Install type: ${server.installType.name}');
    print('   📋 Command: ${server.command} ${server.args.join(' ')}');
    print('   📍 Install source: ${server.installSource}');

    try {
      switch (server.installType) {
        case McpInstallType.npx:
          return await _installNpxServer(server);
        case McpInstallType.uvx:
          return await _installUvxServer(server);
        case McpInstallType.localPath:
          return await _setupLocalPathServer(server);
        case McpInstallType.github:
          return await _installGithubServer(server);
        case McpInstallType.preInstalled:
          return await _verifyPreInstalledServer(server);
      }
    } catch (e) {
      print('❌ Installation failed: $e');
      return false;
    }
  }

  /// 启动MCP服务器
  Future<bool> startServer(McpServer server) async {
    if (_runningProcesses.containsKey(server.id)) {
      print('⚠️ Server ${server.name} is already running (PID: ${_runningProcesses[server.id]?.pid})');
      return true;
    }

    print('🚀 Starting MCP server: ${server.name}');
    print('   📋 Server configuration:');
    print('   - ID: ${server.id}');
    print('   - Install Type: ${server.installType.name}');
    print('   - Original Command: ${server.command}');
    print('   - Original Args: ${server.args.join(' ')}');
    
    try {
          final workingDir = await getServerWorkingDirectory(server);
    final environment = await getServerEnvironment(server);
      final executable = await _getExecutablePath(server);
      final args = await _buildStartArgs(server);

      print('   📍 Working directory: $workingDir');
      print('   🔧 Final executable: $executable');
      print('   📋 Final arguments: ${args.join(' ')}');
      print('   🌍 Environment variables count: ${environment.length}');
      // print('   🌍 PATH environment: ${environment['PATH']?.substring(0, 200) ?? 'Not set'}...');
      
      // 验证可执行文件是否存在
      if (!await File(executable).exists()) {
        print('   ❌ Executable file not found: $executable');
        print('   🔍 Checking if it\'s a system command...');
        
        // 尝试使用which/where命令查找
        final whichCmd = Platform.isWindows ? 'where' : 'which';
        try {
          final whichResult = await Process.run(whichCmd, [executable]);
          if (whichResult.exitCode == 0) {
            print('   ✅ Found executable in system PATH: ${whichResult.stdout.toString().trim()}');
          } else {
            print('   ❌ Executable not found in system PATH either');
            return false;
          }
        } catch (e) {
          print('   ⚠️ Could not verify executable existence: $e');
        }
      } else {
        print('   ✅ Executable file exists: $executable');
      }

      // 验证工作目录是否存在
      if (!await Directory(workingDir).exists()) {
        print('   📁 Creating working directory: $workingDir');
        await Directory(workingDir).create(recursive: true);
      }

      print('   🚀 Starting process...');
      
      // 添加额外的安全检查和异常处理
      // 验证可执行文件路径不包含问题字符
      for (int i = 0; i < executable.length; i++) {
        final charCode = executable.codeUnitAt(i);
        if (charCode > 127) {
          throw Exception('Executable path contains non-ASCII character at position $i: ${executable.substring(i, i+1)}');
        }
      }
      
      // 验证参数不包含问题字符
      for (int argIndex = 0; argIndex < args.length; argIndex++) {
        final arg = args[argIndex];
        for (int i = 0; i < arg.length; i++) {
          final charCode = arg.codeUnitAt(i);
          if (charCode > 127) {
            throw Exception('Argument $argIndex contains non-ASCII character at position $i: ${arg.substring(i, i+1)}');
          }
        }
      }
      
      // 验证工作目录路径
      for (int i = 0; i < workingDir.length; i++) {
        final charCode = workingDir.codeUnitAt(i);
        if (charCode > 127) {
          throw Exception('Working directory contains non-ASCII character at position $i: ${workingDir.substring(i, i+1)}');
        }
      }
      
      print('   ✅ All parameters validated as ASCII-safe');
      
      final process = await Process.start(
        executable,
        args,
        workingDirectory: workingDir,
        environment: environment,
        mode: ProcessStartMode.normal,
      );

      _runningProcesses[server.id] = process;

      // 监听进程输出
      _setupProcessLogging(server, process);

      print('   ✅ Server ${server.name} started successfully');
      print('   - PID: ${process.pid}');
      print('   - Working Directory: $workingDir');
      print('   - Command: $executable ${args.join(' ')}');
      
      return true;

    } catch (e) {
      print('   ❌ Failed to start server ${server.name}');
      print('   - Error: $e');
      print('   - Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// 停止MCP服务器
  Future<bool> stopServer(McpServer server) async {
    final process = _runningProcesses[server.id];
    if (process == null) {
      print('⚠️ Server ${server.name} is not running');
      return true;
    }

    print('🛑 Stopping MCP server: ${server.name}');

    try {
      // 优雅停止
      process.kill(ProcessSignal.sigterm);
      
      // 等待进程结束，最多等待5秒
      final exitCode = await process.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏰ Process didn\'t exit gracefully, force killing...');
          process.kill(ProcessSignal.sigkill);
          return -1;
        },
      );

      _runningProcesses.remove(server.id);
      print('✅ Server ${server.name} stopped with exit code: $exitCode');
      return true;

    } catch (e) {
      print('❌ Failed to stop server ${server.name}: $e');
      return false;
    }
  }

  /// 获取服务器工作目录
  Future<String> getServerWorkingDirectory(McpServer server) async {
    if (server.workingDirectory != null) {
      return server.workingDirectory!;
    }

    // 对于NPX服务器，使用Node.js运行时目录作为工作目录
    if (server.installType == McpInstallType.npx || server.command == 'npm') {
      try {
        final nodeExe = await _runtimeManager.getNodeExecutable();
        final nodeBasePath = path.dirname(path.dirname(nodeExe)); // 上两级目录
        print('   📍 Using Node.js runtime directory as working directory: $nodeBasePath');
        return nodeBasePath;
      } catch (e) {
        print('   ⚠️ Warning: Failed to get Node.js runtime directory, using default: $e');
      }
    }

    // 为其他服务器创建独立的工作目录
    final serverDir = path.join(_environmentsBasePath, server.id);
    final dir = Directory(serverDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return serverDir;
  }

  /// 获取服务器环境变量
  Future<Map<String, String>> getServerEnvironment(McpServer server) async {
    final environment = <String, String>{};
    
    // 🌍 通用环境变量配置，兼容所有MCP服务
    try {
      // 🔧 智能PATH构建：继承用户环境 + 系统基础路径 + 运行时路径
      List<String> pathComponents = [];
      
      // 1. 首先添加我们的运行时路径（最高优先级）
      try {
        final runtimePaths = await _getRuntimePaths();
        pathComponents.addAll(runtimePaths);
        print('   🔧 Added runtime paths: ${runtimePaths.join(', ')}');
      } catch (e) {
        print('   ⚠️ Warning: Failed to get runtime paths: $e');
      }
      
      // 2. 然后添加用户当前环境的PATH（保持兼容性）
      final userPath = Platform.environment['PATH'];
      if (userPath != null && userPath.isNotEmpty) {
        final userPaths = userPath.split(Platform.pathSeparator)
            .where((path) => path.isNotEmpty && !pathComponents.contains(path))
            .toList();
        pathComponents.addAll(userPaths);
        print('   📋 Inherited ${userPaths.length} paths from user environment');
      }
      
      // 3. 最后确保关键系统路径存在（作为后备）
      List<String> essentialPaths;
      if (Platform.isWindows) {
        essentialPaths = [
          'C:\\Windows\\System32',
          'C:\\Windows',
          'C:\\Program Files\\Git\\usr\\bin', // Git Bash工具支持
        ];
      } else {
        essentialPaths = [
          '/bin',             // 基本系统工具 (realpath, dirname, etc.)
          '/usr/bin',         // 系统二进制文件
          '/usr/local/bin',   // 本地安装
          '/opt/homebrew/bin', // Homebrew
        ];
      }
      
      for (final essentialPath in essentialPaths) {
        if (!pathComponents.contains(essentialPath)) {
          pathComponents.add(essentialPath);
        }
      }
      
      environment['PATH'] = pathComponents.join(Platform.pathSeparator);
      
      // 🏠 基础环境变量 - 智能继承用户环境
      environment['HOME'] = Platform.environment['HOME'] ?? 
                           Platform.environment['USERPROFILE'] ?? 
                           (Platform.isWindows ? 'C:\\Users\\mcphub' : '/tmp');
      
      environment['USER'] = Platform.environment['USER'] ?? 
                           Platform.environment['USERNAME'] ?? 
                           'mcphub';
      
      environment['TMPDIR'] = Platform.environment['TMPDIR'] ?? 
                             Platform.environment['TEMP'] ?? 
                             (Platform.isWindows ? 'C:\\temp' : '/tmp');
      
      environment['SHELL'] = Platform.environment['SHELL'] ?? 
                            (Platform.isWindows ? 'cmd.exe' : '/bin/sh');
      
      // 🌐 字符编码设置
      if (Platform.isWindows) {
        environment['LANG'] = 'en_US.UTF-8';
      } else {
        environment['LANG'] = 'en_US.UTF-8';
        environment['LC_ALL'] = 'en_US.UTF-8';
      }
      
      // 📊 继承其他重要的用户环境变量
      final importantEnvVars = [
        'TERM', 'COLORTERM', 'DISPLAY', 'XDG_SESSION_TYPE', // 终端和显示
        'SSH_AUTH_SOCK', 'SSH_AGENT_PID',                   // SSH认证
        'GPG_AGENT_INFO', 'GPG_TTY',                        // GPG
        'HTTP_PROXY', 'HTTPS_PROXY', 'NO_PROXY',            // 代理设置
        'SSL_CERT_FILE', 'SSL_CERT_DIR',                    // SSL证书
        'REQUESTS_CA_BUNDLE', 'CURL_CA_BUNDLE',             // 其他SSL证书配置
      ];
      
      for (final varName in importantEnvVars) {
        final value = Platform.environment[varName];
        if (value != null && value.isNotEmpty) {
          environment[varName] = value;
        }
      }
      
      // 🔒 SSL证书验证配置 - 解决"unable to verify the first certificate"问题
      try {
        // 添加通用SSL配置环境变量
        environment['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'; // Node.js忽略SSL错误
        environment['PYTHONHTTPSVERIFY'] = '0';            // Python忽略HTTPS验证
        environment['SSL_VERIFY'] = 'false';               // 通用SSL验证禁用
        environment['CURL_INSECURE'] = '1';                // curl忽略SSL错误
        
        // 尝试设置系统证书路径
        if (Platform.isMacOS) {
          // macOS系统证书路径
          environment['SSL_CERT_FILE'] = '/etc/ssl/cert.pem';
          environment['SSL_CERT_DIR'] = '/etc/ssl/certs';
        } else if (Platform.isLinux) {
          // Linux系统证书路径（多个可能位置）
          final linuxCertPaths = [
            '/etc/ssl/certs/ca-certificates.crt',
            '/etc/pki/tls/certs/ca-bundle.crt',
            '/etc/ssl/ca-bundle.pem',
            '/etc/ssl/cert.pem',
          ];
          
          for (final certPath in linuxCertPaths) {
            if (File(certPath).existsSync()) {
              environment['SSL_CERT_FILE'] = certPath;
              break;
            }
          }
          
          environment['SSL_CERT_DIR'] = '/etc/ssl/certs';
        } else if (Platform.isWindows) {
          // Windows不需要额外证书配置，使用系统证书存储
          // 但可以设置一些通用配置
          environment['SSL_CERT_DIR'] = '';
        }
        
        print('   🔒 Added SSL configuration for HTTPS requests:');
        print('   - NODE_TLS_REJECT_UNAUTHORIZED: ${environment['NODE_TLS_REJECT_UNAUTHORIZED']}');
        print('   - PYTHONHTTPSVERIFY: ${environment['PYTHONHTTPSVERIFY']}');
        print('   - SSL_VERIFY: ${environment['SSL_VERIFY']}');
        if (environment.containsKey('SSL_CERT_FILE')) {
          print('   - SSL_CERT_FILE: ${environment['SSL_CERT_FILE']}');
        }
        if (environment.containsKey('SSL_CERT_DIR')) {
          print('   - SSL_CERT_DIR: ${environment['SSL_CERT_DIR']}');
        }
      } catch (e) {
        print('   ⚠️ Warning: Failed to configure SSL settings: $e');
      }
      
      print('   📊 Built universal environment with ${environment.length} variables for all MCP services');
      print('   🔧 PATH components: ${pathComponents.length}');
      print('   🏠 HOME: ${environment['HOME']}');
      print('   🐚 SHELL: ${environment['SHELL']}');
      
    } catch (e) {
      print('   ⚠️ Warning: Failed to build environment, using minimal fallback: $e');
      // 最小安全环境作为后备
      if (Platform.isWindows) {
        environment['PATH'] = 'C:\\Windows\\System32;C:\\Windows';
        environment['HOME'] = 'C:\\Users\\mcphub';
        environment['SHELL'] = 'cmd.exe';
      } else {
        environment['PATH'] = '/bin:/usr/bin:/usr/local/bin:/opt/homebrew/bin';
        environment['HOME'] = '/tmp';
        environment['SHELL'] = '/bin/sh';
      }
      environment['LANG'] = 'en_US.UTF-8';
    }

    // 为UVX/Python服务器添加特定环境变量
    if (server.installType == McpInstallType.uvx || server.command == 'uvx' || server.command == 'uv') {
      try {
        final mcpHubBasePath = PathConstants.getUserMcpHubPath();
        
        // 📋 从配置服务获取镜像源设置
        final pythonMirrorUrl = await _configService.getPythonMirrorUrl();
        final timeoutSeconds = await _configService.getDownloadTimeoutSeconds();
        final concurrentDownloads = await _configService.getConcurrentDownloads();
        
        // 🔧 配置UV环境变量，使用~/.mcphub目录
        environment['UV_CACHE_DIR'] = '$mcpHubBasePath/cache/uv';
        environment['UV_DATA_DIR'] = '$mcpHubBasePath/data/uv';
        environment['UV_TOOL_DIR'] = '$mcpHubBasePath/packages/uv/tools';
        environment['UV_TOOL_BIN_DIR'] = '$mcpHubBasePath/packages/uv/bin';
        
        // 📋 使用配置中的Python包源
        environment['UV_INDEX_URL'] = pythonMirrorUrl;
        environment['UV_EXTRA_INDEX_URL'] = 'https://pypi.org/simple';
        environment['UV_HTTP_TIMEOUT'] = '$timeoutSeconds';
        environment['UV_CONCURRENT_DOWNLOADS'] = '$concurrentDownloads';
        
        // 🐍 为直接Python执行添加PYTHONPATH
        final shouldUseDirectPython = await _shouldUseDirectPython(server);
        if (shouldUseDirectPython) {
          final packageName = server.args.isNotEmpty ? server.args.first : '';
          final packageDir = await _findPythonPackage(packageName);
          if (packageDir != null) {
            final sitePackagesDir = path.dirname(packageDir);
            environment['PYTHONPATH'] = sitePackagesDir;
            print('   🐍 Added PYTHONPATH for direct execution: $sitePackagesDir');
          }
        }
        
        print('   🐍 Added Python/UV environment variables:');
        print('   - UV_CACHE_DIR: ${environment['UV_CACHE_DIR']}');
        print('   - UV_TOOL_DIR: ${environment['UV_TOOL_DIR']}');
        print('   - UV_INDEX_URL: ${environment['UV_INDEX_URL']}');
        print('   - UV_HTTP_TIMEOUT: ${environment['UV_HTTP_TIMEOUT']}s');
        if (environment.containsKey('PYTHONPATH')) {
          print('   - PYTHONPATH: ${environment['PYTHONPATH']}');
        }
      } catch (e) {
        print('   ⚠️ Warning: Failed to set UV environment variables: $e');
      }
    }

    // 为NPX/Node.js服务器添加特定环境变量
    if (server.installType == McpInstallType.npx || server.command == 'npm' || server.command == 'node') {
      try {
        final nodeExe = await _runtimeManager.getNodeExecutable();
        final nodePath = path.dirname(nodeExe);
        final nodeBasePath = path.dirname(nodePath); // 上一级目录
        
        // 📋 从配置服务获取镜像源设置
        final npmMirrorUrl = await _configService.getNpmMirrorUrl();
        
        // 🌍 跨平台Node.js环境变量设置
        String nodeModulesPath;
        String npmCacheDir;
        
        if (Platform.isWindows) {
          // Windows路径配置
          nodeModulesPath = path.join(nodeBasePath, 'node_modules');
          npmCacheDir = path.join(nodeBasePath, 'npm-cache');
        } else {
          // Unix/Linux/macOS路径配置
          nodeModulesPath = path.join(nodeBasePath, 'lib', 'node_modules');
          npmCacheDir = path.join(nodeBasePath, '.npm');
        }
        
        // 设置Node.js相关环境变量
        environment['NODE_PATH'] = nodeModulesPath;
        environment['NPM_CONFIG_PREFIX'] = nodeBasePath;
        environment['NPM_CONFIG_CACHE'] = npmCacheDir;
        
        // 🔧 修复HOME环境变量的跨平台处理
        if (Platform.isWindows) {
          // Windows使用USERPROFILE，NPM需要这个来找到全局配置
          environment['USERPROFILE'] = environment['HOME'] ?? 
                                     Platform.environment['USERPROFILE'] ?? 
                                     'C:\\Users\\mcphub';
        } else {
          // Unix系统使用HOME
          environment['HOME'] = environment['HOME'] ?? 
                               Platform.environment['HOME'] ?? 
                               '/tmp';
        }
        
        // 📋 使用配置中的NPM镜像源
        environment['NPM_CONFIG_REGISTRY'] = npmMirrorUrl;
        
        print('   🟢 Added ${Platform.operatingSystem} Node.js environment variables:');
        print('   - NODE_PATH: ${environment['NODE_PATH']}');
        print('   - NPM_CONFIG_PREFIX: ${environment['NPM_CONFIG_PREFIX']}');
        print('   - NPM_CONFIG_CACHE: ${environment['NPM_CONFIG_CACHE']}');
        print('   - NPM_CONFIG_REGISTRY: ${environment['NPM_CONFIG_REGISTRY']}');
        if (Platform.isWindows) {
          print('   - USERPROFILE: ${environment['USERPROFILE']}');
        } else {
          print('   - HOME: ${environment['HOME']}');
        }
      } catch (e) {
        print('   ⚠️ Warning: Failed to set Node.js environment variables: $e');
      }
    }

    // 安全地添加服务器特定的环境变量
    try {
      for (final entry in server.env.entries) {
        final key = entry.key;
        final value = entry.value;
        
        // 验证键值对有效性
        if (key.isNotEmpty && key.length < 1000 && value.length < 10000) {
          environment[key] = value;
        }
      }
    } catch (e) {
      print('   ⚠️ Warning: Failed to add server environment variables: $e');
    }

    return environment;
  }

  /// 获取运行时路径列表
  Future<List<String>> _getRuntimePaths() async {
    final paths = <String>[];
    
    try {
      // Python路径
      final pythonExe = await _runtimeManager.getPythonExecutable();
      paths.add(path.dirname(pythonExe));

      // UV路径
      final uvExe = await _runtimeManager.getUvExecutable();
      paths.add(path.dirname(uvExe));

      // Node.js路径
      final nodeExe = await _runtimeManager.getNodeExecutable();
      paths.add(path.dirname(nodeExe));
    } catch (e) {
      print('⚠️ Warning: Failed to get some runtime paths: $e');
    }

    return paths;
  }

  /// 获取可执行文件路径
  Future<String> _getExecutablePath(McpServer server) async {
    print('🔧 Getting executable path for ${server.installType.name}...');
    
    switch (server.installType) {
      case McpInstallType.npx:
        // 对于NPX服务器，我们使用Node.js直接执行，避免shell依赖
        final nodeExe = await _runtimeManager.getNodeExecutable();
        print('   🟢 Using Node.js direct execution: $nodeExe');
        return nodeExe;
      
      case McpInstallType.uvx:
        // 🔧 智能UVX处理：检查是否应该直接使用Python
        print('   🔍 Checking if should use direct Python execution...');
        final shouldUseDirectPython = await _shouldUseDirectPython(server);
        print('   📋 Should use direct Python: $shouldUseDirectPython');
        
        if (shouldUseDirectPython) {
          final pythonExe = await _runtimeManager.getPythonExecutable();
          print('   🐍 Using direct Python execution to avoid shell script issues: $pythonExe');
          return pythonExe;
        }
        
        if (server.command == 'uvx' || server.command.endsWith('/uvx')) {
          final uvxPath = await _runtimeManager.getUvxExecutable();
          print('   ⚡ Using UVX executable: $uvxPath');
          return uvxPath;
        }
        print('   ➡️ Using original command: ${server.command}');
        return server.command;

      case McpInstallType.localPath:
        print('   📁 Using local path: ${server.command}');
        return server.command;

      default:
        print('   ➡️ Using original command: ${server.command}');
        return server.command;
    }
  }

  /// 构建启动参数
  Future<List<String>> _buildStartArgs(McpServer server) async {
    print('🔧 Building start arguments for ${server.installType.name}...');
    
    switch (server.installType) {
      case McpInstallType.npx:
        // 对于NPX服务器，我们需要：
        // 1. 先安装包到全局或本地
        // 2. 然后直接用node执行包的入口文件
        
        if (server.installSource != null) {
          // 构建npx包的直接执行路径
          final packageName = server.installSource!;
          print('   📦 Preparing to execute NPX package: $packageName');
          
          // 首先尝试安装包
          await _ensureNpxPackageInstalled(server);
          
          // 获取包的安装路径和入口文件
          final packagePath = await _getNpxPackagePath(packageName);
          if (packagePath != null) {
            print('   🎯 Using direct package execution: $packagePath');
            return [packagePath];
          }
        }
        
        // 如果无法直接执行，回退到npm exec但使用更简单的方式
        final args = [
          '-e', 
          'require("child_process").spawn("${server.installSource}", process.argv.slice(1), {stdio: "inherit"})'
        ];
        print('   📦 Using Node.js spawn fallback with args: ${args.join(' ')}');
        return args;

      case McpInstallType.uvx:
        // 🔧 智能UVX参数构建：检查是否应该直接使用Python
        print('   🔍 Checking if should use direct Python args...');
        final shouldUseDirectPython = await _shouldUseDirectPython(server);
        print('   📋 Should use direct Python: $shouldUseDirectPython');
        
        if (shouldUseDirectPython) {
          final pythonModuleArgs = await _buildDirectPythonArgs(server);
          print('   🐍 Using direct Python module execution: ${pythonModuleArgs.join(' ')}');
          return pythonModuleArgs;
        }
        
        if (server.command == 'uvx' || server.command.endsWith('/uvx')) {
          print('   ⚡ Using direct UVX execution with args: ${server.args.join(' ')}');
          return server.args;
        }
        print('   ➡️ Using original args for non-uvx command');
        return server.args;

      default:
        print('   ➡️ Using original args for ${server.installType.name}');
        return server.args;
    }
  }

  /// 确保NPX包已安装
  Future<void> _ensureNpxPackageInstalled(McpServer server) async {
    if (server.installSource == null) return;
    
    final packageName = server.installSource!;
    print('   📦 Ensuring package is installed: $packageName');
    
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final npmExe = await _runtimeManager.getNpmExecutable();
      final workingDir = await getServerWorkingDirectory(server);
      
      // 检查包是否已经安装
      final isInstalled = await _isNpxPackageInstalled(packageName);
      if (isInstalled) {
        print('   ✅ Package already installed: $packageName');
        return;
      }
      
      print('   📥 Installing package globally: $packageName');
      
      // 使用npm全局安装包
      final result = await Process.run(
        npmExe,
        ['install', '-g', packageName],
        workingDirectory: workingDir,
        environment: await getServerEnvironment(server),
      );
      
      if (result.exitCode == 0) {
        print('   ✅ Package installed successfully: $packageName');
      } else {
        print('   ⚠️ Package installation failed: ${result.stderr}');
      }
    } catch (e) {
      print('   ⚠️ Error installing package: $e');
    }
  }
  
  /// 检查NPX包是否已安装
  Future<bool> _isNpxPackageInstalled(String packageName) async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeModulesPath = path.join(
        path.dirname(path.dirname(nodeExe)), 
        'lib', 
        'node_modules', 
        packageName
      );
      
      return await Directory(nodeModulesPath).exists();
    } catch (e) {
      return false;
    }
  }
  
  /// 获取NPX包的执行路径
  Future<String?> _getNpxPackagePath(String packageName) async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeModulesPath = path.join(
        path.dirname(path.dirname(nodeExe)), 
        'lib', 
        'node_modules', 
        packageName
      );
      
      // 读取package.json获取bin信息
      final packageJsonPath = path.join(nodeModulesPath, 'package.json');
      final packageJsonFile = File(packageJsonPath);
      
      if (await packageJsonFile.exists()) {
        final packageJsonContent = await packageJsonFile.readAsString();
        final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
        
        if (packageJson['bin'] is Map) {
          final binMap = packageJson['bin'] as Map<String, dynamic>;
          if (binMap.isNotEmpty) {
            final binPath = binMap.values.first as String;
            return path.join(nodeModulesPath, binPath);
          }
        } else if (packageJson['bin'] is String) {
          final binPath = packageJson['bin'] as String;
          return path.join(nodeModulesPath, binPath);
        }
      }
      
      return null;
    } catch (e) {
      print('   ⚠️ Error getting package path: $e');
      return null;
    }
  }

  /// 安装NPX服务器
  Future<bool> _installNpxServer(McpServer server) async {
    print('📦 Installing NPX server...');
    print('   📋 Server details:');
    print('   - Name: ${server.name}');
    print('   - Install source: ${server.installSource}');
    print('   - Command: ${server.command}');
    print('   - Args: ${server.args.join(' ')}');
    
    // 对于npx -y命令，包会自动下载，无需预安装
    if (server.args.contains('-y') || server.args.contains('--yes')) {
      print('   ✅ NPX server uses auto-install (-y flag detected)');
      print('   📝 Package will be downloaded on first run: ${server.installSource}');
      return true;
    }

    // 对于普通npx命令，我们需要在服务器环境中安装包
    if (server.installSource != null) {
      print('   📦 Pre-installing package: ${server.installSource}');
      
      final serverDir = await getServerWorkingDirectory(server);
      print('   📍 Server directory: $serverDir');
      
      try {
        final nodeExe = await _runtimeManager.getNodeExecutable();
        final npmPath = path.join(path.dirname(nodeExe), 'npm');
        
        print('   🔧 Node executable: $nodeExe');
        print('   🔧 NPM path: $npmPath');

        // 验证npm是否存在
        if (!await File(npmPath).exists()) {
          print('   ⚠️ NPM not found at expected path, trying alternative...');
          final npmExe = await _runtimeManager.getNpmExecutable();
          print('   🔧 Alternative NPM path: $npmExe');
        }

        // 初始化package.json
        await _createPackageJson(serverDir, server);

        // 安装包
        print('   📦 Running npm install...');
        final result = await Process.run(
          npmPath,
          ['install', server.installSource!],
          workingDirectory: serverDir,
        );

        print('   📋 NPM install result:');
        print('   - Exit code: ${result.exitCode}');
        print('   - Stdout: ${result.stdout}');
        if (result.stderr.toString().isNotEmpty) {
          print('   - Stderr: ${result.stderr}');
        }

        if (result.exitCode == 0) {
          print('   ✅ NPX package installed successfully');
          return true;
        } else {
          print('   ❌ NPX installation failed');
          return false;
        }
      } catch (e) {
        print('   ❌ Exception during NPX installation: $e');
        print('   🔍 Stack trace: ${StackTrace.current}');
        return false;
      }
    }

    print('   ℹ️ No install source specified, assuming package is globally available');
    return true;
  }

  /// 安装UVX服务器
  Future<bool> _installUvxServer(McpServer server) async {
    print('📦 Installing UVX server...');
    
    // UVX会自动管理虚拟环境，无需预安装
    print('✅ UVX server uses auto-managed virtual environments');
    return true;
  }

  /// 设置本地路径服务器
  Future<bool> _setupLocalPathServer(McpServer server) async {
    print('📁 Setting up local path server...');
    
    final localPath = server.command;
    if (await File(localPath).exists() || await Directory(localPath).exists()) {
      print('✅ Local path exists: $localPath');
      return true;
    } else {
      print('❌ Local path not found: $localPath');
      return false;
    }
  }

  /// 安装GitHub服务器
  Future<bool> _installGithubServer(McpServer server) async {
    print('📦 Installing GitHub server...');
    // TODO: 实现GitHub仓库克隆和安装
    print('⚠️ GitHub installation not implemented yet');
    return false;
  }

  /// 验证预安装服务器
  Future<bool> _verifyPreInstalledServer(McpServer server) async {
    print('🔍 Verifying pre-installed server...');
    
    try {
      final result = await Process.run(server.command, ['--version']);
      if (result.exitCode == 0) {
        print('✅ Pre-installed command verified: ${server.command}');
        return true;
      } else {
        print('❌ Pre-installed command failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('❌ Pre-installed command not found: ${server.command}');
      return false;
    }
  }

  /// 创建package.json文件
  Future<void> _createPackageJson(String directory, McpServer server) async {
    final packageJsonFile = File(path.join(directory, 'package.json'));
    
    if (!await packageJsonFile.exists()) {
      final packageJson = {
        'name': 'mcp-server-${server.id}',
        'version': '1.0.0',
        'description': 'MCP Server environment for ${server.name}',
        'private': true,
        'dependencies': {}
      };

      await packageJsonFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(packageJson)
      );
      print('   📄 Created package.json');
    }
  }

  /// 设置进程日志监听
  void _setupProcessLogging(McpServer server, Process process) {
    // 使用安全的字符解码器，避免RangeError
    process.stdout.transform(const Utf8Decoder(allowMalformed: true)).listen(
      (data) {
        try {
          print('[${server.name}] STDOUT: $data');
        } catch (e) {
          print('[${server.name}] STDOUT: <encoding error>');
        }
      },
      onError: (error) {
        print('[${server.name}] STDOUT error: $error');
      },
    );

    process.stderr.transform(const Utf8Decoder(allowMalformed: true)).listen(
      (data) {
        try {
          print('[${server.name}] STDERR: $data');
        } catch (e) {
          print('[${server.name}] STDERR: <encoding error>');
        }
      },
      onError: (error) {
        print('[${server.name}] STDERR error: $error');
      },
    );

    process.exitCode.then((exitCode) {
      print('[${server.name}] Process exited with code: $exitCode');
      _runningProcesses.remove(server.id);
    }).catchError((error) {
      print('[${server.name}] Exit code error: $error');
      _runningProcesses.remove(server.id);
    });
  }

  /// 获取运行中的服务器列表
  List<String> getRunningServerIds() {
    return _runningProcesses.keys.toList();
  }

  /// 检查服务器是否运行中
  bool isServerRunning(String serverId) {
    return _runningProcesses.containsKey(serverId);
  }

  /// 获取正在运行的进程
  Process? getRunningProcess(String serverId) {
    return _runningProcesses[serverId];
  }

  /// 停止所有服务器
  Future<void> stopAllServers() async {
    print('🛑 Stopping all running servers...');
    
    final futures = <Future>[];
    for (final entry in _runningProcesses.entries) {
      futures.add(_stopProcessById(entry.key));
    }

    await Future.wait(futures);
    _runningProcesses.clear();
    print('✅ All servers stopped');
  }

  /// 根据ID停止进程
  Future<void> _stopProcessById(String serverId) async {
    final process = _runningProcesses[serverId];
    if (process != null) {
      try {
        process.kill(ProcessSignal.sigterm);
        await process.exitCode.timeout(const Duration(seconds: 3));
      } catch (e) {
        process.kill(ProcessSignal.sigkill);
      }
    }
  }

  /// 验证环境变量是否安全
  bool _isValidEnvironmentVariable(String key, String value) {
    try {
      // 检查基本条件
      if (key.isEmpty || value.isEmpty || key.length > 1000 || value.length > 10000) {
        return false;
      }

      // 检查键中的字符是否安全
      for (int i = 0; i < key.length; i++) {
        final charCode = key.codeUnitAt(i);
        if (charCode < 32 || charCode > 126) { // 只允许可打印ASCII字符
          return false;
        }
      }

      // 检查值中的字符，允许更多字符但排除控制字符
      for (int i = 0; i < value.length; i++) {
        final charCode = value.codeUnitAt(i);
        if (charCode < 9 || (charCode > 13 && charCode < 32) || charCode > 255) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 为Hub服务获取服务器的可执行文件路径
  Future<String> getExecutablePathForServer(McpServer server) async {
    return await _getExecutablePath(server);
  }

  /// 为Hub服务获取服务器的启动参数
  Future<List<String>> getArgsForServer(McpServer server) async {
    return await _buildStartArgs(server);
  }

  /// 检查是否应该直接使用Python执行而不是UVX脚本
  Future<bool> _shouldUseDirectPython(McpServer server) async {
    try {
      print('   🔍 _shouldUseDirectPython: Checking server args: ${server.args}');
      
      // 如果服务器参数中包含已知的Python包名，我们可以尝试直接执行
      if (server.args.isNotEmpty) {
        final packageName = server.args.first;
        print('   📦 Package name to check: $packageName');
        
        // 检查是否存在对应的Python包
        final packageDir = await _findPythonPackage(packageName);
        print('   📁 Package directory found: $packageDir');
        
        if (packageDir != null) {
          print('   ✅ Found Python package for direct execution: $packageDir');
          return true;
        } else {
          print('   ❌ Python package not found for: $packageName');
        }
      } else {
        print('   ⚠️ No args provided for server');
      }
      
      return false;
    } catch (e) {
      print('   ❌ Error checking for direct Python execution: $e');
      return false;
    }
  }

  /// 构建直接Python执行的参数
  Future<List<String>> _buildDirectPythonArgs(McpServer server) async {
    try {
      if (server.args.isNotEmpty) {
        final packageName = server.args.first;
        final remainingArgs = server.args.skip(1).toList();
        
        // 构建Python模块执行参数
        return ['-m', packageName.replaceAll('-', '_'), ...remainingArgs];
      }
      
      return server.args;
    } catch (e) {
      print('   ⚠️ Error building direct Python args: $e');
      return server.args;
    }
  }

  /// 查找Python包目录
  Future<String?> _findPythonPackage(String packageName) async {
    try {
      final mcpHubBasePath = PathConstants.getUserMcpHubPath();
      print('   🔍 Searching for package in: $mcpHubBasePath');
      
      // UVX包实际安装在cache目录下，不是packages目录
      final uvCacheDir = Directory('$mcpHubBasePath/cache/uv');
      print('   📁 UV cache directory: ${uvCacheDir.path}');
      
      if (!await uvCacheDir.exists()) {
        print('   ❌ UV cache directory does not exist');
        return null;
      }
      
      // 查找archive-v0目录下的所有虚拟环境
      final archiveDir = Directory('${uvCacheDir.path}/archive-v0');
      if (await archiveDir.exists()) {
        print('   📂 Searching in archive directory...');
        await for (final entity in archiveDir.list()) {
          if (entity is Directory) {
            final sitePackagesDir = Directory('${entity.path}/lib/python3.12/site-packages');
            print('   🔍 Checking site-packages: ${sitePackagesDir.path}');
            
            if (await sitePackagesDir.exists()) {
              // 检查包名的各种变体
              final packageVariants = [
                packageName,                    // mcp-server-time
                packageName.replaceAll('-', '_'), // mcp_server_time
                packageName.replaceAll('mcp-server-', ''), // time
                packageName.replaceAll('mcp-server-', '').replaceAll('-', '_'), // time
              ];
              
              for (final variant in packageVariants) {
                final packageDir = Directory('${sitePackagesDir.path}/$variant');
                print('   🔍 Checking package variant: ${packageDir.path}');
                
                if (await packageDir.exists()) {
                  print('   ✅ Found package directory: ${packageDir.path}');
                  return packageDir.path;
                }
              }
            }
          }
        }
      }
      
      // 也检查UV tools目录（作为备选）
      final uvToolsDir = Directory('$mcpHubBasePath/packages/uv/tools');
      if (await uvToolsDir.exists()) {
        print('   📂 Also searching in tools directory...');
        await for (final entity in uvToolsDir.list()) {
          if (entity is Directory) {
            final sitePackagesDir = Directory('${entity.path}/lib/python3.12/site-packages');
            if (await sitePackagesDir.exists()) {
              final packageDir = Directory('${sitePackagesDir.path}/${packageName.replaceAll('-', '_')}');
              if (await packageDir.exists()) {
                print('   ✅ Found package in tools directory: ${packageDir.path}');
                return packageDir.path;
              }
            }
          }
        }
      }
      
      print('   ❌ Package not found in any location');
      return null;
    } catch (e) {
      print('   ❌ Error finding Python package: $e');
      return null;
    }
  }
} 