import 'dart:async';
import 'dart:convert';
import 'package:mcp_dart/mcp_dart.dart';

import '../../business/services/mcp_hub_service.dart';
import '../../core/models/mcp_server.dart';

/// MCP工具聚合器
/// 负责聚合和管理所有子服务器的工具
class McpToolsAggregator {
  static McpToolsAggregator? _instance;
  static McpToolsAggregator get instance => _instance ??= McpToolsAggregator._();
  
  McpToolsAggregator._();

  final McpHubService _hubService = McpHubService.instance;
  final Map<String, List<Tool>> _serverTools = {};
  final Map<String, List<Resource>> _serverResources = {};
  final StreamController<ToolEvent> _toolEvents = StreamController<ToolEvent>.broadcast();

  /// 工具事件流
  Stream<ToolEvent> get toolEvents => _toolEvents.stream;

  /// 获取所有可用工具
  List<AggregatedTool> getAllTools() {
    final allTools = <AggregatedTool>[];
    
    // 添加Hub自身的工具
    final hubTools = _getHubTools();
    allTools.addAll(hubTools);
    
    // 添加子服务器的工具
    for (final entry in _serverTools.entries) {
      final serverId = entry.key;
      final tools = entry.value;
      final server = _hubService.childServers.firstWhere(
        (s) => s.id == serverId,
        orElse: () => throw Exception('Server not found: $serverId'),
      );
      
      for (final tool in tools) {
        allTools.add(AggregatedTool(
          tool: tool,
          serverId: serverId,
          serverName: server.name,
          source: ToolSource.childServer,
        ));
      }
    }
    
    return allTools;
  }

  /// 获取指定服务器的工具
  List<AggregatedTool> getToolsByServer(String serverId) {
    if (serverId == 'hub') {
      return _getHubTools();
    }
    
    final tools = _serverTools[serverId] ?? [];
    final server = _hubService.childServers.firstWhere(
      (s) => s.id == serverId,
      orElse: () => throw Exception('Server not found: $serverId'),
    );
    
    return tools.map((tool) => AggregatedTool(
      tool: tool,
      serverId: serverId,
      serverName: server.name,
      source: ToolSource.childServer,
    )).toList();
  }

  /// 根据工具名称查找工具
  AggregatedTool? findTool(String toolName, {String? preferredServerId}) {
    final allTools = getAllTools();
    
    // 如果指定了首选服务器，优先从该服务器查找
    if (preferredServerId != null) {
      final serverTools = allTools.where((t) => t.serverId == preferredServerId);
      final tool = serverTools.firstWhere(
        (t) => t.tool.name == toolName,
        orElse: () => throw Exception('Tool not found'),
      );
      if (tool != null) return tool;
    }
    
    // 从所有工具中查找
    try {
      return allTools.firstWhere((t) => t.tool.name == toolName);
    } catch (e) {
      return null;
    }
  }

  /// 调用工具
  Future<CallToolResult> callTool(String toolName, Map<String, dynamic> args, {String? serverId}) async {
    final tool = findTool(toolName, preferredServerId: serverId);
    if (tool == null) {
      throw Exception('Tool not found: $toolName');
    }

    _emitToolEvent(ToolEventType.toolCalled, {
      'tool_name': toolName,
      'server_id': tool.serverId,
      'args': args,
    });

    try {
      CallToolResult result;
      
      if (tool.source == ToolSource.hub) {
        // 调用Hub自身的工具
        result = await _callHubTool(toolName, args);
      } else {
                 // 调用子服务器的工具
         result = await _callChildTool(tool.serverId, toolName, args);
      }

      _emitToolEvent(ToolEventType.toolCompleted, {
        'tool_name': toolName,
        'server_id': tool.serverId,
        'success': true,
      });

      return result;
    } catch (e) {
      _emitToolEvent(ToolEventType.toolFailed, {
        'tool_name': toolName,
        'server_id': tool.serverId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 更新服务器工具列表
  void updateServerTools(String serverId, List<Tool> tools, List<Resource> resources) {
    _serverTools[serverId] = tools;
    _serverResources[serverId] = resources;
    
    _emitToolEvent(ToolEventType.toolsUpdated, {
      'server_id': serverId,
      'tools_count': tools.length,
      'resources_count': resources.length,
    });
  }

  /// 移除服务器工具
  void removeServerTools(String serverId) {
    _serverTools.remove(serverId);
    _serverResources.remove(serverId);
    
    _emitToolEvent(ToolEventType.toolsRemoved, {
      'server_id': serverId,
    });
  }

  /// 获取工具统计信息
  ToolStatistics getStatistics() {
    final hubToolsCount = _getHubTools().length;
    final childToolsCount = _serverTools.values.fold(0, (sum, tools) => sum + tools.length);
    final resourcesCount = _serverResources.values.fold(0, (sum, resources) => sum + resources.length);
    
    return ToolStatistics(
      totalTools: hubToolsCount + childToolsCount,
      hubTools: hubToolsCount,
      childServerTools: childToolsCount,
      totalResources: resourcesCount,
      connectedServers: _serverTools.length,
    );
  }

  /// 获取Hub自身的工具
  List<AggregatedTool> _getHubTools() {
    final hubToolDefinitions = [
      ToolDefinition('ping', 'Test connectivity to MCP Hub'),
      ToolDefinition('get_status', 'Get comprehensive MCP Hub server status'),
      ToolDefinition('calculate', 'Perform basic arithmetic operations'),
      ToolDefinition('list_servers', 'List all registered child MCP servers'),
      ToolDefinition('connect_server', 'Connect to a child MCP server'),
      ToolDefinition('disconnect_server', 'Disconnect from a child MCP server'),
      ToolDefinition('get_server_info', 'Get detailed information about a specific child server'),
      ToolDefinition('list_all_tools', 'List all available tools from all connected servers'),
      ToolDefinition('call_child_tool', 'Call a tool on a connected child server'),
    ];
    
    return hubToolDefinitions.map((def) => AggregatedTool(
             tool: Tool(
         name: def.name,
         description: def.description,
         inputSchema: ToolInputSchema(
           properties: {},
         ),
       ),
      serverId: 'hub',
      serverName: 'MCP Hub',
      source: ToolSource.hub,
    )).toList();
  }

  /// 调用Hub工具
  Future<CallToolResult> _callHubTool(String toolName, Map<String, dynamic> args) async {
    // 这里应该调用MCP Hub服务器的实际工具实现
    // 为了简化，这里返回一个模拟结果
    return CallToolResult(
      content: [
        TextContent(text: 'Hub tool $toolName executed with args: ${jsonEncode(args)}'),
      ],
    );
  }

  /// 调用子服务器工具
  Future<CallToolResult> _callChildTool(String serverId, String toolName, Map<String, dynamic> args) async {
    // 暂时返回一个简单的结果，实际实现需要通过MCP Hub服务器调用
    return CallToolResult(
      content: [
        TextContent(text: 'Child tool $toolName called on server $serverId with args: ${jsonEncode(args)}'),
      ],
    );
  }

  /// 发送工具事件
  void _emitToolEvent(ToolEventType type, Map<String, dynamic> data) {
    _toolEvents.add(ToolEvent(
      type: type,
      timestamp: DateTime.now(),
      data: data,
    ));
  }

  /// 清理资源
  void dispose() {
    _toolEvents.close();
  }
}

/// 聚合工具信息
class AggregatedTool {
  final Tool tool;
  final String serverId;
  final String serverName;
  final ToolSource source;

  const AggregatedTool({
    required this.tool,
    required this.serverId,
    required this.serverName,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': tool.name,
      'description': tool.description,
      'server_id': serverId,
      'server_name': serverName,
      'source': source.name,
    };
  }
}

/// 工具来源
enum ToolSource {
  hub,
  childServer,
}

/// 工具定义
class ToolDefinition {
  final String name;
  final String description;

  const ToolDefinition(this.name, this.description);
}

/// 工具统计信息
class ToolStatistics {
  final int totalTools;
  final int hubTools;
  final int childServerTools;
  final int totalResources;
  final int connectedServers;

  const ToolStatistics({
    required this.totalTools,
    required this.hubTools,
    required this.childServerTools,
    required this.totalResources,
    required this.connectedServers,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_tools': totalTools,
      'hub_tools': hubTools,
      'child_server_tools': childServerTools,
      'total_resources': totalResources,
      'connected_servers': connectedServers,
    };
  }
}

/// 工具事件
class ToolEvent {
  final ToolEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const ToolEvent({
    required this.type,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }
}

/// 工具事件类型
enum ToolEventType {
  toolCalled,
  toolCompleted,
  toolFailed,
  toolsUpdated,
  toolsRemoved,
} 