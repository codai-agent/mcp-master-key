import 'dart:io';
import 'dart:convert';
import 'dart:async';
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

      // 参考NPX实现：确定安装路径
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeBasePath = path.dirname(path.dirname(nodeExe));
      
      if (Platform.isWindows) {
        return path.join(nodeBasePath, 'node_modules', packageInfo.smitheryPackage);
      } else {
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
      // 参考 NPX 实现：所有平台都使用Node.js执行
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

      print('   📦 Smithery package: ${packageInfo.smitheryPackage}');
      print('   🎯 Target package: ${packageInfo.targetPackage}');

      if (Platform.isWindows) {
        // Windows策略：参考NPX实现，直接使用 Node.js 执行包的入口文件
        print('   🪟 Windows direct execution strategy');
        
        final nodeExe = await _runtimeManager.getNodeExecutable();
        final nodeDir = path.dirname(nodeExe);
        
        // 尝试找到@smithery/cli的入口文件
        final smitheryCliPath = path.join(nodeDir, 'node_modules', '@smithery', 'cli');
        
        // 检查build/index.js
        final entryFile = path.join(smitheryCliPath, 'build', 'index.js');
        if (await File(entryFile).exists()) {
          print('   🪟 Windows direct execution: $entryFile');
          final args = [entryFile, 'run', packageInfo.targetPackage];
          
          // 添加其他参数
          final otherArgs = _extractOtherArgs(server.args);
          args.addAll(otherArgs);
          
          return args;
        }
        
        // 如果没有build/index.js，尝试package.json中的main字段
        final packageJsonFile = File(path.join(smitheryCliPath, 'package.json'));
        if (await packageJsonFile.exists()) {
          try {
            final packageJsonContent = await packageJsonFile.readAsString();
            final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
            final mainFile = packageJson['main'] as String?;
            if (mainFile != null) {
              final mainPath = path.join(smitheryCliPath, mainFile);
              if (await File(mainPath).exists()) {
                print('   🪟 Windows main file execution: $mainPath');
                final args = [mainPath, 'run', packageInfo.targetPackage];
                
                // 添加其他参数
                final otherArgs = _extractOtherArgs(server.args);
                args.addAll(otherArgs);
                
                return args;
              }
            }
          } catch (e) {
            print('   ⚠️ Error reading package.json: $e');
          }
        }
        
        // 回退到原始参数
        print('   🪟 Windows fallback to original args');
        return server.args;
      } else {
        // macOS/Linux策略：参考NPX实现，使用 Node.js spawn 方式
        print('   🍎 macOS/Linux spawn execution with enhanced PATH');
        
        final nodeExe = await _runtimeManager.getNodeExecutable();
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        final binDir = path.join(nodeBasePath, 'bin');
        
        // 构建JavaScript代码，参考NPX的实现
        final jsCode = '''
process.chdir('${nodeBasePath.replaceAll('\\', '\\\\')}');
process.env.PATH = '${binDir.replaceAll('\\', '\\\\')}:' + (process.env.PATH || '');
require('child_process').spawn('cli', ['run', '${packageInfo.targetPackage}'].concat(process.argv.slice(1)), {stdio: 'inherit'});
'''.trim();
        
        print('   📋 JavaScript code: $jsCode');
        
        // 添加其他参数
        final otherArgs = _extractOtherArgs(server.args);
        return ['-e', jsCode, ...otherArgs];
      }
      //AI给出的优化代码，目前安装代码在各个平台都正常运行，故先不替换
//       print('   📦 Smithery package: ${packageInfo.smitheryPackage}');
//       print('   🎯 Target package: ${packageInfo.targetPackage}');

//       if (Platform.isWindows) {
//         // Windows上使用Node.js spawn方式，参考NPX的实现
//         print('   🪟 Using Node.js spawn method for Smithery on Windows');
        
//         // 获取工作目录（这里可能需要一个默认值或从配置获取）
//         final runtimeManager = RuntimeManager.instance;
//         final nodeExe = await runtimeManager.getNodeExecutable();
//         final nodeBasePath = path.dirname(path.dirname(nodeExe));
//         final workingDir = server.workingDirectory ?? nodeBasePath;
        
//         // 构建JavaScript代码来执行smithery
//         final jsCode = '''
// process.chdir("${workingDir.replaceAll('\\', '\\\\')}");
// const { spawn } = require("child_process");
// const npmExec = spawn("npm", ["exec", "${packageInfo.smitheryPackage}", "--", "run", "${packageInfo.targetPackage}"], {
//   stdio: "inherit",
//   shell: true
// });
// npmExec.on('exit', (code) => process.exit(code));
// '''.trim();
        
//         final args = ['-e', jsCode];
//         print('   📦 Using Node.js spawn method for Smithery:');
//         print('   📋 JavaScript code: ${jsCode.replaceAll('\n', '; ')}');
//         return args;
//       } else {
//         // 其他平台使用直接的npm exec命令
//         print('   🐧 Using direct npm exec for Smithery on non-Windows');
//         final args = <String>[];
        
//         // 添加npm exec调用
//         args.addAll([
//           'exec',
//           packageInfo.smitheryPackage,
//           '--', // 分隔符：npm exec的参数和要执行程序的参数
//           'run',
//           packageInfo.targetPackage,
//         ]);
        
//         // 添加其他参数（排除已处理的部分）
//         final otherArgs = _extractOtherArgs(server.args);
//         args.addAll(otherArgs);
        
//         return args;
//       }
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeDir = path.dirname(path.dirname(nodeExe));
      final npmMirrorUrl = await _configService.getNpmMirrorUrl();

      String nodeModulesPath;
      String npmCacheDir;
      
      if (Platform.isWindows) {
        nodeModulesPath = path.join(nodeDir, 'node_modules');
        npmCacheDir = path.join(nodeDir, 'npm-cache');
      } else {
        nodeModulesPath = path.join(nodeDir, 'lib', 'node_modules');
        npmCacheDir = path.join(nodeDir, '.npm');
      }

      // 参考NPX实现的环境变量设置
      final envVars = {
        'NODE_PATH': nodeModulesPath,
        'NPM_CONFIG_PREFIX': nodeDir,
        'NPM_CONFIG_CACHE': npmCacheDir,
        'NPM_CONFIG_GLOBALCONFIG': path.join(nodeDir, 'etc', 'npmrc'),
        'NPM_CONFIG_USERCONFIG': path.join(nodeDir, '.npmrc'),
        'NPM_CONFIG_REGISTRY': npmMirrorUrl,
        ...server.env,
      };

      if (Platform.isWindows) {
        envVars['USERPROFILE'] = Platform.environment['USERPROFILE'] ?? 
                                 Platform.environment['HOME'] ?? 
                                 'C:\\Users\\mcphub';
      } else {
        envVars['HOME'] = Platform.environment['HOME'] ?? '/tmp';
      }

      // 禁用Smithery的交互式提示
      envVars['SMITHERY_NO_TELEMETRY'] = 'true';
      envVars['SMITHERY_AUTO_ACCEPT'] = 'true';
      envVars['CI'] = 'true'; // 很多工具在CI环境下会自动禁用交互式提示
      envVars['NO_UPDATE_NOTIFIER'] = 'true'; // 禁用更新通知
      envVars['DISABLE_TELEMETRY'] = 'true'; // 通用的禁用遥测环境变量
      envVars['SMITHERY_DISABLE_TELEMETRY'] = 'true'; // 尝试更多可能的环境变量
      envVars['SMITHERY_NON_INTERACTIVE'] = 'true'; // 非交互模式

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
      
      // 参考NPX实现：确定Smithery CLI的安装路径
      String nodeModulesPath;
      final nodeBasePath = path.dirname(path.dirname(nodeExe));
      
      if (Platform.isWindows) {
        // Windows: 参考NPX实现
        nodeModulesPath = path.join(nodeBasePath, 'node_modules', smitheryPackage);
      } else {
        // Unix-like: /path/to/node/lib/node_modules/@smithery/cli
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

  /// 安装@smithery/cli - 参考NPX实现
  Future<_SmitheryInstallResult> _installSmitheryCli(String smitheryPackage, McpServer server) async {
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🔧 NPM executable: $npmPath');
      print('   📦 Installing: $smitheryPackage');

      // 参考NPX的安装参数设置
      List<String> args;
      if (Platform.isWindows) {
        // Windows: 参考NPX实现，添加--no-package-lock参数
        args = ['install', '-g', '--no-package-lock', smitheryPackage];
      } else {
        // Unix-like: 参考NPX实现
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

  /// 可取消的安装@smithery/cli - 参考NPX实现
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

      // 参考NPX的安装参数设置
      List<String> args;
      if (Platform.isWindows) {
        // Windows: 参考NPX实现，添加--no-package-lock参数
        args = ['install', '-g', '--no-package-lock', smitheryPackage];
      } else {
        // Unix-like: 参考NPX实现
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

      // 监听输出流（@smithery/cli安装通常不需要交互）
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

  /// 使用smithery cli安装目标包 - 参考NPX风格执行
  Future<_SmitheryInstallResult> _installTargetPackage(_SmitheryPackageInfo packageInfo, McpServer server) async {
    try {
      // 参考NPX实现：使用Node.js直接执行已安装的@smithery/cli
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🎯 Installing target package: ${packageInfo.targetPackage}');
      print('   🔧 Node executable: $nodeExe');

      // 获取其他参数（排除已处理的smithery相关参数）
      final otherArgs = _extractOtherArgs(server.args);

      List<String> args;
      
      if (Platform.isWindows) {
        // Windows策略：参考NPX实现，直接执行@smithery/cli的入口文件
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        final smitheryCliPath = path.join(nodeBasePath, 'node_modules', '@smithery', 'cli');
        
        // 检查build/index.js
        final entryFile = path.join(smitheryCliPath, 'build', 'index.js');
        if (await File(entryFile).exists()) {
          args = [
            entryFile,
            'install',
            packageInfo.targetPackage,
            '--client',
            packageInfo.clientType,
            ...otherArgs,
          ];
        } else {
          // 尝试package.json中的main字段
          final packageJsonFile = File(path.join(smitheryCliPath, 'package.json'));
          if (await packageJsonFile.exists()) {
            try {
              final packageJsonContent = await packageJsonFile.readAsString();
              final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
              final mainFile = packageJson['main'] as String?;
              if (mainFile != null) {
                final mainPath = path.join(smitheryCliPath, mainFile);
                args = [
                  mainPath,
                  'install',
                  packageInfo.targetPackage,
                  '--client',
                  packageInfo.clientType,
                  ...otherArgs,
                ];
              } else {
                throw Exception('Cannot find smithery cli entry point');
              }
            } catch (e) {
              throw Exception('Failed to read smithery cli package.json: $e');
            }
          } else {
            throw Exception('Smithery CLI not properly installed');
          }
        }
      } else {
        // macOS/Linux策略：使用JavaScript spawn方式
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        final binDir = path.join(nodeBasePath, 'bin');
        
        // 构建完整的参数列表
        final allArgs = ['install', packageInfo.targetPackage, '--client', packageInfo.clientType, ...otherArgs];
        final argsJson = jsonEncode(allArgs);
        
        final jsCode = '''
process.chdir('${nodeBasePath.replaceAll('\\', '\\\\')}');
process.env.PATH = '${binDir.replaceAll('\\', '\\\\')}:' + (process.env.PATH || '');
const args = $argsJson;
require('child_process').spawn('cli', args, {stdio: 'inherit'});
'''.trim();
        
        args = ['-e', jsCode];
      }
      
      print('   📋 Command: $nodeExe ${args.join(' ')}');

      final result = await Process.run(
        nodeExe,
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

  /// 可取消的使用smithery cli安装目标包 - 参考NPX风格执行
  Future<_SmitheryInstallResult> _installTargetPackageCancellable(
    _SmitheryPackageInfo packageInfo, 
    McpServer server,
    Function(Process)? onProcessStarted,
  ) async {
    Timer? autoAnswerTimer; // 声明在方法级别
    try {
      // 参考NPX实现：使用Node.js直接执行已安装的@smithery/cli
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   🎯 Installing target package (cancellable): ${packageInfo.targetPackage}');
      print('   🔧 Node executable: $nodeExe');

      // 获取其他参数（排除已处理的smithery相关参数）
      final otherArgs = _extractOtherArgs(server.args);

      List<String> args;
      
      if (Platform.isWindows) {
        // Windows策略：参考NPX实现，直接执行@smithery/cli的入口文件
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        final smitheryCliPath = path.join(nodeBasePath, 'node_modules', '@smithery', 'cli');
        
        // 检查build/index.js
        final entryFile = path.join(smitheryCliPath, 'build', 'index.js');
        if (await File(entryFile).exists()) {
          args = [
            entryFile,
            'install',
            packageInfo.targetPackage,
            '--client',
            packageInfo.clientType,
            ...otherArgs,
          ];
        } else {
          // 尝试package.json中的main字段
          final packageJsonFile = File(path.join(smitheryCliPath, 'package.json'));
          if (await packageJsonFile.exists()) {
            try {
              final packageJsonContent = await packageJsonFile.readAsString();
              final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
              final mainFile = packageJson['main'] as String?;
              if (mainFile != null) {
                final mainPath = path.join(smitheryCliPath, mainFile);
                args = [
                  mainPath,
                  'install',
                  packageInfo.targetPackage,
                  '--client',
                  packageInfo.clientType,
                ];
              } else {
                throw Exception('Cannot find smithery cli entry point');
              }
            } catch (e) {
              throw Exception('Failed to read smithery cli package.json: $e');
            }
          } else {
            throw Exception('Smithery CLI not properly installed');
          }
        }
      } else {
        // macOS/Linux策略：使用JavaScript spawn方式
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        final binDir = path.join(nodeBasePath, 'bin');
        
        // 构建完整的参数列表
        final allArgs = ['install', packageInfo.targetPackage, '--client', packageInfo.clientType, ...otherArgs];
        final argsJson = jsonEncode(allArgs);
        
        final jsCode = '''
process.chdir('${nodeBasePath.replaceAll('\\', '\\\\')}');
process.env.PATH = '${binDir.replaceAll('\\', '\\\\')}:' + (process.env.PATH || '');
const args = $argsJson;
require('child_process').spawn('cli', args, {stdio: 'inherit'});
'''.trim();
        
        args = ['-e', jsCode];
      }


      
      print('   📋 Command: $nodeExe ${args.join(' ')}');

      // 使用Process.start来获得进程控制权
      final process = await Process.start(
        nodeExe,
        args,
        environment: environment,
      );

      // 通过回调传递进程实例，允许外部控制
      if (onProcessStarted != null) {
        onProcessStarted(process);
      }

      // 智能自动回答交互式提示
      bool hasSeenTelemetryPrompt = false;
      final outputBuffer = StringBuffer();
      
      autoAnswerTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        try {
          final currentOutput = outputBuffer.toString().toLowerCase();
          
          // 检测各种可能的交互式提示
          if (!hasSeenTelemetryPrompt && (
              currentOutput.contains('telemetry') ||
              currentOutput.contains('usage data') ||
              currentOutput.contains('anonymized') ||
              currentOutput.contains('would you like to help') ||
              currentOutput.contains('improve smithery') ||
              currentOutput.contains('y/n') ||
              currentOutput.contains('(y/n)') ||
              currentOutput.contains('[y/n]')
          )) {
            print('   🤖 Detected telemetry prompt, sending "n" to decline...');
            process.stdin.writeln('n'); // 拒绝遥测数据收集
            hasSeenTelemetryPrompt = true;
          }
          
          // 如果检测到其他确认提示，发送 'y'
          if (currentOutput.contains('continue') && currentOutput.contains('?')) {
            print('   🤖 Detected confirmation prompt, sending "y"...');
            process.stdin.writeln('y');
          }
        } catch (e) {
          // 如果进程已经结束，忽略错误并停止定时器
          timer.cancel();
        }
        
        // 30秒后停止自动回答（给足够时间处理慢速网络）
        if (timer.tick >= 60) { // 500ms * 60 = 30秒
          timer.cancel();
        }
      });

      // 收集输出
      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      // 监听输出流
      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        stdoutBuffer.write(data);
        outputBuffer.write(data); // 添加到输出缓冲区用于交互式提示检测
        print('   📝 stdout: ${data.trim()}');
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        stderrBuffer.write(data);
        outputBuffer.write(data); // stderr 也可能包含交互式提示
        print('   ❌ stderr: ${data.trim()}');
      });

      // 等待进程完成，10分钟超时
      final exitCode = await process.exitCode.timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          print('   ⏰ Target package installation timed out, killing process...');
          autoAnswerTimer?.cancel(); // 清理定时器
          InstallManagerInterface.killProcessCrossPlatform(process);
          return -1;
        },
      );

      // 进程完成后清理定时器
      autoAnswerTimer.cancel();
      
      print('   📊 Exit code: $exitCode');

      return _SmitheryInstallResult(
        success: exitCode == 0,
        output: stdoutBuffer.toString(),
        errorMessage: exitCode != 0 ? stderrBuffer.toString() : null,
      );
    } catch (e) {
      print('   ❌ Target package cancellable installation failed: $e');
      // 确保在异常情况下也清理定时器
      try {
        autoAnswerTimer?.cancel();
      } catch (_) {
        // 忽略清理错误
      }
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

  /// 卸载目标包 - 参考NPX风格执行
  Future<bool> _uninstallTargetPackage(_SmitheryPackageInfo packageInfo, McpServer server) async {
    try {
      // 参考NPX实现：使用Node.js直接执行已安装的@smithery/cli
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final environment = await getEnvironmentVariables(server);

      List<String> args;
      
      if (Platform.isWindows) {
        // Windows策略：参考NPX实现，直接执行@smithery/cli的入口文件
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        final smitheryCliPath = path.join(nodeBasePath, 'node_modules', '@smithery', 'cli');
        
        // 检查build/index.js
        final entryFile = path.join(smitheryCliPath, 'build', 'index.js');
        if (await File(entryFile).exists()) {
          args = [
            entryFile,
            'uninstall',
            packageInfo.targetPackage,
            '--client',
            packageInfo.clientType,
          ];
        } else {
          // 尝试package.json中的main字段
          final packageJsonFile = File(path.join(smitheryCliPath, 'package.json'));
          if (await packageJsonFile.exists()) {
            try {
              final packageJsonContent = await packageJsonFile.readAsString();
              final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
              final mainFile = packageJson['main'] as String?;
              if (mainFile != null) {
                final mainPath = path.join(smitheryCliPath, mainFile);
                args = [
                  mainPath,
                  'uninstall',
                  packageInfo.targetPackage,
                  '--client',
                  packageInfo.clientType,
                ];
              } else {
                throw Exception('Cannot find smithery cli entry point');
              }
            } catch (e) {
              throw Exception('Failed to read smithery cli package.json: $e');
            }
          } else {
            throw Exception('Smithery CLI not properly installed');
          }
        }
      } else {
        // macOS/Linux策略：使用JavaScript spawn方式
        final nodeBasePath = path.dirname(path.dirname(nodeExe));
        final binDir = path.join(nodeBasePath, 'bin');
        
        final jsCode = '''
process.chdir('${nodeBasePath.replaceAll('\\', '\\\\')}');
process.env.PATH = '${binDir.replaceAll('\\', '\\\\')}:' + (process.env.PATH || '');
require('child_process').spawn('cli', ['uninstall', '${packageInfo.targetPackage}', '--client', '${packageInfo.clientType}'], {stdio: 'inherit'});
'''.trim();
        
        args = ['-e', jsCode];
      }

      final result = await Process.run(
        nodeExe,
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