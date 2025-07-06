import 'dart:io';
import '../lib/core/models/mcp_server.dart';
import '../lib/business/managers/install_managers/uvx_install_manager.dart';
import '../lib/business/managers/process_managers/uvx_process_manager.dart';

Future<void> main() async {
  print('🚀 Testing UVX Refactor - Direct Manager Test');
  print('==============================================');

  try {
    // 直接测试安装管理器和进程管理器
    final installManager = UvxInstallManager();
    final processManager = UvxProcessManager();

    // 创建测试服务器配置
    final testServer = McpServer(
      id: 'test_uvx_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Test UVX Server',
      command: 'uvx',
      args: ['mcp-server-time'], // 使用一个简单的测试包
      installType: McpInstallType.uvx,
      installSource: 'mcp-server-time',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('\n🔧 Test Server Configuration:');
    print('   - Name: ${testServer.name}');
    print('   - Install Type: ${testServer.installType.name}');
    print('   - Command: ${testServer.command}');
    print('   - Args: ${testServer.args}');
    print('   - Install Source: ${testServer.installSource}');

    // 第一步：测试配置验证
    print('\n🔍 Step 1: Validating Configuration');
    print('-----------------------------------');
    
    final isValidConfig = await installManager.validateServerConfig(testServer);
    print('   - Config Valid: $isValidConfig');
    
    if (!isValidConfig) {
      print('   ❌ Configuration validation failed');
      exit(1);
    }

    // 第二步：测试安装
    print('\n📦 Step 2: Testing Installation');
    print('-------------------------------');
    
    final installResult = await installManager.install(testServer);
    
    print('   📊 Installation Result:');
    print('   - Success: ${installResult.success}');
    print('   - Install Type: ${installResult.installType.name}');
    if (installResult.output != null) {
      print('   - Output: ${installResult.output}');
    }
    if (installResult.errorMessage != null) {
      print('   - Error: ${installResult.errorMessage}');
    }
    if (installResult.installPath != null) {
      print('   - Install Path: ${installResult.installPath}');
    }

    if (!installResult.success) {
      print('   ❌ Installation failed');
      exit(1);
    }

    // 第三步：验证安装状态
    print('\n🔍 Step 3: Verifying Installation');
    print('----------------------------------');
    
    final isInstalled = await installManager.isInstalled(testServer);
    print('   - Is Installed: $isInstalled');
    
    if (!isInstalled) {
      print('   ❌ Package not detected as installed');
      exit(1);
    }

    // 第四步：测试进程启动参数
    print('\n⚙️ Step 4: Testing Process Configuration');
    print('----------------------------------------');
    
    final executablePath = await processManager.getExecutablePath(testServer);
    final startupArgs = await processManager.getStartupArgs(testServer);
    final environment = await processManager.getEnvironmentVariables(testServer);
    final workingDir = await processManager.getWorkingDirectory(testServer);
    
    print('   - Executable: $executablePath');
    print('   - Args: ${startupArgs.join(' ')}');
    print('   - Working Dir: $workingDir');
    print('   - Environment vars count: ${environment.length}');
    
    if (executablePath == null) {
      print('   ❌ Cannot determine executable path');
      exit(1);
    }

    // 第五步：测试进程启动
    print('\n🚀 Step 5: Testing Process Start');
    print('---------------------------------');
    
    try {
      final process = await processManager.startProcess(testServer);
      print('   ✅ Process started successfully');
      print('   - PID: ${process.pid}');
      
      // 等待几秒钟
      print('\n⏳ Letting process run for 5 seconds...');
      await Future.delayed(const Duration(seconds: 5));
      
      // 停止进程
      print('\n🛑 Stopping process...');
      process.kill();
      
      // 等待进程结束
      final exitCode = await process.exitCode;
      print('   ✅ Process stopped with exit code: $exitCode');
      
    } catch (e) {
      print('   ❌ Process start failed: $e');
      exit(1);
    }

    // 总结
    print('\n🎯 Test Summary');
    print('===============');
    print('   ✅ Configuration validation: passed');
    print('   ✅ Installation: passed');
    print('   ✅ Installation verification: passed');
    print('   ✅ Process configuration: passed');
    print('   ✅ Process start/stop: passed');
    
    print('\n🎉 All UVX refactor tests passed successfully!');
    print('   The new architecture is working correctly.');

  } catch (e, stackTrace) {
    print('\n💥 Test failed with exception: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
} 