import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/runtime/runtime_initializer.dart';
import '../../infrastructure/database/database_service.dart';
import '../../business/services/mcp_hub_service.dart';
import '../../business/managers/mcp_process_manager.dart';
import 'home_page.dart';

/// 启动画面，处理应用初始化
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _currentStatus = '正在启动 MCP Hub...';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // 最小显示时间，避免闪烁
      await Future.delayed(const Duration(milliseconds: 800));

      // 🏗️ 初始化运行时环境
      setState(() {
        _currentStatus = '正在初始化运行环境...';
      });
      await Future.delayed(const Duration(milliseconds: 300));

      final runtimeInitializer = RuntimeInitializer.instance;
      final runtimeSuccess = await runtimeInitializer.initializeAllRuntimes();
      
      if (runtimeSuccess) {
        setState(() {
          _currentStatus = '正在初始化进程管理器...';
        });
        await Future.delayed(const Duration(milliseconds: 200));

        final processManager = McpProcessManager.instance;
        await processManager.initialize();
      }

      // 💾 初始化数据库
      setState(() {
        _currentStatus = '正在初始化数据库...';
      });
      await Future.delayed(const Duration(milliseconds: 200));

      final dbService = DatabaseService.instance;
      await dbService.database;

      // 🌐 启动MCP Hub服务器
      setState(() {
        _currentStatus = '正在启动 MCP Hub 服务器...';
      });
      await Future.delayed(const Duration(milliseconds: 300));

      final hubService = McpHubService.instance;
      await hubService.startHub();

      setState(() {
        _currentStatus = '启动完成！';
        _isInitialized = true;
      });

      // 等待一下再跳转
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      setState(() {
        _currentStatus = '启动失败: $e';
      });
      
      // 即使失败也跳转到主页，让用户可以手动重试
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.hub,
                          color: Colors.white,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 应用名称
              Text(
                'MCP Hub',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 副标题
              Text(
                'Model Context Protocol 服务器管理平台',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 60),
              
              // 加载指示器
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    if (!_isInitialized)
                      LinearProgressIndicator(
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      )
                    else
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // 状态文本
                    Text(
                      _currentStatus,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isInitialized ? Colors.green : Colors.grey[600],
                        fontWeight: _isInitialized ? FontWeight.w500 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 