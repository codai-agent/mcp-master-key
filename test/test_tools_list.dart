import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 Testing Streamable MCP Hub Tools');
  
  await testToolsList();
}

Future<void> testToolsList() async {
  const mcpUrl = 'http://127.0.0.1:3001/mcp';
  
  // 先进行初始化
  print('📡 Step 1: Initialize session...');
  final sessionId = await initializeSession(mcpUrl);
  
  if (sessionId == null) {
    print('❌ Failed to initialize session');
    return;
  }
  
  print('✅ Session initialized: $sessionId');
  
  // 等待一下，让服务器监控有机会发现子服务器
  print('⏳ Waiting 15 seconds for server monitoring...');
  await Future.delayed(Duration(seconds: 15));
  
  // 列出工具
  print('\n📡 Step 2: List available tools...');
  await listTools(mcpUrl, sessionId);
}

Future<String?> initializeSession(String mcpUrl) async {
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
        'name': 'tools-test-client',
        'version': '1.0.0'
      }
    }
  };
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(mcpUrl));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json, text/event-stream');
    request.add(utf8.encode(jsonEncode(initRequest)));
    
    final response = await request.close();
    final sessionId = response.headers.value('mcp-session-id');
    
    // 读取并丢弃SSE响应
    await response.drain();
    client.close();
    
    return sessionId;
  } catch (e) {
    print('💥 Error during initialization: $e');
    return null;
  }
}

Future<void> listTools(String mcpUrl, String sessionId) async {
  final toolsRequest = {
    'jsonrpc': '2.0',
    'id': 2,
    'method': 'tools/list',
  };
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(mcpUrl));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json, text/event-stream');
    request.headers.set('mcp-session-id', sessionId);
    request.add(utf8.encode(jsonEncode(toolsRequest)));
    
    final response = await request.close();
    
    print('📊 Tools list response status: ${response.statusCode}');
    
    if (response.headers.contentType?.mimeType == 'text/event-stream') {
      print('📡 Processing SSE stream for tools list...');
      
      await for (final chunk in response.transform(utf8.decoder)) {
        print('📥 SSE chunk: $chunk');
        
        // 解析SSE事件
        final lines = chunk.split('\n');
        String? eventData;
        
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            eventData = line.substring(6);
          }
        }
        
        if (eventData != null) {
          try {
            final messageData = jsonDecode(eventData);
            print('📋 Tools Response: $messageData');
            
            // 检查是否是工具列表响应
            if (messageData['id'] == 2 && messageData['result'] != null) {
              final tools = messageData['result']['tools'] as List?;
              if (tools != null) {
                print('\n🔧 Available Tools (${tools.length}):');
                for (int i = 0; i < tools.length; i++) {
                  final tool = tools[i];
                  print('  ${i + 1}. ${tool['name']} - ${tool['description']}');
                }
              } else {
                print('⚠️ No tools found in response');
              }
              break;
            }
          } catch (e) {
            print('❌ Failed to parse tools data: $e');
          }
        }
      }
    }
    
    client.close();
  } catch (e) {
    print('💥 Error listing tools: $e');
  }
} 