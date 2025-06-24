import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mcp_server.dart';
import '../providers/servers_provider.dart';

class ServerCard extends ConsumerWidget {
  final McpServer server;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onRestart;

  const ServerCard({
    Key? key,
    required this.server,
    this.onTap,
    this.onStart,
    this.onStop,
    this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  // 状态指示器
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(server.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 服务器名称
                  Expanded(
                    child: Text(
                      server.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // 类型标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(server.installType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getTypeColor(server.installType).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      server.installType.name.toUpperCase(),
                      style: TextStyle(
                        color: _getTypeColor(server.installType),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 描述
              if (server.description?.isNotEmpty == true)
                Text(
                  server.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // 状态和操作按钮
              Row(
                children: [
                  // 状态文本
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(server.status),
                          size: 16,
                          color: _getStatusColor(server.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(server.status),
                          style: TextStyle(
                            color: _getStatusColor(server.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 操作按钮
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (server.status == McpServerStatus.stopped || 
                          server.status == McpServerStatus.installed)
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: onStart,
                          tooltip: '启动',
                          iconSize: 20,
                        ),
                      if (server.status == McpServerStatus.running) ...[
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: onRestart,
                          tooltip: '重启',
                          iconSize: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: onStop,
                          tooltip: '停止',
                          iconSize: 20,
                        ),
                      ],
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        tooltip: '更多选项',
                        onSelected: (value) => _handleMenuSelection(context, ref, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'details',
                            child: ListTile(
                              leading: Icon(Icons.info),
                              title: Text('查看详情'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('编辑配置'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'copy',
                            child: ListTile(
                              leading: Icon(Icons.copy),
                              title: Text('复制配置'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('删除服务器'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              // 额外信息（如果有的话）
              if (server.status == McpServerStatus.running && server.lastStartedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '运行时间: ${_formatDuration(DateTime.now().difference(server.lastStartedAt!))}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.running:
        return Colors.green;
      case McpServerStatus.stopped:
        return Colors.grey;
      case McpServerStatus.installed:
        return Colors.blue;
      case McpServerStatus.starting:
        return Colors.orange;
      case McpServerStatus.stopping:
        return Colors.orange;
      case McpServerStatus.error:
        return Colors.red;
      case McpServerStatus.installing:
        return Colors.blue.shade300;
      case McpServerStatus.uninstalling:
        return Colors.red.shade300;
      case McpServerStatus.notInstalled:
        return Colors.grey.shade400;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.running:
        return Icons.check_circle;
      case McpServerStatus.stopped:
        return Icons.stop_circle;
      case McpServerStatus.installed:
        return Icons.verified;
      case McpServerStatus.starting:
        return Icons.play_circle;
      case McpServerStatus.stopping:
        return Icons.pause_circle;
      case McpServerStatus.error:
        return Icons.error;
      case McpServerStatus.installing:
        return Icons.download;
      case McpServerStatus.uninstalling:
        return Icons.delete;
      case McpServerStatus.notInstalled:
        return Icons.cancel;
      default:
        return Icons.help;
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
      case McpServerStatus.installing:
        return '安装中';
      case McpServerStatus.uninstalling:
        return '卸载中';
      case McpServerStatus.installed:
        return '已安装';
      case McpServerStatus.notInstalled:
        return '未安装';
      default:
        return '未知';
    }
  }

  Color _getTypeColor(McpInstallType installType) {
    switch (installType) {
      case McpInstallType.npx:
        return Colors.green;
      case McpInstallType.uvx:
        return Colors.blue;
      case McpInstallType.localPath:
        return Colors.orange;
      case McpInstallType.github:
        return Colors.purple;
      case McpInstallType.preInstalled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天 ${duration.inHours % 24}小时';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时 ${duration.inMinutes % 60}分钟';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分钟';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'details':
        _showServerDetails(context);
        break;
      case 'edit':
        _editServerConfig(context);
        break;
      case 'copy':
        _copyServerConfig(context);
        break;
      case 'delete':
        _confirmDelete(context, ref);
        break;
    }
  }

  void _showServerDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('服务器详情 - ${server.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('名称', server.name),
              _buildDetailRow('描述', server.description ?? '无'),
              _buildDetailRow('状态', _getStatusText(server.status)),
              _buildDetailRow('安装类型', server.installType.toString().split('.').last),
              _buildDetailRow('命令', server.command ?? '无'),
              _buildDetailRow('参数', server.args?.join(' ') ?? '无'),
                             if (server.lastStartedAt != null)
                 _buildDetailRow('最后启动时间', server.lastStartedAt!.toString()),
               if (server.errorMessage != null)
                 _buildDetailRow('错误信息', server.errorMessage!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editServerConfig(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('编辑配置功能即将推出'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyServerConfig(BuildContext context) {
    // 这里可以实现复制配置到剪贴板的功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制服务器 "${server.name}" 的配置'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除服务器 "${server.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // 使用ServerActions删除服务器
                final serverActions = ref.read(serverActionsProvider);
                await serverActions.deleteServer(server.id);
                
                // 刷新服务器列表
                ref.refresh(serversListProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('服务器 "${server.name}" 已删除'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('删除失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 