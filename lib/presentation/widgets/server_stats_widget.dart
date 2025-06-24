import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mcp_server.dart';
import '../providers/servers_provider.dart';

/// 服务器统计小部件
class ServerStatsWidget extends ConsumerWidget {
  const ServerStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversAsync = ref.watch(serversListProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '服务器统计',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            serversAsync.when(
              data: (servers) => _buildStatsContent(context, servers),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '加载失败: $error',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, List<McpServer> servers) {
    final stats = _calculateStats(servers);

    return Column(
      children: [
        // 总体统计
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: '总服务器',
                value: stats.total.toString(),
                icon: Icons.dns,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: '运行中',
                value: stats.running.toString(),
                icon: Icons.play_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: '已停止',
                value: stats.stopped.toString(),
                icon: Icons.stop_circle,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: '错误',
                value: stats.error.toString(),
                icon: Icons.error,
                color: Colors.red,
              ),
            ),
          ],
        ),
        if (stats.total > 0) ...[
          const SizedBox(height: 16),
          _buildStatusDistribution(context, stats),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(BuildContext context, ServerStats stats) {
    final total = stats.total;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '状态分布',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              if (stats.running > 0)
                Expanded(
                  flex: stats.running,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              if (stats.stopped > 0)
                Expanded(
                  flex: stats.stopped,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              if (stats.error > 0)
                Expanded(
                  flex: stats.error,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            if (stats.running > 0)
              _buildLegendItem('运行中', Colors.green, stats.running, total),
            if (stats.stopped > 0)
              _buildLegendItem('已停止', Colors.orange, stats.stopped, total),
            if (stats.error > 0)
              _buildLegendItem('错误', Colors.red, stats.error, total),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, int total) {
    final percentage = ((count / total) * 100).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($percentage%)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  ServerStats _calculateStats(List<McpServer> servers) {
    int running = 0;
    int stopped = 0;
    int error = 0;

    for (final server in servers) {
      switch (server.status) {
        case McpServerStatus.running:
          running++;
          break;
        case McpServerStatus.stopped:
        case McpServerStatus.installed:
        case McpServerStatus.notInstalled:
          stopped++;
          break;
        case McpServerStatus.error:
          error++;
          break;
        case McpServerStatus.starting:
        case McpServerStatus.stopping:
        case McpServerStatus.installing:
        case McpServerStatus.uninstalling:
          // 暂时归类为运行中（处理中状态）
          running++;
          break;
      }
    }

    return ServerStats(
      total: servers.length,
      running: running,
      stopped: stopped,
      error: error,
    );
  }
}

/// 服务器统计数据
class ServerStats {
  final int total;
  final int running;
  final int stopped;
  final int error;

  ServerStats({
    required this.total,
    required this.running,
    required this.stopped,
    required this.error,
  });
} 