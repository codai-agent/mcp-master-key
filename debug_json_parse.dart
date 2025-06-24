import 'dart:convert';

void main() {
  // 测试我们发送的JSON是否能正确解析
  const jsonString = '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{"roots":{"listChanged":true},"sampling":{}}},"id":1}';
  
  print('原始JSON字符串:');
  print(jsonString);
  print('\n开始解析...');
  
  try {
    final decoded = jsonDecode(jsonString);
    print('解析成功!');
    print('类型: ${decoded.runtimeType}');
    print('内容: $decoded');
    
    // 检查字段
    print('\n字段检查:');
    print('jsonrpc: ${decoded['jsonrpc']}');
    print('method: ${decoded['method']}');
    print('params: ${decoded['params']}');
    print('id: ${decoded['id']}');
    
    // 检查是否为初始化请求
    bool isInit = decoded is Map<String, dynamic> &&
        decoded.containsKey('method') &&
        decoded['method'] == 'initialize';
    print('\n是否为初始化请求: $isInit');
    
  } catch (e, stackTrace) {
    print('解析失败: $e');
    print('Stack trace: $stackTrace');
  }
} 