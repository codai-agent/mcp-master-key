import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mcp_server.dart';
import '../../presentation/providers/servers_provider.dart';
import '../widgets/server_card.dart';
import 'installation_wizard_page.dart';
import 'config_import_page.dart';
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
    final serversAsync = ref.watch(serversListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP 服务器'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(serversListProvider);
            },
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
                    const Text('快速操作', style: TextStyle(fontWeight: FontWeight.w500)),
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
                      label: const Text('安装MCP服务器'),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConfigImportPage()),
                      ),
                      icon: const Icon(Icons.file_upload, size: 18),
                      label: const Text('导入配置'),
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
                    decoration: const InputDecoration(
                      hintText: '搜索服务器...',
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
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('名称')),
                    DropdownMenuItem(value: 'status', child: Text('状态')),
                    DropdownMenuItem(value: 'created', child: Text('时间')),
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
                          _searchQuery.isEmpty ? '暂无服务器' : '未找到匹配的服务器',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击浮动按钮开始添加服务器',
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
                        onStart: () => _startServer(server),
                        onStop: () => _stopServer(server),
                        onRestart: () => _restartServer(server),
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
                      '加载失败',
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
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const InstallationWizardPage(),
            ),
          );
          // 如果安装成功，刷新服务器列表
          if (result == true && mounted) {
            ref.refresh(serversListProvider);
          }
        },
        icon: const Icon(Icons.add_circle),
        label: const Text('添加MCP服务器'),
        tooltip: '安装并添加新的MCP服务器',
        backgroundColor: Theme.of(context).primaryColor,
      ),
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

  void _startServer(McpServer server) async {
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
              Text('正在启动服务器: ${server.name}...'),
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
              Text('正在启动服务器: ${server.name}'),
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
              Expanded(child: Text('启动失败: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      
      // 错误状态会由StreamProvider自动刷新
    }
  }

  void _stopServer(McpServer server) async {
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
              Text('正在停止服务器: ${server.name}...'),
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
              Text('正在停止服务器: ${server.name}'),
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
              Expanded(child: Text('停止失败: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      
      // 错误状态会由StreamProvider自动刷新
    }
  }

  void _restartServer(McpServer server) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('正在重启服务器: ${server.name}'),
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
} 