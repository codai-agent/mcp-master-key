// import 'dart:io';
// import 'package:test/test.dart';
// import '../lib/core/models/mcp_server.dart';
// import '../lib/business/services/install_service.dart';
// import '../lib/business/services/process_service.dart';
// import '../lib/infrastructure/runtime/runtime_manager.dart';
// import '../lib/business/services/config_service.dart';
//
// void main() {
//   group('UVX Refactor Tests', () {
//     late InstallService installService;
//     late ProcessService processService;
//     late RuntimeManager runtimeManager;
//
//     setUpAll(() async {
//       print('🚀 Setting up test environment...');
//
//       // 初始化服务
//       installService = InstallService.instance;
//       processService = ProcessService.instance;
//       runtimeManager = RuntimeManager.instance;
//
//       // 初始化运行时管理器
//       await runtimeManager.initialize();
//
//       print('✅ Test environment setup complete');
//     });
//
//     test('UVX Install Manager - Package Installation', () async {
//       print('\n📦 Testing UVX package installation...');
//
//       // 创建测试服务器配置
//       final testServer = McpServer(
//         id: 'test_uvx_${DateTime.now().millisecondsSinceEpoch}',
//         name: 'Test UVX Server',
//         command: 'uvx',
//         args: ['mcp-server-time'], // 使用一个简单的测试包
//         installType: McpInstallType.uvx,
//         installSource: 'mcp-server-time',
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//
//       print('   🔧 Server config:');
//       print('   - Name: ${testServer.name}');
//       print('   - Install Type: ${testServer.installType.name}');
//       print('   - Command: ${testServer.command}');
//       print('   - Args: ${testServer.args}');
//       print('   - Install Source: ${testServer.installSource}');
//
//       // 测试安装
//       print('\n   📦 Starting installation...');
//       final installResult = await installService.installServer(testServer);
//
//       print('   📊 Install result:');
//       print('   - Success: ${installResult.success}');
//       print('   - Install Type: ${installResult.installType.name}');
//       if (installResult.output != null) {
//         print('   - Output: ${installResult.output}');
//       }
//       if (installResult.errorMessage != null) {
//         print('   - Error: ${installResult.errorMessage}');
//       }
//       if (installResult.installPath != null) {
//         print('   - Install Path: ${installResult.installPath}');
//       }
//
//       // 验证安装结果
//       expect(installResult.success, isTrue, reason: 'Installation should succeed');
//       expect(installResult.installType, equals(McpInstallType.uvx));
//
//       // 检查是否已安装
//       print('\n   🔍 Checking installation status...');
//       final isInstalled = await installService.isServerInstalled(testServer);
//       print('   - Is Installed: $isInstalled');
//       expect(isInstalled, isTrue, reason: 'Package should be installed');
//
//       print('   ✅ UVX installation test passed');
//     });
//
//     test('UVX Process Manager - Process Startup', () async {
//       print('\n🚀 Testing UVX process startup...');
//
//       // 创建测试服务器配置
//       final testServer = McpServer(
//         id: 'test_uvx_process_${DateTime.now().millisecondsSinceEpoch}',
//         name: 'Test UVX Process Server',
//         command: 'uvx',
//         args: ['mcp-server-time'],
//         installType: McpInstallType.uvx,
//         installSource: 'mcp-server-time',
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//
//       print('   🔧 Server config:');
//       print('   - Name: ${testServer.name}');
//       print('   - Install Type: ${testServer.installType.name}');
//       print('   - Command: ${testServer.command}');
//       print('   - Args: ${testServer.args}');
//
//       // 确保包已安装
//       print('\n   📦 Ensuring package is installed...');
//       final isInstalled = await installService.isServerInstalled(testServer);
//       if (!isInstalled) {
//         print('   📥 Installing package first...');
//         final installResult = await installService.installServer(testServer);
//         expect(installResult.success, isTrue, reason: 'Pre-installation should succeed');
//       }
//
//       // 测试启动进程
//       print('\n   🚀 Starting process...');
//       final processResult = await processService.startServer(testServer);
//
//       print('   📊 Process result:');
//       print('   - Success: ${processResult.success}');
//       print('   - Server ID: ${processResult.serverId}');
//       print('   - Process ID: ${processResult.processId}');
//       if (processResult.errorMessage != null) {
//         print('   - Error: ${processResult.errorMessage}');
//       }
//       if (processResult.metadata != null) {
//         print('   - Metadata: ${processResult.metadata}');
//       }
//
//       // 验证启动结果
//       expect(processResult.success, isTrue, reason: 'Process startup should succeed');
//       expect(processResult.processId, isNotNull, reason: 'Process ID should be provided');
//
//       // 检查进程是否运行中
//       print('\n   🔍 Checking process status...');
//       final isRunning = processService.isServerRunning(testServer.id);
//       print('   - Is Running: $isRunning');
//       expect(isRunning, isTrue, reason: 'Process should be running');
//
//       // 等待一段时间让进程稳定
//       print('\n   ⏳ Waiting for process to stabilize...');
//       await Future.delayed(const Duration(seconds: 3));
//
//       // 测试停止进程
//       print('\n   🛑 Stopping process...');
//       final stopResult = await processService.stopServer(testServer);
//
//       print('   📊 Stop result:');
//       print('   - Success: ${stopResult.success}');
//       print('   - Server ID: ${stopResult.serverId}');
//       if (stopResult.errorMessage != null) {
//         print('   - Error: ${stopResult.errorMessage}');
//       }
//
//       // 验证停止结果
//       expect(stopResult.success, isTrue, reason: 'Process stop should succeed');
//
//       // 检查进程是否已停止
//       await Future.delayed(const Duration(seconds: 1));
//       final isStillRunning = processService.isServerRunning(testServer.id);
//       print('   - Is Still Running: $isStillRunning');
//       expect(isStillRunning, isFalse, reason: 'Process should be stopped');
//
//       print('   ✅ UVX process management test passed');
//     });
//
//     test('UVX End-to-End Test', () async {
//       print('\n🎯 Running UVX end-to-end test...');
//
//       // 创建测试服务器配置
//       final testServer = McpServer(
//         id: 'test_uvx_e2e_${DateTime.now().millisecondsSinceEpoch}',
//         name: 'Test UVX E2E Server',
//         command: 'uvx',
//         args: ['mcp-server-time'],
//         installType: McpInstallType.uvx,
//         installSource: 'mcp-server-time',
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//
//       print('   🔧 Server config: ${testServer.name}');
//
//       // 1. 安装
//       print('\n   1️⃣ Installing...');
//       final installResult = await installService.installServer(testServer);
//       expect(installResult.success, isTrue);
//       print('   ✅ Installation: ${installResult.success}');
//
//       // 2. 验证安装
//       print('\n   2️⃣ Verifying installation...');
//       final isInstalled = await installService.isServerInstalled(testServer);
//       expect(isInstalled, isTrue);
//       print('   ✅ Verification: $isInstalled');
//
//       // 3. 启动
//       print('\n   3️⃣ Starting process...');
//       final startResult = await processService.startServer(testServer);
//       expect(startResult.success, isTrue);
//       print('   ✅ Start: ${startResult.success} (PID: ${startResult.processId})');
//
//       // 4. 运行一段时间
//       print('\n   4️⃣ Running for 5 seconds...');
//       await Future.delayed(const Duration(seconds: 5));
//       final isRunning = processService.isServerRunning(testServer.id);
//       expect(isRunning, isTrue);
//       print('   ✅ Running: $isRunning');
//
//       // 5. 停止
//       print('\n   5️⃣ Stopping process...');
//       final stopResult = await processService.stopServer(testServer);
//       expect(stopResult.success, isTrue);
//       print('   ✅ Stop: ${stopResult.success}');
//
//       // 6. 验证停止
//       await Future.delayed(const Duration(seconds: 2));
//       final isStopped = !processService.isServerRunning(testServer.id);
//       expect(isStopped, isTrue);
//       print('   ✅ Stopped: $isStopped');
//
//       print('\n   🎉 End-to-end test completed successfully!');
//     });
//
//     tearDownAll(() async {
//       print('\n🧹 Cleaning up test environment...');
//
//       // 停止所有测试进程
//       await processService.stopAllServers();
//
//       // 释放资源
//       await processService.dispose();
//
//       print('✅ Test cleanup complete');
//     });
//   });
// }