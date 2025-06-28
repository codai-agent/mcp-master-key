import 'package:flutter/material.dart';
import 'dart:convert';
import '../lib/presentation/widgets/json_config_editor.dart';

void main() {
  runApp(const JsonEditorTestApp());
}

class JsonEditorTestApp extends StatelessWidget {
  const JsonEditorTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Editor Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const JsonEditorTestPage(),
    );
  }
}

class JsonEditorTestPage extends StatefulWidget {
  const JsonEditorTestPage({super.key});

  @override
  State<JsonEditorTestPage> createState() => _JsonEditorTestPageState();
}

class _JsonEditorTestPageState extends State<JsonEditorTestPage> {
  String _currentConfig = '''
{
  "mcpServers": {
    "example-server": {
      "command": "uvx",
      "args": ["mcp-server-hotnews"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}''';

  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON 配置编辑器测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'JSON 配置编辑器',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // JSON 编辑器
            Expanded(
              flex: 2,
              child: JsonConfigEditor(
                initialValue: _currentConfig,
                onChanged: (newConfig) {
                  setState(() {
                    _currentConfig = newConfig;
                    _validateConfig();
                  });
                },
                errorText: _errorText,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 当前配置预览
            const Text(
              '当前完整配置：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _currentConfig,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 示例配置按钮
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _loadExample('uvx'),
                  child: const Text('UVX 示例'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _loadExample('npx'),
                  child: const Text('NPX 示例'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _loadExample('python'),
                  child: const Text('Python 示例'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearConfig,
                  child: const Text('清空'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _validateConfig() {
    try {
      final Map<String, dynamic> config = 
          const JsonDecoder().convert(_currentConfig);
      if (!config.containsKey('mcpServers')) {
        setState(() {
          _errorText = '配置必须包含 mcpServers 字段';
        });
        return;
      }
      
      final mcpServers = config['mcpServers'] as Map<String, dynamic>;
      if (mcpServers.isEmpty) {
        setState(() {
          _errorText = 'mcpServers 不能为空';
        });
        return;
      }
      
      setState(() {
        _errorText = null;
      });
    } catch (e) {
      setState(() {
        _errorText = 'JSON 格式错误: $e';
      });
    }
  }

  void _loadExample(String type) {
    String example = '';
    switch (type) {
      case 'uvx':
        example = '''
{
  "mcpServers": {
    "hotnews": {
      "command": "uvx",
      "args": ["mcp-server-hotnews"],
      "env": {
        "NEWS_API_KEY": "your-api-key"
      }
    }
  }
}''';
        break;
      case 'npx':
        example = '''
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
    }
  }
}''';
        break;
      case 'python':
        example = '''
{
  "mcpServers": {
    "custom-server": {
      "command": "python",
      "args": ["-m", "my_mcp_server"],
      "env": {
        "PYTHONPATH": "/path/to/server"
      }
    }
  }
}''';
        break;
    }
    
    setState(() {
      _currentConfig = example;
    });
  }

  void _clearConfig() {
    setState(() {
      _currentConfig = '''
{
  "mcpServers": {
  }
}''';
    });
  }
} 