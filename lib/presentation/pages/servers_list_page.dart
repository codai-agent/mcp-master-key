import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:process_run/process_run.dart';
import 'dart:io';
import '../../core/models/mcp_server.dart';
import '../../infrastructure/repositories/mcp_server_repository.dart';
import '../../business/managers/mcp_process_manager.dart';
import '../../l10n/generated/app_localizations.dart';
import '../providers/servers_provider.dart';
import '../widgets/server_card.dart';
import '../widgets/mcp_config_dialog.dart';
import 'installation_wizard_page.dart';

import 'server_monitor_page.dart';

class ServersListPage extends ConsumerStatefulWidget {
  const ServersListPage({super.key});

  @override
  ConsumerState<ServersListPage> createState() => _ServersListPageState();
}

class _ServersListPageState extends ConsumerState<ServersListPage> {
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serversListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.servers_title),
        automaticallyImplyLeading: false,
        actions: [
          // GitHub图标
          Tooltip(
            message: l10n.tooltip_github,
            child: IconButton(
              icon: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/github.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.code);
                  },
                ),
              ),
              onPressed: () => _launchUrl('https://github.com/codai-agent/mcp-master-key'),
            ),
          ),
          // CodAI图标
          Tooltip(
            message: l10n.tooltip_mcp_client,
            child: IconButton(
              icon: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/codai.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.app_registration);
                  },
                ),
              ),
              onPressed: () => _launchUrl('https://github.com/codai-agent/codai/releases'),
            ),
          ),
          // QQ交流反馈图标
          Tooltip(
            message: l10n.tooltip_feedback,
            child: IconButton(
              icon: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/qq.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.forum);
                  },
                ),
              ),
              onPressed: () => _showFeedbackDialog(context, l10n),
            ),
          ),
          // 刷新图标
          Tooltip(
            message: l10n.tooltip_refresh,
            child: IconButton(
              icon: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/refresh.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.refresh);
                  },
                ),
              ),
              onPressed: () {
                ref.refresh(serversListProvider);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 紧凑的快速操作栏
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.flash_on, color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.servers_quick_actions, style: TextStyle(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (context) => const InstallationWizardPage()),
                        );
                        // 如果安装成功，刷新服务器列表
                        if (result == true && mounted) {
                          ref.refresh(serversListProvider);
                        }
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(l10n.servers_install),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => const McpConfigDialog(),
                        );
                      },
                      icon: const Icon(Icons.view_module, size: 18),
                      label: const Text('查看MCP配置'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        foregroundColor: Colors.teal,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
          
          // 搜索和筛选栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.servers_search_hint,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: [
                    DropdownMenuItem(value: 'name', child: Text(l10n.servers_sort_by_name)),
                    DropdownMenuItem(value: 'status', child: Text(l10n.servers_sort_by_status)),
                    DropdownMenuItem(value: 'created', child: Text(l10n.servers_sort_by_created)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // 服务器列表
          Expanded(
            child: serversAsync.when(
              data: (servers) {
                final filteredServers = _filterAndSortServers(servers);
                
                if (filteredServers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? l10n.servers_no_servers : l10n.servers_no_servers_found,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.servers_add_server_hint,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredServers.length,
                  itemBuilder: (context, index) {
                    final server = filteredServers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ServerCard(
                        server: server,
                        onStart: () => _startServer(server, l10n),
                        onStop: () => _stopServer(server, l10n),
                        onRestart: () => _restartServer(server, l10n),
                        onTap: () => _viewServerDetails(server),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.servers_load_error,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(serversListProvider);
                      },
                      child: Text(l10n.servers_retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     final result = await Navigator.push<bool>(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const InstallationWizardPage(),
      //       ),
      //     );
      //     // 如果安装成功，刷新服务器列表
      //     if (result == true && mounted) {
      //       ref.refresh(serversListProvider);
      //     }
      //   },
      //   icon: const Icon(Icons.add_circle),
      //   label: const Text('添加MCP服务器'),
      //   tooltip: '安装并添加新的MCP服务器',
      //   backgroundColor: Theme.of(context).primaryColor,
      // ),
    );
  }

  List<McpServer> _filterAndSortServers(List<McpServer> servers) {
    var filtered = servers;

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((server) {
        return server.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (server.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // 排序
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'status':
          comparison = a.status.name.compareTo(b.status.name);
          break;
        case 'created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _startServer(McpServer server, AppLocalizations l10n) async {
    try {
      // 立即显示启动中状态
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(l10n.servers_starting_message(server.name)),
            ],
          ),
          duration: const Duration(seconds: 30), // 延长显示时间
          backgroundColor: Colors.orange,
        ),
      );
      
      final serverActions = ref.read(serverActionsProvider);
      
      // 首先更新状态为启动中，立即刷新UI
      final startingServer = server.copyWith(
        status: McpServerStatus.starting,
        updatedAt: DateTime.now(),
      );
      await serverActions.updateServer(startingServer);
      
      // 执行实际的启动操作
      await serverActions.startServer(server.id);
      
      // 显示成功提示，状态变化会由StreamProvider自动刷新界面
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.rocket_launch, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.servers_starting_message(server.name)),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      // 隐藏之前的SnackBar并显示错误消息
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.servers_start_failed(e.toString()))),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      
      // 错误状态会由StreamProvider自动刷新
    }
  }

  void _stopServer(McpServer server, AppLocalizations l10n) async {
    try {
      // 立即显示停止中状态
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(l10n.servers_stopping_message(server.name)),
            ],
          ),
          duration: const Duration(seconds: 30),
          backgroundColor: Colors.orange,
        ),
      );
      
      final serverActions = ref.read(serverActionsProvider);
      
      // 首先更新状态为停止中，立即刷新UI
      final stoppingServer = server.copyWith(
        status: McpServerStatus.stopping,
        updatedAt: DateTime.now(),
      );
      await serverActions.updateServer(stoppingServer);
      
      // 执行实际的停止操作
      await serverActions.stopServer(server.id);
      
      // 显示成功提示，状态变化会由StreamProvider自动刷新界面
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.stop_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.servers_stopping_message(server.name)),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      // 隐藏之前的SnackBar并显示错误消息
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.servers_stop_failed(e.toString()))),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      
      // 错误状态会由StreamProvider自动刷新
    }
  }

  void _restartServer(McpServer server, AppLocalizations l10n) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.servers_restarting_message(server.name)),
          duration: const Duration(seconds: 2),
        ),
      );
      
      final serverActions = ref.read(serverActionsProvider);
      await serverActions.restartServer(server.id);
      
      // 服务器列表会自动刷新
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('服务器重启成功: ${server.name}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('重启失败: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _viewServerDetails(McpServer server) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServerMonitorPage(serverId: server.id),
      ),
    );
  }

  /// 启动URL
  Future<void> _launchUrl(String urlString) async {
    try {
      // 验证URL格式
      if (urlString.isEmpty) {
        throw 'URL不能为空';
      }
      
      ProcessResult result;
      if (Platform.isMacOS) {
        result = await run('open', [urlString]);
      } else if (Platform.isWindows) {
        result = await run('cmd', ['/c', 'start', '""', urlString]);
      } else if (Platform.isLinux) {
        result = await run('xdg-open', [urlString]);
      } else {
        throw '不支持的平台: ${Platform.operatingSystem}';
      }
      
      // 检查命令执行结果
      if (result.exitCode != 0) {
        final stderr = result.stderr?.toString() ?? '未知错误';
        throw '命令执行失败 (退出码: ${result.exitCode}): $stderr';
      }
      
      print('✅ 成功打开URL: $urlString');
      
    } catch (e) {
      print('❌ 打开URL失败: $urlString, 错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法打开链接\n$urlString\n\n错误: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '复制链接',
              textColor: Colors.white,
              onPressed: () {
                // TODO: 实现复制到剪贴板功能
              },
            ),
          ),
        );
      }
    }
  }

  /// 显示交流反馈对话框
  void _showFeedbackDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.feedback_dialog_title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                
                // 内容区域
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // QR码图片
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/qr.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.withOpacity(0.1),
                                child: const Center(
                                  child: Icon(
                                    Icons.qr_code,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 报告Bug按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _launchUrl('https://github.com/codai-agent/mcp-master-key/issues');
                          },
                          icon: const Icon(Icons.bug_report),
                          label: Text(l10n.feedback_report_bug),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 