import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/market_server_model.dart';

/// MCP市场服务类
class McpMarketService {
  static const String _baseUrl = 'http://localhost:8000';
  static McpMarketService? _instance;
  
  static McpMarketService get instance {
    _instance ??= McpMarketService._();
    return _instance!;
  }
  
  McpMarketService._();

  /// 获取MCP服务器列表
  Future<MarketServerResponse> getServers({
    String? category,
    int page = 1,
    int size = 12,
    String? sort = 'usedCount',
    String? order = 'desc',
    String? search,
    bool? isRecommended,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (sort != null) {
      queryParams['sort'] = sort;
    }
    if (order != null) {
      queryParams['order'] = order;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (isRecommended != null) {
      queryParams['is_recommended'] = isRecommended.toString();
    }

    final uri = Uri.parse('$_baseUrl/api/mcp-servers').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MarketServerResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load servers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 获取服务器类别列表
  Future<MarketCategoryResponse> getCategories() async {
    final uri = Uri.parse('$_baseUrl/api/categories');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MarketCategoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 创建MCP服务器（管理员功能）
  Future<bool> createServer(MarketServerModel server) async {
    final uri = Uri.parse('$_baseUrl/api/mcp-servers');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(server.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create server: $e');
    }
  }

  /// 增加使用计数
  Future<bool> incrementUsedCount(String mcpId) async {
    final uri = Uri.parse('$_baseUrl/api/mcp-servers/$mcpId/used');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false; // 静默失败，不影响用户体验
    }
  }

  /// 增加下载计数
  Future<bool> incrementDownloadCount(String mcpId) async {
    final uri = Uri.parse('$_baseUrl/api/mcp-servers/$mcpId/download');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false; // 静默失败，不影响用户体验
    }
  }
} 