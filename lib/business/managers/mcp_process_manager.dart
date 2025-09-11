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
import 'install_managers/local_python_install_manager.dart';

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
        runInShell: Platform.isWindows, // Windows上需要shell来执行.cmd文件
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

      var pathSeparator = ":";
      if (Platform.isWindows) {
        pathSeparator = ";";
      }
      // // 2. 然后添加用户当前环境的PATH（保持兼容性）
      // final userPath = Platform.environment['PATH'];
      // if (userPath != null && userPath.isNotEmpty) {
      //   final userPaths = userPath.split(pathSeparator)
      //       .where((path) => path.isNotEmpty && !pathComponents.contains(path))
      //       .toList();
      //   pathComponents.addAll(userPaths);
      //   print('   📋 Inherited ${userPaths.length} paths from user environment');
      // }
      
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
          '/opt/homebrew/bin', // Homebrew (Apple Silicon)
          '/usr/local/homebrew/bin', // Homebrew (Intel)
        ];
        
        // macOS特定：确保系统工具路径优先
        if (Platform.isMacOS) {
          // 将系统路径插入到最前面，确保realpath、dirname等基础工具可用
          final systemPaths = ['/bin', '/usr/bin'];
          for (final systemPath in systemPaths.reversed) {
            if (pathComponents.contains(systemPath)) {
              pathComponents.remove(systemPath);
            }
            pathComponents.insert(0, systemPath);
          }
          print('   🍎 macOS: Prioritized system paths for basic tools');
        }
      }
      
      for (final essentialPath in essentialPaths) {
        if (!pathComponents.contains(essentialPath)) {
          pathComponents.add(essentialPath);
        }
      }

      environment['PATH'] = pathComponents.join(pathSeparator);
      
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
        
        // 🎯 核心优化：指定UV使用内置Python，避免下载额外Python
        final pythonExePath = await _runtimeManager.getPythonExecutable();
        environment['UV_PYTHON'] = pythonExePath;
        environment['UV_PYTHON_PREFERENCE'] = 'only-system'; // 只使用指定的Python，不自动下载
        
        // 📋 使用配置中的Python包源
        environment['UV_INDEX_URL'] = pythonMirrorUrl;
        // 移除UV_EXTRA_INDEX_URL避免回退到官方源导致超时
        // environment['UV_EXTRA_INDEX_URL'] = 'https://pypi.org/simple';
        environment['UV_HTTP_TIMEOUT'] = '180'; // 3分钟超时，避免网络慢导致的下载失败
        environment['UV_CONCURRENT_DOWNLOADS'] = '2'; // 降低并发数，避免对镜像源造成压力
        environment['UV_HTTP_RETRIES'] = '3'; // 网络失败时重试3次
        
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
        print('   - UV_PYTHON: ${environment['UV_PYTHON']} (using internal Python)');
        print('   - UV_PYTHON_PREFERENCE: ${environment['UV_PYTHON_PREFERENCE']}');
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
        //PATH已经在上面组装过了，这里直接跳过，避免覆盖掉 //huqb
        if (key == 'PATH') {
          continue;
        }
        // 验证键值对有效性
        if (key.isNotEmpty && key.length < 1000 && value.length < 10000) {
          environment[key] = value;
          print('   ✅ Added server env var: $key = ${value.length > 50 ? '${value.substring(0, 50)}...' : value}');
        } else {
          print('   ⚠️ Skipped invalid env var: $key (key: ${key.length} chars, value: ${value.length} chars)');
        }
      }
      
      if (server.env.isNotEmpty) {
        print('   🌍 Added ${server.env.length} server-specific environment variables');
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
        if (Platform.isWindows) {
          // Windows上使用node直接执行
          final nodeExe = await _runtimeManager.getNodeExecutable();
          print('   🟢 Using Node.js on Windows: $nodeExe');
          return nodeExe;
        } else {
          // 其他平台使用Node.js
          final nodeExe = await _runtimeManager.getNodeExecutable();
          print('   🟢 Using Node.js on non-Windows: $nodeExe');
          return nodeExe;
        }
      
      case McpInstallType.uvx:
        // 🔧 智能UVX处理：优先使用已安装的可执行文件
        print('   🔍 Checking if should use direct execution...');
        final shouldUseDirectExecution = await _shouldUseDirectPython(server);
        print('   📋 Should use direct execution: $shouldUseDirectExecution');
        
        if (shouldUseDirectExecution) {
          // 首先尝试找到已安装的可执行文件
          if (server.args.isNotEmpty) {
            final packageName = server.args.first;
            final executablePath = await _findUvxExecutable(packageName);
            
            if (executablePath != null) {
              print('   🚀 Using installed executable: $executablePath');
              return executablePath;
            }
          }
          
          // 如果没找到可执行文件，回退到Python执行
          final pythonExe = await _runtimeManager.getPythonExecutable();
          print('   🐍 Using direct Python execution as fallback: $pythonExe');
          return pythonExe;
        }
        
        // 🔧 macOS/Linux使用shell包装器来避免PATH问题
        if (!Platform.isWindows && (server.command == 'uvx' || server.command.endsWith('/uvx'))) {
          print('   🐚 Using shell wrapper for uvx on macOS/Linux');
          return '/bin/sh';
        }
        
        if (server.command == 'uvx' || server.command.endsWith('/uvx')) {
          final uvxPath = await _runtimeManager.getUvxExecutable();
          print('   ⚡ Using UVX executable: $uvxPath');
          return uvxPath;
        }
        print('   ➡️ Using original command: ${server.command}');
        return server.command;

      case McpInstallType.localPython:
        // 调用LocalPythonInstallManager获取正确的可执行路径
        try {
          final installManager = LocalPythonInstallManager();
          final executablePath = await installManager.getExecutablePath(server);
          if (executablePath != null) {
            print('   🐍 Using LocalPython executable: $executablePath');
            return executablePath;
          }
        } catch (e) {
          print('   ❌ Error getting LocalPython executable: $e');
        }
        // 回退到内置的Python解释器
        final pythonPath = await _runtimeManager.getPythonExecutable();
        print('   🐍 Fallback to Python executable for localPython: $pythonPath');
        return pythonPath;
      case McpInstallType.localJar:
        print('   ☕ Using local JAR path: ${server.command}');
        return server.command;
      case McpInstallType.localExecutable:
        print('   🔧 Using local executable path: ${server.command}');
        return server.command;

      case McpInstallType.smithery:
        if (Platform.isWindows) {
          // Windows上使用Node.js来执行JavaScript代码
          final nodePath = await _runtimeManager.getNodeExecutable();
          print('   🪟 Using Node.js executable for Smithery on Windows: $nodePath');
          return nodePath;
        } else {
          // 其他平台使用npm
          final npmPath = await _runtimeManager.getNpmExecutable();
          print('   📦 Using NPM executable for Smithery: $npmPath');
          return npmPath;
        }

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
        // 从args中提取包名，支持CommandResolverService转换后的格式
        String? packageName = _extractPackageNameFromArgs(server);
        if (packageName == null) {
          print('   ⚠️ Cannot extract package name from args: ${server.args}');
          return server.args;
        }
        
        if (Platform.isWindows) {
          // Windows上使用npm exec命令
          // 首先确保包已安装
          await _ensureNpxPackageInstalledWithPackageName(server, packageName);
          
          // 在Windows上，我们需要确保包在当前目录也安装了
          final workingDir = await getServerWorkingDirectory(server);
          await _ensureLocalPackageInstalled(packageName, workingDir);
          
          // 修改为使用node直接运行包的入口文件，并包含包名后的参数
          final packageDir = path.join(workingDir, 'node_modules', packageName);
          final entryFile = path.join(packageDir, 'build', 'index.js');
          
          // 提取包名后的所有参数
          final packageArgs = _extractArgsAfterPackage(server.args, packageName);
          
          // 组合入口文件和参数
          final args = [entryFile, ...packageArgs];
          print('   📦 Using direct Node.js execution with args: ${args.join(' ')}');
          return args;
        } else {
          // 其他平台：恢复使用Node.js spawn方式（更好的兼容性）
          await _ensureNpxPackageInstalledWithPackageName(server, packageName);
          
          // 使用Node.js spawn方式，这是npm生态系统的标准做法
          // 确保在正确的工作目录下spawn，这样可以找到bin目录中的软链接
          final workingDir = await getServerWorkingDirectory(server);
          final binDir = path.join(workingDir, 'bin');
          
          // 从包名中提取可执行文件名
          // 对于@wopal/mcp-server-hotnews，可执行文件名通常是mcp-server-hotnews
          String executableName = await _getNpxBinName(packageName) ?? packageName;//huqb 这里需要注意，生成的执行文件可能跟报名不一致
          if (executableName.contains('/')) {
            // 对于scoped包（如@wopal/mcp-server-hotnews），通常可执行文件名是包名的后半部分
            executableName = executableName.split('/').last;
          }
          
          // 提取包名后的所有参数
          final packageArgs = _extractArgsAfterPackage(server.args, packageName);
          final argsString = packageArgs.map((arg) => '"${arg.replaceAll('"', '\\"')}"').join(', ');
          
          // 构建JavaScript代码，确保路径正确转义
          var jsCode = '''
process.chdir("${workingDir.replaceAll('\\', '\\\\')}");
process.env.PATH = "${binDir.replaceAll('\\', '\\\\')}:" + (process.env.PATH || "");
require("child_process").spawn("$executableName", [$argsString], {stdio: "inherit"});
'''.trim();
          if(packageArgs.isEmpty) {
            jsCode = '''
process.chdir("${workingDir.replaceAll('\\', '\\\\')}");
process.env.PATH = "${binDir.replaceAll('\\', '\\\\')}:" + (process.env.PATH || "");
require("child_process").spawn("$executableName", process.argv.slice(1), {stdio: "inherit"});
'''.trim();
          }
          
          final args = ['-e', jsCode];
          print('   📦 Using Node.js spawn method with enhanced PATH:');
          print('   📋 Executable name: $executableName (from $packageName)');
          print('   📋 Package args: $packageArgs');
          print('   📋 JavaScript code: ${jsCode.replaceAll('\n', '; ')}');
          return args;
        }

      case McpInstallType.uvx:
        // 🔧 智能UVX参数构建：优先使用已安装的可执行文件
        print('   🔍 Checking if should use direct execution args...');
        final shouldUseDirectExecution = await _shouldUseDirectPython(server);
        print('   📋 Should use direct execution: $shouldUseDirectExecution');
        
        if (shouldUseDirectExecution) {
          // 首先检查是否使用可执行文件
          if (server.args.isNotEmpty) {
            final packageName = server.args.first;
            final executablePath = await _findUvxExecutable(packageName);
            
            if (executablePath != null) {
              // 使用可执行文件时，跳过第一个参数（包名），只使用剩余的参数
              final executableArgs = server.args.skip(1).toList();
              print('   🚀 Using executable args: ${executableArgs.join(' ')}');
              return executableArgs;
            }
          }
          
          // 如果没找到可执行文件，回退到Python模块执行
          final pythonModuleArgs = await _buildDirectPythonArgs(server);
          print('   🐍 Using direct Python module execution as fallback: ${pythonModuleArgs.join(' ')}');
          return pythonModuleArgs;
        }
        
        // 🔧 macOS/Linux特殊处理：使用shell包装器来确保PATH正确传递
        if (!Platform.isWindows && (server.command == 'uvx' || server.command.endsWith('/uvx'))) {
          // 获取uvx的完整路径
          final uvxPath = await _runtimeManager.getUvxExecutable();
          // 创建一个shell包装器来确保环境变量正确传递
          final shellArgs = [
            '-c',
            'export PATH="/bin:/usr/bin:\$PATH" && "$uvxPath" ${server.args.join(' ')}'
          ];
          print('   🐚 Using shell wrapper for uvx on macOS/Linux: ${shellArgs.join(' ')}');
          return shellArgs;
        }
        
        if (server.command == 'uvx' || server.command.endsWith('/uvx')) {
          print('   ⚡ Using direct UVX execution with args: ${server.args.join(' ')}');
          return server.args;
        }
        print('   ➡️ Using original args for non-uvx command');
        return server.args;

      case McpInstallType.smithery:
        // 从args中提取smithery包名和目标包名，支持CommandResolverService转换后的格式
        String? smitheryPackageName = _extractPackageNameFromArgs(server);
        if (smitheryPackageName == null) {
          print('   ⚠️ Cannot extract smithery package name from args: ${server.args}');
          return server.args;
        }
        String? targetPackageName = _extractPackageNameForSmithery(server, smitheryPackageName);
        if (targetPackageName == null) {
          print('   ⚠️ Cannot extract target package name from args: ${server.args}');
          return server.args;
        }

        print('   📦 Smithery package: $smitheryPackageName');
        print('   🎯 Target package: $targetPackageName');

        if (Platform.isWindows) {
          // Windows上使用Node.js spawn方式，参考NPX的实现
          print('   🪟 Using Node.js spawn method for Smithery on Windows');
          
          final workingDir = await getServerWorkingDirectory(server);
          final npmPath = await _runtimeManager.getNpmExecutable();
          final npmPathEscaped = npmPath.replaceAll('\\', '\\\\');
          
          // 获取 Node.js 目录，确保 npm exec 在正确的环境中运行
          final nodeExe = await _runtimeManager.getNodeExecutable();
          final nodeDir = path.dirname(nodeExe);
          final nodeDirEscaped = nodeDir.replaceAll('\\', '\\\\');
          
          // 构建JavaScript代码来执行smithery，使用正确的工作目录
          final jsCode = '''
process.chdir("$nodeDirEscaped");
const { spawn } = require("child_process");
const npmExec = spawn("$npmPathEscaped", ["exec", "$smitheryPackageName", "--", "run", "$targetPackageName"], {
  stdio: "inherit",
  shell: true,
  cwd: "$nodeDirEscaped"
});
npmExec.on('exit', (code) => process.exit(code));
'''.trim();
          
          final args = ['-e', jsCode];
          print('   📦 Using Node.js spawn method for Smithery:');
          print('   📋 JavaScript code: ${jsCode.replaceAll('\n', '; ')}');
          return args;
        } else {
          // 其他平台使用直接的npm exec命令
          print('   🐧 Using direct npm exec for Smithery on non-Windows');
          final args = [
            'exec',
            smitheryPackageName,
            '--', // 分隔符：npm exec的参数和要执行程序的参数
            'run',
            targetPackageName,
          ];
          return args;
        }

      case McpInstallType.localPython:
        // 调用LocalPythonInstallManager获取正确的启动参数
        try {
          final installManager = LocalPythonInstallManager();
          final args = await installManager.getStartupArgs(server);
          print('   🐍 Using LocalPython startup args: ${args.join(' ')}');
          return args;
        } catch (e) {
          print('   ❌ Error getting LocalPython startup args: $e');
          print('   ➡️ Falling back to original args');
          return server.args;
        }

      default:
        print('   ➡️ Using original args for ${server.installType.name}');
        return server.args;
    }
  }

  /// 从服务器参数中为smithery提取包名
  String? _extractPackageNameForSmithery(McpServer server,String smithery) {
    print('   🔍 Extracting package name from args: ${server.args}');
    for (int i = 0; i < server.args.length; i++) {
      final arg = server.args[i];
      if(arg == smithery) {
        if (i + 2 < server.args.length) {
          final packageName = server.args[i + 2];
          print('   ✅ Found package name after smithery flag: $packageName');
          return packageName;
        }
      }
    }
    print('   ❌ Could not extract package name from args');
    return null;
  }

  /// 从服务器参数中提取包名
  String? _extractPackageNameFromArgs(McpServer server) {
    print('   🔍 Extracting package name from args: ${server.args}');
    
    // 优先使用installSource//huqb
    // if (server.installSource != null && server.installSource!.isNotEmpty) {
    //   print('   ✅ Found package name in installSource: ${server.installSource}');
    //   return server.installSource;
    // }
    
    // 从args中提取包名
    // 支持两种格式：
    // 1. 原始NPX格式：[-y, @wopal/mcp-server-hotnews]
    // 2. CommandResolverService转换后的格式：[exec, -y, @wopal/mcp-server-hotnews]
    
    for (int i = 0; i < server.args.length; i++) {
      final arg = server.args[i];
      
      // 跳过exec参数（CommandResolverService添加的）
      if (arg == 'exec') {
        continue;
      }
      
      // 检查-y参数后面的包名
      if (arg == '-y' || arg == '--yes') {
        if (i + 1 < server.args.length) {
          final packageName = server.args[i + 1];
          print('   ✅ Found package name after -y flag: $packageName');
          return packageName;
        }
      }
      
      // 第一个不以-开头的参数通常是包名
      if (!arg.startsWith('-') && arg != 'exec') {
        print('   ✅ Found package name as non-flag arg: $arg');
        return arg;
      }
    }
    
    print('   ❌ Could not extract package name from args');
    return null;
  }

  /// 提取包名后的所有参数
  List<String> _extractArgsAfterPackage(List<String> args, String packageName) {
    print('   🔍 Extracting args after package: $packageName from args: $args');
    
    // 找到包名在args中的位置
    for (int i = 0; i < args.length; i++) {
      if (args[i] == packageName) {
        // 返回包名后的所有参数
        final packageArgs = args.skip(i + 1).toList();
        print('   ✅ Found args after package: $packageArgs');
        return packageArgs;
      }
    }
    
    print('   ⚠️ Package name not found in args, returning empty list');
    return [];
  }

  /// 确保包在本地目录也安装了（Windows特定）
  Future<void> _ensureLocalPackageInstalled(String packageName, String workingDir) async {
    print('   📦 Ensuring local package installation in: $workingDir');
    
    try {
      final npmExe = await _runtimeManager.getNpmExecutable();
      // 创建一个临时的McpServer对象用于环境变量
      final now = DateTime.now();
      final tempServer = McpServer(
        id: 'temp',
        name: 'temp',
        command: 'npm',
        args: [],
        installType: McpInstallType.npx,
        workingDirectory: workingDir,
        createdAt: now,
        updatedAt: now,
      );
      final env = await getServerEnvironment(tempServer);
      
      // 创建package.json如果不存在
      final packageJsonFile = File(path.join(workingDir, 'package.json'));
      if (!await packageJsonFile.exists()) {
        final packageJson = {
          'name': 'mcp-server-local',
          'version': '1.0.0',
          'private': true,
          'dependencies': {}
        };
        await packageJsonFile.writeAsString(jsonEncode(packageJson));
      }
      
      // 安装包到本地目录
      final result = await Process.run(
        npmExe,
        ['install', '--save', packageName, '@modelcontextprotocol/sdk'],
        workingDirectory: workingDir,
        environment: env,
      );
      
      if (result.exitCode == 0) {
        print('   ✅ Package installed locally: $packageName');
        
        // 确保依赖项正确安装
        print('   📦 Installing peer dependencies...');
        await Process.run(
          npmExe,
          ['install', '--save-dev', '@modelcontextprotocol/sdk'],
          workingDirectory: path.join(workingDir, 'node_modules', packageName),
          environment: env,
        );
      } else {
        print('   ⚠️ Local package installation warning: ${result.stderr}');
      }
    } catch (e) {
      print('   ⚠️ Error installing local package: $e');
    }
  }

  /// 确保NPX包已安装（使用已提取的包名，避免重复提取）
  Future<void> _ensureNpxPackageInstalledWithPackageName(McpServer server, String packageName) async {
    print('   📦 Ensuring package is installed: $packageName');
    
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final npmExe = await _runtimeManager.getNpmExecutable();
      final workingDir = await getServerWorkingDirectory(server);
      final env = await getServerEnvironment(server);
      
      if (Platform.isWindows) {
        // Windows平台也使用智能检查，避免不必要的重装
        print('   📥 Installing package on Windows with smart checking...');
        
        // 1. 先检查包是否已经安装
        final isInstalled = await _isNpxPackageInstalled(packageName);
        if (isInstalled) {
          print('   ✅ Package already installed: $packageName');
          return;
        }
        
        // 2. 如果未安装，直接安装（无需先卸载）
        final result = await Process.run(
          npmExe,
          ['install', '-g', '--no-package-lock', packageName],
          workingDirectory: workingDir,
          environment: env,
        );
        
        if (result.exitCode == 0) {
          print('   ✅ Package installed globally: $packageName');
        } else {
          print('   ⚠️ Global package installation failed: ${result.stderr}');
          throw Exception('Failed to install package globally: ${result.stderr}');
        }
      } else {
        // 其他平台保持原有逻辑
        // 检查包是否已经安装
        final isInstalled = await _isNpxPackageInstalled(packageName);
        if (isInstalled) {
          print('   ✅ Package already installed: $packageName');
          return;
        }
        
        print('   📥 Installing package globally: $packageName');
        
        final result = await Process.run(
          npmExe,
          ['install', '-g', packageName],
          workingDirectory: workingDir,
          environment: env,
        );
        
        if (result.exitCode == 0) {
          print('   ✅ Package installed successfully: $packageName');
        } else {
          print('   ⚠️ Package installation failed: ${result.stderr}');
          throw Exception('Failed to install package: ${result.stderr}');
        }
      }
    } catch (e) {
      print('   ⚠️ Error installing package: $e');
      rethrow;
    }
  }

  /// 确保NPX包已安装（兼容旧接口）
  Future<void> _ensureNpxPackageInstalled(McpServer server) async {
    // 从args中提取包名，支持CommandResolverService转换后的格式
    final packageName = _extractPackageNameFromArgs(server);
    if (packageName == null) {
      print('   ⚠️ Cannot extract package name for installation check');
      return;
    }
    
    await _ensureNpxPackageInstalledWithPackageName(server, packageName);
  }

  /// 获取NPX安装包下面的package.json中的‘bin’中定义的执行文件名
  Future<String?> _getNpxBinName(String packageName) async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeBasePath = path.dirname(path.dirname(nodeExe));

      String nodeModulesPath;
      if (Platform.isWindows) {
        // Windows: 直接在node_modules目录下
        nodeModulesPath = path.join(nodeBasePath, 'node_modules', packageName, 'package.json');
      } else {
        // Unix/Linux/macOS: lib/node_modules目录下
        nodeModulesPath = path.join(nodeBasePath, 'lib', 'node_modules', packageName, 'package.json');
      }
      //如果路径里面有version：@latest,需要去掉
      nodeModulesPath = nodeModulesPath.replaceAll('@latest', '');
      print('   🔍 Checking package bin path: $nodeModulesPath');
      final exists = await File(nodeModulesPath).exists();
      print('   📋 Package bin exists: $exists');
      if (exists) {
        //读取bin
        final file = File(nodeModulesPath);
        final jsonString = await file.readAsString();

        // 2. 解析 JSON
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

        // 3. 获取 bin 对象的键名
        if (jsonMap.containsKey('bin') && jsonMap['bin'] is Map) {
          final binMap = jsonMap['bin'] as Map<String, dynamic>;
          final keys = binMap.keys.toList();
          if (keys.isNotEmpty) {
            print('bin name: ${keys.first}');//是否需要判断bin[keys.first]=='dist/index.js'
            return keys.first;
          }
        }
      }
      return null;
    } catch (e) {
      print('   ❌ Error checking package installation: $e');
      return null;
    }
  }
  
  /// 检查NPX包是否已安装（跨平台兼容）
  Future<bool> _isNpxPackageInstalled(String packageName) async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeBasePath = path.dirname(path.dirname(nodeExe));
      
      String nodeModulesPath;
      if (Platform.isWindows) {
        // Windows: 直接在node_modules目录下
        nodeModulesPath = path.join(nodeBasePath, 'node_modules', packageName);
      } else {
        // Unix/Linux/macOS: lib/node_modules目录下
        nodeModulesPath = path.join(nodeBasePath, 'lib', 'node_modules', packageName);
      }
      
      print('   🔍 Checking package path: $nodeModulesPath');
      final exists = await Directory(nodeModulesPath).exists();
      print('   📋 Package exists: $exists');
      
      return exists;
    } catch (e) {
      print('   ❌ Error checking package installation: $e');
      return false;
    }
  }
  
  /// 获取NPX包的执行路径（跨平台兼容）
  Future<String?> _getNpxPackagePath(String packageName) async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeBasePath = path.dirname(path.dirname(nodeExe));
      
      String nodeModulesPath;
      if (Platform.isWindows) {
        // Windows: 直接在node_modules目录下
        nodeModulesPath = path.join(nodeBasePath, 'node_modules', packageName);
      } else {
        // Unix/Linux/macOS: lib/node_modules目录下
        nodeModulesPath = path.join(nodeBasePath, 'lib', 'node_modules', packageName);
      }
      
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

  /// 为Hub服务获取服务器的可执行文件路径
  Future<String> getExecutablePathForServer(McpServer server) async {
    return await _getExecutablePath(server);
  }

  /// 为Hub服务获取服务器的启动参数
  Future<List<String>> getArgsForServer(McpServer server) async {
    return await _buildStartArgs(server);
  }

  /// 检查是否应该直接使用已安装的可执行文件而不是UVX脚本
  Future<bool> _shouldUseDirectPython(McpServer server) async {
    try {
      print('   🔍 _shouldUseDirectPython: Checking server args: ${server.args}');
      
      // 如果服务器参数中包含已知的Python包名，检查是否已有可执行文件
      if (server.args.isNotEmpty) {
        final packageName = server.args.first;
        print('   📦 Package name to check: $packageName');
        
        // 首先检查UV tools目录中是否有可执行文件
        var executablePath = await _findUvxExecutable(packageName);
        print('   🔧 Executable path found: $executablePath');
        
        if (executablePath != null) {
          print('   ✅ Found UVX executable, will use direct execution: $executablePath');
          return true;
        } else {
          //判断是否包含了@latest
          final newPackageName = packageName.replaceAll('@latest', '');
          executablePath = await _findUvxExecutable(newPackageName);
          if (executablePath != null) {
            print('   ✅ Found UVX executable, will use direct execution: $executablePath');
            return true;
          }
        }
        
        // 如果没找到可执行文件，再检查Python包
        final packageDir = await _findPythonPackage(packageName);
        print('   📁 Package directory found: $packageDir');
        
        if (packageDir != null) {
          print('   ✅ Found Python package for direct execution: $packageDir');
          return true;
        } else {
          print('   ❌ Neither executable nor Python package found for: $packageName');
        }
      } else {
        print('   ⚠️ No args provided for server');
      }
      
      return false;
    } catch (e) {
      print('   ❌ Error checking for direct execution: $e');
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

  /// 查找UVX已安装的可执行文件（跨平台兼容）
  Future<String?> _findUvxExecutable(String packageName) async {
    try {
      if (packageName.contains("@")) {
        packageName = packageName.split('@').first;//huqb
      }
      final mcpHubBasePath = PathConstants.getUserMcpHubPath();
      final uvToolsDir = '$mcpHubBasePath/packages/uv';//'$mcpHubBasePath/packages/uv/tools/$packageName';
      
      // 跨平台可执行文件路径
      String executablePath;
      if (Platform.isWindows) {
        // Windows: Scripts目录，.exe后缀
        executablePath = '$uvToolsDir/Scripts/$packageName.exe';
        print('   🔍 Checking Windows UVX executable: $executablePath');
        
        if (await File(executablePath).exists()) {
          print('   ✅ Found Windows UVX executable: $executablePath');
          return executablePath;
        }
        
        // 尝试没有.exe后缀的版本（有些包可能是脚本）
        executablePath = '$uvToolsDir/Scripts/$packageName';
        print('   🔍 Checking Windows UVX script: $executablePath');
        
        if (await File(executablePath).exists()) {
          print('   ✅ Found Windows UVX script: $executablePath');
          return executablePath;
        }
      } else {
        // Unix/Linux/macOS: bin目录，无后缀
        executablePath = '$uvToolsDir/bin/$packageName';
        print('   🔍 Checking Unix UVX executable: $executablePath');
        
        if (await File(executablePath).exists()) {
          print('   ✅ Found Unix UVX executable: $executablePath');
          return executablePath;
        }
      }
      
      print('   ❌ UVX executable not found for platform: ${Platform.operatingSystem}');
      return null;
    } catch (e) {
      print('   ❌ Error finding UVX executable: $e');
      return null;
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
//暂时保留，后面添加node支持的时候进行参考
  Future<Process> _startNodePackageProcess(String packageName, List<String> args) async {
    final nodePath = await _runtimeManager.getNodeExecutable();
    final npmPath = await _runtimeManager.getNpmExecutable();
    final nodeEnv = await _getNodeEnvironment();
    
    if (Platform.isWindows) {
      // Windows上使用npm exec来执行包
      return Process.start(
        npmPath,
        ['exec', packageName, ...args],
        environment: nodeEnv,
        workingDirectory: path.dirname(nodePath),
      );
    } else {
      // 其他平台保持原有的执行方式
      return Process.start(
        nodePath,
        ['-e', 'require("child_process").spawn("$packageName", process.argv.slice(1), {stdio: "inherit"})'],
        environment: nodeEnv,
        workingDirectory: path.dirname(nodePath),
      );
    }
  }

  Future<Map<String, String>> _getNodeEnvironment() async {
    final runtimeBase = _runtimeManager.getRuntimeBasePath();
    final platform = _runtimeManager.getPlatformString();
    final nodeBase = path.join(runtimeBase, 'nodejs', platform);
    
    // 📋 从配置服务获取镜像源设置
    final npmMirrorUrl = await _configService.getNpmMirrorUrl();
    
    final env = {
      ...Platform.environment,
      'NODE_PATH': path.join(nodeBase, 'node_modules'),
      'NPM_CONFIG_PREFIX': nodeBase,
      'NPM_CONFIG_CACHE': path.join(nodeBase, 'npm-cache'),
      'NPM_CONFIG_REGISTRY': npmMirrorUrl,
    };
    
    if (Platform.isWindows) {
      // Windows特定的环境变量
      env['USERPROFILE'] = Platform.environment['USERPROFILE'] ?? '';
    }
    
    return env;
  }
} 