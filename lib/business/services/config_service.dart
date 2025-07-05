import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../core/constants/path_constants.dart';
import '../../core/models/mcp_server.dart';
import '../../infrastructure/database/database_service.dart';

/// 配置服务类
class ConfigService {
  static ConfigService? _instance;
  static ConfigService get instance => _instance ??= ConfigService._();
  
  ConfigService._();

  final DatabaseService _databaseService = DatabaseService.instance;
  Map<String, dynamic>? _config;

  /// 获取配置文件路径（使用用户主目录）
  Future<String> get configPath async {
    final configDir = Directory(PathConstants.getUserConfigPath());
    
    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }

    return path.join(configDir.path, 'config.json');
  }

  /// 加载配置
  Future<Map<String, dynamic>> loadConfig() async {
    if (_config != null) return _config!;

    try {
      final configFile = File(await configPath);
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        _config = jsonDecode(content);
      } else {
        _config = _getDefaultConfig();
        await saveConfig();
      }
    } catch (e) {
      print('⚠️ Error loading config: $e');
      _config = _getDefaultConfig();
    }

    return _config!;
  }

  /// 保存配置
  Future<void> saveConfig() async {
    if (_config == null) return;

    try {
      final configFile = File(await configPath);
      await configFile.writeAsString(jsonEncode(_config));
      print('✅ Configuration saved');
    } catch (e) {
      print('❌ Error saving config: $e');
    }
  }

  /// 获取配置值
  Future<T?> getValue<T>(String key, [T? defaultValue]) async {
    final config = await loadConfig();
    return _getNestedValue(config, key) ?? defaultValue;
  }

  /// 设置配置值
  Future<void> setValue(String key, dynamic value) async {
    await loadConfig();
    _setNestedValue(_config!, key, value);
    await saveConfig();
  }

  /// 获取MCP Hub服务器配置
  Future<Map<String, dynamic>> getHubConfig() async {
    final config = await loadConfig();
    return config['hub'] ?? {};
  }

  /// 设置MCP Hub服务器配置
  Future<void> setHubConfig(Map<String, dynamic> hubConfig) async {
    await setValue('hub', hubConfig);
  }

  /// 获取服务器配置列表
  Future<List<Map<String, dynamic>>> getServerConfigs() async {
    final config = await loadConfig();
    return List<Map<String, dynamic>>.from(config['servers'] ?? []);
  }

  /// 添加服务器配置
  Future<void> addServerConfig(Map<String, dynamic> serverConfig) async {
    final configs = await getServerConfigs();
    configs.add(serverConfig);
    await setValue('servers', configs);
  }

  /// 更新服务器配置
  Future<void> updateServerConfig(String serverId, Map<String, dynamic> serverConfig) async {
    final configs = await getServerConfigs();
    final index = configs.indexWhere((config) => config['id'] == serverId);
    if (index != -1) {
      configs[index] = serverConfig;
      await setValue('servers', configs);
    }
  }

  /// 删除服务器配置
  Future<void> removeServerConfig(String serverId) async {
    final configs = await getServerConfigs();
    configs.removeWhere((config) => config['id'] == serverId);
    await setValue('servers', configs);
  }

  /// 导入配置
  Future<void> importConfig(Map<String, dynamic> importedConfig) async {
    try {
      // 验证配置格式
      _validateConfig(importedConfig);
      
      // 合并配置
      await loadConfig();
      
      // 导入Hub配置
      if (importedConfig.containsKey('hub')) {
        await setHubConfig(importedConfig['hub']);
      }
      
      // 导入服务器配置
      if (importedConfig.containsKey('servers')) {
        final servers = List<Map<String, dynamic>>.from(importedConfig['servers']);
        for (final serverConfig in servers) {
          await addServerConfig(serverConfig);
        }
      }
      
      print('✅ Configuration imported successfully');
    } catch (e) {
      print('❌ Error importing config: $e');
      rethrow;
    }
  }

  /// 导出配置
  Future<Map<String, dynamic>> exportConfig() async {
    final config = await loadConfig();
    
    return {
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'hub': config['hub'] ?? {},
      'servers': config['servers'] ?? [],
      'settings': config['settings'] ?? {},
    };
  }

  /// 重置配置
  Future<void> resetConfig() async {
    _config = _getDefaultConfig();
    await saveConfig();
    print('✅ Configuration reset to defaults');
  }

  /// 获取默认配置
  Map<String, dynamic> _getDefaultConfig() {
    return {
      'version': '1.0.0',
      'hub': {
        'port': 3000,
        'auto_start': true,
        'max_connections': 100,
        'timeout_seconds': 30,
        'enable_cors': true,
        'log_level': 'info',
        'server_mode': 'sse', // 'sse' 或 'streamable'
        'streamable_port': 3001, // streamable模式的端口
      },
      'servers': <Map<String, dynamic>>[],
      'settings': {
        'auto_cleanup_days': 30,
        'max_log_entries': 10000,
        'enable_notifications': true,
        'theme': 'system',
        'language': 'zh-CN',
      },
      'download': {
        'use_china_mirrors': false,
        'python_mirror_url': 'https://pypi.org/simple',
        'python_mirror_url_china': 'https://pypi.tuna.tsinghua.edu.cn/simple',
        'npm_mirror_url': 'https://registry.npmjs.org/',
        'npm_mirror_url_china': 'https://registry.npmmirror.com/',
        'timeout_seconds': 120,
        'concurrent_downloads': 4,
      },
      'security': {
        'enable_auth': false,
        'allowed_origins': ['*'],
        'rate_limit': {
          'enabled': false,
          'requests_per_minute': 100,
        },
      },
    };
  }

  /// 验证配置格式
  void _validateConfig(Map<String, dynamic> config) {
    // 基本验证
    if (!config.containsKey('version')) {
      throw Exception('Configuration missing version field');
    }

    // 验证Hub配置
    if (config.containsKey('hub')) {
      final hubConfig = config['hub'];
      if (hubConfig is! Map<String, dynamic>) {
        throw Exception('Invalid hub configuration format');
      }
    }

    // 验证服务器配置
    if (config.containsKey('servers')) {
      final servers = config['servers'];
      if (servers is! List) {
        throw Exception('Invalid servers configuration format');
      }
      
      for (final server in servers) {
        if (server is! Map<String, dynamic>) {
          throw Exception('Invalid server configuration format');
        }
        
        if (!server.containsKey('id') || !server.containsKey('name')) {
          throw Exception('Server configuration missing required fields');
        }
      }
    }
  }

  /// 获取嵌套值
  dynamic _getNestedValue(Map<String, dynamic> map, String key) {
    final keys = key.split('.');
    dynamic current = map;
    
    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null;
      }
    }
    
    return current;
  }

  /// 设置嵌套值
  void _setNestedValue(Map<String, dynamic> map, String key, dynamic value) {
    final keys = key.split('.');
    Map<String, dynamic> current = map;
    
    for (int i = 0; i < keys.length - 1; i++) {
      final k = keys[i];
      if (!current.containsKey(k) || current[k] is! Map<String, dynamic>) {
        current[k] = <String, dynamic>{};
      }
      current = current[k];
    }
    
    current[keys.last] = value;
  }

  /// 同步服务器配置到数据库
  Future<void> syncServersToDatabase() async {
    try {
      final serverConfigs = await getServerConfigs();
      
      for (final config in serverConfigs) {
        final server = McpServer(
          id: config['id'],
          name: config['name'],
          description: config['description'],
          status: McpServerStatus.values.firstWhere(
            (s) => s.name == (config['status'] ?? 'notInstalled'),
            orElse: () => McpServerStatus.notInstalled,
          ),
          connectionType: McpConnectionType.values.firstWhere(
            (t) => t.name == (config['connection_type'] ?? 'stdio'),
            orElse: () => McpConnectionType.stdio,
          ),
          installType: McpInstallType.values.firstWhere(
            (t) => t.name == (config['install_type'] ?? 'npx'),
            orElse: () => McpInstallType.npx,
          ),
          command: config['command'] ?? '',
          args: List<String>.from(config['args'] ?? []),
          env: Map<String, String>.from(config['env'] ?? {}),
          workingDirectory: config['working_directory'],
          installSource: config['install_source'],
          version: config['version'],
          config: Map<String, dynamic>.from(config['config'] ?? {}),
          autoStart: config['auto_start'] ?? false,
          logLevel: config['log_level'] ?? 'info',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 检查服务器是否已存在
        final existingServer = await _databaseService.database.then((db) => 
          db.query('mcp_servers', where: 'id = ?', whereArgs: [server.id])
        );

        if (existingServer.isEmpty) {
          // 插入新服务器
          await _databaseService.database.then((db) => 
            db.insert('mcp_servers', _serverToMap(server))
          );
        } else {
          // 更新现有服务器
          await _databaseService.database.then((db) => 
            db.update(
              'mcp_servers',
              _serverToMap(server),
              where: 'id = ?',
              whereArgs: [server.id],
            )
          );
        }
      }
      
      print('✅ Server configurations synced to database');
    } catch (e) {
      print('❌ Error syncing servers to database: $e');
    }
  }

  // 下载设置相关的便捷方法
  
  /// 是否使用中国镜像源 (从JSON文件，临时回退)
  Future<bool> getUseChinaMirrors() async {
    try {
      final result = await getValue('download.use_china_mirrors', false) ?? false;
      print('🔧 ConfigService.getUseChinaMirrors: $result');
      return result;
    } catch (e) {
      print('❌ Error getting china mirrors setting: $e');
      return false;
    }
  }
  
  /// 设置是否使用中国镜像源 (保存到JSON文件，临时回退)
  Future<void> setUseChinaMirrors(bool enabled) async {
    try {
      await setValue('download.use_china_mirrors', enabled);
      print('✅ China mirrors setting saved: $enabled');
    } catch (e) {
      print('❌ Error saving china mirrors setting: $e');
      rethrow;
    }
  }
  
  /// 获取Python镜像源URL (统一从JSON文件读取)
  Future<String> getPythonMirrorUrl() async {
    final useChinaMirrors = await getUseChinaMirrors();
    if (useChinaMirrors) {
      final url = await getValue('download.python_mirror_url_china', 'https://pypi.tuna.tsinghua.edu.cn/simple') ?? 'https://pypi.tuna.tsinghua.edu.cn/simple';
      print('🔧 ConfigService.getPythonMirrorUrl: returning $url (China mirror)');
      return url;
    } else {
      final url = await getValue('download.python_mirror_url', 'https://pypi.org/simple') ?? 'https://pypi.org/simple';
      print('🔧 ConfigService.getPythonMirrorUrl: returning $url (Official mirror)');
      return url;
    }
  }
  
  /// 获取NPM镜像源URL (统一从JSON文件读取)
  Future<String> getNpmMirrorUrl() async {
    final useChinaMirrors = await getUseChinaMirrors();
    print('🔧 ConfigService.getNpmMirrorUrl: useChinaMirrors = $useChinaMirrors');
    
    String mirrorUrl;
    if (useChinaMirrors) {
      mirrorUrl = await getValue('download.npm_mirror_url_china', 'https://registry.npmmirror.com/') ?? 'https://registry.npmmirror.com/';
    } else {
      mirrorUrl = await getValue('download.npm_mirror_url', 'https://registry.npmjs.org/') ?? 'https://registry.npmjs.org/';
    }
    
    print('🔧 ConfigService.getNpmMirrorUrl: returning $mirrorUrl');
    return mirrorUrl;
  }
  
  /// 获取下载超时时间 (从数据库)
  Future<int> getDownloadTimeoutSeconds() async {
    final timeout = await _getConfigFromDatabase('download_timeout_seconds', '120');
    return int.tryParse(timeout) ?? 120;
  }
  
  /// 获取并发下载数 (从数据库)
  Future<int> getConcurrentDownloads() async {
    final concurrent = await _getConfigFromDatabase('download_concurrent_downloads', '4');
    return int.tryParse(concurrent) ?? 4;
  }

  /// 将服务器对象转换为数据库映射
  Map<String, dynamic> _serverToMap(McpServer server) {
    return {
      'id': server.id,
      'name': server.name,
      'description': server.description,
      'status': server.status.name,
      'connection_type': server.connectionType.name,
      'install_type': server.installType.name,
      'command': server.command,
      'args': jsonEncode(server.args),
      'env': jsonEncode(server.env),
      'working_directory': server.workingDirectory,
      'install_source': server.installSource,
      'version': server.version,
      'config': jsonEncode(server.config),
      'process_id': server.processId,
      'port': server.port,
      'created_at': server.createdAt.millisecondsSinceEpoch,
      'updated_at': server.updatedAt.millisecondsSinceEpoch,
      'last_started_at': server.lastStartedAt?.millisecondsSinceEpoch,
      'last_stopped_at': server.lastStoppedAt?.millisecondsSinceEpoch,
      'auto_start': server.autoStart ? 1 : 0,
      'error_message': server.errorMessage,
      'log_level': server.logLevel,
    };
  }

  /// 获取MCP服务器运行模式 (从数据库)
  Future<String> getMcpServerMode() async {
    return await _getConfigFromDatabase('hub_server_mode', 'sse');
  }

  /// 设置MCP服务器运行模式 (保存到数据库)
  Future<void> setMcpServerMode(String mode) async {
    await _setConfigToDatabase('hub_server_mode', mode, 'string', 'Hub服务器运行模式', 'hub');
    
    // 记录配置变更事件
    await _recordConfigChangeEvent('hub_server_mode', mode, 'MCP Hub服务器模式更改为: $mode');
  }

  /// 获取Streamable模式端口 (从数据库)
  Future<int> getStreamablePort() async {
    final port = await _getConfigFromDatabase('hub_streamable_port', '3001');
    return int.tryParse(port) ?? 3001;
  }

  /// 设置Streamable模式端口 (保存到数据库)
  Future<void> setStreamablePort(int port) async {
    await _setConfigToDatabase('hub_streamable_port', port.toString(), 'integer', 'Streamable模式端口', 'hub');
  }

  /// 获取主题模式 (从数据库)
  Future<String> getThemeMode() async {
    return await _getConfigFromDatabase('app_theme_mode', 'system');
  }

  /// 设置主题模式 (保存到数据库)
  Future<void> setThemeMode(String mode) async {
    await _setConfigToDatabase('app_theme_mode', mode, 'string', '应用主题模式', 'appearance');
    
    // 记录配置变更事件
    await _recordConfigChangeEvent('app_theme_mode', mode, '应用主题模式更改为: $mode');
  }

  /// 获取语言设置 (从数据库)
  Future<String> getLanguage() async {
    return await _getConfigFromDatabase('app_language', 'system');
  }

  /// 设置语言 (保存到数据库)
  Future<void> setLanguage(String language) async {
    await _setConfigToDatabase('app_language', language, 'string', '应用语言设置', 'appearance');
    
    // 记录配置变更事件
    await _recordConfigChangeEvent('app_language', language, '应用语言更改为: $language');
  }

  /// 从数据库获取配置
  Future<String> _getConfigFromDatabase(String key, String defaultValue) async {
    try {
      final db = await _databaseService.database;
      final results = await db.query(
        'app_config',
        where: 'key = ?',
        whereArgs: [key],
      );
      
      if (results.isNotEmpty) {
        final value = results.first['value'] as String;
        print('🔧 _getConfigFromDatabase: $key = $value (from database)');
        return value;
      }
      
      print('🔧 _getConfigFromDatabase: $key = $defaultValue (default, not found in database)');
      return defaultValue;
    } catch (e) {
      print('❌ Error getting config from database: $e');
      print('🔧 _getConfigFromDatabase: $key = $defaultValue (default, due to error)');
      return defaultValue;
    }
  }

  /// 保存配置到数据库
  Future<void> _setConfigToDatabase(String key, String value, String valueType, String description, String category) async {
    try {
      final db = await _databaseService.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // 检查配置是否已存在
      final existing = await db.query(
        'app_config',
        where: 'key = ?',
        whereArgs: [key],
      );
      
      if (existing.isNotEmpty) {
        // 更新现有配置
        await db.update(
          'app_config',
          {
            'value': value,
            'value_type': valueType,
            'description': description,
            'category': category,
            'updated_at': now,
          },
          where: 'key = ?',
          whereArgs: [key],
        );
      } else {
        // 插入新配置
        await db.insert('app_config', {
          'key': key,
          'value': value,
          'value_type': valueType,
          'description': description,
          'category': category,
          'created_at': now,
          'updated_at': now,
        });
      }
      
      print('✅ Configuration saved to database: $key = $value');
    } catch (e) {
      print('❌ Error saving config to database: $e');
      rethrow;
    }
  }

  /// 记录配置变更事件
  Future<void> _recordConfigChangeEvent(String configKey, String newValue, String message) async {
    try {
      final db = await _databaseService.database;
      await db.insert('system_events', {
        'id': '${DateTime.now().millisecondsSinceEpoch}_config_$configKey',
        'event_type': 'config_updated',
        'event_level': 'info',
        'message': message,
        'details': 'Configuration key: $configKey, New value: $newValue',
        'metadata': jsonEncode({
          'config_key': configKey,
          'new_value': newValue,
          'source': 'settings_page',
        }),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('⚠️ Could not record config change event: $e');
    }
  }

  /// 保存配置到文件
  Future<void> _saveConfig() async {
    if (_config == null) return;
    
    final configFilePath = await configPath;
    final configFile = File(configFilePath);
    
    // 确保目录存在
    await configFile.parent.create(recursive: true);
    
    // 写入配置文件
    await configFile.writeAsString(jsonEncode(_config));
  }
} 