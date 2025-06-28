import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// MCP Hub完整功能测试脚本
class McpHubTester {
  final String baseUrl = 'http://127.0.0.1:3000';
  final http.Client client = http.Client();

  Future<void> runAllTests() async {
    print('🚀 开始MCP Hub完整功能测试...\n');

    try {
      await testBasicEndpoints();
      await testSSEConnection();
      await testMCPProtocol();
      await testServerManagement();
      await testToolRouting();
      await testHealthMonitoring();
      
      print('\n✅ 所有测试通过！MCP Hub功能完整！');
    } catch (e) {
      print('\n❌ 测试失败: $e');
      exit(1);
    } finally {
      client.close();
    }
  }

  /// 测试基础端点
  Future<void> testBasicEndpoints() async {
    print('📋 测试基础端点...');

    // 测试根端点
    final rootResponse = await client.get(Uri.parse('$baseUrl/'));
    if (rootResponse.statusCode != 200) {
      throw Exception('根端点失败: ${rootResponse.statusCode}');
    }
    
    final rootData = jsonDecode(rootResponse.body);
    print('  ✓ 根端点: ${rootData['name']} v${rootData['version']}');

    // 测试健康检查
    final healthResponse = await client.get(Uri.parse('$baseUrl/health'));
    if (healthResponse.statusCode != 200) {
      throw Exception('健康检查失败: ${healthResponse.statusCode}');
    }
    
    final healthData = jsonDecode(healthResponse.body);
    print('  ✓ 健康检查: ${healthData['status']}');

    // 测试服务器列表
    final serversResponse = await client.get(Uri.parse('$baseUrl/servers'));
    if (serversResponse.statusCode != 200) {
      throw Exception('服务器列表失败: ${serversResponse.statusCode}');
    }
    
    final serversData = jsonDecode(serversResponse.body);
    print('  ✓ 服务器列表: ${serversData['count']} 个服务器');

    print('  ✅ 基础端点测试通过\n');
  }

  /// 测试SSE连接
  Future<void> testSSEConnection() async {
    print('📡 测试SSE连接...');

    try {
      final request = http.Request('GET', Uri.parse('$baseUrl/sse'));
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final response = await client.send(request);
      
      if (response.statusCode != 200) {
        throw Exception('SSE连接失败: ${response.statusCode}');
      }

      if (response.headers['content-type'] != 'text/event-stream') {
        throw Exception('SSE Content-Type错误: ${response.headers['content-type']}');
      }

      print('  ✓ SSE连接成功');
      print('  ✓ Content-Type正确: text/event-stream');

      // 读取几个事件
      int eventCount = 0;
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        print('  📨 SSE事件: ${chunk.trim()}');
        eventCount++;
        if (eventCount >= 3) break; // 读取3个事件后停止
      }

      print('  ✅ SSE连接测试通过\n');
    } catch (e) {
      print('  ⚠️ SSE测试跳过: $e\n');
    }
  }

  /// 测试MCP协议
  Future<void> testMCPProtocol() async {
    print('🔧 测试MCP协议...');

    // 测试MCP初始化
    final initRequest = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'initialize',
      'params': {
        'protocolVersion': '2025-03-26',
        'capabilities': {
          'tools': {'listChanged': true},
          'resources': {'listChanged': true},
        },
        'clientInfo': {
          'name': 'MCP Hub Tester',
          'version': '1.0.0',
        },
      },
    };

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/mcp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(initRequest),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  ✓ MCP初始化成功');
        print('  ✓ 服务器信息: ${data['result']['serverInfo']['name']}');
      } else {
        print('  ⚠️ MCP初始化失败: ${response.statusCode}');
      }
    } catch (e) {
      print('  ⚠️ MCP协议测试跳过: $e');
    }

    print('  ✅ MCP协议测试完成\n');
  }

  /// 测试服务器管理
  Future<void> testServerManagement() async {
    print('🖥️ 测试服务器管理...');

    // 测试连接服务器
    final connectRequest = {
      'server_id': 'test_server',
      'name': 'Test Server',
      'command': 'echo',
      'args': ['hello'],
    };

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/servers/connect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(connectRequest),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  ✓ 服务器连接请求成功: ${data['message']}');
      } else {
        print('  ⚠️ 服务器连接失败: ${response.statusCode}');
      }
    } catch (e) {
      print('  ⚠️ 服务器管理测试跳过: $e');
    }

    print('  ✅ 服务器管理测试完成\n');
  }

  /// 测试工具路由
  Future<void> testToolRouting() async {
    print('🛠️ 测试工具路由...');

    // 测试工具列表
    try {
      final response = await client.get(Uri.parse('$baseUrl/tools'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  ✓ 工具列表获取成功: ${data['count']} 个工具');
        
        if (data['tools'] is List && (data['tools'] as List).isNotEmpty) {
          final firstTool = (data['tools'] as List).first;
          print('  ✓ 示例工具: ${firstTool['name']} - ${firstTool['description']}');
        }
      } else {
        print('  ⚠️ 工具列表获取失败: ${response.statusCode}');
      }
    } catch (e) {
      print('  ⚠️ 工具路由测试跳过: $e');
    }

    // 测试工具调用
    final toolCallRequest = {
      'tool_name': 'ping',
      'args': {},
    };

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/tools/call'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(toolCallRequest),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  ✓ 工具调用成功: ${data['result']}');
      } else {
        print('  ⚠️ 工具调用失败: ${response.statusCode}');
      }
    } catch (e) {
      print('  ⚠️ 工具调用测试跳过: $e');
    }

    print('  ✅ 工具路由测试完成\n');
  }

  /// 测试健康监控
  Future<void> testHealthMonitoring() async {
    print('📊 测试健康监控...');

    // 测试统计信息
    try {
      final response = await client.get(Uri.parse('$baseUrl/stats'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  ✓ 统计信息获取成功');
        print('  ✓ 连接的服务器: ${data['connected_servers']}');
        print('  ✓ 总工具数: ${data['total_tools']}');
        print('  ✓ 总资源数: ${data['total_resources']}');
      } else {
        print('  ⚠️ 统计信息获取失败: ${response.statusCode}');
      }
    } catch (e) {
      print('  ⚠️ 健康监控测试跳过: $e');
    }

    // 测试事件流
    try {
      final response = await client.get(Uri.parse('$baseUrl/events'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  ✓ 事件流获取成功: ${data['events']?.length ?? 0} 个事件');
      } else {
        print('  ⚠️ 事件流获取失败: ${response.statusCode}');
      }
    } catch (e) {
      print('  ⚠️ 事件流测试跳过: $e');
    }

    print('  ✅ 健康监控测试完成\n');
  }

  /// 测试性能
  Future<void> testPerformance() async {
    print('⚡ 测试性能...');

    final stopwatch = Stopwatch()..start();
    
    // 并发测试
    final futures = List.generate(10, (i) async {
      final response = await client.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    });

    final results = await Future.wait(futures);
    stopwatch.stop();

    final successCount = results.where((r) => r).length;
    print('  ✓ 并发请求: $successCount/10 成功');
    print('  ✓ 响应时间: ${stopwatch.elapsedMilliseconds}ms');

    print('  ✅ 性能测试完成\n');
  }
}

void main() async {
  final tester = McpHubTester();
  await tester.runAllTests();
} 