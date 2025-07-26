import 'package:flutter/material.dart';
import 'package:mcphub/core/models/mcp_server.dart';
import 'package:mcphub/l10n/generated/app_localizations.dart';

class ServerEditDialog extends StatefulWidget {
  final McpServer server;
  final Function(String command, List<String> args) onSave;

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

  @override
  void initState() {
    super.initState();
    _commandController = TextEditingController(text: widget.server.command);
    _argsController = TextEditingController(text: widget.server.args.join(' '));
  }

  @override
  void dispose() {
    _commandController.dispose();
    _argsController.dispose();
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
      await widget.onSave(command, args);
      
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