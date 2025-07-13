import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';

/// Smithery CLI安装管理器 - 管理通过@smithery/cli管理的包
class SmitheryInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;

  @override
  McpInstallType get installType => McpInstallType.smithery;

  @override
  String get name => 'Smithery CLI Package Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<InstallResult> install(McpServer server) async {
    print('📦 Installing Smithery package for server: ${server.name}');
    
    try {
      // 验证配置
      final isValid = await validateServerConfig(server);
      if (!isValid) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Invalid server configuration for Smithery installation',
        );
      }

      final packageInfo = _extractPackageInfo(server);
      if (packageInfo == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot extract package information from server configuration',
        );
      }

      print('   📦 Smithery CLI package: ${packageInfo.smitheryPackage}');
      print('   🎯 Target package: ${packageInfo.targetPackage}');

      // 步骤1: 确保@smithery/cli已安装
      final smitheryInstallResult = await _ensureSmitheryCli(packageInfo.smitheryPackage, server);
      if (!smitheryInstallResult.success) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Failed to install @smithery/cli: ${smitheryInstallResult.errorMessage}',
        );
      }

      // 步骤2: 使用@smithery/cli安装目标包
      final targetInstallResult = await _installTargetPackage(packageInfo, server);
      
      return InstallResult(
        success: targetInstallResult.success,
        installType: installType,
        output: '${smitheryInstallResult.output}\n${targetInstallResult.output}',
        errorMessage: targetInstallResult.errorMessage,
        installPath: await getInstallPath(server),
        metadata: {
          'smitheryPackage': packageInfo.smitheryPackage,
          'targetPackage': packageInfo.targetPackage,
          'installMethod': 'smithery cli',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Smithery installation failed: $e',
      );
    }
  }

  @override
  Future<bool> isInstalled(McpServer server) async {
    try {
      final packageInfo = _extractPackageInfo(server);
      if (packageInfo == null) return false;

      // 检查@smithery/cli是否安装
      final smitheryInstalled = await _isSmitheryCliInstalled(packageInfo.smitheryPackage);
      if (!smitheryInstalled) {
        print('   ❌ @smithery/cli not installed');
        return false;
      }

      // 检查目标包是否通过smithery安装
      final targetInstalled = await _isTargetPackageInstalled(packageInfo);
      return targetInstalled;
    } catch (e) {
      print('❌ Error checking Smithery installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      final packageInfo = _extractPackageInfo(server);
      if (packageInfo == null) return false;

      // 使用smithery cli卸载目标包
      final result = await _uninstallTargetPackage(packageInfo, server);
      return result;
    } catch (e) {
      print('❌ Error uninstalling Smithery package: $e');
      return false;
    }
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    // 检查是否为Smithery类型
    if (server.installType != McpInstallType.smithery) {
      return false;
    }

    // 检查是否有有效的包信息
    final packageInfo = _extractPackageInfo(server);
    if (packageInfo == null) {
      return false;
    }

    // 检查npm是否可用
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      return await File(npmPath).exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    try {
      final packageInfo = _extractPackageInfo(server);
      if (packageInfo == null) return null;

      // Smithery包通常安装在npm全局目录下
      final nodeExe = await _runtimeManager.getNodeExecutable();
      
      if (Platform.isWindows) {
        // Windows: node.exe同级目录下的node_modules
        final nodeDir = path.dirname(nodeExe);
        return path.join(nodeDir, 'node_modules', packageInfo.smitheryPackage);
      } else {
        // Unix-like: lib/node_modules下
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        return path.join(nodeBasePath, 'lib', 'node_modules', packageInfo.smitheryPackage);
      }
    } catch (e) {
      print('❌ Error getting install path: $e');
      return null;
    }
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    try {
      // Smithery使用npx执行，所以返回node可执行文件
      return await _runtimeManager.getNodeExecutable();
    } catch (e) {
      print('❌ Error getting executable path: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    try {
      final packageInfo = _extractPackageInfo(server);
      if (packageInfo == null) return server.args;

      // 构建smithery运行参数，使用npm exec而不是npx
      final args = <String>[];
      
      // 添加npm exec调用
      args.addAll([
        'exec',
        packageInfo.smitheryPackage,
        '--', // 分隔符：npm exec的参数和要执行程序的参数
        'run',
        packageInfo.targetPackage,
      ]);
      
      // 添加其他参数（排除已处理的部分）
      final otherArgs = _extractOtherArgs(server.args);
      args.addAll(otherArgs);
      
      return args;
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeDir = path.dirname(nodeExe);
      final npmMirrorUrl = await _configService.getNpmMirrorUrl();

      String nodeModulesPath;
      String npmCacheDir;
      String npmPrefix;
      
      if (Platform.isWindows) {
        // Windows: 使用node.exe同级目录
        nodeModulesPath = path.join(nodeDir, 'node_modules');
        npmCacheDir = path.join(nodeDir, 'npm-cache');
        npmPrefix = nodeDir;
      } else {
        // Unix-like: 使用传统的lib结构
        final nodeBasePath = path.dirname(nodeDir);
        nodeModulesPath = path.join(nodeBasePath, 'lib', 'node_modules');
        npmCacheDir = path.join(nodeBasePath, '.npm');
        npmPrefix = nodeBasePath;
      }

      // 构建PATH环境变量，确保包含node和npm目录
      final currentPath = Platform.environment['PATH'] ?? '';
      final pathSeparator = Platform.isWindows ? ';' : ':';
      final newPath = '$nodeDir$pathSeparator$currentPath';

      final envVars = {
        'NODE_PATH': nodeModulesPath,
        'NPM_CONFIG_PREFIX': npmPrefix,
        'NPM_CONFIG_CACHE': npmCacheDir,
        'NPM_CONFIG_REGISTRY': npmMirrorUrl,
        'PATH': newPath,
        ...server.env,
      };

      if (Platform.isWindows) {
        // Windows特定的环境变量
        envVars['USERPROFILE'] = Platform.environment['USERPROFILE'] ?? 
                                 Platform.environment['HOME'] ?? 
                                 'C:\\Users\\mcphub';
        // 设置控制台编码为UTF-8，避免中文乱码
        envVars['CHCP'] = '65001';
        // 禁用npm的进度条，避免在CI环境中的问题
        envVars['NPM_CONFIG_PROGRESS'] = 'false';
        envVars['NPM_CONFIG_LOGLEVEL'] = 'warn';
      } else {
        envVars['HOME'] = Platform.environment['HOME'] ?? '/tmp';
      }

      print('   🔧 Environment variables for Smithery:');
      print('   - NODE_PATH: $nodeModulesPath');
      print('   - NPM_CONFIG_PREFIX: $npmPrefix');
      print('   - PATH: ${newPath.substring(0, 100)}...');

      return envVars;
    } catch (e) {
      print('❌ Error building environment variables: $e');
      return server.env;
    }
  }

  @override
  Future<InstallResult> installCancellable(
    McpServer server, {
    Function(Process)? onProcessStarted,
  }) async {
    try {
      final packageInfo = _extractPackageInfo(server);
      if (packageInfo == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot determine package information from server configuration',
        );
      }

      print('📦 Installing Smithery package (cancellable)');
      print('   📦 Smithery CLI: ${packageInfo.smitheryPackage}');
      print('   🎯 Target package: ${packageInfo.targetPackage}');

      // 步骤1: 确保@smithery/cli已安装（可取消）
      final smitheryInstallResult = await _ensureSmitheryCliCancellable(
        packageInfo.smitheryPackage, 
        server, 
        onProcessStarted,
      );
      if (!smitheryInstallResult.success) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Failed to install @smithery/cli: ${smitheryInstallResult.errorMessage}',
        );
      }

      // 步骤2: 使用@smithery/cli安装目标包（可取消）
      final targetInstallResult = await _installTargetPackageCancellable(
        packageInfo, 
        server, 
        onProcessStarted,
      );
      
      return InstallResult(
        success: targetInstallResult.success,
        installType: installType,
        output: '${smitheryInstallResult.output}\n${targetInstallResult.output}',
        errorMessage: targetInstallResult.errorMessage,
        installPath: await getInstallPath(server),
        metadata: {
          'smitheryPackage': packageInfo.smitheryPackage,
          'targetPackage': packageInfo.targetPackage,
          'installMethod': 'smithery cli (cancellable)',
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Smithery cancellable installation failed: $e',
      );
    }
  }

  /// 从服务器配置中提取包信息
  _SmitheryPackageInfo? _extractPackageInfo(McpServer server) {
    print('   🔍 Extracting package info from server args: ${server.args}');
    
    String? smitheryPackage;
    String? targetPackage;
    String? clientType;
    
    // 查找@smithery/cli包
    for (int i = 0; i < server.args.length; i++) {
      final arg = server.args[i];
      if (arg.startsWith('@smithery/cli')) {
        smitheryPackage = arg;
        
        // 查找run命令后的目标包
        for (int j = i + 1; j < server.args.length; j++) {
          if (server.args[j] == 'run' && j + 1 < server.args.length) {
            targetPackage = server.args[j + 1];
            break;
          }
        }
        break;
      }
    }
    
    // 查找--client参数
    for (int i = 0; i < server.args.length; i++) {
      if (server.args[i] == '--client' && i + 1 < server.args.length) {
        clientType = server.args[i + 1];
        break;
      }
    }
    
    // 如果没有指定客户端，使用claude作为默认值
    if (clientType == null) {
      clientType = 'claude'; // claude通常不需要额外的命令行工具
      print('   ℹ️ No client specified, defaulting to claude');
    }
    
    if (smitheryPackage != null && targetPackage != null) {
      print('   ✅ Found smithery package: $smitheryPackage');
      print('   ✅ Found target package: $targetPackage');
      print('   ✅ Client type: $clientType');
      return _SmitheryPackageInfo(
        smitheryPackage: smitheryPackage,
        targetPackage: targetPackage,
        clientType: clientType,
      );
    }
    
    print('   ❌ Could not extract package info from server configuration');
    return null;
  }

  /// 检测可用的客户端
  Future<String> _detectAvailableClient() async {
    // 检查VSCode是否可用
    try {
      final result = await Process.run('code', ['--version']).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0) {
        print('   ✅ VSCode detected, using vscode client');
        return 'vscode';
      }
    } catch (e) {
      print('   ❌ VSCode not available: $e');
    }
    
    // 默认使用claude
    print('   ℹ️ Defaulting to claude client');
    return 'claude';
  }

  /// 提取其他参数（排除已处理的smithery相关参数）
  List<String> _extractOtherArgs(List<String> args) {
    final otherArgs = <String>[];
    bool skipNext = false;
    bool foundSmithery = false;
    
    for (int i = 0; i < args.length; i++) {
      if (skipNext) {
        skipNext = false;
        continue;
      }
      
      final arg = args[i];
      
      // 跳过已处理的参数
      if (arg == '-y' || arg == '--yes') {
        continue;
      }
      
      if (arg.startsWith('@smithery/cli')) {
        foundSmithery = true;
        continue;
      }
      
      if (foundSmithery && (arg == 'run')) {
        skipNext = true; // 跳过run后的目标包名
        foundSmithery = false;
        continue;
      }
      
      // 保留有用的参数，如--config, --key等
      if (arg == '--config' || arg == '--key') {
        otherArgs.add(arg);
        if (i + 1 < args.length) {
          otherArgs.add(args[i + 1]);
          skipNext = true;
        }
        continue;
      }
      
      // 跳过我们会自动添加的--client参数
      if (arg == '--client') {
        skipNext = true; // 跳过--client及其值
        continue;
      }
      
      // 如果不是smithery相关的控制参数，保留它
      if (!foundSmithery) {
        otherArgs.add(arg);
      }
    }
    
    return otherArgs;
  }

  /// 确保@smithery/cli已安装
  Future<_SmitheryInstallResult> _ensureSmitheryCli(String smitheryPackage, McpServer server) async {
    try {
      // 检查是否已安装
      final isInstalled = await _isSmitheryCliInstalled(smitheryPackage);
      if (isInstalled) {
        print('   ✅ @smithery/cli already installed');
        return _SmitheryInstallResult(
          success: true,
          output: '@smithery/cli already installed',
        );
      }

      // 安装@smithery/cli
      print('   🔧 Installing @smithery/cli...');
      return await _installSmitheryCli(smitheryPackage, server);
    } catch (e) {
      return _SmitheryInstallResult(
        success: false,
        errorMessage: 'Error ensuring @smithery/cli: $e',
      );
    }
  }

  /// 可取消的确保@smithery/cli已安装
  Future<_SmitheryInstallResult> _ensureSmitheryCliCancellable(
    String smitheryPackage, 
    McpServer server,
    Function(Process)? onProcessStarted,
  ) async {
    try {
      // 检查是否已安装
      final isInstalled = await _isSmitheryCliInstalled(smitheryPackage);
      if (isInstalled) {
        print('   ✅ @smithery/cli already installed');
        return _SmitheryInstallResult(
          success: true,
          output: '@smithery/cli already installed',
        );
      }

      // 安装@smithery/cli（可取消）
      print('   🔧 Installing @smithery/cli (cancellable)...');
      return await _installSmitheryCliCancellable(smitheryPackage, server, onProcessStarted);
    } catch (e) {
      return _SmitheryInstallResult(
        success: false,
        errorMessage: 'Error ensuring @smithery/cli: $e',
      );
    }
  }

  /// 检查@smithery/cli是否已安装
  Future<bool> _isSmitheryCliInstalled(String smitheryPackage) async {
    smitheryPackage = '@smithery/cli';//huqb
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      print('   🔍 Node executable: $nodeExe');
      
      // 对于Windows，npm全局包通常安装在node.exe同级目录下
      String nodeModulesPath;
      if (Platform.isWindows) {
        // Windows: C:\path\to\node\node_modules\@smithery\cli
        final nodeDir = path.dirname(nodeExe);
        nodeModulesPath = path.join(nodeDir, 'node_modules', smitheryPackage);
      } else {
        // Unix-like: /path/to/node/lib/node_modules/@smithery/cli
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        nodeModulesPath = path.join(nodeBasePath, 'lib', 'node_modules', smitheryPackage);
      }
      
      print('   🔍 Checking Smithery CLI path: $nodeModulesPath');
      final exists = await Directory(nodeModulesPath).exists();
      print('   📋 Smithery CLI installed: $exists');
      
      return exists;
    } catch (e) {
      print('❌ Error checking @smithery/cli installation: $e');
      return false;
    }
  }

  /// 安装@smithery/cli
  Future<_SmitheryInstallResult> _installSmitheryCli(String smitheryPackage, McpServer server) async {
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🔧 NPM executable: $npmPath');
      print('   📦 Installing: $smitheryPackage');

      // Windows特定：确保目录存在并设置权限
      if (Platform.isWindows) {
        try {
          final nodeDir = path.dirname(await _runtimeManager.getNodeExecutable());
          final nodeModulesDir = path.join(nodeDir, 'node_modules');
          
          // 创建node_modules目录（如果不存在）
          final nodeModulesDirectory = Directory(nodeModulesDir);
          if (!await nodeModulesDirectory.exists()) {
            print('   📁 Creating node_modules directory: $nodeModulesDir');
            await nodeModulesDirectory.create(recursive: true);
          }
        } catch (dirError) {
          print('   ⚠️ Warning: Could not prepare directories: $dirError');
        }
      }

      List<String> args;
      if (Platform.isWindows) {
        // Windows: 添加更多参数来避免权限问题
        args = [
          'install', '-g', 
          '--no-package-lock',
          '--no-audit',
          '--no-fund',
          '--prefer-offline',
          smitheryPackage
        ];
      } else {
        args = ['install', '-g', smitheryPackage];
      }
      
      print('   📋 Command: $npmPath ${args.join(' ')}');

      final result = await Process.run(
        npmPath,
        args,
        environment: environment,
      ).timeout(const Duration(minutes: 5));

      print('   📊 Exit code: ${result.exitCode}');
      
      if (result.stdout.isNotEmpty) {
        print('   📝 stdout: ${result.stdout}');
      }
      if (result.stderr.isNotEmpty) {
        print('   ❌ stderr: ${result.stderr}');
      }

      return _SmitheryInstallResult(
        success: result.exitCode == 0,
        output: result.stdout.toString(),
        errorMessage: result.exitCode != 0 ? result.stderr.toString() : null,
      );
    } catch (e) {
      print('   ❌ @smithery/cli installation failed: $e');
      return _SmitheryInstallResult(
        success: false,
        errorMessage: '@smithery/cli installation failed: $e',
      );
    }
  }

  /// 可取消的安装@smithery/cli
  Future<_SmitheryInstallResult> _installSmitheryCliCancellable(
    String smitheryPackage, 
    McpServer server,
    Function(Process)? onProcessStarted,
  ) async {
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🔧 NPM executable: $npmPath');
      print('   📦 Installing: $smitheryPackage');

      // Windows特定：确保目录存在
      if (Platform.isWindows) {
        try {
          final nodeDir = path.dirname(await _runtimeManager.getNodeExecutable());
          final nodeModulesDir = path.join(nodeDir, 'node_modules');
          
          final nodeModulesDirectory = Directory(nodeModulesDir);
          if (!await nodeModulesDirectory.exists()) {
            print('   📁 Creating node_modules directory: $nodeModulesDir');
            await nodeModulesDirectory.create(recursive: true);
          }
        } catch (dirError) {
          print('   ⚠️ Warning: Could not prepare directories: $dirError');
        }
      }

      List<String> args;
      if (Platform.isWindows) {
        args = [
          'install', '-g', 
          '--no-package-lock',
          '--no-audit',
          '--no-fund',
          '--prefer-offline',
          smitheryPackage
        ];
      } else {
        args = ['install', '-g', smitheryPackage];
      }
      
      print('   📋 Command: $npmPath ${args.join(' ')}');

      // 使用Process.start来获得进程控制权
      final process = await Process.start(
        npmPath,
        args,
        environment: environment,
      );

      // 通过回调传递进程实例，允许外部控制
      if (onProcessStarted != null) {
        onProcessStarted(process);
      }

      // 收集输出
      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      // 监听输出流
      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        stdoutBuffer.write(data);
        print('   📝 stdout: ${data.trim()}');
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        stderrBuffer.write(data);
        print('   ❌ stderr: ${data.trim()}');
      });

      // 等待进程完成，5分钟超时
      final exitCode = await process.exitCode.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          print('   ⏰ @smithery/cli installation timed out, killing process...');
          InstallManagerInterface.killProcessCrossPlatform(process);
          return -1;
        },
      );

      print('   📊 Exit code: $exitCode');

      return _SmitheryInstallResult(
        success: exitCode == 0,
        output: stdoutBuffer.toString(),
        errorMessage: exitCode != 0 ? stderrBuffer.toString() : null,
      );
    } catch (e) {
      print('   ❌ @smithery/cli cancellable installation failed: $e');
      return _SmitheryInstallResult(
        success: false,
        errorMessage: '@smithery/cli cancellable installation failed: $e',
      );
    }
  }

  /// 使用smithery cli安装目标包
  Future<_SmitheryInstallResult> _installTargetPackage(_SmitheryPackageInfo packageInfo, McpServer server) async {
    try {
      // 使用npm exec而不是npx，与mcp_hub_service.dart保持一致
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🎯 Installing target package: ${packageInfo.targetPackage}');
      print('   🔧 NPM executable: $npmPath');

      final args = [
        'exec',
        packageInfo.smitheryPackage,
        '--', // 分隔符：npm exec的参数和要执行程序的参数
        'install',
        packageInfo.targetPackage,
        '--client',
        packageInfo.clientType,
      ];

      // 添加其他参数（排除已处理的smithery相关参数）
      final otherArgs = _extractOtherArgs(server.args);
      args.addAll(otherArgs);
      
      print('   📋 Command: $npmPath ${args.join(' ')}');

      final result = await Process.run(
        npmPath,
        args,
        environment: environment,
      ).timeout(const Duration(minutes: 10));

      print('   📊 Exit code: ${result.exitCode}');

      return _SmitheryInstallResult(
        success: result.exitCode == 0,
        output: result.stdout.toString(),
        errorMessage: result.exitCode != 0 ? result.stderr.toString() : null,
      );
    } catch (e) {
      print('   ❌ Target package installation failed: $e');
      return _SmitheryInstallResult(
        success: false,
        errorMessage: 'Target package installation failed: $e',
      );
    }
  }

  /// 可取消的使用smithery cli安装目标包
  Future<_SmitheryInstallResult> _installTargetPackageCancellable(
    _SmitheryPackageInfo packageInfo, 
    McpServer server,
    Function(Process)? onProcessStarted,
  ) async {
    try {
      // 使用npm exec而不是npx，与mcp_hub_service.dart保持一致
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🎯 Installing target package (cancellable): ${packageInfo.targetPackage}');
      print('   🔧 NPM executable: $npmPath');

      final args = [
        'exec',
        packageInfo.smitheryPackage,
        '--', // 分隔符：npm exec的参数和要执行程序的参数
        'install',
        packageInfo.targetPackage,
        '--client',
        packageInfo.clientType,
      ];

      // 添加其他参数（排除已处理的smithery相关参数）
      final otherArgs = _extractOtherArgs(server.args);
      args.addAll(otherArgs);
      
      print('   📋 Command: $npmPath ${args.join(' ')}');

      // 使用Process.start来获得进程控制权
      final process = await Process.start(
        npmPath,
        args,
        environment: environment,
      );

      // 通过回调传递进程实例，允许外部控制
      if (onProcessStarted != null) {
        onProcessStarted(process);
      }

      // 收集输出
      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      // 监听输出流
      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        stdoutBuffer.write(data);
        print('   📝 stdout: ${data.trim()}');
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        stderrBuffer.write(data);
        print('   ❌ stderr: ${data.trim()}');
      });

      // 等待进程完成，10分钟超时
      final exitCode = await process.exitCode.timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          print('   ⏰ Target package installation timed out, killing process...');
          InstallManagerInterface.killProcessCrossPlatform(process);
          return -1;
        },
      );

      print('   📊 Exit code: $exitCode');

      return _SmitheryInstallResult(
        success: exitCode == 0,
        output: stdoutBuffer.toString(),
        errorMessage: exitCode != 0 ? stderrBuffer.toString() : null,
      );
    } catch (e) {
      print('   ❌ Target package cancellable installation failed: $e');
      return _SmitheryInstallResult(
        success: false,
        errorMessage: 'Target package cancellable installation failed: $e',
      );
    }
  }

  /// 检查目标包是否已安装
  Future<bool> _isTargetPackageInstalled(_SmitheryPackageInfo packageInfo) async {
    try {
      // 这里可能需要调用smithery cli来检查包状态
      // 目前暂时返回false，表示需要安装
      print('   🔍 Checking if target package is installed: ${packageInfo.targetPackage}');
      return false;
    } catch (e) {
      print('❌ Error checking target package installation: $e');
      return false;
    }
  }

  /// 卸载目标包
  Future<bool> _uninstallTargetPackage(_SmitheryPackageInfo packageInfo, McpServer server) async {
    try {
      // 使用npm exec而不是npx，与mcp_hub_service.dart保持一致
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      final args = [
        'exec',
        packageInfo.smitheryPackage,
        '--', // 分隔符：npm exec的参数和要执行程序的参数
        'uninstall',
        packageInfo.targetPackage,
        '--client',
        packageInfo.clientType,
      ];

      final result = await Process.run(
        npmPath,
        args,
        environment: environment,
      );

      if (result.exitCode == 0) {
        print('✅ Target package uninstalled: ${packageInfo.targetPackage}');
        return true;
      } else {
        print('❌ Target package uninstall failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('❌ Error uninstalling target package: $e');
      return false;
    }
  }


}

/// Smithery包信息
class _SmitheryPackageInfo {
  final String smitheryPackage;
  final String targetPackage;
  final String clientType;

  _SmitheryPackageInfo({
    required this.smitheryPackage,
    required this.targetPackage,
    required this.clientType,
  });
}

/// Smithery安装结果
class _SmitheryInstallResult {
  final bool success;
  final String? output;
  final String? errorMessage;

  _SmitheryInstallResult({
    required this.success,
    this.output,
    this.errorMessage,
  });
} 