import 'package:flutter/material.dart';
import 'package:mcphub/core/models/mcp_server.dart';
import 'package:mcphub/l10n/generated/app_localizations.dart';

class ServerEditDialog extends StatefulWidget {
  final McpServer server;
  final Function(String command, List<String> args, Map<String, String> env) onSave;

  const ServerEditDialog({
    super.key,
    required this.server,
    required this.onSave,
  });

  @override
  State<ServerEditDialog> createState() => _ServerEditDialogState();
}

class _ServerEditDialogState extends State<ServerEditDialog> {
  late TextEditingController _commandController;
  late TextEditingController _argsController;
  bool _isLoading = false;
  
  // 环境变量管理
  final List<MapEntry<String, String>> _envEntries = [];
  final List<TextEditingController> _envKeyControllers = [];
  final List<TextEditingController> _envValueControllers = [];

  @override
  void initState() {
    super.initState();
    _commandController = TextEditingController(text: widget.server.command);
    _argsController = TextEditingController(text: widget.server.args.join(' '));
    
    // 初始化环境变量
    _initializeEnvVariables();
  }
  
  void _initializeEnvVariables() {
    for (final entry in widget.server.env.entries) {
      _envEntries.add(MapEntry(entry.key, entry.value));
      _envKeyControllers.add(TextEditingController(text: entry.key));
      _envValueControllers.add(TextEditingController(text: entry.value));
    }
    
    // 总是添加一个空行供新增环境变量
    _addEmptyEnvEntry();
  }
  
  void _addEmptyEnvEntry() {
    _envEntries.add(const MapEntry('', ''));
    _envKeyControllers.add(TextEditingController());
    _envValueControllers.add(TextEditingController());
  }
  
  void _removeEnvEntry(int index) {
    // 确保至少保留一个输入行
    if (_envKeyControllers.length <= 1) return;
    
    setState(() {
      _envEntries.removeAt(index);
      _envKeyControllers[index].dispose();
      _envValueControllers[index].dispose();
      _envKeyControllers.removeAt(index);
      _envValueControllers.removeAt(index);
    });
  }
  
  void _addNewEnvEntry() {
    setState(() {
      // 检查最后一行是否为空，如果不是空的才添加新行
      final lastIndex = _envKeyControllers.length - 1;
      if (lastIndex >= 0 && 
          (_envKeyControllers[lastIndex].text.trim().isNotEmpty || 
           _envValueControllers[lastIndex].text.trim().isNotEmpty)) {
        _addEmptyEnvEntry();
      }
    });
  }
  
  Map<String, String> _buildEnvMap() {
    final envMap = <String, String>{};
    for (int i = 0; i < _envKeyControllers.length; i++) {
      final key = _envKeyControllers[i].text.trim();
      final value = _envValueControllers[i].text.trim();
      if (key.isNotEmpty) {
        envMap[key] = value;
      }
    }
    return envMap;
  }
  
  Widget _buildEnvVariablesSection(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 环境变量列表
          Container(
            constraints: const BoxConstraints(maxHeight: 200), // 减少高度，为其他元素留出空间
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(), // 确保可以滚动
              itemCount: _envKeyControllers.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: index > 0 ? Border(top: BorderSide(color: Colors.grey[200]!)) : null,
                  ),
                  child: Row(
                    children: [
                      // Key输入框
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _envKeyControllers[index],
                          decoration: InputDecoration(
                            hintText: l10n.servers_edit_env_hint_key,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            isDense: true,
                          ),
                          enabled: !_isLoading,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 等号
                      const Text('='),
                      const SizedBox(width: 8),
                      // Value输入框
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _envValueControllers[index],
                          decoration: InputDecoration(
                            hintText: l10n.servers_edit_env_hint_value,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            isDense: true,
                          ),
                          enabled: !_isLoading,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 删除按钮
                      IconButton(
                        onPressed: _isLoading || _envKeyControllers.length <= 1 ? null : () => _removeEnvEntry(index),
                        icon: const Icon(Icons.remove_circle_outline, size: 16),
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 添加按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _addNewEnvEntry,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.servers_edit_env_add),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commandController.dispose();
    _argsController.dispose();
    
    // 清理环境变量控制器
    for (final controller in _envKeyControllers) {
      controller.dispose();
    }
    for (final controller in _envValueControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  List<String> _parseArgs(String argsText) {
    // 简单的参数解析，按空格分割
    if (argsText.trim().isEmpty) return [];
    
    final List<String> args = [];
    bool inQuotes = false;
    String currentArg = '';
    String quoteChar = '';
    
    for (int i = 0; i < argsText.length; i++) {
      final char = argsText[i];
      
      if (!inQuotes && (char == '"' || char == "'")) {
        inQuotes = true;
        quoteChar = char;
      } else if (inQuotes && char == quoteChar) {
        inQuotes = false;
        quoteChar = '';
      } else if (!inQuotes && char == ' ') {
        if (currentArg.isNotEmpty) {
          args.add(currentArg);
          currentArg = '';
        }
      } else {
        currentArg += char;
      }
    }
    
    if (currentArg.isNotEmpty) {
      args.add(currentArg);
    }
    
    return args;
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    final command = _commandController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    
    if (command.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.servers_edit_command_empty)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final args = _parseArgs(_argsController.text);
      final env = _buildEnvMap();
      await widget.onSave(command, args, env);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.servers_edit_save_success)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.servers_edit_save_failed(e.toString()))),
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
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.servers_edit_dialog_title(widget.server.name)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7, // 限制对话框高度
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              l10n.servers_edit_command_label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commandController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.servers_edit_command_hint,
                helperText: l10n.servers_edit_command_helper,
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.servers_edit_args_label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _argsController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.servers_edit_args_hint,
                helperText: l10n.servers_edit_args_helper,
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  l10n.servers_edit_env_label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (_envKeyControllers.length > 3) // 超过3个环境变量时显示滚动提示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.unfold_more, size: 12, color: Colors.blue[600]),
                        const SizedBox(width: 2),
                        Text(
                          '可滚动',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildEnvVariablesSection(l10n),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Text(
                        l10n.servers_edit_preview_title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_commandController.text.trim()} ${_argsController.text.trim()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.common_save),
        ),
      ],
    );
  }
} 