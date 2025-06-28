import '../lib/business/services/mcp_hub_service.dart';
import '../lib/business/services/config_service.dart';
import '../lib/infrastructure/database/database_service.dart';
import '../lib/infrastructure/repositories/mcp_server_repository.dart';

void main() async {
  print('🔍 Debug: Checking child servers status');
  
  try {
    // 初始化必要的服务
    final dbService = DatabaseService.instance;
    await dbService.database; // 触发数据库初始化
    
    // 获取Hub服务实例
    final hubService = McpHubService.instance;
    
    print('📊 MCP Hub Service Status:');
    print('  - Is running: ${hubService.isRunning}');
    print('  - Child servers count: ${hubService.childServers.length}');
    
    if (hubService.childServers.isNotEmpty) {
      print('\n📋 Child Servers:');
      for (int i = 0; i < hubService.childServers.length; i++) {
        final server = hubService.childServers[i];
        print('  ${i + 1}. ${server.name} (${server.id})');
        print('     - Connected: ${server.isConnected}');
        print('     - Tools: ${server.tools.length}');
        
        if (server.tools.isNotEmpty) {
          print('     - Tool names: ${server.tools.map((t) => t.name).join(', ')}');
        }
      }
    } else {
      print('\n⚠️ No child servers found in McpHubService');
    }
    
    // 检查数据库中的服务器
    print('\n📊 Database Servers:');
    final repository = McpServerRepository.instance;
    final servers = await repository.getAllServers();
    
    print('  - Database servers count: ${servers.length}');
    for (final server in servers) {
      print('    - ${server.name}: status=${server.status.name}, autoStart=${server.autoStart}');
    }
    
    // 检查特定的hotnews服务器
    final hotNewsServers = servers.where((s) => s.name.toLowerCase().contains('hotnews')).toList();
    if (hotNewsServers.isNotEmpty) {
      print('\n🔥 HotNews Servers:');
      for (final server in hotNewsServers) {
        print('    - ${server.name}: ${server.status.name}, command: ${server.command}');
      }
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
} 