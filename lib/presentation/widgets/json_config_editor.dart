import 'package:flutter/material.dart';
import 'dart:convert';

/// JSON 配置编辑器组件
/// 固定 JSON 的开头和结尾结构，只允许编辑中间的服务器配置部分
class JsonConfigEditor extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final String? errorText;

  const JsonConfigEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<JsonConfigEditor> createState() => _JsonConfigEditorState();
}

class _JsonConfigEditorState extends State<JsonConfigEditor> {
  late TextEditingController _serverConfigController;
  final FocusNode _focusNode = FocusNode();
  
  // 固定的 JSON 结构
  static const String _jsonPrefix = '{\n  "mcpServers": {';
  static const String _jsonSuffix = '\n  }\n}';
  
  // 占位符提示文本
  static const String _placeholderText = '点击此处输入MCP服务器配置...\n\n示例格式：\n    "server-name": {\n        "command": "uvx",\n        "args": ["package-name"]\n    }';

  @override
  void initState() {
    super.initState();
    _serverConfigController = TextEditingController();
    _initializeFromFullConfig();
    _serverConfigController.addListener(_onServerConfigChanged);
  }

  @override
  void dispose() {
    _serverConfigController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 从完整的 JSON 配置中提取服务器配置部分
  void _initializeFromFullConfig() {
    try {
      final fullConfig = jsonDecode(widget.initialValue) as Map<String, dynamic>;
      final mcpServers = fullConfig['mcpServers'] as Map<String, dynamic>?;
      
      if (mcpServers != null && mcpServers.isNotEmpty) {
        // 将服务器配置转换为缩进的 JSON 字符串
        final encoder = JsonEncoder.withIndent('    ');
        String serverConfigJson = encoder.convert(mcpServers);
        
        // 移除最外层的大括号，只保留内容
        final lines = serverConfigJson.split('\n');
        if (lines.length > 2) {
          final innerContent = lines.sublist(1, lines.length - 1).join('\n');
          _serverConfigController.text = innerContent;
        }
      } else {
        // 如果没有服务器配置，使用占位符
        _serverConfigController.text = '';
      }
    } catch (e) {
      // 如果解析失败，使用占位符
      _serverConfigController.text = '';
    }
  }

  /// 当服务器配置改变时，合成完整的 JSON 并通知父组件
  void _onServerConfigChanged() {
    final serverConfig = _serverConfigController.text.trim();
    String fullJson;
    
    if (serverConfig.isEmpty) {
      // 如果用户输入为空，返回基础结构
      fullJson = '$_jsonPrefix$_jsonSuffix';
    } else {
      // 合成完整的 JSON
      fullJson = '$_jsonPrefix\n$serverConfig$_jsonSuffix';
    }
    
    widget.onChanged(fullJson);
  }

  @override
  Widget build(BuildContext context) {
    final serverConfig = _serverConfigController.text.trim();
    final showPlaceholder = serverConfig.isEmpty;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.errorText != null ? Colors.red : Colors.grey[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 固定的开头部分
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Text(
              _jsonPrefix,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // 可编辑的服务器配置部分
          SizedBox(
            height: 6 * 14 * 1.5 + 24, // 6行 * 字体大小 * 行高 + padding
            child: Stack(
              children: [
                // 占位符文本（当用户没有输入时显示）
                if (showPlaceholder)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _placeholderText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                
                // 实际的输入框（支持滚动）
                Scrollbar(
                  child: TextField(
                    controller: _serverConfigController,
                    focusNode: _focusNode,
                    maxLines: null,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onTap: () {
                      // 当用户点击时，如果是空的，获取焦点即可
                      if (showPlaceholder) {
                        _focusNode.requestFocus();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 固定的结尾部分
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(7),
                bottomRight: Radius.circular(7),
              ),
            ),
            child: Text(
              _jsonSuffix,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // 错误提示
          if (widget.errorText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                widget.errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 