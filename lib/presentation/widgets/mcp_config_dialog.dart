import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../business/services/mcp_hub_service.dart';
import '../../business/services/config_service.dart';

/// MCP配置查看对话框
class McpConfigDialog extends ConsumerStatefulWidget {
  const McpConfigDialog({super.key});

  @override
  ConsumerState<McpConfigDialog> createState() => _McpConfigDialogState();
}

class _McpConfigDialogState extends ConsumerState<McpConfigDialog> {
  bool _isLoading = true;
  String _configContent = '';
  String _serverMode = '';
  int _serverPort = 0;
  Map<String, dynamic>? _hubStatus;

  @override
  void initState() {
    super.initState();
    _loadMcpConfig();
  }

  /// 加载MCP配置信息
  Future<void> _loadMcpConfig() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 获取Hub状态和服务器模式
      final hubService = McpHubService.instance;
      final configService = ConfigService.instance;
      
      _hubStatus = hubService.getStatus();
      _serverMode = await configService.getMcpServerMode();
      _serverPort = _hubStatus?['port'] ?? 0;

      // 根据服务器模式生成对应的mcpservers配置
      final mcpServersConfig = await _generateMcpServersConfig();
      
      setState(() {
        _configContent = const JsonEncoder.withIndent('  ').convert(mcpServersConfig);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _configContent = '加载配置失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 生成mcpservers配置
  Future<Map<String, dynamic>> _generateMcpServersConfig() async {
    final configService = ConfigService.instance;
    
    if (_serverMode == 'streamable') {
      // Streamable HTTP模式配置
      final streamablePort = await configService.getStreamablePort();
      
      return {
        "mcpservers": {
          "mcphub": {
            "url": "http://127.0.0.1:$streamablePort/mcp",
            "type": "streamableHttp",
            "transportType": "streamableHttp",
            "autoApprove": [],
            "disabled": false,
            "timeout": 60
          }
        }
      };
    } else {
      // SSE模式配置
      final ssePort = _hubStatus?['port'] ?? 3000;
      
      return {
        "mcpservers": {
          "mcphub": {
            "url": "http://127.0.0.1:$ssePort/sse",
            "transportType": "sse",
            "autoApprove": [],
            "disabled": false,
            "timeout": 60
          }
        }
      };
    }
  }

  /// 复制配置到剪贴板
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _configContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('配置已复制到剪贴板'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MCP配置',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: '关闭',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 服务器信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hub服务信息',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _hubStatus?['running'] == true ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: _hubStatus?['running'] == true ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '状态: ${_hubStatus?['running'] == true ? '运行中' : '已停止'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        Icons.settings,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '模式: ${_serverMode.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        Icons.router,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '端口: $_serverPort',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 配置内容
            Text(
              'mcpservers配置信息:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: SelectableText(
                          _configContent,
                          style: TextStyle(
                            fontFamily: 'Consolas, Monaco, monospace',
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 底部操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _copyToClipboard,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('复制'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 