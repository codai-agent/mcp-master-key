import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'presentation/pages/splash_page.dart';

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

  // 启动应用，使用启动画面处理初始化
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
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
