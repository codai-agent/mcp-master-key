import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../core/models/mcp_server.dart';
import '../providers/servers_provider.dart';
import '../themes/app_theme.dart';

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
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getStatusColor(server.status),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor(server.status).withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getTypeColor(server.installType).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getTypeColor(server.installType).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      server.installType.name.toUpperCase(),
                      style: TextStyle(
                        color: _getTypeColor(server.installType),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
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
                            value: 'show_config',
                            child: ListTile(
                              leading: Icon(Icons.code),
                              title: Text('显示配置'),
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
        return AppTheme.vscodeGreen;
      case McpServerStatus.stopped:
        return Colors.grey;
      case McpServerStatus.installed:
        return AppTheme.vscodeBlue;
      case McpServerStatus.starting:
        return AppTheme.vscodeOrange;
      case McpServerStatus.stopping:
        return AppTheme.vscodeOrange;
      case McpServerStatus.error:
        return AppTheme.vscodeRed;
      case McpServerStatus.installing:
        return AppTheme.vscodeBlue.withOpacity(0.7);
      case McpServerStatus.uninstalling:
        return AppTheme.vscodeRed.withOpacity(0.7);
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
        return AppTheme.vscodeGreen;
      case McpInstallType.uvx:
        return AppTheme.vscodeBlue;
      case McpInstallType.localPath:
        return AppTheme.vscodeOrange;
      case McpInstallType.github:
        return AppTheme.vscodePurple;
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
      case 'show_config':
        _showServerConfig(context);
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

  void _showServerConfig(BuildContext context) {
    // 构建服务器配置的 JSON 格式
    final config = {
      'mcpServers': {
        server.name: {
          'command': server.command,
          'args': server.args,
          if (server.env.isNotEmpty) 'env': server.env,
          if (server.workingDirectory != null) 'workingDirectory': server.workingDirectory,
        }
      }
    };

    // 格式化 JSON 字符串
    const encoder = JsonEncoder.withIndent('  ');
    final configJson = encoder.convert(config);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  const Icon(Icons.code, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '服务器配置 - ${server.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 配置内容
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      configJson,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 底部按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: configJson));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('已复制服务器 "${server.name}" 的配置到剪贴板'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('复制'),
                  ),
                ],
              ),
            ],
          ),
        ),
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