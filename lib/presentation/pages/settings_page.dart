import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/system_info_widget.dart';
import '../providers/servers_provider.dart';
import '../../business/services/config_service.dart';
import '../../core/constants/app_constants.dart';
import '../themes/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';

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
    final configService = ConfigService.instance;
    
    final useChinaMirrors = await configService.getUseChinaMirrors();
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            // 通用设置
            _buildSectionCard(
              title: l10n.settings_general,
              children: [
                ListTile(
                  title: Text(l10n.settings_language),
                  subtitle: Text(_getLanguageDisplayName(ref.watch(localeProvider))),
                  trailing: DropdownButton<AppLanguage>(
                    value: ref.watch(localeProvider),
                    items: AppLanguage.values.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(_getLanguageDisplayName(language)),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        await ref.read(localeProvider.notifier).setLanguage(value);
                      }
                    },
                  ),
                ),
                SwitchListTile(
                  title: Text(l10n.settings_theme),
                  subtitle: Text(_getThemeDisplayName(ref.watch(themeProvider))),
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
              title: l10n.settings_hub,
              children: [
                ListTile(
                  title: Text(l10n.settings_runtime_mode),
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
              title: l10n.settings_app_behavior,
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
              title: l10n.settings_log_settings,
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
              title: l10n.settings_download_settings,
              children: [
                SwitchListTile(
                  title: const Text('使用中国大陆镜像源'),
                  subtitle: const Text('使用清华大学等国内镜像源加速包下载'),
                  value: _useChinaMirrors,
                  onChanged: (value) async {
                    setState(() {
                      _useChinaMirrors = value;
                    });
                    await ConfigService.instance.setUseChinaMirrors(value);
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
                  subtitle: _buildMirrorStatusWithErrorHandling(),
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
              title: l10n.settings_storage_management,
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.computer,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '系统信息',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            '操作系统:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _getOperatingSystemSimple(),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            '运行时状态:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.construction,
                                  size: 16,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '开发中...',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '详细的系统信息检查功能正在优化中，将在后续版本提供更稳定的体验。',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 关于
            _buildSectionCard(
              title: l10n.settings_about_section,
              children: [
                ListTile(
                  title: const Text('版本'),
                  subtitle: Text('${AppVersion.appName} ${AppVersion.displayVersion}'),
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
            
            // 添加底部安全间距
            const SizedBox(height: 50),
          ],
        ),
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
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case 'sse':
        return l10n.settings_single_client_mode;
      case 'streamable':
        return l10n.settings_multi_client_support;
      default:
        return mode;
    }
  }

  String _getServerModeHelp(String mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case 'sse':
        return l10n.settings_single_client_help;
      case 'streamable':
        return l10n.settings_multi_client_help;
      default:
        return '';
    }
  }

  Future<void> _changeServerMode(String newMode) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final configService = ConfigService.instance;
      await configService.setMcpServerMode(newMode);
      
      setState(() {
        _serverMode = newMode;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settings_mode_changed(_getServerModeDescription(newMode))),
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
            content: Text(l10n.settings_mode_change_failed(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_restart_required_title),
        content: Text(l10n.settings_restart_required_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.settings_restart_later),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _restartHubService();
            },
            child: Text(l10n.settings_restart_now),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_clear_cache_title),
        content: Text(l10n.settings_clear_cache_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performCleanup();
            },
            child: Text(l10n.settings_confirm),
          ),
        ],
      ),
    );
  }

  void _performCleanup() {
    final l10n = AppLocalizations.of(context)!;
    // TODO: 实现清理逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settings_cache_cleared)),
    );
  }

  void _exportConfiguration() {
    final l10n = AppLocalizations.of(context)!;
    // TODO: 实现配置导出
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settings_export_todo)),
    );
  }



  void _checkForUpdates() {
    final l10n = AppLocalizations.of(context)!;
    // TODO: 实现更新检查
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settings_already_latest)),
    );
  }

  void _showLicenseDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_license_title),
        content: const SingleChildScrollView(
          child: Text(
            'MCP Master Key\n\n'
            'Copyright (c) 2025 codai studio\n\n'
            'Licensed under the Apache License, Version 2.0 (the "License");\n\n'
            'you may not use this file except in compliance with the License. '
            'You may obtain a copy of the License at \n\n'
            'http://www.apache.org/licenses/LICENSE-2.0 \n\n'
            'Unless required by applicable law or agreed to in writing, software '
            'distributed under the License is distributed on an "AS IS" BASIS, '
            'WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.'
            'See the License for the specific language governing permissions and '
            'limitations under the License.\n',
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

  /// 获取语言显示名称
  String _getLanguageDisplayName(AppLanguage language) {
    final l10n = AppLocalizations.of(context)!;
    switch (language) {
      case AppLanguage.system:
        return l10n.settings_language_system;
      case AppLanguage.english:
        return l10n.settings_language_en;
      case AppLanguage.chinese:
        return l10n.settings_language_zh;
    }
  }

  /// 获取主题显示名称
  String _getThemeDisplayName(ThemeMode themeMode) {
    final l10n = AppLocalizations.of(context)!;
    switch (themeMode) {
      case ThemeMode.system:
        return l10n.settings_theme_system;
      case ThemeMode.light:
        return l10n.settings_theme_light;
      case ThemeMode.dark:
        return l10n.settings_theme_dark;
    }
  }

  Widget _buildMirrorStatusWithErrorHandling() {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<String>(
      future: ConfigService.instance.getPythonMirrorUrl(),
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
    );
  }

  Widget _buildSystemInfoWithErrorHandling() {
    return const SystemInfoWidget();
  }

  String _getOperatingSystemSimple() {
    try {
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
} 