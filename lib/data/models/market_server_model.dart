import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_server_model.freezed.dart';
part 'market_server_model.g.dart';

/// MCP服务器市场项目模型
@freezed
class MCPMarketServer with _$MCPMarketServer {
  const factory MCPMarketServer({
    required String id,
    required String name,
    required String description,
    required String author,
    required String version,
    required List<String> tags,
    required String category,
    @Default(0) int downloadCount,
    @Default(0.0) double rating,
    @Default([]) List<String> screenshots,
    @Default('') String readme,
    required MCPServerInstallConfig installConfig,
    @Default([]) List<String> capabilities,
    @Default({}) Map<String, dynamic> metadata,
    required DateTime publishedAt,
    required DateTime updatedAt,
    @Default('') String iconUrl,
    @Default('') String homepage,
    @Default('') String repository,
    @Default([]) List<String> keywords,
    @Default('') String license,
    @Default(0) int reviewCount,
  }) = _MCPMarketServer;

  factory MCPMarketServer.fromJson(Map<String, dynamic> json) =>
      _$MCPMarketServerFromJson(json);
}

/// MCP服务器安装配置
@freezed
class MCPServerInstallConfig with _$MCPServerInstallConfig {
  const factory MCPServerInstallConfig({
    required String installMethod, // 'uvx' | 'npx' | 'git' | 'manual'
    required String packageName,
    @Default([]) List<String> installArgs,
    @Default({}) Map<String, String> envVars,
    @Default([]) List<String> dependencies,
    @Default({}) Map<String, dynamic> mcpConfig,
    @Default('') String repositoryUrl,
    @Default('') String branch,
    @Default('') String subPath,
    @Default([]) List<String> buildCommands,
  }) = _MCPServerInstallConfig;

  factory MCPServerInstallConfig.fromJson(Map<String, dynamic> json) =>
      _$MCPServerInstallConfigFromJson(json);
}

/// 服务器分类枚举
enum ServerCategory {
  @JsonValue('file-system')
  fileSystem,
  @JsonValue('search-engine')
  searchEngine,
  @JsonValue('database')
  database,
  @JsonValue('ai-service')
  aiService,
  @JsonValue('productivity')
  productivity,
  @JsonValue('development')
  development,
  @JsonValue('integration')
  integration,
  @JsonValue('security')
  security,
  @JsonValue('other')
  other,
}

/// 安装方法枚举
enum InstallMethod {
  @JsonValue('uvx')
  uvx,
  @JsonValue('npx')
  npx,
  @JsonValue('git')
  git,
  @JsonValue('manual')
  manual,
}

/// 服务器评价模型
@freezed
class ServerReview with _$ServerReview {
  const factory ServerReview({
    required String id,
    required String serverId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    required DateTime createdAt,
    @Default(0) int helpfulCount,
  }) = _ServerReview;

  factory ServerReview.fromJson(Map<String, dynamic> json) =>
      _$ServerReviewFromJson(json);
}

/// 市场搜索结果
@freezed
class MarketSearchResult with _$MarketSearchResult {
  const factory MarketSearchResult({
    required List<MCPMarketServer> servers,
    required int totalCount,
    required int currentPage,
    required int totalPages,
    @Default([]) List<String> suggestions,
  }) = _MarketSearchResult;

  factory MarketSearchResult.fromJson(Map<String, dynamic> json) =>
      _$MarketSearchResultFromJson(json);
}

/// 搜索过滤器
@freezed
class MarketFilter with _$MarketFilter {
  const factory MarketFilter({
    @Default('') String query,
    @Default([]) List<String> categories,
    @Default([]) List<String> tags,
    @Default('') String author,
    @Default(SortBy.popularity) SortBy sortBy,
    @Default(SortOrder.descending) SortOrder sortOrder,
    @Default(0.0) double minRating,
    @Default([]) List<String> installMethods,
  }) = _MarketFilter;

  factory MarketFilter.fromJson(Map<String, dynamic> json) =>
      _$MarketFilterFromJson(json);
}

/// 排序方式
enum SortBy {
  @JsonValue('popularity')
  popularity,
  @JsonValue('rating')
  rating,
  @JsonValue('updated')
  updated,
  @JsonValue('name')
  name,
  @JsonValue('downloads')
  downloads,
}

/// 排序顺序
enum SortOrder {
  @JsonValue('asc')
  ascending,
  @JsonValue('desc')
  descending,
} 