import '../lib/business/services/command_resolver_service.dart';
import '../lib/core/models/mcp_server.dart';

void main() async {
  print('🧪 Testing Command Resolver Service');
  
  final resolver = CommandResolverService.instance;
  
  try {
    // 测试npx命令解析
    print('\n1️⃣ Testing NPX command resolution...');
    final npxResolved = await resolver.resolveServerConfig(
      command: 'npx',
      args: ['-y', '@wopal/mcp-server-hotnews'],
      env: {},
      installType: McpInstallType.npx,
    );
    
    print('   📋 NPX Resolution Result:');
    print('   - Command: ${npxResolved.command}');
    print('   - Args: ${npxResolved.args.join(' ')}');
    print('   - ENV PATH: ${npxResolved.env['PATH']?.substring(0, 100) ?? 'Not set'}...');
    
    // 测试uvx命令解析
    print('\n2️⃣ Testing UVX command resolution...');
    final uvxResolved = await resolver.resolveServerConfig(
      command: 'uvx',
      args: ['mcp-server-weather'],
      env: {'API_KEY': 'test-key'},
      installType: McpInstallType.uvx,
    );
    
    print('   📋 UVX Resolution Result:');
    print('   - Command: ${uvxResolved.command}');
    print('   - Args: ${uvxResolved.args.join(' ')}');
    print('   - ENV PATH: ${uvxResolved.env['PATH']?.substring(0, 100) ?? 'Not set'}...');
    print('   - ENV API_KEY: ${uvxResolved.env['API_KEY']}');
    
    // 测试本地路径（不应该改变）
    print('\n3️⃣ Testing Local Path (should not change)...');
    final localResolved = await resolver.resolveServerConfig(
      command: '/usr/local/bin/my-custom-server',
      args: ['--config', 'config.json'],
      env: {},
      installType: McpInstallType.localPath,
    );
    
    print('   📋 Local Path Resolution Result:');
    print('   - Command: ${localResolved.command}');
    print('   - Args: ${localResolved.args.join(' ')}');
    
    print('\n✅ All tests completed successfully!');
    
  } catch (e, stackTrace) {
    print('\n❌ Test failed with error: $e');
    print('Stack trace: $stackTrace');
  }
} 