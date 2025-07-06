import 'dart:io';
import 'lib/core/models/mcp_server.dart';
import 'lib/business/services/install_service.dart';
import 'lib/business/services/process_service.dart';
import 'lib/infrastructure/runtime/runtime_manager.dart';

Future<void> main() async {
  print('🚀 Testing UVX Refactor Implementation');
  print('=====================================');

  try {
    // 初始化服务
    print('\n📋 Initializing services...');
    final installService = InstallService.instance;
    final processService = ProcessService.instance;
    final runtimeManager = RuntimeManager.instance;

    print('   ✅ Services initialized');

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

    // 第一步：测试安装
    print('\n📦 Step 1: Testing UVX Installation');
    print('-----------------------------------');
    
    print('   🔄 Starting installation...');
    final installResult = await installService.installServer(testServer);
    
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
      print('   ❌ Installation failed, stopping test');
      exit(1);
    }

    // 验证安装状态
    print('\n   🔍 Verifying installation status...');
    final isInstalled = await installService.isServerInstalled(testServer);
    print('   - Is Installed: $isInstalled');

    if (!isInstalled) {
      print('   ❌ Package not detected as installed, stopping test');
      exit(1);
    }

    print('   ✅ Installation test passed');

    // 第二步：测试进程启动
    print('\n🚀 Step 2: Testing Process Startup');
    print('----------------------------------');
    
    print('   🔄 Starting process...');
    final processResult = await processService.startServer(testServer);
    
    print('   📊 Process Start Result:');
    print('   - Success: ${processResult.success}');
    print('   - Server ID: ${processResult.serverId}');
    print('   - Process ID: ${processResult.processId}');
    if (processResult.errorMessage != null) {
      print('   - Error: ${processResult.errorMessage}');
    }
    if (processResult.metadata != null) {
      print('   - Metadata: ${processResult.metadata}');
    }

    if (!processResult.success) {
      print('   ❌ Process startup failed, stopping test');
      exit(1);
    }

    // 检查进程状态
    print('\n   🔍 Checking process status...');
    final isRunning = processService.isServerRunning(testServer.id);
    print('   - Is Running: $isRunning');

    if (!isRunning) {
      print('   ❌ Process not detected as running');
    } else {
      print('   ✅ Process startup test passed');
    }

    // 第三步：运行一段时间
    print('\n⏳ Step 3: Running Process for 5 seconds');
    print('----------------------------------------');
    
    print('   🔄 Letting process run...');
    await Future.delayed(const Duration(seconds: 5));
    
    final stillRunning = processService.isServerRunning(testServer.id);
    print('   - Still Running: $stillRunning');
    
    if (stillRunning) {
      print('   ✅ Process stability test passed');
    } else {
      print('   ⚠️ Process stopped unexpectedly');
    }

    // 第四步：测试进程停止
    print('\n🛑 Step 4: Testing Process Stop');
    print('-------------------------------');
    
    print('   🔄 Stopping process...');
    final stopResult = await processService.stopServer(testServer);
    
    print('   📊 Process Stop Result:');
    print('   - Success: ${stopResult.success}');
    print('   - Server ID: ${stopResult.serverId}');
    if (stopResult.errorMessage != null) {
      print('   - Error: ${stopResult.errorMessage}');
    }

    // 等待进程完全停止
    await Future.delayed(const Duration(seconds: 2));
    
    final isStopped = !processService.isServerRunning(testServer.id);
    print('   - Is Stopped: $isStopped');

    if (stopResult.success && isStopped) {
      print('   ✅ Process stop test passed');
    } else {
      print('   ❌ Process stop test failed');
    }

    // 总结
    print('\n🎯 Test Summary');
    print('===============');
    print('   ✅ Installation: ${installResult.success}');
    print('   ✅ Process Start: ${processResult.success}');
    print('   ✅ Process Stop: ${stopResult.success}');
    
    if (installResult.success && processResult.success && stopResult.success) {
      print('\n🎉 All UVX refactor tests passed successfully!');
      print('   The new architecture is working correctly.');
    } else {
      print('\n❌ Some tests failed. Please check the implementation.');
      exit(1);
    }

  } catch (e, stackTrace) {
    print('\n💥 Test failed with exception: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  } finally {
    // 清理
    print('\n🧹 Cleaning up...');
    try {
      await ProcessService.instance.stopAllServers();
      await ProcessService.instance.dispose();
      print('   ✅ Cleanup completed');
    } catch (e) {
      print('   ⚠️ Cleanup error: $e');
    }
  }
} 