import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mcp_server.dart';
import '../../infrastructure/repositories/mcp_server_repository.dart';
import '../../business/managers/enhanced_mcp_process_manager.dart';
import '../../infrastructure/mcp/mcp_tools_aggregator.dart';
import '../../l10n/generated/app_localizations.dart';
import '../providers/servers_provider.dart';
import '../widgets/server_edit_dialog.dart';

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
  List<McpLogEntry> _filteredLogs = [];
  bool _isLoadingLogs = false;
  String? _selectedLogLevel;
  bool _autoScroll = true;
  final ScrollController _logScrollController = ScrollController();
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
    _logScrollController.dispose();
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
        _filterLogs();
        _isLoadingLogs = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoadingLogs = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.server_monitor_log_load_failed(e.toString()))),
        );
      }
    }
  }
  
  void _filterLogs() {
    if (_selectedLogLevel == null) {
      _filteredLogs = _logs;
    } else {
      _filteredLogs = _logs.where((log) => log.level.toLowerCase() == _selectedLogLevel).toList();
    }
  }
  
  void _scrollToBottom() {
    if (_autoScroll && _logScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }
  
  Widget _buildLogLevelChip(String label, String? level) {
    final isSelected = _selectedLogLevel == level;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedLogLevel = selected ? level : null;
          _filterLogs();
        });
      },
      backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serverAsync = ref.watch(serverProvider(widget.serverId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.server_monitor_title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.info), text: l10n.server_monitor_overview),
            Tab(icon: const Icon(Icons.settings), text: l10n.server_monitor_config),
            Tab(icon: const Icon(Icons.article), text: l10n.server_monitor_logs),
            Tab(icon: const Icon(Icons.analytics), text: l10n.server_monitor_stats),
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
            return Center(
              child: Text(l10n.servers_not_exist),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(server, l10n),
              _buildConfigTab(server, l10n),
              _buildLogsTab(l10n),
              _buildStatsTab(server, l10n),
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
              Text(l10n.servers_load_failed(error.toString())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(serverProvider(widget.serverId)),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(McpServer server, AppLocalizations l10n) {
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
                          label: Text(l10n.servers_start),
                          onPressed: () => _handleServerAction('start'),
                        ),
                      if (server.status == McpServerStatus.running)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop),
                          label: Text(l10n.servers_stop),
                          onPressed: () => _handleServerAction('stop'),
                        ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.servers_restart),
                        onPressed: () => _handleServerAction('restart'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.common_edit),
                        onPressed: () => _handleServerAction('edit'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: Text(l10n.common_delete),
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

  Widget _buildConfigTab(McpServer server, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MCP 服务器配置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'MCP 服务器配置',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('服务器名称', server.name),
                  if (server.description != null)
                    _buildInfoRow('描述', server.description!),
                  _buildInfoRow('安装类型', server.installType.name.toUpperCase()),
                  _buildInfoRow('连接类型', server.connectionType.name.toUpperCase()),
                  _buildInfoRow('命令', server.command),
                  if (server.args.isNotEmpty)
                    _buildInfoRow('参数', server.args.join(' ')),
                  if (server.workingDirectory != null)
                    _buildInfoRow('工作目录', server.workingDirectory!),
                  if (server.installSource != null)
                    _buildInfoRow('安装源', server.installSource!),
                  if (server.version != null)
                    _buildInfoRow('版本', server.version!),
                  _buildInfoRow('自动启动', server.autoStart ? '是' : '否'),
                  _buildInfoRow('日志级别', server.logLevel.toUpperCase()),
                  _buildInfoRow('状态', _getStatusText(server.status)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 环境变量
          if (server.env.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '环境变量',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
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
                    Row(
                      children: [
                        const Icon(Icons.code, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '附加配置参数',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
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

  Widget _buildLogsTab(AppLocalizations l10n) {
    return Column(
      children: [
        // 日志控制栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              // 标题和操作按钮
              Row(
                children: [
                  const Icon(Icons.article, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '服务器日志 (${_logs.length})',
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
              const SizedBox(height: 12),
              
              // 日志级别过滤器
              Row(
                children: [
                  Text(l10n.server_monitor_log_filter),
                  const SizedBox(width: 8),
                  _buildLogLevelChip('ALL', null),
                  const SizedBox(width: 4),
                  _buildLogLevelChip('ERROR', 'error'),
                  const SizedBox(width: 4),
                  _buildLogLevelChip('WARN', 'warning'),
                  const SizedBox(width: 4),
                  _buildLogLevelChip('INFO', 'info'),
                  const SizedBox(width: 4),
                  _buildLogLevelChip('DEBUG', 'debug'),
                  const Spacer(),
                  
                  // 自动滚动开关
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.server_monitor_auto_scroll),
                      Switch(
                        value: _autoScroll,
                        onChanged: (value) {
                          setState(() {
                            _autoScroll = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 日志列表
        Expanded(
          child: _isLoadingLogs
              ? const Center(child: CircularProgressIndicator())
              : _filteredLogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedLogLevel == null ? '暂无日志' : '该级别暂无日志',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '服务器运行时的日志信息将在这里显示',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _logScrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = _filteredLogs[index];
                        return _buildLogEntry(log);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatsTab(McpServer server, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, size: 24),
              const SizedBox(width: 8),
              Text(
                '服务器统计',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 基本运行统计
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '运行状态',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('当前状态', _getStatusText(server.status)),
                  if (server.lastStartedAt != null) ...[
                    _buildInfoRow('最后启动时间', _formatDateTime(server.lastStartedAt!)),
                    if (server.status == McpServerStatus.running)
                      _buildInfoRow(
                        '运行时长',
                        _formatDuration(DateTime.now().difference(server.lastStartedAt!)),
                      ),
                  ],
                  if (server.lastStoppedAt != null)
                    _buildInfoRow('最后停止时间', _formatDateTime(server.lastStoppedAt!)),
                  if (server.processId != null)
                    _buildInfoRow('进程ID', server.processId.toString()),
                  if (server.port != null)
                    _buildInfoRow('运行端口', server.port.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 工具统计
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.build, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '工具统计',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('可用工具数量', '${_serverTools.length}'),
                  if (_serverTools.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('工具列表：', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    ..._serverTools.map((tool) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.label, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            tool['name'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                  ] else ...[
                    Text(
                      '暂无可用工具',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 日志统计
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.article, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '日志统计',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('总日志条数', '${_logs.length}'),
                  if (_logs.isNotEmpty) ...[
                    _buildInfoRow('错误日志', '${_logs.where((log) => log.level.toLowerCase() == 'error').length}'),
                    _buildInfoRow('警告日志', '${_logs.where((log) => log.level.toLowerCase() == 'warning').length}'),
                    _buildInfoRow('信息日志', '${_logs.where((log) => log.level.toLowerCase() == 'info').length}'),
                    _buildInfoRow('调试日志', '${_logs.where((log) => log.level.toLowerCase() == 'debug').length}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 性能指标
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '性能指标',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_processInfo != null) ...[
                    _buildInfoRow('重启次数', '${_processInfo!['restart_count'] ?? 0}'),
                  ] else ...[
                    Text(
                      '暂无性能数据',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '启动服务器后将显示详细的性能指标',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 生命周期统计
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '生命周期',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('创建时间', _formatDateTime(server.createdAt)),
                  _buildInfoRow('最后更新', _formatDateTime(server.updatedAt)),
                  _buildInfoRow('自动启动', server.autoStart ? '已启用' : '已禁用'),
                  if (server.errorMessage != null)
                    _buildInfoRow('最后错误', server.errorMessage!),
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
          await _showEditDialog();
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

  Future<void> _showEditDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final serverAsync = ref.read(serverProvider(widget.serverId));
    final server = serverAsync.value;
    
    if (server == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.servers_edit_load_failed)),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => ServerEditDialog(
        server: server,
        onSave: (command, args) async {
          // 更新服务器配置
          final updatedServer = server.copyWith(
            command: command,
            args: args,
            updatedAt: DateTime.now(),
          );
          
          // 保存到数据库
          final serverActions = ref.read(serverActionsProvider);
          await serverActions.updateServer(updatedServer);
          
          // 刷新服务器信息
          ref.refresh(serverProvider(widget.serverId));
        },
      ),
    );
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