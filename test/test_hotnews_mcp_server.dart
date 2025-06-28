import 'dart:io';
import 'package:flutter/material.dart';
import '../lib/business/services/mcp_server_service.dart';
import '../lib/business/managers/mcp_process_manager.dart';
import '../lib/infrastructure/runtime/runtime_manager.dart';
import '../lib/infrastructure/runtime/runtime_initializer.dart';

/// HotNews MCP服务器测试程序
/// 
/// 测试配置：
/// "mcp-server-hotnews": {
///   "disabled": true,
///   "timeout": 60,
///   "command": "npx",
///   "args": ["-y", "@wopal/mcp-server-hotnews"],
///   "transportType": "stdio"
/// }
void main() async {
  print('🧪 Starting HotNews MCP Server Test');
  print('=' * 60);
  
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. 初始化运行时环境
    print('📋 Step 1: Initializing runtime environment...');
    await _initializeRuntime();
    
    // 2. 添加HotNews服务器
    print('\n📋 Step 2: Adding HotNews MCP server...');
    await _addHotNewsServer();
    
    // 3. 测试服务器生命周期
    print('\n📋 Step 3: Testing server lifecycle...');
    await _testServerLifecycle();
    
    print('\n✅ All tests completed successfully!');
    
  } catch (e) {
    print('\n❌ Test failed: $e');
    print('🔍 Stack trace: ${StackTrace.current}');
    exit(1);
  }
  
  exit(0);
}

/// 初始化运行时环境
Future<void> _initializeRuntime() async {
  print('🏗️ Initializing runtime components...');
  
  // 初始化运行时
  final runtimeInitializer = RuntimeInitializer.instance;
  final initSuccess = await runtimeInitializer.initializeAllRuntimes();
  if (initSuccess) {
    print('   ✅ Runtime initializer completed');
  } else {
    print('   ❌ Runtime initialization failed');
    throw Exception('Runtime initialization failed');
  }
  
  // 初始化进程管理器
  final processManager = McpProcessManager.instance;
  await processManager.initialize();
  print('   ✅ Process manager initialized');
  
  // 验证运行时环境
  await _verifyRuntimeEnvironment();
}

/// 验证运行时环境
Future<void> _verifyRuntimeEnvironment() async {
  print('🔍 Verifying runtime environment...');
  
  final runtimeManager = RuntimeManager.instance;
  
  // 验证Node.js
  try {
    final nodeExe = await runtimeManager.getNodeExecutable();
    print('   🟢 Node.js executable: $nodeExe');
    
    final nodeResult = await Process.run(nodeExe, ['--version']);
    if (nodeResult.exitCode == 0) {
      print('   ✅ Node.js version: ${nodeResult.stdout.toString().trim()}');
    } else {
      print('   ❌ Node.js test failed: ${nodeResult.stderr}');
    }
  } catch (e) {
    print('   ❌ Node.js verification failed: $e');
  }
  
  // 验证NPX
  try {
    final npxExe = await runtimeManager.getNpxExecutable();
    print('   📦 NPX executable: $npxExe');
    
    // 检查NPX是否可用（可能会失败，这是预期的）
    try {
      final npxResult = await Process.run(npxExe, ['--version']);
      if (npxResult.exitCode == 0) {
        print('   ✅ NPX version: ${npxResult.stdout.toString().trim()}');
      } else {
        print('   ⚠️ NPX test returned non-zero: ${npxResult.exitCode}');
        print('   📝 This is expected due to NPX path issues, will use node directly');
      }
    } catch (e) {
      print('   ⚠️ NPX test failed: $e');
      print('   📝 This is expected, will use alternative approach');
    }
  } catch (e) {
    print('   ❌ NPX verification failed: $e');
  }
}

/// 添加HotNews服务器
Future<void> _addHotNewsServer() async {
  print('📦 Adding HotNews MCP server...');
  
  final serverService = McpServerService.instance;
  
  // 调用专门的测试方法
  await serverService.addHotNewsTestServer();
  
  // 验证服务器已添加
  final servers = await serverService.getAllServers();
  final hotNewsServer = servers.where((s) => s.name.contains('HotNews')).toList();
  
  if (hotNewsServer.isNotEmpty) {
    print('✅ HotNews server found in database:');
    for (final server in hotNewsServer) {
      print('   📋 Server details:');
      print('   - ID: ${server.id}');
      print('   - Name: ${server.name}');
      print('   - Status: ${server.status.name}');
      print('   - Install Type: ${server.installType.name}');
      print('   - Command: ${server.command}');
      print('   - Args: ${server.args.join(' ')}');
      print('   - Install Source: ${server.installSource}');
    }
  } else {
    throw Exception('HotNews server not found after adding');
  }
}

/// 测试服务器生命周期
Future<void> _testServerLifecycle() async {
  print('🔄 Testing HotNews server lifecycle...');
  
  final serverService = McpServerService.instance;
  
  try {
    // 测试完整生命周期
    await serverService.testServerLifecycle('HotNews');
    
    print('✅ Lifecycle test completed successfully');
    
  } catch (e) {
    print('❌ Lifecycle test failed: $e');
    
    // 尝试获取进程管理器状态
    final processManager = McpProcessManager.instance;
    final runningServers = processManager.getRunningServerIds();
    print('📋 Currently running servers: ${runningServers.length}');
    for (final serverId in runningServers) {
      print('   - Server ID: $serverId');
    }
    
    rethrow;
  }
} 