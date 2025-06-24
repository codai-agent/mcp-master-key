// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MCPMarketServerImpl _$$MCPMarketServerImplFromJson(
  Map<String, dynamic> json,
) => _$MCPMarketServerImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  author: json['author'] as String,
  version: json['version'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  category: json['category'] as String,
  downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  screenshots:
      (json['screenshots'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  readme: json['readme'] as String? ?? '',
  installConfig: MCPServerInstallConfig.fromJson(
    json['installConfig'] as Map<String, dynamic>,
  ),
  capabilities:
      (json['capabilities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  iconUrl: json['iconUrl'] as String? ?? '',
  homepage: json['homepage'] as String? ?? '',
  repository: json['repository'] as String? ?? '',
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  license: json['license'] as String? ?? '',
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$MCPMarketServerImplToJson(
  _$MCPMarketServerImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'author': instance.author,
  'version': instance.version,
  'tags': instance.tags,
  'category': instance.category,
  'downloadCount': instance.downloadCount,
  'rating': instance.rating,
  'screenshots': instance.screenshots,
  'readme': instance.readme,
  'installConfig': instance.installConfig,
  'capabilities': instance.capabilities,
  'metadata': instance.metadata,
  'publishedAt': instance.publishedAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'iconUrl': instance.iconUrl,
  'homepage': instance.homepage,
  'repository': instance.repository,
  'keywords': instance.keywords,
  'license': instance.license,
  'reviewCount': instance.reviewCount,
};

_$MCPServerInstallConfigImpl _$$MCPServerInstallConfigImplFromJson(
  Map<String, dynamic> json,
) => _$MCPServerInstallConfigImpl(
  installMethod: json['installMethod'] as String,
  packageName: json['packageName'] as String,
  installArgs:
      (json['installArgs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  envVars:
      (json['envVars'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  dependencies:
      (json['dependencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  mcpConfig: json['mcpConfig'] as Map<String, dynamic>? ?? const {},
  repositoryUrl: json['repositoryUrl'] as String? ?? '',
  branch: json['branch'] as String? ?? '',
  subPath: json['subPath'] as String? ?? '',
  buildCommands:
      (json['buildCommands'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MCPServerInstallConfigImplToJson(
  _$MCPServerInstallConfigImpl instance,
) => <String, dynamic>{
  'installMethod': instance.installMethod,
  'packageName': instance.packageName,
  'installArgs': instance.installArgs,
  'envVars': instance.envVars,
  'dependencies': instance.dependencies,
  'mcpConfig': instance.mcpConfig,
  'repositoryUrl': instance.repositoryUrl,
  'branch': instance.branch,
  'subPath': instance.subPath,
  'buildCommands': instance.buildCommands,
};

_$ServerReviewImpl _$$ServerReviewImplFromJson(Map<String, dynamic> json) =>
    _$ServerReviewImpl(
      id: json['id'] as String,
      serverId: json['serverId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ServerReviewImplToJson(_$ServerReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serverId': instance.serverId,
      'userId': instance.userId,
      'userName': instance.userName,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'helpfulCount': instance.helpfulCount,
    };

_$MarketSearchResultImpl _$$MarketSearchResultImplFromJson(
  Map<String, dynamic> json,
) => _$MarketSearchResultImpl(
  servers: (json['servers'] as List<dynamic>)
      .map((e) => MCPMarketServer.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  suggestions:
      (json['suggestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MarketSearchResultImplToJson(
  _$MarketSearchResultImpl instance,
) => <String, dynamic>{
  'servers': instance.servers,
  'totalCount': instance.totalCount,
  'currentPage': instance.currentPage,
  'totalPages': instance.totalPages,
  'suggestions': instance.suggestions,
};

_$MarketFilterImpl _$$MarketFilterImplFromJson(Map<String, dynamic> json) =>
    _$MarketFilterImpl(
      query: json['query'] as String? ?? '',
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      author: json['author'] as String? ?? '',
      sortBy:
          $enumDecodeNullable(_$SortByEnumMap, json['sortBy']) ??
          SortBy.popularity,
      sortOrder:
          $enumDecodeNullable(_$SortOrderEnumMap, json['sortOrder']) ??
          SortOrder.descending,
      minRating: (json['minRating'] as num?)?.toDouble() ?? 0.0,
      installMethods:
          (json['installMethods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MarketFilterImplToJson(_$MarketFilterImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'categories': instance.categories,
      'tags': instance.tags,
      'author': instance.author,
      'sortBy': _$SortByEnumMap[instance.sortBy]!,
      'sortOrder': _$SortOrderEnumMap[instance.sortOrder]!,
      'minRating': instance.minRating,
      'installMethods': instance.installMethods,
    };

const _$SortByEnumMap = {
  SortBy.popularity: 'popularity',
  SortBy.rating: 'rating',
  SortBy.updated: 'updated',
  SortBy.name: 'name',
  SortBy.downloads: 'downloads',
};

const _$SortOrderEnumMap = {
  SortOrder.ascending: 'asc',
  SortOrder.descending: 'desc',
};
