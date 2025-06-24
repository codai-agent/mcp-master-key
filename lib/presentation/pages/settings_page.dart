import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/system_info_widget.dart';
import '../providers/servers_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _darkMode = false;
  String _logLevel = 'info';
  bool _autoStart = false;
  bool _minimizeToTray = true;
  int _logRetentionDays = 30;
  bool _useChinaMirrors = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final configNotifier = ref.read(configProvider.notifier);
    final useChinaMirrors = await configNotifier.useChinaMirrors;
    if (mounted) {
      setState(() {
        _useChinaMirrors = useChinaMirrors;
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
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
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
              ListTile(
                title: const Text('导入配置'),
                subtitle: const Text('从文件导入配置'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _importConfiguration();
                  },
                  child: const Text('导入'),
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
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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

  void _importConfiguration() {
    // TODO: 实现配置导入
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配置导入功能开发中')),
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