import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/runtime/runtime_initializer.dart';
import '../../infrastructure/database/database_service.dart';
import '../../business/services/mcp_hub_service.dart';
import '../../business/managers/mcp_process_manager.dart';
import '../../l10n/generated/app_localizations.dart';
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
  String _currentStatus = '';
  bool _isInitialized = false;
  bool _hasStartedInitialization = false;

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
    // 不在这里调用_initializeApp，而是在build中延迟调用
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    if (_hasStartedInitialization) return;
    _hasStartedInitialization = true;
    
    try {
      // 获取本地化文本，此时应该已经准备好了
      final l10n = AppLocalizations.of(context)!;
      
      // 最小显示时间，避免闪烁
      setState(() {
        _currentStatus = l10n.splash_initializing;
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // 🏗️ 初始化运行时环境
      setState(() {
        _currentStatus = l10n.splash_init_runtime;
      });
      await Future.delayed(const Duration(milliseconds: 300));

      final runtimeInitializer = RuntimeInitializer.instance;
      final runtimeSuccess = await runtimeInitializer.initializeAllRuntimes();
      
      if (runtimeSuccess) {
        setState(() {
          _currentStatus = l10n.splash_init_process;
        });
        await Future.delayed(const Duration(milliseconds: 200));

        final processManager = McpProcessManager.instance;
        await processManager.initialize();
      }

      // 💾 初始化数据库
      setState(() {
        _currentStatus = l10n.splash_init_database;
      });
      await Future.delayed(const Duration(milliseconds: 200));

      final dbService = DatabaseService.instance;
      await dbService.database;

      // 🌐 启动MCP Hub服务器
      setState(() {
        _currentStatus = l10n.splash_init_hub;
      });
      await Future.delayed(const Duration(milliseconds: 300));

      final hubService = McpHubService.instance;
      await hubService.startHub();

      setState(() {
        _currentStatus = l10n.splash_init_complete;
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
      final l10n = AppLocalizations.of(context);
      setState(() {
        _currentStatus = l10n != null ? '${l10n.splash_init_error}: $e' : 'Initialization error: $e';
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
    // 在第一次build时启动初始化，此时国际化系统应该已经准备好了
    if (!_hasStartedInitialization) {
      // 使用postFrameCallback确保在build完成后再开始初始化
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeApp();
      });
    }
    
    // 安全地获取本地化文本，如果还没准备好就使用默认值
    AppLocalizations? l10n;
    try {
      l10n = AppLocalizations.of(context);
    } catch (e) {
      // 如果国际化还没准备好，使用null
    }
    
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
                l10n?.appTitle ?? 'MCP Master Key',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 副标题
              Text(
                l10n?.appSubtitle ?? 'Unified Management Center for MCP Servers',
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
                      _currentStatus.isEmpty ? (l10n?.splash_initializing ?? 'Initializing...') : _currentStatus,
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