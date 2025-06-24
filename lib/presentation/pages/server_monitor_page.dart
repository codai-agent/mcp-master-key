import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mcp_server.dart';
import '../../infrastructure/repositories/mcp_server_repository.dart';
import '../../business/managers/enhanced_mcp_process_manager.dart';
import '../../infrastructure/mcp/mcp_tools_aggregator.dart';
import '../providers/servers_provider.dart';

class ServerMonitorPage extends ConsumerStatefulWidget {
  final String serverId;
  
  const ServerMonitorPage({Key? key, required this.serverId}) : super(key: key);

  @override
  ConsumerState<ServerMonitorPage> createState() => _ServerMonitorPageState();
}

class _ServerMonitorPageState extends ConsumerState<ServerMonitorPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final McpServerRepository _repository = McpServerRepository.instance;
  final EnhancedMcpProcessManager _processManager = EnhancedMcpProcessManager.instance;
  final McpToolsAggregator _toolsAggregator = McpToolsAggregator.instance;
  
  List<McpLogEntry> _logs = [];
  bool _isLoadingLogs = false;
  Map<String, dynamic>? _processInfo;
  List<Map<String, dynamic>> _serverTools = [];
  StreamSubscription? _processEventSubscription;
  StreamSubscription? _toolEventSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadServerLogs();
    _loadProcessInfo();
    _loadServerTools();
    _setupRealTimeMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _processEventSubscription?.cancel();
    _toolEventSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProcessInfo() async {
    // 暂时使用模拟数据，等待增强版进程管理器完全实现
    setState(() {
      _processInfo = {
        'server_id': widget.serverId,
        'status': 'running',
        'pid': 12345,
        'started_at': DateTime.now().toIso8601String(),
        'restart_count': 0,
      };
    });
  }

  Future<void> _loadServerTools() async {
    try {
      final tools = _toolsAggregator.getAllTools()
          .where((tool) => tool.serverId == widget.serverId)
          .toList();
      setState(() {
        _serverTools = tools.map((tool) => tool.toJson()).toList();
      });
    } catch (e) {
      // 服务器可能还没有连接，忽略错误
      setState(() {
        _serverTools = [];
      });
    }
  }

  void _setupRealTimeMonitoring() {
    // 监听工具事件
    _toolEventSubscription = _toolsAggregator.toolEvents.listen((event) {
      if (event.data['server_id'] == widget.serverId) {
        _loadServerTools();
      }
    });

    // 定期刷新数据
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadProcessInfo();
      _loadServerTools();
    });
  }

  Future<void> _loadServerLogs() async {
    setState(() {
      _isLoadingLogs = true;
    });

    try {
      final logs = await _repository.getServerLogs(widget.serverId, limit: 100);
      setState(() {
        _logs = logs;
        _isLoadingLogs = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLogs = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载日志失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverAsync = ref.watch(serverProvider(widget.serverId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器监控'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: '概览'),
            Tab(icon: Icon(Icons.settings), text: '配置'),
            Tab(icon: Icon(Icons.article), text: '日志'),
            Tab(icon: Icon(Icons.analytics), text: '统计'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(serverProvider(widget.serverId));
              _loadServerLogs();
            },
          ),
        ],
      ),
      body: serverAsync.when(
        data: (server) {
          if (server == null) {
            return const Center(
              child: Text('服务器不存在'),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(server),
              _buildConfigTab(server),
              _buildLogsTab(),
              _buildStatsTab(server),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(serverProvider(widget.serverId)),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(McpServer server) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(server.status),
                        color: _getStatusColor(server.status),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              server.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              _getStatusText(server.status),
                              style: TextStyle(
                                color: _getStatusColor(server.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (server.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      server.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 详细信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '详细信息',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('ID', server.id),
                  _buildInfoRow('安装类型', server.installType.name),
                  _buildInfoRow('连接类型', server.connectionType.name),
                  _buildInfoRow('命令', server.command),
                  if (server.args.isNotEmpty)
                    _buildInfoRow('参数', server.args.join(' ')),
                  if (server.workingDirectory != null)
                    _buildInfoRow('工作目录', server.workingDirectory!),
                  if (server.version != null)
                    _buildInfoRow('版本', server.version!),
                  _buildInfoRow('自动启动', server.autoStart ? '是' : '否'),
                  _buildInfoRow('创建时间', _formatDateTime(server.createdAt)),
                  _buildInfoRow('更新时间', _formatDateTime(server.updatedAt)),
                  if (server.lastStartedAt != null)
                    _buildInfoRow('最后启动', _formatDateTime(server.lastStartedAt!)),
                  if (server.lastStoppedAt != null)
                    _buildInfoRow('最后停止', _formatDateTime(server.lastStoppedAt!)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 操作按钮
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '操作',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (server.status == McpServerStatus.stopped)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('启动'),
                          onPressed: () => _handleServerAction('start'),
                        ),
                      if (server.status == McpServerStatus.running)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop),
                          label: const Text('停止'),
                          onPressed: () => _handleServerAction('stop'),
                        ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('重启'),
                        onPressed: () => _handleServerAction('restart'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('编辑'),
                        onPressed: () => _handleServerAction('edit'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('删除'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _handleServerAction('delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab(McpServer server) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 环境变量
          if (server.env.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '环境变量',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...server.env.entries.map((entry) => 
                      _buildInfoRow(entry.key, entry.value)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 配置参数
          if (server.config.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '配置参数',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SelectableText(
                        _formatJson(server.config),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return Column(
      children: [
        // 日志控制栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Text(
                '日志 (${_logs.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadServerLogs,
                tooltip: '刷新日志',
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _clearLogs(),
                tooltip: '清空日志',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _exportLogs(),
                tooltip: '导出日志',
              ),
            ],
          ),
        ),
        
        // 日志列表
        Expanded(
          child: _isLoadingLogs
              ? const Center(child: CircularProgressIndicator())
              : _logs.isEmpty
                  ? const Center(
                      child: Text('暂无日志'),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return _buildLogEntry(log);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatsTab(McpServer server) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '运行时统计',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // 运行时间统计
          if (server.status == McpServerStatus.running && server.lastStartedAt != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前会话',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '运行时间',
                      _formatDuration(DateTime.now().difference(server.lastStartedAt!)),
                    ),
                    if (server.processId != null)
                      _buildInfoRow('进程ID', server.processId.toString()),
                    if (server.port != null)
                      _buildInfoRow('端口', server.port.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // TODO: 添加更多统计信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '统计功能开发中',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text('将来这里会显示：'),
                  const Text('• 请求数量统计'),
                  const Text('• 响应时间统计'),
                  const Text('• 错误率统计'),
                  const Text('• 资源使用情况'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(McpLogEntry log) {
    Color levelColor;
    IconData levelIcon;
    
    switch (log.level.toLowerCase()) {
      case 'error':
        levelColor = Colors.red;
        levelIcon = Icons.error;
        break;
      case 'warning':
      case 'warn':
        levelColor = Colors.orange;
        levelIcon = Icons.warning;
        break;
      case 'info':
        levelColor = Colors.blue;
        levelIcon = Icons.info;
        break;
      case 'debug':
        levelColor = Colors.grey;
        levelIcon = Icons.bug_report;
        break;
      default:
        levelColor = Colors.grey;
        levelIcon = Icons.notes;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(levelIcon, color: levelColor, size: 16),
          const SizedBox(width: 8),
          Text(
            _formatDateTime(log.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              log.level.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: levelColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              log.message,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.running:
        return Icons.play_circle;
      case McpServerStatus.stopped:
        return Icons.stop_circle;
      case McpServerStatus.starting:
        return Icons.hourglass_empty;
      case McpServerStatus.stopping:
        return Icons.hourglass_full;
      case McpServerStatus.error:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.running:
        return Colors.green;
      case McpServerStatus.stopped:
        return Colors.grey;
      case McpServerStatus.starting:
      case McpServerStatus.stopping:
        return Colors.orange;
      case McpServerStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.running:
        return '运行中';
      case McpServerStatus.stopped:
        return '已停止';
      case McpServerStatus.starting:
        return '启动中';
      case McpServerStatus.stopping:
        return '停止中';
      case McpServerStatus.error:
        return '错误';
      default:
        return '未知';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天 ${duration.inHours % 24}小时 ${duration.inMinutes % 60}分钟';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时 ${duration.inMinutes % 60}分钟';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分钟 ${duration.inSeconds % 60}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  String _formatJson(Map<String, dynamic> json) {
    // 简单的JSON格式化
    final buffer = StringBuffer();
    _writeJsonValue(buffer, json, 0);
    return buffer.toString();
  }

  void _writeJsonValue(StringBuffer buffer, dynamic value, int indent) {
    final indentStr = '  ' * indent;
    
    if (value is Map) {
      buffer.writeln('{');
      final entries = value.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.write('$indentStr  "${entry.key}": ');
        _writeJsonValue(buffer, entry.value, indent + 1);
        if (i < entries.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$indentStr}');
    } else if (value is List) {
      buffer.writeln('[');
      for (int i = 0; i < value.length; i++) {
        buffer.write('$indentStr  ');
        _writeJsonValue(buffer, value[i], indent + 1);
        if (i < value.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$indentStr]');
    } else if (value is String) {
      buffer.write('"$value"');
    } else {
      buffer.write(value.toString());
    }
  }

  Future<void> _handleServerAction(String action) async {
    try {
      final serverActions = ref.read(serverActionsProvider);
      
      switch (action) {
        case 'start':
          await serverActions.startServer(widget.serverId);
          break;
        case 'stop':
          await serverActions.stopServer(widget.serverId);
          break;
        case 'restart':
          await serverActions.restartServer(widget.serverId);
          break;
        case 'edit':
          // TODO: 导航到编辑页面
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('编辑功能开发中')),
          );
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation();
          if (confirmed) {
            await serverActions.deleteServer(widget.serverId);
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
          break;
      }
      
      // 刷新服务器信息
      ref.refresh(serverProvider(widget.serverId));
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个服务器吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _clearLogs() async {
    try {
      await _repository.clearServerLogs(widget.serverId);
      await _loadServerLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志已清空')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清空日志失败: $e')),
        );
      }
    }
  }

  Future<void> _exportLogs() async {
    try {
      // TODO: 实现日志导出功能
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志导出功能开发中')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出日志失败: $e')),
        );
      }
    }
  }
} 