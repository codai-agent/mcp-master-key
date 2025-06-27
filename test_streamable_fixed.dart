import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('🧪 测试 Streamable MCP Hub 修复');
  
  // 先检查应用是否启动
  print('🔍 检查应用是否启动...');
  await _checkServerStatus();
  
  // 等待应用完全启动
  await Future.delayed(Duration(seconds: 2));
  
  try {
    // 1. 测试初始化请求
    print('\n📝 步骤 1: 发送初始化请求...');
    final initResponse = await _sendHttpRequest(
      'POST',
      'http://localhost:3001',
      {
        'method': 'initialize',
        'params': {
          'protocolVersion': '2025-03-26',
          'capabilities': {
            'tools': true,
            'prompts': false,
            'resources': false,
            'logging': false,
            'roots': {'listChanged': false}
          },
          'clientInfo': {'name': 'test-client', 'version': '1.0.0'}
        },
        'jsonrpc': '2.0',
        'id': 0
      },
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'TestClient/1.0',
      },
    );
    
    print('✅ 初始化响应: ${jsonEncode(initResponse)}');
    
    // 提取会话ID
    final sessionId = initResponse['sessionId'] as String?;
    if (sessionId == null) {
      throw Exception('初始化响应中没有找到 sessionId');
    }
    print('🔑 会话ID: $sessionId');
    
    // 2. 发送通知已初始化
    print('\n📝 步骤 2: 发送初始化完成通知...');
    await _sendHttpRequest(
      'POST',
      'http://localhost:3001',
      {
        'method': 'notifications/initialized',
        'jsonrpc': '2.0'
      },
      headers: {
        'Content-Type': 'application/json',
        'mcp-session-id': sessionId,
      },
    );
    print('✅ 初始化通知发送成功');
    
    // 3. 测试工具列表请求
    print('\n📝 步骤 3: 请求工具列表...');
    final toolsResponse = await _sendHttpRequest(
      'POST',
      'http://localhost:3001',
      {
        'method': 'tools/list',
        'jsonrpc': '2.0',
        'id': 1
      },
      headers: {
        'Content-Type': 'application/json',
        'mcp-session-id': sessionId,
      },
    );
    
    print('✅ 工具列表响应: ${jsonEncode(toolsResponse)}');
    
    if (toolsResponse.containsKey('result') && 
        toolsResponse['result'].containsKey('tools')) {
      final tools = toolsResponse['result']['tools'] as List;
      print('🛠️ 找到 ${tools.length} 个工具:');
      for (final tool in tools) {
        print('   - ${tool['name']}: ${tool['description']}');
      }
    }
    
    print('\n🎉 测试成功完成！Streamable 模式工作正常。');
    
  } catch (error) {
    print('❌ 测试失败: $error');
    exit(1);
  }
}

Future<Map<String, dynamic>> _sendHttpRequest(
  String method,
  String url,
  Map<String, dynamic> body, {
  Map<String, String>? headers,
}) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(method, Uri.parse(url));
    
    // 设置headers
    if (headers != null) {
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    
    // 发送body (对于POST请求)
    if (method == 'POST') {
      final bodyBytes = utf8.encode(jsonEncode(body));
      request.headers.contentLength = bodyBytes.length;
      request.add(bodyBytes);
    }
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('📡 ${method} ${url} -> ${response.statusCode}');
    print('📨 响应: $responseBody');
    
    if (response.statusCode >= 400) {
      throw Exception('HTTP ${response.statusCode}: $responseBody');
    }
    
    return jsonDecode(responseBody) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}

Future<void> _checkServerStatus() async {
  final client = HttpClient();
  try {
    // 尝试连接到服务器
    final request = await client.openUrl('GET', Uri.parse('http://localhost:3001'));
    request.headers.set('User-Agent', 'TestClient/1.0');
    
    final response = await request.close();
    print('✅ 服务器响应状态: ${response.statusCode}');
    
    // 读取响应内容
    final responseBody = await response.transform(utf8.decoder).join();
    print('📄 响应内容: $responseBody');
    
  } catch (error) {
    print('⚠️ 连接服务器时出错: $error');
    print('🔄 尝试使用 curl 检查...');
    
    // 使用 curl 进行额外检查
    final result = await Process.run('curl', ['-v', 'http://localhost:3001']);
    print('🌐 Curl 输出: ${result.stdout}');
    print('❌ Curl 错误: ${result.stderr}');
  } finally {
    client.close();
  }
} 