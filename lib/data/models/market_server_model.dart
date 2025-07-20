import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_server_model.freezed.dart';
part 'market_server_model.g.dart';

@freezed
class MarketServerModel with _$MarketServerModel {
  const factory MarketServerModel({
    @JsonKey(name: 'mcpId') required String mcpId,
    @JsonKey(name: 'githubUrl') required String githubUrl,
    @JsonKey(name: 'logoUrl') String? logoUrl,
    required String name,
    required String author,
    required String description,
    required String category,
    required List<String> tags,
    @JsonKey(name: 'installCmd') required String installCmd,
    @JsonKey(name: 'mcpConfig') String? mcpConfig,
    @JsonKey(name: 'isRecommended') @Default(false) bool isRecommended,
    @JsonKey(name: 'usedCount') @Default(0) int usedCount,
    @JsonKey(name: 'downloadCount') @Default(0) int downloadCount,
    @JsonKey(name: 'createdAt') required String createdAt,
    @JsonKey(name: 'updatedAt') required String updatedAt,
  }) = _MarketServerModel;

  factory MarketServerModel.fromJson(Map<String, dynamic> json) =>
      _$MarketServerModelFromJson(json);
}

@freezed
class MarketCategoryModel with _$MarketCategoryModel {
  const factory MarketCategoryModel({
    required int id,
    required String code,
    required String name,
    required String description,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _MarketCategoryModel;

  factory MarketCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$MarketCategoryModelFromJson(json);
}

@freezed
class MarketServerResponse with _$MarketServerResponse {
  const factory MarketServerResponse({
    required int code,
    required String message,
    required MarketServerData data,
  }) = _MarketServerResponse;

  factory MarketServerResponse.fromJson(Map<String, dynamic> json) =>
      _$MarketServerResponseFromJson(json);
}

@freezed
class MarketServerData with _$MarketServerData {
  const factory MarketServerData({
    required List<MarketServerModel> items,
    @Default(1) int page,
    @Default(20) int size,
    @Default(0) int total,
  }) = _MarketServerData;

  factory MarketServerData.fromJson(Map<String, dynamic> json) =>
      _$MarketServerDataFromJson(json);
}

@freezed
class MarketCategoryResponse with _$MarketCategoryResponse {
  const factory MarketCategoryResponse({
    required int code,
    required String message,
    required List<MarketCategoryModel> data,
  }) = _MarketCategoryResponse;

  factory MarketCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$MarketCategoryResponseFromJson(json);
} 