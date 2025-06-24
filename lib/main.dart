import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'infrastructure/runtime/runtime_initializer.dart';
import 'infrastructure/database/database_service.dart';
import 'business/services/mcp_server_service.dart';
import 'business/services/mcp_hub_service.dart';
import 'business/services/config_service.dart';
import 'business/managers/mcp_process_manager.dart';
import 'core/models/mcp_server.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/config_import_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化窗口管理器
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'MCP Hub',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 🏗️ 初始化运行时环境
  print('🏗️ Initializing runtime environment...');
  try {
    final runtimeInitializer = RuntimeInitializer.instance;
    final runtimeSuccess = await runtimeInitializer.initializeAllRuntimes();
    if (runtimeSuccess) {
      print('✅ Runtime environment initialized successfully');
      
      // 初始化进程管理器
      final processManager = McpProcessManager.instance;
      await processManager.initialize();
      print('✅ Process manager initialized');
    } else {
      print('⚠️ Runtime environment initialization failed, some features may not work');
    }
  } catch (e) {
    print('❌ Runtime initialization error: $e');
  }

  // 💾 初始化数据库
  print('💾 Initializing database...');
  try {
    final dbService = DatabaseService.instance;
    await dbService.database; // 这会触发数据库初始化
    print('✅ Database initialized successfully');
  } catch (e) {
    print('❌ Database initialization error: $e');
  }

  // 🌐 启动MCP Hub服务器
  print('🌐 Starting MCP Hub Server...');
  try {
    final hubService = McpHubService.instance;
    await hubService.startHub();
    print('✅ MCP Hub Server started successfully on port 3000');
  } catch (e) {
    print('❌ Failed to start MCP Hub Server: $e');
  }

  runApp(const ProviderScope(child: McpHubApp()));
}

class McpHubApp extends StatelessWidget {
  const McpHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
