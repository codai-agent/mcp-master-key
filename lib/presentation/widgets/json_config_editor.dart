import 'package:flutter/material.dart';
import 'dart:convert';

/// JSON 配置编辑器组件
/// 固定 JSON 的开头和结尾结构，只允许编辑中间的服务器配置部分
class JsonConfigEditor extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final String? errorText;
  final String? placeholderText;

  const JsonConfigEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
    this.placeholderText,
  });

  @override
  State<JsonConfigEditor> createState() => _JsonConfigEditorState();
}

class _JsonConfigEditorState extends State<JsonConfigEditor> {
  late TextEditingController _serverConfigController;
  final FocusNode _focusNode = FocusNode();
  
  // 固定的 JSON 结构
  static const String _jsonPrefix = '{\n  "mcpServers": {';
  static const String _jsonSuffix = '  }\n}';
  
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
  void didUpdateWidget(JsonConfigEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部的 initialValue 发生变化时，重新初始化
    if (widget.initialValue != oldWidget.initialValue) {
      _initializeFromFullConfig();
    }
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
            height: 8 * 14 * 1.5 + 24, // 12行 * 字体大小 * 行高 + padding (增加高度)
            child: Scrollbar(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                  controller: _serverConfigController,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholderText ?? _placeholderText, // 使用传入的占位符或默认占位符
                    hintStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onTap: () {
                    _focusNode.requestFocus();
                  },
                ),
              ),
            ),
          ),
          
          // 固定的结尾部分
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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