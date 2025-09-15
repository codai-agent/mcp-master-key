import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../../../core/models/mcp_server.dart';
import '../../../infrastructure/runtime/runtime_manager.dart';
import '../../services/config_service.dart';
import '../../services/install_service.dart';
import 'install_manager_interface.dart';

/// 本地Node工程安装管理器 - 管理本地Node.js工程的安装和编译
class LocalNodeInstallManager implements InstallManagerInterface {
  final RuntimeManager _runtimeManager = RuntimeManager.instance;
  final ConfigService _configService = ConfigService.instance;

  @override
  McpInstallType get installType => McpInstallType.localNode;

  @override
  String get name => 'Local Node.js Project Manager';

  @override
  List<String> get supportedPlatforms => ['windows', 'macos', 'linux'];

  @override
  Future<InstallResult> install(McpServer server) async {
    print('📦 Installing local Node.js project for server: ${server.name}');
    
    try {
      // 验证配置
      final isValid = await validateServerConfig(server);
      if (!isValid) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Invalid server configuration for local Node.js installation',
        );
      }

      // 获取项目路径
      final projectPath = _extractProjectPath(server);
      if (projectPath == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot extract project path from server configuration',
        );
      }

      // 检查项目是否存在
      if (!await Directory(projectPath).exists()) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Project directory does not exist: $projectPath',
        );
      }

      // 检查是否已安装（即dist/index.js是否存在）
      final alreadyInstalled = await isInstalled(server);
      if (alreadyInstalled) {
        print('   ✅ Project already compiled and installed: $projectPath');
        
        // 获取更新后的启动参数
        final updatedArgs = await getStartupArgs(server);
        
        return InstallResult(
          success: true,
          installType: installType,
          output: 'Project already compiled and installed',
          installPath: await getInstallPath(server),
          metadata: {
            'projectPath': projectPath,
            'installMethod': 'local_node (already installed)',
            'updatedArgs': updatedArgs,  // 添加更新后的启动参数
          },
        );
      }

      // 执行安装流程：npm install -> npm run build -> 创建快捷方式
      final result = await _installLocalNodeProject(projectPath, server);
      
      // 获取更新后的启动参数
      final updatedArgs = await getStartupArgs(server);
      
      return InstallResult(
        success: result.success,
        installType: installType,
        output: result.output,
        errorMessage: result.errorMessage,
        installPath: await getInstallPath(server),
        metadata: {
          'projectPath': projectPath,
          'installMethod': 'local_node',
          'updatedArgs': updatedArgs,  // 添加更新后的启动参数
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Local Node.js installation failed: $e',
      );
    }
  }

  @override
  Future<bool> isInstalled(McpServer server) async {
    try {
      final projectPath = _extractProjectPath(server);
      if (projectPath == null) return false;

      // 检查dist/index.js是否存在
      final distIndexPath = path.join(projectPath, 'dist', 'index.js');
      return await File(distIndexPath).exists();
    } catch (e) {
      print('❌ Error checking local Node.js installation: $e');
      return false;
    }
  }

  @override
  Future<bool> uninstall(McpServer server) async {
    try {
      final projectPath = _extractProjectPath(server);
      if (projectPath == null) return false;

      // 删除dist目录
      final distDir = Directory(path.join(projectPath, 'dist'));
      if (await distDir.exists()) {
        await distDir.delete(recursive: true);
        print('✅ Removed dist directory: ${distDir.path}');
      }

      // 删除node_modules目录（可选）
      final nodeModulesDir = Directory(path.join(projectPath, 'node_modules'));
      if (await nodeModulesDir.exists()) {
        await nodeModulesDir.delete(recursive: true);
        print('✅ Removed node_modules directory: ${nodeModulesDir.path}');
      }

      // 删除快捷方式
      final shortcutPath = await _getShortcutPath(server);
      if (shortcutPath != null) {
        final shortcutFile = File(shortcutPath);
        if (await shortcutFile.exists()) {
          await shortcutFile.delete();
          print('✅ Removed shortcut: $shortcutPath');
        }
      }

      print('✅ Local Node.js project uninstalled successfully: $projectPath');
      return true;
    } catch (e) {
      print('❌ Error uninstalling local Node.js project: $e');
      return false;
    }
  }

  @override
  Future<bool> validateServerConfig(McpServer server) async {
    // 检查是否为localNode类型
    if (server.installType != McpInstallType.localNode) {
      return false;
    }

    // 检查是否有有效的项目路径
    final projectPath = _extractProjectPath(server);
    if (projectPath == null || projectPath.isEmpty) {
      return false;
    }

    // 检查node和npm是否可用
    try {
      final nodePath = await _runtimeManager.getNodeExecutable();
      final npmPath = await _runtimeManager.getNpmExecutable();
      return await File(nodePath).exists() && await File(npmPath).exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getInstallPath(McpServer server) async {
    try {
      final projectPath = _extractProjectPath(server);
      if (projectPath == null) return null;

      // 返回dist目录路径
      return path.join(projectPath, 'dist');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getExecutablePath(McpServer server) async {
    try {
      // 使用Node.js执行
      return await _runtimeManager.getNodeExecutable();
    } catch (e) {
      print('❌ Error getting executable path: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getStartupArgs(McpServer server) async {
    try {
      final projectPath = _extractProjectPath(server);
      if (projectPath == null) return server.args;

      // 使用快捷方式路径或dist/index.js路径
      final shortcutPath = await _getShortcutPath(server);
      if (shortcutPath != null && await File(shortcutPath).exists()) {
        return [shortcutPath];
      }

      // 回退到dist/index.js
      final distIndexPath = path.join(projectPath, 'dist', 'index.js');
      if (await File(distIndexPath).exists()) {
        return [distIndexPath];
      }

      // 如果都没有，返回原始参数
      return server.args;
    } catch (e) {
      print('❌ Error building startup args: $e');
      return server.args;
    }
  }

  @override
  Future<Map<String, String>> getEnvironmentVariables(McpServer server) async {
    try {
      final projectPath = _extractProjectPath(server);
      if (projectPath == null) return server.env;

      // 基础环境变量
      final envVars = {
        'NODE_PATH': path.join(projectPath, 'node_modules'),
        ...server.env,
      };

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
      final projectPath = _extractProjectPath(server);
      if (projectPath == null) {
        return InstallResult(
          success: false,
          installType: installType,
          errorMessage: 'Cannot determine project path from server configuration',
        );
      }

      // 检查是否已安装
      final alreadyInstalled = await isInstalled(server);
      if (alreadyInstalled) {
        print('   ✅ Project already compiled and installed: $projectPath');
        
        // 获取更新后的启动参数
        final updatedArgs = await getStartupArgs(server);
        
        return InstallResult(
          success: true,
          installType: installType,
          output: 'Project already compiled and installed',
          installPath: await getInstallPath(server),
          metadata: {
            'projectPath': projectPath,
            'installMethod': 'local_node (already installed)',
            'updatedArgs': updatedArgs,  // 添加更新后的启动参数
          },
        );
      }

      // 执行可取消安装流程
      final result = await _installLocalNodeProjectCancellable(projectPath, server, onProcessStarted);
      
      // 获取更新后的启动参数
      final updatedArgs = await getStartupArgs(server);
      
      return InstallResult(
        success: result.success,
        installType: installType,
        output: result.output,
        errorMessage: result.errorMessage,
        installPath: await getInstallPath(server),
        metadata: {
          'projectPath': projectPath,
          'installMethod': 'local_node (cancellable)',
          'updatedArgs': updatedArgs,  // 添加更新后的启动参数
        },
      );
    } catch (e) {
      return InstallResult(
        success: false,
        installType: installType,
        errorMessage: 'Local Node.js cancellable installation failed: $e',
      );
    }
  }

  /// 从服务器配置中提取项目路径
  String? _extractProjectPath(McpServer server) {
    print('   🔍 Extracting project path from server args: ${server.args}');
    
    // 从args中提取项目路径（通常是第一个参数）
    if (server.args.isNotEmpty) {
      final projectPath = server.args.first;
      print('   ✅ Found project path: $projectPath');
      return projectPath;
    }
    
    // 如果从args中找不到，使用installSource
    if (server.installSource != null && server.installSource!.isNotEmpty) {
      print('   ✅ Using install source as project path: ${server.installSource}');
      return server.installSource;
    }
    
    print('   ❌ Could not extract project path from server configuration');
    return null;
  }

  /// 安装本地Node项目
  Future<_LocalNodeInstallResult> _installLocalNodeProject(String projectPath, McpServer server) async {
    try {
      print('   🔧 Installing local Node.js project: $projectPath');

      // 1. 检查package.json是否存在
      final packageJsonPath = path.join(projectPath, 'package.json');
      final packageJsonFile = File(packageJsonPath);
      if (!await packageJsonFile.exists()) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'package.json not found in project directory: $projectPath',
        );
      }

      // 2. 读取package.json
      final packageJsonContent = await packageJsonFile.readAsString();
      final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
      final projectName = packageJson['name'] as String? ?? 'unknown';
      print('   📋 Project name: $projectName');

      // 3. 执行npm install
      print('   📦 Running npm install...');
      final installResult = await _runNpmInstall(projectPath, server);
      if (!installResult.success) {
        return installResult;
      }

      // 4. 执行npm run build
      print('   🔨 Running npm run build...');
      final buildResult = await _runNpmBuild(projectPath, server);
      if (!buildResult.success) {
        return buildResult;
      }

      // 5. 检查dist/index.js是否生成
      final distIndexPath = path.join(projectPath, 'dist', 'index.js');
      if (!await File(distIndexPath).exists()) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'dist/index.js was not generated after build. Build output: ${buildResult.output}',
        );
      }

      // 6. 创建快捷方式
      print('   🔗 Creating shortcut for dist/index.js...');
      final shortcutResult = await _createShortcut(distIndexPath, server);
      if (!shortcutResult.success) {
        return shortcutResult;
      }

      print('   ✅ Local Node.js project installed successfully: $projectPath');
      return _LocalNodeInstallResult(
        success: true,
        output: 'Project compiled and shortcut created successfully',
      );
    } catch (e) {
      print('   ❌ Local Node.js project installation failed: $e');
      return _LocalNodeInstallResult(
        success: false,
        errorMessage: 'Local Node.js project installation failed: $e',
      );
    }
  }

  /// 运行npm install
  Future<_LocalNodeInstallResult> _runNpmInstall(String projectPath, McpServer server) async {
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   📋 Running: $npmPath install in $projectPath');

      // 修复package.json中的link:协议问题
      await _fixPackageJsonForInstallation(projectPath);

      final result = await Process.run(
        npmPath,
        ['install'],
        workingDirectory: projectPath,
        environment: environment,
      ).timeout(const Duration(minutes: 10));

      print('   📊 npm install exit code: ${result.exitCode}');
      if (result.stdout.toString().isNotEmpty) {
        print('   📝 npm install stdout: ${result.stdout}');
      }
      if (result.stderr.toString().isNotEmpty) {
        print('   ❌ npm install stderr: ${result.stderr}');
      }

      if (result.exitCode != 0) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'npm install failed: ${result.stderr}',
        );
      }

      return _LocalNodeInstallResult(
        success: true,
        output: 'npm install completed successfully',
      );
    } catch (e) {
      print('   ❌ npm install failed: $e');
      return _LocalNodeInstallResult(
        success: false,
        errorMessage: 'npm install failed: $e',
      );
    }
  }

  /// 运行npm run build
  Future<_LocalNodeInstallResult> _runNpmBuild(String projectPath, McpServer server) async {
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   📋 Running: $npmPath run build in $projectPath');

      final result = await Process.run(
        npmPath,
        ['run', 'build'],
        workingDirectory: projectPath,
        environment: environment,
      ).timeout(const Duration(minutes: 10));

      print('   📊 npm run build exit code: ${result.exitCode}');
      if (result.stdout.toString().isNotEmpty) {
        print('   📝 npm run build stdout: ${result.stdout}');
      }
      if (result.stderr.toString().isNotEmpty) {
        print('   ❌ npm run build stderr: ${result.stderr}');
      }

      if (result.exitCode != 0) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'npm run build failed: ${result.stderr}',
        );
      }

      return _LocalNodeInstallResult(
        success: true,
        output: result.stdout.toString(),
      );
    } catch (e) {
      print('   ❌ npm run build failed: $e');
      return _LocalNodeInstallResult(
        success: false,
        errorMessage: 'npm run build failed: $e',
      );
    }
  }

  /// 创建快捷方式
  Future<_LocalNodeInstallResult> _createShortcut(String targetPath, McpServer server) async {
    try {
      final shortcutPath = await _getShortcutPath(server);
      if (shortcutPath == null) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'Could not determine shortcut path',
        );
      }

      // 确保目标文件存在
      final targetFile = File(targetPath);
      if (!await targetFile.exists()) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'Target file does not exist: $targetPath',
        );
      }

      // 创建快捷方式目录（如果不存在）
      final shortcutDir = Directory(path.dirname(shortcutPath));
      if (!await shortcutDir.exists()) {
        await shortcutDir.create(recursive: true);
      }

      // 创建符号链接（快捷方式）
      final shortcutFile = File(shortcutPath);
      if (await shortcutFile.exists()) {
        await shortcutFile.delete();
      }

      if (Platform.isWindows) {
        // Windows: 创建硬链接
        final link = Link(shortcutPath);
        await link.create(targetPath);
      } else {
        // macOS/Linux: 创建符号链接
        final link = Link(shortcutPath);
        await link.create(targetPath);
      }

      print('   ✅ Created shortcut: $shortcutPath -> $targetPath');
      return _LocalNodeInstallResult(
        success: true,
        output: 'Shortcut created: $shortcutPath',
      );
    } catch (e) {
      print('   ❌ Failed to create shortcut: $e');
      return _LocalNodeInstallResult(
        success: false,
        errorMessage: 'Failed to create shortcut: $e',
      );
    }
  }

  /// 可取消的本地Node项目安装
  Future<_LocalNodeInstallResult> _installLocalNodeProjectCancellable(
    String projectPath,
    McpServer server,
    Function(Process)? onProcessStarted,
  ) async {
    try {
      print('   🔧 Installing local Node.js project (cancellable): $projectPath');

      // 1. 检查package.json是否存在
      final packageJsonPath = path.join(projectPath, 'package.json');
      final packageJsonFile = File(packageJsonPath);
      if (!await packageJsonFile.exists()) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'package.json not found in project directory: $projectPath',
        );
      }

      // 2. 读取package.json
      final packageJsonContent = await packageJsonFile.readAsString();
      final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
      final projectName = packageJson['name'] as String? ?? 'unknown';
      print('   📋 Project name: $projectName');

      // 3. 执行npm install（可取消）
      print('   📦 Running npm install (cancellable)...');
      final installResult = await _runNpmInstallCancellable(projectPath, server, onProcessStarted);
      if (!installResult.success) {
        return installResult;
      }

      // 4. 执行npm run build（可取消）
      print('   🔨 Running npm run build (cancellable)...');
      final buildResult = await _runNpmBuildCancellable(projectPath, server, onProcessStarted);
      if (!buildResult.success) {
        return buildResult;
      }

      // 5. 检查dist/index.js是否生成
      final distIndexPath = path.join(projectPath, 'dist', 'index.js');
      if (!await File(distIndexPath).exists()) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'dist/index.js was not generated after build. Build output: ${buildResult.output}',
        );
      }

      // 6. 创建快捷方式
      print('   🔗 Creating shortcut for dist/index.js...');
      final shortcutResult = await _createShortcut(distIndexPath, server);
      if (!shortcutResult.success) {
        return shortcutResult;
      }

      print('   ✅ Local Node.js project installed successfully (cancellable): $projectPath');
      return _LocalNodeInstallResult(
        success: true,
        output: 'Project compiled and shortcut created successfully',
      );
    } catch (e) {
      print('   ❌ Local Node.js project installation failed (cancellable): $e');
      return _LocalNodeInstallResult(
        success: false,
        errorMessage: 'Local Node.js project installation failed: $e',
      );
    }
  }

  /// 可取消的npm install
  Future<_LocalNodeInstallResult> _runNpmInstallCancellable(
    String projectPath,
    McpServer server,
    Function(Process)? onProcessStarted,
  ) async {
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   📋 Running: $npmPath install in $projectPath (cancellable)');

      // 修复package.json中的link:协议问题
      await _fixPackageJsonForInstallation(projectPath);

      // 使用Process.start来获得进程控制权
      final process = await Process.start(
        npmPath,
        ['install'],
        workingDirectory: projectPath,
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
        print('   📝 npm install stdout: ${data.trim()}');
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        stderrBuffer.write(data);
        print('   ❌ npm install stderr: ${data.trim()}');
      });

      // 等待进程完成，10分钟超时
      final exitCode = await process.exitCode.timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          print('   ⏰ npm install timed out, killing process...');
          InstallManagerInterface.killProcessCrossPlatform(process);
          return -1;
        },
      );

      print('   📊 npm install exit code: $exitCode');

      if (exitCode != 0) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'npm install failed: ${stderrBuffer.toString()}',
        );
      }

      return _LocalNodeInstallResult(
        success: true,
        output: stdoutBuffer.toString(),
      );
    } catch (e) {
      print('   ❌ npm install failed: $e');
      return _LocalNodeInstallResult(
        success: false,
        errorMessage: 'npm install failed: $e',
      );
    }
  }

  /// 可取消的npm run build
  Future<_LocalNodeInstallResult> _runNpmBuildCancellable(
    String projectPath,
    McpServer server,
    Function(Process)? onProcessStarted,
  ) async {
    try {
      final npmPath = await _runtimeManager.getNpmExecutable();
      final environment = await getEnvironmentVariables(server);

      print('   📋 Running: $npmPath run build in $projectPath (cancellable)');

      // 使用Process.start来获得进程控制权
      final process = await Process.start(
        npmPath,
        ['run', 'build'],
        workingDirectory: projectPath,
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
        print('   📝 npm run build stdout: ${data.trim()}');
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        stderrBuffer.write(data);
        print('   ❌ npm run build stderr: ${data.trim()}');
      });

      // 等待进程完成，10分钟超时
      final exitCode = await process.exitCode.timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          print('   ⏰ npm run build timed out, killing process...');
          InstallManagerInterface.killProcessCrossPlatform(process);
          return -1;
        },
      );

      print('   📊 npm run build exit code: $exitCode');

      if (exitCode != 0) {
        return _LocalNodeInstallResult(
          success: false,
          errorMessage: 'npm run build failed: ${stderrBuffer.toString()}',
        );
      }

      return _LocalNodeInstallResult(
        success: true,
        output: stdoutBuffer.toString(),
      );
    } catch (e) {
      print('   ❌ npm run build failed: $e');
      return _LocalNodeInstallResult(
        success: false,
        errorMessage: 'npm run build failed: $e',
      );
    }
  }

  /// 修复package.json中的link:协议问题
  Future<void> _fixPackageJsonForInstallation(String projectPath) async {
    try {
      final packageJsonPath = path.join(projectPath, 'package.json');
      final packageJsonFile = File(packageJsonPath);
      
      if (!await packageJsonFile.exists()) {
        return;
      }

      final packageJsonContent = await packageJsonFile.readAsString();
      final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
      
      bool modified = false;
      
      // 检查并修复devDependencies中的link:协议
      if (packageJson.containsKey('devDependencies')) {
        final devDeps = packageJson['devDependencies'] as Map<String, dynamic>;
        final keysToRemove = <String>[];
        
        for (final entry in devDeps.entries) {
          final packageName = entry.key;
          final packageVersion = entry.value.toString();
          
          // 检查是否包含link:协议
          if (packageVersion.startsWith('link:')) {
            print('   ⚠️  Found problematic link: protocol in devDependencies: $packageName -> $packageVersion');
            
            // 检查是否是已知的无效包（如@types/modelcontextprotocol）
            if (packageVersion.contains('@types/modelcontextprotocol')) {
              print('   🗑️  Removing invalid package: $packageName');
              keysToRemove.add(packageName);
              modified = true;
            } else {
              // 对于其他link:协议，尝试移除link:前缀
              final cleanVersion = packageVersion.replaceFirst('link:', '');
              print('   🔧 Converting link: to regular dependency: $packageName -> $cleanVersion');
              devDeps[packageName] = cleanVersion;
              modified = true;
            }
          }
        }
        
        // 移除无效的包
        for (final key in keysToRemove) {
          devDeps.remove(key);
        }
      }
      
      // 检查并修复dependencies中的link:协议
      if (packageJson.containsKey('dependencies')) {
        final deps = packageJson['dependencies'] as Map<String, dynamic>;
        
        for (final entry in deps.entries) {
          final packageName = entry.key;
          final packageVersion = entry.value.toString();
          
          // 检查是否包含link:协议
          if (packageVersion.startsWith('link:')) {
            print('   ⚠️  Found problematic link: protocol in dependencies: $packageName -> $packageVersion');
            
            // 对于dependencies中的link:协议，尝试移除link:前缀
            final cleanVersion = packageVersion.replaceFirst('link:', '');
            print('   🔧 Converting link: to regular dependency: $packageName -> $cleanVersion');
            deps[packageName] = cleanVersion;
            modified = true;
          }
        }
      }
      
      // 如果修改了package.json，保存更改
      if (modified) {
        final modifiedContent = const JsonEncoder.withIndent('  ').convert(packageJson);
        await packageJsonFile.writeAsString(modifiedContent);
        print('   ✅ Fixed package.json - removed problematic link: protocols');
      }
    } catch (e) {
      print('   ⚠️  Warning: Failed to fix package.json: $e');
      // 不抛出异常，继续安装流程
    }
  }

  /// 获取快捷方式路径
  Future<String?> _getShortcutPath(McpServer server) async {
    try {
      // 获取Node.js运行时目录
      final nodeExe = await _runtimeManager.getNodeExecutable();
      final nodeBasePath = path.dirname(path.dirname(nodeExe));
      
      // 获取项目信息
      final projectPath = _extractProjectPath(server);
      if (projectPath == null) return null;
      
      // 从package.json获取项目名称
      final packageJsonPath = path.join(projectPath, 'package.json');
      final packageJsonFile = File(packageJsonPath);
      if (!await packageJsonFile.exists()) return null;
      
      final packageJsonContent = await packageJsonFile.readAsString();
      final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
      final projectName = packageJson['name'] as String? ?? 'local-node-project';
      
      // 清理项目名称，只保留字母、数字、连字符和下划线
      final cleanProjectName = projectName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
      
      // 构建快捷方式路径
      final shortcutName = cleanProjectName;
      final binDir = path.join(nodeBasePath, 'bin');
      
      if (Platform.isWindows) {
        return path.join(binDir, '$shortcutName.cmd');
      } else {
        return path.join(binDir, shortcutName);
      }
    } catch (e) {
      print('❌ Error getting shortcut path: $e');
      return null;
    }
  }
}

/// 本地Node项目安装结果
class _LocalNodeInstallResult {
  final bool success;
  final String? output;
  final String? errorMessage;

  _LocalNodeInstallResult({
    required this.success,
    this.output,
    this.errorMessage,
  });
}
