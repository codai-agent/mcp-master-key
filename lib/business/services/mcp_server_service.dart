import 'dart:async';
import 'package:mutex/mutex.dart';
import 'package:mcphub/core/models/mcp_server.dart' as models;
import 'package:mcphub/business/services/install_service.dart';
// import 'package:mcphub/business/services/process_service.dart';
import 'package:mcphub/infrastructure/repositories/mcp_server_repository.dart';
import 'command_resolver_service.dart';
import 'mcp_hub_service.dart';

/// MCP服务器管理服务
class McpServerService {
  static McpServerService? _instance;
  final McpServerRepository _repository = McpServerRepository.instance;
  final InstallService _installService = InstallService.instance;
  // final ProcessService _processService = ProcessService.instance;
  final CommandResolverService _commandResolver = CommandResolverService.instance;
  final Mutex _statusLock = Mutex(); // 状态读写锁

  McpServerService._internal();

  /// 获取单例实例
  static McpServerService get instance {
    _instance ??= McpServerService._internal();
    return _instance!;
  }

  /// 获取所有服务器
  Future<List<models.McpServer>> getAllServers() async {
    return await _statusLock.protect(() async {
      return await _repository.getAllServers();
    });
  }

  /// 添加新服务器
  Future<void> addServer({
    required String name,
    required String command,
    required models.McpInstallType installType,
    String? description,
    List<String> args = const [],
    Map<String, String> env = const {},
    String? workingDirectory,
    String? installSource,
    String? installSourceType,
    bool autoStart = false,
    models.McpConnectionType connectionType = models.McpConnectionType.stdio,
  }) async {
    print('📝 Adding new server: $name');
    print('   📋 Original command: $command');
    print('   📋 Install type: ${installType.name}');
    
    await _statusLock.protect(() async {
      // 🔍 检查是否已存在相同的服务器
      final existingServers = await _repository.getAllServers();
      
      // 检查相同名称的服务器
      final duplicateByName = existingServers.where((s) => s.name == name).toList();
      if (duplicateByName.isNotEmpty) {
        print('❌ 服务器名称重复: $name (ID: ${duplicateByName.first.id})');
        throw Exception('已存在同名的服务器: $name');
      }
      
      // 检查相同安装源的服务器（如果提供了installSource）
      if (installSource != null && installSource.isNotEmpty) {
        final duplicateBySource = existingServers.where((s) => 
          s.installSource == installSource && 
          s.installType == installType
        ).toList();
        if (duplicateBySource.isNotEmpty) {
          print('❌ 服务器安装源重复: $installSource (已存在服务器: ${duplicateBySource.first.name})');
          throw Exception('已存在相同安装源的服务器: ${duplicateBySource.first.name} ($installSource)');
        }
      }
      
      // 检查相同命令和参数的服务器（更精确的重复检查）
      final duplicateByCommand = existingServers.where((s) => 
        s.command == command && 
        s.args.length == args.length &&
        s.args.every((arg) => args.contains(arg)) &&
        args.every((arg) => s.args.contains(arg))
      ).toList();
      if (duplicateByCommand.isNotEmpty) {
        print('❌ 服务器命令重复: $command ${args.join(' ')} (已存在服务器: ${duplicateByCommand.first.name})');
        throw Exception('已存在相同命令配置的服务器: ${duplicateByCommand.first.name}');
      }
      
      // 🔧 解析命令和环境变量，转换为内置runtime路径
      final resolvedConfig = await _commandResolver.resolveServerConfig(
        command: command,
        args: args,
        env: env,
        installType: installType,
      );
      
      print('   ✅ Command resolved: ${resolvedConfig.command}');
      print('   ✅ Duplicate check passed');
      
      final server = models.McpServer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        installType: installType,
        connectionType: connectionType,  // 使用解析的连接类型
        command: resolvedConfig.command,  // 使用解析后的完整路径
        args: resolvedConfig.args,        // 使用解析后的参数
        env: resolvedConfig.env,          // 使用解析后的环境变量
        workingDirectory: workingDirectory,
        installSource: installSource,
        installSourceType: installSourceType,
        autoStart: autoStart,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.insertServer(server);
      print('✅ Server added with resolved paths: ${server.name}');
      print('   💾 Stored command: ${server.command}');
    });
  }

  /// 启动服务器（用户手动操作） - 直接调用Hub启动方法
  Future<bool> startServerByUser(String serverId) async {
    return await _statusLock.protect(() async {
      try {
        print('🚀 User request: START server $serverId');
        
        // 获取服务器信息
        final server = await _repository.getServerById(serverId);
        if (server == null) {
          print('❌ Server not found: $serverId');
          return false;
        }
        
        // 检查当前状态
        if (server.status == models.McpServerStatus.running) {
          print('⚠️ Server already running: ${server.name}');
          return true;
        }
        
        // 如果服务器状态是starting，说明可能之前启动失败或卡住了，继续尝试启动
        if (server.status == models.McpServerStatus.starting) {
          print('⚠️ Server is in starting state, will retry startup: ${server.name}');
        }
        
        // 直接调用Hub启动方法
        print('🚀 Direct start: Calling Hub to start server ${server.name}');
        
        // 首先更新状态为starting
        await _simpleUpdateStatus(serverId, models.McpServerStatus.starting);

        //huqb 重复启动了服务器，数据库监控的地方也会去启动
        // 导入Hub服务并直接调用启动方法
        try {
          final hubService = McpHubService.instance;
          await hubService.startServerDirectly(server);
          print('✅ Direct start completed for ${server.name}');
        } catch (hubError) {
          print('❌ Hub service error: $hubError, falling back to status update');
          // Hub启动失败时，立即更新状态为error
          await _simpleUpdateStatus(serverId, models.McpServerStatus.error);
          return false;
        }
        
        return true;
        
      } catch (e) {
        print('❌ Error processing user start request for $serverId: $e');
        // 启动失败时重置状态
        try {
          await _simpleUpdateStatus(serverId, models.McpServerStatus.error);
        } catch (statusError) {
          print('❌ Failed to update status after error: $statusError');
        }
        return false;
      }
    });
  }

  /// 停止服务器（用户手动操作） - 直接调用Hub停止方法
  Future<bool> stopServerByUser(String serverId) async {
    return await _statusLock.protect(() async {
      try {
        print('🛑 User request: STOP server $serverId');
        
        // 获取服务器信息
        final server = await _repository.getServerById(serverId);
        if (server == null) {
          print('❌ Server not found: $serverId');
          return false;
        }
        
        // 检查当前状态
        if (server.status == models.McpServerStatus.stopped) {
          print('⚠️ Server already stopped: ${server.name}');
          return true;
        }
        
        // 如果服务器状态是stopping，说明可能之前停止失败或卡住了，继续尝试停止
        if (server.status == models.McpServerStatus.stopping) {
          print('⚠️ Server is in stopping state, will retry stopping: ${server.name}');
        }
        
        // 直接调用Hub停止方法
        print('🛑 Direct stop: Calling Hub to stop server ${server.name}');
        
        // 首先更新状态为stopping
        await _simpleUpdateStatus(serverId, models.McpServerStatus.stopping);
        
        // 导入Hub服务并直接调用停止方法
        try {
          final hubService = McpHubService.instance;
          await hubService.stopServerDirectly(server);
          print('✅ Direct stop completed for ${server.name}');
        } catch (hubError) {
          print('❌ Hub service error: $hubError, falling back to status update');
          // Hub停止失败时，立即更新状态为error
          await _simpleUpdateStatus(serverId, models.McpServerStatus.error);
          return false;
        }
        
        return true;
        
      } catch (e) {
        print('❌ Error processing user stop request for $serverId: $e');
        // 停止失败时重置状态
        try {
          await _simpleUpdateStatus(serverId, models.McpServerStatus.error);
        } catch (statusError) {
          print('❌ Failed to update status after error: $statusError');
        }
        return false;
      }
    });
  }

  /// 获取服务器状态（线程安全）
  Future<models.McpServerStatus?> getServerStatus(String serverId) async {
    return await _statusLock.protect(() async {
      final server = await _repository.getServerById(serverId);
      return server?.status;
    });
  }

  /// 简单更新状态（不执行实际操作）
  Future<void> _simpleUpdateStatus(String serverId, models.McpServerStatus status) async {
    final server = await _repository.getServerById(serverId);
    if (server == null) {
      print('❌ Cannot update status: Server $serverId not found');
      return;
    }
    
    final updatedServer = server.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    
    await _repository.updateServer(updatedServer);
    print('📋 Status updated: ${server.name} -> ${status.name}');
  }

  /// 更新服务器状态（保留旧接口兼容性）
  Future<void> updateServerStatus(String serverId, models.McpServerStatus status) async {
    await _statusLock.protect(() async {
      await _updateServerStatus(serverId, status);
    });
  }

  /// 删除服务器
  Future<void> removeServer(String serverId) async {
    await _statusLock.protect(() async {
      final server = await _repository.getServerById(serverId);
      if (server == null) {
        throw Exception('Server not found: $serverId');
      }

      await _repository.deleteServer(serverId);
      print('🗑️ Server removed: ${server.name}');
    });
  }

  /// 获取运行中的服务器
  Future<List<models.McpServer>> getRunningServers() async {
    return await _statusLock.protect(() async {
      return await _repository.getServersByStatus(models.McpServerStatus.running);
    });
  }

  /// 获取需要自动启动的服务器
  Future<List<models.McpServer>> getAutoStartServers() async {
    return await _repository.getAutoStartServers();
  }

  /// 创建示例服务器（用于测试）
  Future<void> createSampleServers() async {
    print('🧪 Creating sample servers for testing...');

    // 示例1：Everything MCP Server
    await addServer(
      name: 'Everything MCP Server',
      description: 'Search and retrieve information from the Everything search engine',
      installType: models.McpInstallType.npx,
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-everything'],
      installSource: '@modelcontextprotocol/server-everything',
    );

    // 示例2：Filesystem MCP Server
    await addServer(
      name: 'Filesystem MCP Server',
      description: 'Secure file system operations',
      installType: models.McpInstallType.npx,
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-filesystem', '/tmp'],
      installSource: '@modelcontextprotocol/server-filesystem',
      autoStart: true,
    );

    // 示例3：Python Weather Server
    await addServer(
      name: 'Weather MCP Server',
      description: 'Weather information using Python',
      installType: models.McpInstallType.uvx,
      command: 'uvx',
      args: ['mcp-server-weather'],
      installSource: 'mcp-server-weather',
      env: {'API_KEY': 'your-weather-api-key'},
    );

    print('✅ Sample servers created successfully');
  }

  /// 添加测试用的HotNews服务器
  Future<void> addHotNewsTestServer() async {
    print('🧪 Adding HotNews test server...');
    print('   📋 Configuration from user:');
    print('   - name: mcp-server-hotnews');
    print('   - disabled: true (will be enabled for testing)');
    print('   - timeout: 60');
    print('   - command: npx');
    print('   - args: ["-y", "@wopal/mcp-server-hotnews"]');
    print('   - transportType: stdio');
    
    try {
      await addServer(
        name: 'HotNews MCP Server',
        description: 'Hot news information server for testing',
        installType: models.McpInstallType.npx,
        command: 'npx',
        args: ['-y', '@wopal/mcp-server-hotnews'],
        installSource: '@wopal/mcp-server-hotnews',
        autoStart: false, // 对应配置中的disabled: true
      );
      
      print('✅ HotNews test server added successfully');
      print('   📝 Server will be available for manual start/stop testing');
      
    } catch (e) {
      print('❌ Failed to add HotNews test server: $e');
      print('   🔍 Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// 测试服务器完整生命周期
  Future<void> testServerLifecycle(String serverName) async {
    print('🧪 Testing complete lifecycle for server: $serverName');
    
    // 1. 查找服务器
    final servers = await getAllServers();
    final server = servers.firstWhere(
      (s) => s.name.contains(serverName),
      orElse: () => throw Exception('Server not found: $serverName'),
    );
    
    print('   📋 Found server: ${server.name} (ID: ${server.id})');
    print('   📋 Current status: ${server.status.name}');
    print('   📋 Install type: ${server.installType.name}');
    print('   📋 Command: ${server.command}');
    print('   📋 Args: ${server.args.join(' ')}');
    print('   📋 Install source: ${server.installSource}');
    
    try {
      // 2. 测试启动
      print('   🚀 Testing server start...');
      await updateServerStatus(server.id, models.McpServerStatus.running);
      print('   ✅ Server start test completed');
      
      // 3. 等待一段时间
      print('   ⏳ Waiting 5 seconds to observe server behavior...');
      await Future.delayed(Duration(seconds: 5));
      
      // 4. 测试停止
      print('   🛑 Testing server stop...');
      await updateServerStatus(server.id, models.McpServerStatus.stopped);
      print('   ✅ Server stop test completed');
      
      print('✅ Complete lifecycle test finished for: $serverName');
      
    } catch (e) {
      print('❌ Lifecycle test failed for $serverName: $e');
      print('   🔍 Stack trace: ${StackTrace.current}');
      
      // 尝试清理
      try {
        await updateServerStatus(server.id, models.McpServerStatus.stopped);
        print('   🧹 Cleanup: Server stopped');
      } catch (cleanupError) {
        print('   ⚠️ Cleanup failed: $cleanupError');
      }
      
      rethrow;
    }
  }

  /// 更新服务器状态（内部方法）
  Future<void> _updateServerStatus(String serverId, models.McpServerStatus status) async {
    final server = await _repository.getServerById(serverId);
    if (server == null) {
      print('❌ Cannot update status: Server $serverId not found');
      return;
    }
    
    print('🔄 Updating server status: ${server.name}');
    print('   📋 Server details:');
    print('   - ID: ${server.id}');
    print('   - Install Type: ${server.installType.name}');
    print('   - Command: ${server.command}');
    print('   - Args: ${server.args}');
    print('   - Install Source: ${server.installSource}');
    print('   - Working Directory: ${server.workingDirectory}');
    print('   - Environment: ${server.env}');
    print('   - Status: ${server.status.name} -> ${status.name}');

    // 用户手动操作：实际启动/停止进程，然后更新数据库状态
    if (status == models.McpServerStatus.running) {
      print('🚀 User request: START server');
      
      // 确保服务器已安装
      if (server.status != models.McpServerStatus.installed) {
        print('   📦 Installing server first...');
        final installResult = await _installService.installServer(server);
        if (!installResult.success) {
          throw Exception('Failed to install server: ${server.name} - ${installResult.errorMessage}');
        }
      } else {
        print('   ✅ Server already installed, proceeding to start');
      }
      
      // 启动进程
      // final processResult = await _processService.startServer(server);
      // if (!processResult.success) {
      //   throw Exception('Failed to start server: ${server.name} - ${processResult.errorMessage}');
      // }
      // print('   ✅ Server process started successfully (PID: ${processResult.processId})');
      
    } else if (status == models.McpServerStatus.stopped) {
      print('🛑 User request: STOP server');
      
      // 停止进程
      // final processResult = await _processService.stopServer(server);
      // if (!processResult.success) {
      //   print('⚠️ Warning: Failed to stop server gracefully: ${server.name} - ${processResult.errorMessage}');
      // }
      print('   ✅ Server process stopped');
      
    } else if (status == models.McpServerStatus.installed) {
      print('✅ Marking server as installed (package already installed by wizard)');
    }

    final updatedServer = server.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    await _repository.updateServer(updatedServer);
    print('✅ Server status updated: ${server.name} -> ${status.name}');
  }
} 