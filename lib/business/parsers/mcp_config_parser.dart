import 'dart:convert';
import 'dart:io';

import '../../core/models/mcp_server.dart';

/// MCP配置解析结果
class McpConfigParseResult {
  final bool success;
  final String? error;
  final List<McpServerConfig> servers;
  final Map<String, dynamic>? rawConfig;

  McpConfigParseResult({
    required this.success,
    this.error,
    this.servers = const [],
    this.rawConfig,
  });
}

/// MCP服务器配置
class McpServerConfig {
  final String name;
  final String? description;
  final McpInstallType installType;
  final McpInstallStrategy installStrategy;
  final String command;
  final List<String> args;
  final Map<String, String> env;
  final String? workingDirectory;
  final String? installSource;
  final bool needsUserInput;
  final String? userInputReason;
  final McpConnectionType connectionType;

  McpServerConfig({
    required this.name,
    this.description,
    required this.installType,
    required this.installStrategy,
    required this.command,
    this.args = const [],
    this.env = const {},
    this.workingDirectory,
    this.installSource,
    this.needsUserInput = false,
    this.userInputReason,
    this.connectionType = McpConnectionType.stdio, // 默认为stdio
  });
}

/// MCP安装策略
enum McpInstallStrategy {
  /// 自包含命令，无需额外安装
  selfContained,
  /// 需要预安装，用户需要指定安装源
  requiresInstallation,
  /// 本地路径，需要路径转换
  localPath,
  /// 未知命令，需要用户手动配置
  unknown,
}

/// MCP配置解析器
class McpConfigParser {
  static McpConfigParser? _instance;

  McpConfigParser._internal();

  /// 获取单例实例
  static McpConfigParser get instance {
    _instance ??= McpConfigParser._internal();
    return _instance!;
  }

  /// 解析MCP配置
  McpConfigParseResult parseConfig(String configText) {
    try {
      // 尝试解析JSON
      final jsonConfig = jsonDecode(configText);
      
      // 检查是否包含mcpServers配置
      if (!jsonConfig.containsKey('mcpServers')) {
        return McpConfigParseResult(
          success: false,
          error: '配置中未找到 mcpServers 字段',
        );
      }

      final mcpServers = jsonConfig['mcpServers'] as Map<String, dynamic>;
      final servers = <McpServerConfig>[];

      // 解析每个服务器配置
      for (final entry in mcpServers.entries) {
        final serverName = entry.key;
        final serverConfig = entry.value as Map<String, dynamic>;

        try {
          final parsedServer = _parseServerConfig(serverName, serverConfig);
          servers.add(parsedServer);
        } catch (e) {
          print('Warning: Failed to parse server $serverName: $e');
          // 继续解析其他服务器
        }
      }

      return McpConfigParseResult(
        success: true,
        servers: servers,
        rawConfig: jsonConfig,
      );

    } catch (e) {
      return McpConfigParseResult(
        success: false,
        error: '配置解析失败: $e',
      );
    }
  }

  /// 解析连接类型，兼容 type 和 transportType 字段
  McpConnectionType parseConnectionType(Map<String, dynamic> config) {
    // 优先检查 type 字段
    String? typeValue = config['type'] as String?;
    
    // 如果没有 type 字段，检查 transportType 字段
    if (typeValue == null) {
      typeValue = config['transportType'] as String?;
    }
    
    // 如果都没有，默认为 stdio
    if (typeValue == null) {
      return McpConnectionType.stdio;
    }
    
    // 解析类型值
    switch (typeValue.toLowerCase()) {
      case 'sse':
        return McpConnectionType.sse;
      case 'stdio':
        return McpConnectionType.stdio;
      default:
        // 如果是未知类型，默认为 stdio 并打印警告
        print('Warning: Unknown connection type "$typeValue", defaulting to stdio');
        return McpConnectionType.stdio;
    }
  }

  /// 解析单个服务器配置
  McpServerConfig _parseServerConfig(String name, Map<String, dynamic> config) {
    final command = config['command'] as String? ?? '';
    final args = (config['args'] as List<dynamic>?)?.cast<String>() ?? [];
    final env = (config['env'] as Map<String, dynamic>?)?.cast<String, String>() ?? {};
    final workingDirectory = config['cwd'] as String?;

    // 解析连接类型，兼容 type 和 transportType 字段
    final connectionType = parseConnectionType(config);

    // 分析安装策略
    final analysis = _analyzeInstallStrategy(command, args);

    return McpServerConfig(
      name: name,
      description: _generateDescription(name, command, args),
      installType: analysis.installType,
      installStrategy: analysis.strategy,
      command: command,
      args: args,
      env: env,
      workingDirectory: workingDirectory,
      installSource: analysis.installSource,
      needsUserInput: analysis.needsUserInput,
      userInputReason: analysis.userInputReason,
      connectionType: connectionType,
    );
  }

  /// 分析安装策略
  _InstallAnalysis _analyzeInstallStrategy(String command, List<String> args) {
    // 1. 检查自包含命令
    if (_isSelfContainedCommand(command, args)) {
      return _analyzeSelfContainedCommand(command, args);
    }

    // 2. 检查本地路径
    if (_isLocalPath(command)) {
      return _analyzeLocalPath(command);
    }

    // 3. 检查预安装命令
    if (_isPreInstalledCommand(command)) {
      return _analyzePreInstalledCommand(command, args);
    }

    // 4. 未知命令
    return _InstallAnalysis(
      installType: McpInstallType.preInstalled,
      strategy: McpInstallStrategy.unknown,
      needsUserInput: true,
      userInputReason: '未知命令类型，需要用户手动配置安装方式',
    );
  }

  /// 检查是否为自包含命令
  bool _isSelfContainedCommand(String command, List<String> args) {
    // npx -y 或 npx --yes
    if (command == 'npx' && args.isNotEmpty) {
      return args.contains('-y') || args.contains('--yes');
    }

    // uvx 命令
    if (command == 'uvx') {
      return true;
    }

    return false;
  }

  /// 分析自包含命令
  _InstallAnalysis _analyzeSelfContainedCommand(String command, List<String> args) {
    if (command == 'npx') {
      // 查找包名
      String? packageName;
      for (int i = 0; i < args.length; i++) {
        if (args[i] == '-y' || args[i] == '--yes') {
          if (i + 1 < args.length) {
            packageName = args[i + 1];
            break;
          }
        }
      }

      return _InstallAnalysis(
        installType: McpInstallType.npx,
        strategy: McpInstallStrategy.selfContained,
        installSource: packageName,
      );
    }

    if (command == 'uvx') {
      // 第一个参数通常是包名
      final packageName = args.isNotEmpty ? args.first : null;

      return _InstallAnalysis(
        installType: McpInstallType.uvx,
        strategy: McpInstallStrategy.selfContained,
        installSource: packageName,
      );
    }

    return _InstallAnalysis(
      installType: McpInstallType.preInstalled,
      strategy: McpInstallStrategy.unknown,
    );
  }

  /// 检查是否为本地路径
  bool _isLocalPath(String command) {
    // 检查是否包含路径分隔符
    return command.contains('/') || command.contains('\\') || 
           command.startsWith('./') || command.startsWith('../') ||
           command.startsWith('~');
  }

  /// 分析本地路径
  _InstallAnalysis _analyzeLocalPath(String command) {
    return _InstallAnalysis(
      installType: McpInstallType.localPath,
      strategy: McpInstallStrategy.localPath,
      needsUserInput: true,
      userInputReason: '本地路径需要用户确认或调整路径映射',
    );
  }

  /// 检查是否为预安装命令
  bool _isPreInstalledCommand(String command) {
    final preInstalledCommands = [
      'python', 'python3', 'python3.12',
      'node', 'nodejs',
      'npm', 'npx',
      'pip', 'pip3',
      'uv', 'uvx',
    ];

    return preInstalledCommands.contains(command);
  }

  /// 分析预安装命令
  _InstallAnalysis _analyzePreInstalledCommand(String command, List<String> args) {
    // 检查是否为简单的npx命令（不带-y）
    if (command == 'npx' && !args.contains('-y') && !args.contains('--yes')) {
      final packageName = args.isNotEmpty ? args.first : null;
      return _InstallAnalysis(
        installType: McpInstallType.npx,
        strategy: McpInstallStrategy.requiresInstallation,
        installSource: packageName,
        needsUserInput: true,
        userInputReason: '需要用户确认是否添加 -y 参数以启用自动安装',
      );
    }

    // Python脚本或模块
    if (command.startsWith('python')) {
      return _InstallAnalysis(
        installType: McpInstallType.uvx,
        strategy: McpInstallStrategy.requiresInstallation,
        needsUserInput: true,
        userInputReason: '需要用户指定Python包的安装源（pip包名或GitHub仓库）',
      );
    }

    // Node.js脚本
    if (command == 'node') {
      return _InstallAnalysis(
        installType: McpInstallType.npx,
        strategy: McpInstallStrategy.requiresInstallation,
        needsUserInput: true,
        userInputReason: '需要用户指定Node.js包的安装源（npm包名或GitHub仓库）',
      );
    }

    return _InstallAnalysis(
      installType: McpInstallType.preInstalled,
      strategy: McpInstallStrategy.requiresInstallation,
      needsUserInput: true,
      userInputReason: '预安装命令需要用户指定安装源',
    );
  }

  /// 生成服务器描述
  String _generateDescription(String name, String command, List<String> args) {
    if (command == 'npx') {
      final packageName = args.isNotEmpty ? args.last : 'unknown';
      return 'Node.js MCP服务器: $packageName';
    }

    if (command == 'uvx') {
      final packageName = args.isNotEmpty ? args.first : 'unknown';
      return 'Python MCP服务器: $packageName';
    }

    if (command.startsWith('python')) {
      return 'Python MCP服务器';
    }

    if (command == 'node') {
      return 'Node.js MCP服务器';
    }

    return 'MCP服务器: $name';
  }

  /// 验证配置格式
  bool isValidMcpConfig(String configText) {
    try {
      final jsonConfig = jsonDecode(configText);
      return jsonConfig.containsKey('mcpServers') && 
             jsonConfig['mcpServers'] is Map<String, dynamic>;
    } catch (e) {
      return false;
    }
  }

  /// 获取示例配置
  String getExampleConfig() {
    return '''
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"],
      "env": {}
    },
    "everything": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-everything"]
    },
    "weather": {
      "command": "uvx",
      "args": ["mcp-server-weather"],
      "env": {
        "API_KEY": "your-api-key"
      }
    },
    "custom-python": {
      "command": "python",
      "args": ["-m", "my_mcp_server"],
      "cwd": "/path/to/project"
    }
  }
}''';
  }
}

/// 安装分析结果
class _InstallAnalysis {
  final McpInstallType installType;
  final McpInstallStrategy strategy;
  final String? installSource;
  final bool needsUserInput;
  final String? userInputReason;

  _InstallAnalysis({
    required this.installType,
    required this.strategy,
    this.installSource,
    this.needsUserInput = false,
    this.userInputReason,
  });
} 