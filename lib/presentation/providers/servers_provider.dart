import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mcp_server.dart';
import '../../infrastructure/repositories/mcp_server_repository.dart';
import '../../business/services/mcp_server_service.dart';
import '../../business/services/config_service.dart';

// 服务器仓库Provider
final serverRepositoryProvider = Provider<McpServerRepository>((ref) {
  return McpServerRepository.instance;
});

// 服务器服务Provider (新增)
final serverServiceProvider = Provider<McpServerService>((ref) {
  return McpServerService.instance;
});

// 服务器列表Provider
final serversListProvider = FutureProvider<List<McpServer>>((ref) async {
  final repository = ref.read(serverRepositoryProvider);
  return await repository.getAllServers();
});

// 单个服务器Provider
final serverProvider = FutureProvider.family<McpServer?, String>((ref, serverId) async {
  final repository = ref.read(serverRepositoryProvider);
  return await repository.getServerById(serverId);
});

// 服务器状态Provider
final serverStatusProvider = StreamProvider.family<String, String>((ref, serverId) {
  // TODO: 实现服务器状态监听
  return Stream.periodic(const Duration(seconds: 1), (count) => 'running');
});

// 服务器操作Provider
final serverActionsProvider = Provider<ServerActions>((ref) {
  final serverService = ref.read(serverServiceProvider);
  final repository = ref.read(serverRepositoryProvider);
  return ServerActions(serverService, repository);
});

// 添加ConfigService的provider
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService.instance;
});

// 添加配置状态的provider
final configProvider = StateNotifierProvider<ConfigNotifier, Map<String, dynamic>>((ref) {
  final configService = ref.watch(configServiceProvider);
  return ConfigNotifier(configService);
});

class ConfigNotifier extends StateNotifier<Map<String, dynamic>> {
  final ConfigService _configService;
  
  ConfigNotifier(this._configService) : super({}) {
    _loadConfig();
  }
  
  Future<void> _loadConfig() async {
    final config = await _configService.loadConfig();
    state = config;
  }
  
  Future<void> updateSetting(String key, dynamic value) async {
    await _configService.setValue(key, value);
    final config = await _configService.loadConfig();
    state = config;
  }
  
  Future<void> setUseChinaMirrors(bool enabled) async {
    await _configService.setUseChinaMirrors(enabled);
    final config = await _configService.loadConfig();
    state = config;
  }
  
  Future<bool> get useChinaMirrors => _configService.getUseChinaMirrors();
  Future<String> get pythonMirrorUrl => _configService.getPythonMirrorUrl();
  Future<String> get npmMirrorUrl => _configService.getNpmMirrorUrl();
  Future<int> get downloadTimeoutSeconds => _configService.getDownloadTimeoutSeconds();
  Future<int> get concurrentDownloads => _configService.getConcurrentDownloads();
}

class ServerActions {
  final McpServerService _serverService;
  final McpServerRepository _repository;

  ServerActions(this._serverService, this._repository);

  /// 启动服务器 (使用统一架构)
  Future<void> startServer(String serverId) async {
    print('🚀 用户请求启动服务器: $serverId');
    
    try {
      // 使用新的统一架构：只更新状态，Hub负责实际启动
      final success = await _serverService.startServerByUser(serverId);
      
      if (success) {
        print('✅ 服务器启动请求成功: $serverId');
      } else {
        throw Exception('启动服务器请求失败: $serverId');
      }
    } catch (e) {
      print('❌ 启动服务器失败: $e');
      rethrow;
    }
  }

  /// 停止服务器 (使用统一架构)
  Future<void> stopServer(String serverId) async {
    print('🛑 用户请求停止服务器: $serverId');
    
    try {
      // 使用新的统一架构：只更新状态，Hub负责实际停止
      final success = await _serverService.stopServerByUser(serverId);
      
      if (success) {
        print('✅ 服务器停止请求成功: $serverId');
      } else {
        throw Exception('停止服务器请求失败: $serverId');
      }
    } catch (e) {
      print('❌ 停止服务器失败: $e');
      rethrow;
    }
  }

  /// 重启服务器 (使用统一架构)
  Future<void> restartServer(String serverId) async {
    print('🔄 用户请求重启服务器: $serverId');
    
    try {
      // 先停止，再启动
      await stopServer(serverId);
      // 等待一小段时间确保停止完成
      await Future.delayed(const Duration(milliseconds: 1000));
      await startServer(serverId);
      
      print('✅ 服务器重启请求成功: $serverId');
    } catch (e) {
      print('❌ 重启服务器失败: $e');
      rethrow;
    }
  }

  /// 删除服务器
  Future<void> deleteServer(String serverId) async {
    try {
      // 如果服务器正在运行，先停止它
      final server = await _repository.getServerById(serverId);
      if (server != null && server.status == McpServerStatus.running) {
        await stopServer(serverId);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // 删除服务器
      await _repository.deleteServer(serverId);
    } catch (e) {
      print('❌ 删除服务器失败: $e');
      rethrow;
    }
  }

  /// 更新服务器
  Future<void> updateServer(McpServer server) async {
    try {
      final updatedServer = server.copyWith(updatedAt: DateTime.now());
      await _repository.updateServer(updatedServer);
    } catch (e) {
      print('❌ 更新服务器失败: $e');
      rethrow;
    }
  }
} 