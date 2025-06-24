import 'dart:io';
import 'lib/business/services/mcp_server_service.dart';
import 'lib/business/managers/mcp_process_manager.dart';
import 'lib/infrastructure/runtime/runtime_manager.dart';
import 'lib/infrastructure/runtime/runtime_initializer.dart';
import 'lib/infrastructure/database/database_service.dart';

/// 简化的HotNews MCP服务器测试程序
/// 
/// 测试配置：
/// "mcp-server-hotnews": {
///   "disabled": true,
///   "timeout": 60,
///   "command": "npx",
///   "args": ["-y", "@wopal/mcp-server-hotnews"],
///   "transportType": "stdio"
/// }
Future<void> main() async {
  print('🧪 HotNews MCP Server Test - Simple Version');
  print('📋 This test will:');
  print('   1. Initialize database');
  print('   2. Add HotNews test server');
  print('   3. Test server lifecycle (start/stop)');
  print('');
  
  try {
    // 1. 初始化数据库
    print('💾 Step 1: Initialize database...');
    final databaseService = DatabaseService.instance;
    await databaseService.database; // 触发数据库初始化
    print('✅ Database initialized');
    
    // 2. 添加HotNews测试服务器
    print('🔧 Step 2: Add HotNews test server...');
    final serverService = McpServerService.instance;
    await serverService.addHotNewsTestServer();
    print('✅ HotNews server added');
    
    // 3. 列出所有服务器
    print('📋 Step 3: List all servers...');
    final servers = await serverService.getAllServers();
    print('📊 Found ${servers.length} servers:');
    for (final server in servers) {
      print('   - ${server.name} (${server.status.name}) - ${server.installSource}');
      print('     Command: ${server.command}');
      print('     Args: ${server.args.join(' ')}');
    }
    
    // 4. 找到HotNews服务器并测试
    final hotNewsServer = servers.firstWhere(
      (s) => s.name.contains('HotNews'),
      orElse: () => throw Exception('HotNews server not found'),
    );
    
    print('🧪 Step 4: Test HotNews server lifecycle...');
    await serverService.testServerLifecycle('HotNews');
    
    print('');
    print('✅ All tests completed successfully!');
    print('🎉 npm exec functionality is working correctly');
    
  } catch (e) {
    print('❌ Test failed: $e');
    print('🔍 Stack trace: ${StackTrace.current}');
    exit(1);
  }
}

/// 初始化数据库
Future<void> _initializeDatabase() async {
  print('💾 Initializing database...');
  
  try {
    final dbService = DatabaseService.instance;
    await dbService.database;
    print('   ✅ Database initialized successfully');
  } catch (e) {
    print('   ❌ Database initialization failed: $e');
    throw e;
  }
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