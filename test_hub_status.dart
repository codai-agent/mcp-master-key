import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Checking MCP Hub Status');
  
  // 检查Streamable Hub状态
  await checkStreamableHub();
  
  // 检查SSE Hub状态  
  await checkSseHub();
}

Future<void> checkStreamableHub() async {
  print('\n📡 Checking Streamable Hub (port 3001)...');
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://127.0.0.1:3001'));
    final response = await request.close();
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('✅ Streamable Hub Status: ${response.statusCode}');
    print('📄 Response: $responseBody');
    
    client.close();
  } catch (e) {
    print('❌ Streamable Hub not accessible: $e');
  }
}

Future<void> checkSseHub() async {
  print('\n📡 Checking SSE Hub (port 3000)...');
  
  try {
    final client = HttpClient();
    
    // 检查根路径
    final rootRequest = await client.getUrl(Uri.parse('http://127.0.0.1:3000'));
    final rootResponse = await rootRequest.close();
    final rootBody = await rootResponse.transform(utf8.decoder).join();
    
    print('✅ SSE Hub Root Status: ${rootResponse.statusCode}');
    print('📄 Root Response: $rootBody');
    
    // 检查服务器列表
    try {
      final serversRequest = await client.getUrl(Uri.parse('http://127.0.0.1:3000/servers'));
      final serversResponse = await serversRequest.close();
      final serversBody = await serversResponse.transform(utf8.decoder).join();
      
      print('✅ SSE Hub Servers Status: ${serversResponse.statusCode}');
      print('📄 Servers Response: $serversBody');
      
      // 解析服务器信息
      try {
        final serversData = jsonDecode(serversBody);
        print('📋 Servers Data: $serversData');
      } catch (e) {
        print('❌ Failed to parse servers data: $e');
      }
    } catch (e) {
      print('❌ Failed to get servers: $e');
    }
    
    client.close();
  } catch (e) {
    print('❌ SSE Hub not accessible: $e');
  }
} 