import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mcp_server.dart';
import '../../business/services/mcp_hub_service.dart';
import '../../business/services/mcp_server_service.dart';
import '../../infrastructure/repositories/mcp_server_repository.dart';
import '../themes/app_theme.dart';

class HubMonitorPage extends ConsumerStatefulWidget {
  const HubMonitorPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HubMonitorPage> createState() => _HubMonitorPageState();
}

class _HubMonitorPageState extends ConsumerState<HubMonitorPage> {
  final McpHubService _hubService = McpHubService.instance;
  final McpServerService _serverService = McpServerService.instance;
  
  Map<String, dynamic>? _hubStatus;
  List<McpServer> _allServers = [];
  Map<McpServerStatus, int> _serverStatusCounts = {};
  List<dynamic> _connectedChildServers = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadHubData();
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadHubData();
    });
  }

  Future<void> _loadHubData() async {
    try {
      // 获取Hub状态
      final hubStatus = _hubService.getStatus();
      
      // 添加调试信息
      print('🔍 Hub Status Debug:');
      print('   - isRunning: ${_hubService.isRunning}');
      print('   - port: ${_hubService.port}');
      print('   - status: $hubStatus');
      
      // 获取所有服务器
      final servers = await _serverService.getAllServers();
      
      // 统计服务器状态
      final statusCounts = <McpServerStatus, int>{};
      for (final server in servers) {
        statusCounts[server.status] = (statusCounts[server.status] ?? 0) + 1;
      }
      
      // 获取已连接的子服务器信息
      final childServers = _hubService.childServers;
      
      if (mounted) {
        setState(() {
          _hubStatus = hubStatus;
          _allServers = servers;
          _serverStatusCounts = statusCounts;
          _connectedChildServers = childServers;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading hub data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadHubData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHubStatusCard(),
              const SizedBox(height: 16),
              _buildServerStatisticsCard(),
              const SizedBox(height: 16),
              _buildConnectedServersCard(),
              const SizedBox(height: 16),
              _buildSystemInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHubStatusCard() {
    final isRunning = _hubStatus?['running'] == true;
    final port = _hubStatus?['port'];
    final connectedServers = _hubStatus?['connected_servers'] ?? 0;
    final totalTools = _hubStatus?['total_tools'] ?? 0;
    final serverMode = _hubStatus?['server_mode'] ?? '未知';
    final debugInfo = _hubStatus?['debug_info'] as Map<String, dynamic>?;
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hub,
                  color: isRunning ? AppTheme.vscodeGreen : AppTheme.vscodeRed,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'MCP Hub 状态',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isRunning ? AppTheme.vscodeGreen.withOpacity(0.1) : AppTheme.vscodeRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRunning ? AppTheme.vscodeGreen : AppTheme.vscodeRed,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isRunning ? AppTheme.vscodeGreen : AppTheme.vscodeRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isRunning ? '运行中' : '已停止',
                        style: TextStyle(
                          color: isRunning ? AppTheme.vscodeGreen : AppTheme.vscodeRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isRunning) ...[
              _buildInfoRow('服务端口', port?.toString() ?? '未知'),
              _buildInfoRow('运行模式', serverMode),
              _buildInfoRow('连接的服务器', '$connectedServers 个'),
              _buildInfoRow('可用工具数量', '$totalTools 个'),
              _buildInfoRow('服务地址', 'http://localhost:$port'),
            ] else ...[
              const Text(
                'Hub 服务未运行',
                style: TextStyle(color: Colors.red),
              ),
              if (debugInfo != null) ...[
                const SizedBox(height: 8),
                Text(
                  '调试信息:',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...debugInfo.entries.map((entry) => 
                  Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerStatisticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns, size: 24),
                const SizedBox(width: 8),
                Text(
                  '服务器统计',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '总计: ${_allServers.length} 个服务器',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip('运行中', McpServerStatus.running, Colors.green),
                _buildStatusChip('已安装', McpServerStatus.installed, Colors.blue),
                _buildStatusChip('已停止', McpServerStatus.stopped, Colors.grey),
                _buildStatusChip('错误', McpServerStatus.error, Colors.red),
                _buildStatusChip('启动中', McpServerStatus.starting, Colors.orange),
                _buildStatusChip('停止中', McpServerStatus.stopping, Colors.orange),
                _buildStatusChip('未安装', McpServerStatus.notInstalled, Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _allServers.isEmpty ? 0 : (_serverStatusCounts[McpServerStatus.running] ?? 0) / _allServers.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '运行率: ${_allServers.isEmpty ? 0 : ((_serverStatusCounts[McpServerStatus.running] ?? 0) / _allServers.length * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, McpServerStatus status, Color color) {
    final count = _serverStatusCounts[status] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildConnectedServersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, size: 24),
                const SizedBox(width: 8),
                Text(
                  '已连接的服务器',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_connectedChildServers.isEmpty) ...[
              const Text('暂无已连接的服务器'),
            ] else ...[
              for (final server in _connectedChildServers) ...[
                _buildConnectedServerItem(server),
                if (server != _connectedChildServers.last) const Divider(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedServerItem(dynamic server) {
    final name = server.name ?? '未知服务器';
    final toolsCount = server.tools?.length ?? 0;
    final resourcesCount = server.resources?.length ?? 0;
    final connectedAt = server.connectedAt;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '工具: $toolsCount 个 • 资源: $resourcesCount 个',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (connectedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '连接时间: ${_formatDateTime(connectedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, size: 24),
                const SizedBox(width: 8),
                Text(
                  '系统信息',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('协议版本', '2024-11-05'),
            _buildInfoRow('应用版本', '1.0.0'),
            _buildInfoRow('运行模式', _hubStatus?['running'] == true ? 'SSE' : '未运行'),
            _buildInfoRow('数据更新', '每 5 秒自动刷新'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.vscodeBlue.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} 小时前';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
} 