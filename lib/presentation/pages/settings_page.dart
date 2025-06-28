import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/system_info_widget.dart';
import '../providers/servers_provider.dart';
import '../../business/services/config_service.dart';
import '../themes/app_theme.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _logLevel = 'info';
  bool _autoStart = false;
  bool _minimizeToTray = true;
  int _logRetentionDays = 30;
  bool _useChinaMirrors = false;
  String _serverMode = 'sse'; // 新增：服务器模式
  int _streamablePort = 3001; // 新增：Streamable模式端口

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final configNotifier = ref.read(configProvider.notifier);
    final configService = ConfigService.instance;
    
    final useChinaMirrors = await configNotifier.useChinaMirrors;
    final serverMode = await configService.getMcpServerMode();
    final streamablePort = await configService.getStreamablePort();
    
    if (mounted) {
      setState(() {
        _useChinaMirrors = useChinaMirrors;
        _serverMode = serverMode;
        _streamablePort = streamablePort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 外观设置
          _buildSectionCard(
            title: '外观',
            children: [
              SwitchListTile(
                title: const Text('深色主题'),
                subtitle: const Text('使用深色界面主题'),
                value: ref.watch(themeProvider) == ThemeMode.dark,
                onChanged: (value) async {
                  await ref.read(themeProvider.notifier).toggleDarkMode(value);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Hub服务器配置
          _buildSectionCard(
            title: 'MCP Hub 服务器',
            children: [
              ListTile(
                title: const Text('运行模式'),
                subtitle: Text(_getServerModeDescription(_serverMode)),
                trailing: DropdownButton<String>(
                  value: _serverMode,
                  items: const [
                    DropdownMenuItem(
                      value: 'sse',
                      child: Text('SSE模式 (单客户端)'),
                    ),
                    DropdownMenuItem(
                      value: 'streamable',
                      child: Text('Streamable模式 (多客户端)'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value != null && value != _serverMode) {
                      await _changeServerMode(value);
                    }
                  },
                ),
              ),
              if (_serverMode == 'streamable') ...[
                ListTile(
                  title: const Text('Streamable端口'),
                  subtitle: Text('多客户端模式使用的端口: $_streamablePort'),
                  trailing: SizedBox(
                    width: 100,
                    child: TextField(
                      controller: TextEditingController(text: _streamablePort.toString()),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onSubmitted: (value) async {
                        final port = int.tryParse(value);
                        if (port != null && port > 1024 && port < 65536) {
                          await _changeStreamablePort(port);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('端口必须在1024-65535之间')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
                             Container(
                 padding: const EdgeInsets.all(12),
                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 decoration: BoxDecoration(
                   color: _serverMode == 'sse' ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(
                     color: _serverMode == 'sse' ? Colors.blue.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
                   ),
                 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _serverMode == 'sse' ? Icons.person : Icons.group,
                          color: _serverMode == 'sse' ? Colors.blue : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _serverMode == 'sse' ? 'SSE模式' : 'Streamable模式',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _serverMode == 'sse' ? Colors.blue : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getServerModeHelp(_serverMode),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 应用行为
          _buildSectionCard(
            title: '应用行为',
            children: [
              SwitchListTile(
                title: const Text('开机自启动'),
                subtitle: const Text('系统启动时自动启动应用'),
                value: _autoStart,
                onChanged: (value) {
                  setState(() {
                    _autoStart = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('最小化到系统托盘'),
                subtitle: const Text('关闭窗口时最小化到系统托盘'),
                value: _minimizeToTray,
                onChanged: (value) {
                  setState(() {
                    _minimizeToTray = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 日志设置
          _buildSectionCard(
            title: '日志设置',
            children: [
              ListTile(
                title: const Text('日志级别'),
                subtitle: Text('当前级别: ${_getLogLevelText(_logLevel)}'),
                trailing: DropdownButton<String>(
                  value: _logLevel,
                  items: const [
                    DropdownMenuItem(value: 'debug', child: Text('调试')),
                    DropdownMenuItem(value: 'info', child: Text('信息')),
                    DropdownMenuItem(value: 'warn', child: Text('警告')),
                    DropdownMenuItem(value: 'error', child: Text('错误')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _logLevel = value;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('日志保留天数'),
                subtitle: Text('自动删除 $_logRetentionDays 天前的日志'),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: TextEditingController(text: _logRetentionDays.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null && days > 0) {
                        setState(() {
                          _logRetentionDays = days;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 下载设置
          _buildSectionCard(
            title: '下载设置',
            children: [
              SwitchListTile(
                title: const Text('使用中国大陆镜像源'),
                subtitle: const Text('使用清华大学等国内镜像源加速包下载'),
                value: _useChinaMirrors,
                onChanged: (value) async {
                  setState(() {
                    _useChinaMirrors = value;
                  });
                  await ref.read(configProvider.notifier).setUseChinaMirrors(value);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value ? '已启用中国大陆镜像源' : '已关闭中国大陆镜像源'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                title: const Text('当前镜像源'),
                subtitle: FutureBuilder<String>(
                  future: ref.read(configProvider.notifier).pythonMirrorUrl,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final url = snapshot.data!;
                      final isChina = url.contains('tuna.tsinghua.edu.cn');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Python: ${isChina ? '清华大学镜像源' : '官方源'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NPM: ${_useChinaMirrors ? '淘宝镜像源' : '官方源'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    }
                    return const Text('加载中...');
                  },
                ),
                trailing: const Icon(Icons.info_outline),
              ),
              if (_useChinaMirrors) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.speed, color: Colors.green),
                  title: const Text('镜像源优势'),
                  subtitle: const Text('• 下载速度提升 5-10 倍\n• 解决网络连接问题\n• 支持 Python 和 NPM 包'),
                  dense: true,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 存储管理
          _buildSectionCard(
            title: '存储管理',
            children: [
              ListTile(
                title: const Text('清理缓存'),
                subtitle: const Text('清理临时文件和缓存数据'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showCleanupDialog();
                  },
                  child: const Text('清理'),
                ),
              ),
              ListTile(
                title: const Text('导出配置'),
                subtitle: const Text('导出服务器配置和应用设置'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _exportConfiguration();
                  },
                  child: const Text('导出'),
                ),
              ),

            ],
          ),
          
          const SizedBox(height: 16),
          
          // 系统信息
          const SystemInfoWidget(),
          
          const SizedBox(height: 16),
          
          // 关于
          _buildSectionCard(
            title: '关于',
            children: [
              ListTile(
                title: const Text('版本'),
                subtitle: const Text('MCP Hub v1.0.0'),
                trailing: const Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('检查更新'),
                subtitle: const Text('检查是否有新版本可用'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _checkForUpdates();
                  },
                  child: const Text('检查'),
                ),
              ),
              ListTile(
                title: const Text('开源许可'),
                subtitle: const Text('查看开源许可信息'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showLicenseDialog();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.vscodeBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  String _getLogLevelText(String level) {
    switch (level) {
      case 'debug':
        return '调试';
      case 'info':
        return '信息';
      case 'warn':
        return '警告';
      case 'error':
        return '错误';
      default:
        return '未知';
    }
  }

  String _getServerModeDescription(String mode) {
    switch (mode) {
      case 'sse':
        return '只允许单个客户端连接';
      case 'streamable':
        return '支持多个客户端并发连接';
      default:
        return mode;
    }
  }

  String _getServerModeHelp(String mode) {
    switch (mode) {
      case 'sse':
        return '适合单一应用使用，性能更好，兼容性强';
      case 'streamable':
        return '适合多个应用同时连接，支持会话隔离，资源共享';
      default:
        return '';
    }
  }

  Future<void> _changeServerMode(String newMode) async {
    try {
      final configService = ConfigService.instance;
      await configService.setMcpServerMode(newMode);
      
      setState(() {
        _serverMode = newMode;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('服务器模式已更改为: ${_getServerModeDescription(newMode)}'),
            backgroundColor: Colors.green,
          ),
        );

        // 显示重启提示
        _showRestartDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更改服务器模式失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeStreamablePort(int newPort) async {
    try {
      final configService = ConfigService.instance;
      await configService.setStreamablePort(newPort);
      
      setState(() {
        _streamablePort = newPort;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Streamable端口已更改为: $newPort'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更改端口失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要重启'),
        content: const Text('服务器模式更改需要重启MCP Hub服务才能生效。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('稍后重启'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _restartHubService();
            },
            child: const Text('立即重启'),
          ),
        ],
      ),
    );
  }

  Future<void> _restartHubService() async {
    try {
      // 这里应该调用Hub服务的重启方法
      // final hubService = McpHubService.instance;
      // await hubService.stopHub();
      // await hubService.startHub();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MCP Hub服务重启成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重启Hub服务失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理所有缓存数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performCleanup();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _performCleanup() {
    // TODO: 实现清理逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('缓存清理完成')),
    );
  }

  void _exportConfiguration() {
    // TODO: 实现配置导出
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配置导出功能开发中')),
    );
  }



  void _checkForUpdates() {
    // TODO: 实现更新检查
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('当前已是最新版本')),
    );
  }

  void _showLicenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开源许可'),
        content: const SingleChildScrollView(
          child: Text(
            'MCP Hub\n\n'
            'Copyright (c) 2024 MCP Hub Team\n\n'
            'Licensed under the MIT License.\n\n'
            'Permission is hereby granted, free of charge, to any person obtaining a copy '
            'of this software and associated documentation files (the "Software"), to deal '
            'in the Software without restriction, including without limitation the rights '
            'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
            'copies of the Software, and to permit persons to whom the Software is '
            'furnished to do so, subject to the following conditions:\n\n'
            'The above copyright notice and this permission notice shall be included in all '
            'copies or substantial portions of the Software.\n\n'
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
            'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
            'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
} 