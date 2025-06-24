import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 模拟官方StreamableHTTPClientTransport的请求
Future<void> testStreamableCompatibility() async {
  print('🧪 Testing Streamable MCP Hub compatibility with official client');
  
  const baseUrl = 'http://127.0.0.1:3001';
  const mcpUrl = '$baseUrl/mcp';
  
  // 测试1: 发送初始化请求（模拟官方客户端）
  print('\n📡 Test 1: Initialize request');
  
  final initRequest = {
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'initialize',
    'params': {
      'protocolVersion': '2024-11-05',
      'capabilities': {
        'roots': {
          'listChanged': true
        },
        'sampling': {}
      },
      'clientInfo': {
        'name': 'test-client',
        'version': '1.0.0'
      }
    }
  };
  
  try {
    // 发送POST请求
    final response = await http.post(
      Uri.parse(mcpUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        // 注意：初始化请求不包含session-id
      },
      body: jsonEncode(initRequest),
    );
    
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response headers: ${response.headers}');
    print('📥 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('✅ Initialize successful');
      print('📋 Response data: $responseData');
      
      // 检查是否有session-id
      final sessionId = response.headers['mcp-session-id'];
      if (sessionId != null) {
        print('🔑 Session ID received: $sessionId');
        
        // 测试2: 使用session-id发送后续请求
        await testWithSessionId(mcpUrl, sessionId);
      } else {
        print('⚠️ No session ID in response headers');
      }
    } else {
      print('❌ Initialize failed');
    }
    
  } catch (e, stackTrace) {
    print('💥 Error during initialize: $e');
    print('📚 Stack trace: $stackTrace');
  }
}

/// 使用session ID测试后续请求
Future<void> testWithSessionId(String mcpUrl, String sessionId) async {
  print('\n📡 Test 2: Request with session ID');
  
  final listToolsRequest = {
    'jsonrpc': '2.0',
    'id': 2,
    'method': 'tools/list',
  };
  
  try {
    final response = await http.post(
      Uri.parse(mcpUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        'mcp-session-id': sessionId,
      },
      body: jsonEncode(listToolsRequest),
    );
    
    print('📥 Tools/list response status: ${response.statusCode}');
    print('📥 Tools/list response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('✅ Tools/list successful');
      print('📋 Available tools: $responseData');
    } else {
      print('❌ Tools/list failed');
    }
    
  } catch (e) {
    print('💥 Error during tools/list: $e');
  }
  
  // 测试3: 测试ping工具
  await testPingTool(mcpUrl, sessionId);
}

/// 测试ping工具
Future<void> testPingTool(String mcpUrl, String sessionId) async {
  print('\n📡 Test 3: Call ping tool');
  
  final callToolRequest = {
    'jsonrpc': '2.0',
    'id': 3,
    'method': 'tools/call',
    'params': {
      'name': 'ping',
      'arguments': {}
    }
  };
  
  try {
    final response = await http.post(
      Uri.parse(mcpUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        'mcp-session-id': sessionId,
      },
      body: jsonEncode(callToolRequest),
    );
    
    print('📥 Ping tool response status: ${response.statusCode}');
    print('📥 Ping tool response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('✅ Ping tool successful');
      print('📋 Ping result: $responseData');
    } else {
      print('❌ Ping tool failed');
    }
    
  } catch (e) {
    print('💥 Error during ping tool: $e');
  }
}

/// 测试服务器状态
Future<void> testServerStatus() async {
  print('\n📊 Testing server status');
  
  try {
    final response = await http.get(Uri.parse('http://127.0.0.1:3001'));
    print('📥 Server status: ${response.statusCode}');
    print('📥 Server response: ${response.body}');
  } catch (e) {
    print('💥 Server not responding: $e');
  }
}

/// 模拟问题场景：发送null请求
Future<void> testNullRequest() async {
  print('\n🔍 Test 4: Null request (reproducing the issue)');
  
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:3001/mcp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: 'null', // 模拟客户端发送null
    );
    
    print('📥 Null request response status: ${response.statusCode}');
    print('📥 Null request response body: ${response.body}');
    
  } catch (e) {
    print('💥 Error during null request: $e');
  }
}

/// 测试空字符串
Future<void> testEmptyRequest() async {
  print('\n🔍 Test 5: Empty request');
  
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:3001/mcp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: '', // 空请求体
    );
    
    print('📥 Empty request response status: ${response.statusCode}');
    print('📥 Empty request response body: ${response.body}');
    
  } catch (e) {
    print('💥 Error during empty request: $e');
  }
}

void main() async {
  print('🚀 Starting Streamable MCP Hub compatibility tests');
  
  // 首先检查服务器状态
  await testServerStatus();
  
  // 等待1秒确保服务器准备就绪
  await Future.delayed(Duration(seconds: 1));
  
  // 运行兼容性测试
  await testStreamableCompatibility();
  
  // 测试问题场景
  await testNullRequest();
  await testEmptyRequest();
  
  print('\n✅ All tests completed');
} 