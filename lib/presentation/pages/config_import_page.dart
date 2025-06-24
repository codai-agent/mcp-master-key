import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../business/parsers/mcp_config_parser.dart';
import '../../business/services/mcp_server_service.dart';
import '../../core/models/mcp_server.dart';

/// MCP配置导入页面
class ConfigImportPage extends StatefulWidget {
  const ConfigImportPage({super.key});

  @override
  State<ConfigImportPage> createState() => _ConfigImportPageState();
}

class _ConfigImportPageState extends State<ConfigImportPage> {
  final TextEditingController _configController = TextEditingController();
  final McpConfigParser _parser = McpConfigParser.instance;
  final McpServerService _serverService = McpServerService.instance;

  McpConfigParseResult? _parseResult;
  bool _isLoading = false;
  List<bool> _selectedServers = [];

  @override
  void initState() {
    super.initState();
    // 填入示例配置
    _configController.text = _parser.getExampleConfig();
  }

  @override
  void dispose() {
    _configController.dispose();
    super.dispose();
  }

  /// 解析配置
  void _parseConfig() {
    final configText = _configController.text.trim();
    if (configText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入MCP配置')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = _parser.parseConfig(configText);
      setState(() {
        _parseResult = result;
        _selectedServers = List.filled(result.servers.length, true);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _parseResult = McpConfigParseResult(
          success: false,
          error: '解析失败: $e',
        );
        _isLoading = false;
      });
    }
  }

  /// 导入选中的服务器
  Future<void> _importSelectedServers() async {
    if (_parseResult == null || !_parseResult!.success) return;

    final selectedConfigs = <McpServerConfig>[];
    for (int i = 0; i < _parseResult!.servers.length; i++) {
      if (_selectedServers[i]) {
        selectedConfigs.add(_parseResult!.servers[i]);
      }
    }

    if (selectedConfigs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要导入的服务器')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (final config in selectedConfigs) {
        await _serverService.addServer(
          name: config.name,
          description: config.description,
          installType: config.installType,
          command: config.command,
          args: config.args,
          env: config.env,
          workingDirectory: config.workingDirectory,
          installSource: config.installSource,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 ${selectedConfigs.length} 个服务器')),
        );
        Navigator.of(context).pop(true); // 返回true表示有导入
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入MCP配置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: '帮助',
          ),
        ],
      ),
      body: Column(
        children: [
          // 配置输入区域
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'MCP配置',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.content_paste),
                        label: const Text('粘贴'),
                        onPressed: _pasteFromClipboard,
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.clear),
                        label: const Text('清空'),
                        onPressed: () => _configController.clear(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _configController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: '请粘贴您的MCP配置JSON...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.analytics),
                        label: const Text('解析配置'),
                        onPressed: _isLoading ? null : _parseConfig,
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('示例配置'),
                        onPressed: () {
                          _configController.text = _parser.getExampleConfig();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(height: 1),
          
          // 解析结果区域
          Expanded(
            flex: 1,
            child: _buildParseResultArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildParseResultArea() {
    if (_parseResult == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('请输入MCP配置并点击"解析配置"'),
          ],
        ),
      );
    }

    if (!_parseResult!.success) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '解析失败',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _parseResult!.error ?? '未知错误',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // 头部信息
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                '找到 ${_parseResult!.servers.length} 个MCP服务器',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('导入选中'),
                onPressed: _isLoading ? null : _importSelectedServers,
              ),
            ],
          ),
        ),
        
        // 服务器列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _parseResult!.servers.length,
            itemBuilder: (context, index) {
              final server = _parseResult!.servers[index];
              return _buildServerCard(server, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServerCard(McpServerConfig server, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：名称和选择框
            Row(
              children: [
                Checkbox(
                  value: _selectedServers[index],
                  onChanged: (value) {
                    setState(() {
                      _selectedServers[index] = value ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (server.description != null)
                        Text(
                          server.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                _getStrategyChip(server.installStrategy),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 命令信息
            _buildInfoRow('命令', '${server.command} ${server.args.join(' ')}'),
            _buildInfoRow('安装类型', server.installType.name),
            if (server.installSource != null)
              _buildInfoRow('安装源', server.installSource!),
            if (server.workingDirectory != null)
              _buildInfoRow('工作目录', server.workingDirectory!),
            if (server.env.isNotEmpty)
              _buildInfoRow('环境变量', server.env.entries.map((e) => '${e.key}=${e.value}').join(', ')),
            
            // 用户输入提示
            if (server.needsUserInput) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        server.userInputReason ?? '需要用户确认',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  Widget _getStrategyChip(McpInstallStrategy strategy) {
    Color color;
    String label;
    
    switch (strategy) {
      case McpInstallStrategy.selfContained:
        color = Colors.green;
        label = '自包含';
        break;
      case McpInstallStrategy.requiresInstallation:
        color = Colors.orange;
        label = '需安装';
        break;
      case McpInstallStrategy.localPath:
        color = Colors.blue;
        label = '本地路径';
        break;
      case McpInstallStrategy.unknown:
        color = Colors.red;
        label = '未知';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  /// 从剪贴板粘贴
  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        _configController.text = clipboardData!.text!;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('粘贴失败: $e')),
        );
      }
    }
  }

  /// 显示帮助对话框
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MCP配置导入帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('支持的配置格式：'),
              SizedBox(height: 8),
              Text('• 标准的MCP配置JSON格式'),
              Text('• 必须包含 mcpServers 字段'),
              Text('• 每个服务器需要 command 和 args 字段'),
              SizedBox(height: 16),
              Text('自动识别的安装策略：'),
              SizedBox(height: 8),
              Text('🟢 自包含：npx -y, uvx 命令'),
              Text('🟠 需安装：普通的 python, node 命令'),
              Text('🔵 本地路径：包含路径分隔符的命令'),
              Text('🔴 未知：无法识别的命令类型'),
            ],
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
} 