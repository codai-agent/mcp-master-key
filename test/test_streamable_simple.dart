import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Simple Streamable MCP Hub Test');
  
  const mcpUrl = 'http://127.0.0.1:3001/mcp';
  
  // 测试初始化请求
  final initRequest = {
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'initialize',
    'params': {
      'protocolVersion': '2024-11-05',
      'capabilities': {
        'roots': {'listChanged': true},
        'sampling': {}
      },
      'clientInfo': {
        'name': 'test-client',
        'version': '1.0.0'
      }
    }
  };
  
  try {
    print('📡 Sending initialize request...');
    
    // 创建HTTP客户端
    final client = HttpClient();
    
    // 创建请求
    final request = await client.postUrl(Uri.parse(mcpUrl));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json, text/event-stream');
    
    // 发送请求体
    request.add(utf8.encode(jsonEncode(initRequest)));
    
    // 获取响应
    final response = await request.close();
    
    print('✅ Response received!');
    print('📊 Status: ${response.statusCode}');
    print('🏷️ Headers:');
    response.headers.forEach((name, values) {
      print('   $name: ${values.join(', ')}');
    });
    
    // 检查session ID
    final sessionId = response.headers.value('mcp-session-id');
    if (sessionId != null) {
      print('🎉 SUCCESS! Session ID: $sessionId');
    } else {
      print('⚠️ No session ID in response');
    }
    
    // 处理SSE流响应
    if (response.headers.contentType?.mimeType == 'text/event-stream') {
      print('📡 Processing SSE stream...');
      
      await for (final chunk in response.transform(utf8.decoder)) {
        print('📥 SSE chunk: $chunk');
        
        // 解析SSE事件
        final lines = chunk.split('\n');
        String? eventType;
        String? eventData;
        
        for (final line in lines) {
          if (line.startsWith('event: ')) {
            eventType = line.substring(7);
          } else if (line.startsWith('data: ')) {
            eventData = line.substring(6);
          }
        }
        
        if (eventType == 'message' && eventData != null) {
          try {
            final messageData = jsonDecode(eventData);
            print('📋 MCP Response: $messageData');
            
            // 如果是初始化响应，我们可以结束了
            if (messageData['id'] == 1) {
              print('✅ Initialize response received, closing connection');
              break;
            }
          } catch (e) {
            print('❌ Failed to parse message data: $e');
          }
        }
      }
    } else {
      // 处理普通JSON响应
      final responseBody = await response.transform(utf8.decoder).join();
      print('📄 Response body: $responseBody');
      
      try {
        final responseData = jsonDecode(responseBody);
        print('📋 Response data: $responseData');
      } catch (e) {
        print('❌ Failed to parse response: $e');
      }
    }
    
    client.close();
    
  } catch (e) {
    print('�� Error: $e');
  }
} 