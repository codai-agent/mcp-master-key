// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarketServerModelImpl _$$MarketServerModelImplFromJson(
  Map<String, dynamic> json,
) => _$MarketServerModelImpl(
  mcpId: json['mcpId'] as String,
  githubUrl: json['githubUrl'] as String,
  logoUrl: json['logoUrl'] as String?,
  name: json['name'] as String,
  author: json['author'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  installCmd: json['installCmd'] as String,
  mcpConfig: json['mcpConfig'] as String?,
  isRecommended: json['isRecommended'] as bool? ?? false,
  usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
  downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$$MarketServerModelImplToJson(
  _$MarketServerModelImpl instance,
) => <String, dynamic>{
  'mcpId': instance.mcpId,
  'githubUrl': instance.githubUrl,
  'logoUrl': instance.logoUrl,
  'name': instance.name,
  'author': instance.author,
  'description': instance.description,
  'category': instance.category,
  'tags': instance.tags,
  'installCmd': instance.installCmd,
  'mcpConfig': instance.mcpConfig,
  'isRecommended': instance.isRecommended,
  'usedCount': instance.usedCount,
  'downloadCount': instance.downloadCount,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_$MarketCategoryModelImpl _$$MarketCategoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$MarketCategoryModelImpl(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$$MarketCategoryModelImplToJson(
  _$MarketCategoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_$MarketServerResponseImpl _$$MarketServerResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MarketServerResponseImpl(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: MarketServerData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MarketServerResponseImplToJson(
  _$MarketServerResponseImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$MarketServerDataImpl _$$MarketServerDataImplFromJson(
  Map<String, dynamic> json,
) => _$MarketServerDataImpl(
  items: (json['items'] as List<dynamic>)
      .map((e) => MarketServerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num?)?.toInt() ?? 1,
  size: (json['size'] as num?)?.toInt() ?? 20,
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$MarketServerDataImplToJson(
  _$MarketServerDataImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'size': instance.size,
  'total': instance.total,
};

_$MarketCategoryResponseImpl _$$MarketCategoryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MarketCategoryResponseImpl(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => MarketCategoryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$MarketCategoryResponseImplToJson(
  _$MarketCategoryResponseImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};
