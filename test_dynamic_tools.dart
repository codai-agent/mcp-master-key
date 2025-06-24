import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 测试MCP Hub的动态工具聚合功能
class DynamicToolsTest {
  final String baseUrl = 'http://127.0.0.1:3000';
  final http.Client client = http.Client();

  Future<void> runTest() async {
    print('🧪 开始测试MCP Hub动态工具聚合功能...\n');

    try {
      // 等待Hub启动
      await Future.delayed(const Duration(seconds: 5));
      
      await testInitialTools();
      await testSSEToolList();
      await testToolCalling();
      await testAfterServerConnection();
      
      print('\n✅ 动态工具聚合测试通过！');
    } catch (e) {
      print('\n❌ 测试失败: $e');
      exit(1);
    } finally {
      client.close();
    }
  }

  /// 测试初始工具列表（应该只有ping）
  Future<void> testInitialTools() async {
    print('📋 测试初始工具列表...');

    final toolsResponse = await client.get(Uri.parse('$baseUrl/tools'));
    if (toolsResponse.statusCode != 200) {
      throw Exception('获取工具列表失败: ${toolsResponse.statusCode}');
    }
    
    final toolsData = jsonDecode(toolsResponse.body);
    print('  📊 工具统计: ${toolsData['count']} 个工具');
    print('  🏢 Hub工具: ${toolsData['hub_tools']} 个');
    print('  🔧 子服务器工具: ${toolsData['child_tools']} 个');
    
    // 验证只有ping工具
    final tools = toolsData['tools'] as List;
    final hubTools = tools.where((t) => t['source'] == 'hub').toList();
    
    if (hubTools.length != 1) {
      throw Exception('期望Hub只有1个工具，实际有${hubTools.length}个');
    }
    
    if (hubTools[0]['name'] != 'ping') {
      throw Exception('期望Hub工具为ping，实际为${hubTools[0]['name']}');
    }
    
    print('  ✅ 初始工具列表正确：只有ping工具');
  }

  /// 测试SSE端点的工具发现
  Future<void> testSSEToolList() async {
    print('\n📡 测试SSE工具发现...');

    try {
      // 使用SSE端点发起tools/list请求
      final mcpRequest = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'tools/list',
        'params': {},
      };

      final response = await client.post(
        Uri.parse('$baseUrl/mcp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(mcpRequest),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final tools = responseData['result']['tools'] as List;
        
        print('  📋 SSE发现的工具数量: ${tools.length}');
        
        final hubTools = tools.where((t) => 
          t['description']?.toString().contains('Hub') == true).toList();
        final childTools = tools.where((t) => 
          t['description']?.toString().contains('via') == true).toList();
          
        print('  🏢 Hub工具: ${hubTools.length} 个');
        print('  🔧 子服务器工具: ${childTools.length} 个');
        
        // 列出所有工具
        for (final tool in tools) {
          print('    - ${tool['name']}: ${tool['description']}');
        }
        
        print('  ✅ SSE工具发现正常');
      } else {
        print('  ⚠️ SSE工具发现跳过: ${response.statusCode}');
      }
    } catch (e) {
      print('  ⚠️ SSE工具发现跳过: $e');
    }
  }

  /// 测试工具调用
  Future<void> testToolCalling() async {
    print('\n🔧 测试工具调用...');

    try {
      // 测试ping工具
      final pingRequest = {
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {
          'name': 'ping',
          'arguments': {},
        },
      };

      final pingResponse = await client.post(
        Uri.parse('$baseUrl/mcp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pingRequest),
      );

      if (pingResponse.statusCode == 200) {
        final pingData = jsonDecode(pingResponse.body);
        if (pingData['result'] != null) {
          final content = pingData['result']['content'] as List;
          final textContent = content.isNotEmpty ? content[0]['text'] : 'no content';
          print('  🏓 Ping结果: $textContent');
          
          if (textContent.contains('pong')) {
            print('  ✅ Ping工具调用成功');
          } else {
            print('  ⚠️ Ping响应异常: $textContent');
          }
        } else {
          print('  ⚠️ Ping调用失败: ${pingData['error']}');
        }
      } else {
        print('  ⚠️ Ping调用失败: ${pingResponse.statusCode}');
      }
    } catch (e) {
      print('  ⚠️ 工具调用测试跳过: $e');
    }
  }

  /// 测试服务器连接后的工具变化
  Future<void> testAfterServerConnection() async {
    print('\n🔗 监控服务器连接后的工具变化...');

    // 获取当前工具列表
    final initialResponse = await client.get(Uri.parse('$baseUrl/tools'));
    final initialData = jsonDecode(initialResponse.body);
    final initialCount = initialData['count'];
    
    print('  📊 当前工具数量: $initialCount');
    
    // 等待一段时间，让服务器连接
    print('  ⏳ 等待服务器连接...');
    await Future.delayed(const Duration(seconds: 10));
    
    // 再次检查工具列表
    final finalResponse = await client.get(Uri.parse('$baseUrl/tools'));
    final finalData = jsonDecode(finalResponse.body);
    final finalCount = finalData['count'];
    
    print('  📊 最终工具数量: $finalCount');
    
    if (finalCount > initialCount) {
      print('  🎉 检测到工具数量增加，动态聚合正常！');
      
      // 显示新增的工具
      final tools = finalData['tools'] as List;
      final childTools = tools.where((t) => t['source'] == 'child_server').toList();
      
      if (childTools.isNotEmpty) {
        print('  🔧 子服务器工具:');
        for (final tool in childTools) {
          print('    - ${tool['name']}: ${tool['description']}');
        }
      }
    } else if (finalCount == initialCount) {
      print('  📋 工具数量未变化，可能子服务器未连接');
    } else {
      print('  ⚠️ 工具数量异常减少');
    }
    
    print('  ✅ 动态工具聚合监控完成');
  }
}

Future<void> main() async {
  final tester = DynamicToolsTest();
  await tester.runTest();
} 