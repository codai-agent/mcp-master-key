import 'lib/business/services/mcp_hub_service.dart';
import 'lib/infrastructure/database/database_service.dart';
import 'lib/infrastructure/repositories/mcp_server_repository.dart';

void main() async {
  print('🔍 Debug: Manual monitoring trigger');
  
  try {
    // 初始化数据库
    final dbService = DatabaseService.instance;
    await dbService.database;
    print('✅ Database initialized');
    
    // 检查数据库状态
    final repository = McpServerRepository.instance;
    final servers = await repository.getAllServers();
    
    print('📊 Database Servers:');
    for (final server in servers) {
      print('  - ${server.name}: ${server.status.name}');
    }
    
    // 检查Hub服务
    final hubService = McpHubService.instance;
    print('📊 Hub Service Status:');
    print('  - Is running: ${hubService.isRunning}');
    print('  - Child servers: ${hubService.childServers.length}');
    
    // 手动触发监控（需要访问私有方法）
    // 我们可以通过反射或者直接调用公共接口
    print('🔄 Manual monitoring trigger (if hub is running)...');
    
    if (!hubService.isRunning) {
      print('⚠️ Hub is not running, cannot trigger monitoring');
      print('💡 Try starting the hub first');
    }
    
  } catch (e) {
    print('❌ Error: $e');
    print('Stack trace: ${StackTrace.current}');
  }
} 