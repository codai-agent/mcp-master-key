// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_server_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MarketServerModel _$MarketServerModelFromJson(Map<String, dynamic> json) {
  return _MarketServerModel.fromJson(json);
}

/// @nodoc
mixin _$MarketServerModel {
  @JsonKey(name: 'mcpId')
  String get mcpId => throw _privateConstructorUsedError;
  @JsonKey(name: 'githubUrl')
  String get githubUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'logoUrl')
  String? get logoUrl => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'installCmd')
  String get installCmd => throw _privateConstructorUsedError;
  @JsonKey(name: 'mcpConfig')
  String? get mcpConfig => throw _privateConstructorUsedError;
  @JsonKey(name: 'isRecommended')
  bool get isRecommended => throw _privateConstructorUsedError;
  @JsonKey(name: 'usedCount')
  int get usedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'downloadCount')
  int get downloadCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAt')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MarketServerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketServerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketServerModelCopyWith<MarketServerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketServerModelCopyWith<$Res> {
  factory $MarketServerModelCopyWith(
    MarketServerModel value,
    $Res Function(MarketServerModel) then,
  ) = _$MarketServerModelCopyWithImpl<$Res, MarketServerModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'mcpId') String mcpId,
    @JsonKey(name: 'githubUrl') String githubUrl,
    @JsonKey(name: 'logoUrl') String? logoUrl,
    String name,
    String author,
    String description,
    String category,
    List<String> tags,
    @JsonKey(name: 'installCmd') String installCmd,
    @JsonKey(name: 'mcpConfig') String? mcpConfig,
    @JsonKey(name: 'isRecommended') bool isRecommended,
    @JsonKey(name: 'usedCount') int usedCount,
    @JsonKey(name: 'downloadCount') int downloadCount,
    @JsonKey(name: 'createdAt') String createdAt,
    @JsonKey(name: 'updatedAt') String updatedAt,
  });
}

/// @nodoc
class _$MarketServerModelCopyWithImpl<$Res, $Val extends MarketServerModel>
    implements $MarketServerModelCopyWith<$Res> {
  _$MarketServerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketServerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mcpId = null,
    Object? githubUrl = null,
    Object? logoUrl = freezed,
    Object? name = null,
    Object? author = null,
    Object? description = null,
    Object? category = null,
    Object? tags = null,
    Object? installCmd = null,
    Object? mcpConfig = freezed,
    Object? isRecommended = null,
    Object? usedCount = null,
    Object? downloadCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            mcpId: null == mcpId
                ? _value.mcpId
                : mcpId // ignore: cast_nullable_to_non_nullable
                      as String,
            githubUrl: null == githubUrl
                ? _value.githubUrl
                : githubUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            logoUrl: freezed == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            installCmd: null == installCmd
                ? _value.installCmd
                : installCmd // ignore: cast_nullable_to_non_nullable
                      as String,
            mcpConfig: freezed == mcpConfig
                ? _value.mcpConfig
                : mcpConfig // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRecommended: null == isRecommended
                ? _value.isRecommended
                : isRecommended // ignore: cast_nullable_to_non_nullable
                      as bool,
            usedCount: null == usedCount
                ? _value.usedCount
                : usedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            downloadCount: null == downloadCount
                ? _value.downloadCount
                : downloadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarketServerModelImplCopyWith<$Res>
    implements $MarketServerModelCopyWith<$Res> {
  factory _$$MarketServerModelImplCopyWith(
    _$MarketServerModelImpl value,
    $Res Function(_$MarketServerModelImpl) then,
  ) = __$$MarketServerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'mcpId') String mcpId,
    @JsonKey(name: 'githubUrl') String githubUrl,
    @JsonKey(name: 'logoUrl') String? logoUrl,
    String name,
    String author,
    String description,
    String category,
    List<String> tags,
    @JsonKey(name: 'installCmd') String installCmd,
    @JsonKey(name: 'mcpConfig') String? mcpConfig,
    @JsonKey(name: 'isRecommended') bool isRecommended,
    @JsonKey(name: 'usedCount') int usedCount,
    @JsonKey(name: 'downloadCount') int downloadCount,
    @JsonKey(name: 'createdAt') String createdAt,
    @JsonKey(name: 'updatedAt') String updatedAt,
  });
}

/// @nodoc
class __$$MarketServerModelImplCopyWithImpl<$Res>
    extends _$MarketServerModelCopyWithImpl<$Res, _$MarketServerModelImpl>
    implements _$$MarketServerModelImplCopyWith<$Res> {
  __$$MarketServerModelImplCopyWithImpl(
    _$MarketServerModelImpl _value,
    $Res Function(_$MarketServerModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketServerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mcpId = null,
    Object? githubUrl = null,
    Object? logoUrl = freezed,
    Object? name = null,
    Object? author = null,
    Object? description = null,
    Object? category = null,
    Object? tags = null,
    Object? installCmd = null,
    Object? mcpConfig = freezed,
    Object? isRecommended = null,
    Object? usedCount = null,
    Object? downloadCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$MarketServerModelImpl(
        mcpId: null == mcpId
            ? _value.mcpId
            : mcpId // ignore: cast_nullable_to_non_nullable
                  as String,
        githubUrl: null == githubUrl
            ? _value.githubUrl
            : githubUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        logoUrl: freezed == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        installCmd: null == installCmd
            ? _value.installCmd
            : installCmd // ignore: cast_nullable_to_non_nullable
                  as String,
        mcpConfig: freezed == mcpConfig
            ? _value.mcpConfig
            : mcpConfig // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRecommended: null == isRecommended
            ? _value.isRecommended
            : isRecommended // ignore: cast_nullable_to_non_nullable
                  as bool,
        usedCount: null == usedCount
            ? _value.usedCount
            : usedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        downloadCount: null == downloadCount
            ? _value.downloadCount
            : downloadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketServerModelImpl implements _MarketServerModel {
  const _$MarketServerModelImpl({
    @JsonKey(name: 'mcpId') required this.mcpId,
    @JsonKey(name: 'githubUrl') required this.githubUrl,
    @JsonKey(name: 'logoUrl') this.logoUrl,
    required this.name,
    required this.author,
    required this.description,
    required this.category,
    required final List<String> tags,
    @JsonKey(name: 'installCmd') required this.installCmd,
    @JsonKey(name: 'mcpConfig') this.mcpConfig,
    @JsonKey(name: 'isRecommended') this.isRecommended = false,
    @JsonKey(name: 'usedCount') this.usedCount = 0,
    @JsonKey(name: 'downloadCount') this.downloadCount = 0,
    @JsonKey(name: 'createdAt') required this.createdAt,
    @JsonKey(name: 'updatedAt') required this.updatedAt,
  }) : _tags = tags;

  factory _$MarketServerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketServerModelImplFromJson(json);

  @override
  @JsonKey(name: 'mcpId')
  final String mcpId;
  @override
  @JsonKey(name: 'githubUrl')
  final String githubUrl;
  @override
  @JsonKey(name: 'logoUrl')
  final String? logoUrl;
  @override
  final String name;
  @override
  final String author;
  @override
  final String description;
  @override
  final String category;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'installCmd')
  final String installCmd;
  @override
  @JsonKey(name: 'mcpConfig')
  final String? mcpConfig;
  @override
  @JsonKey(name: 'isRecommended')
  final bool isRecommended;
  @override
  @JsonKey(name: 'usedCount')
  final int usedCount;
  @override
  @JsonKey(name: 'downloadCount')
  final int downloadCount;
  @override
  @JsonKey(name: 'createdAt')
  final String createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  @override
  String toString() {
    return 'MarketServerModel(mcpId: $mcpId, githubUrl: $githubUrl, logoUrl: $logoUrl, name: $name, author: $author, description: $description, category: $category, tags: $tags, installCmd: $installCmd, mcpConfig: $mcpConfig, isRecommended: $isRecommended, usedCount: $usedCount, downloadCount: $downloadCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketServerModelImpl &&
            (identical(other.mcpId, mcpId) || other.mcpId == mcpId) &&
            (identical(other.githubUrl, githubUrl) ||
                other.githubUrl == githubUrl) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.installCmd, installCmd) ||
                other.installCmd == installCmd) &&
            (identical(other.mcpConfig, mcpConfig) ||
                other.mcpConfig == mcpConfig) &&
            (identical(other.isRecommended, isRecommended) ||
                other.isRecommended == isRecommended) &&
            (identical(other.usedCount, usedCount) ||
                other.usedCount == usedCount) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    mcpId,
    githubUrl,
    logoUrl,
    name,
    author,
    description,
    category,
    const DeepCollectionEquality().hash(_tags),
    installCmd,
    mcpConfig,
    isRecommended,
    usedCount,
    downloadCount,
    createdAt,
    updatedAt,
  );

  /// Create a copy of MarketServerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketServerModelImplCopyWith<_$MarketServerModelImpl> get copyWith =>
      __$$MarketServerModelImplCopyWithImpl<_$MarketServerModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketServerModelImplToJson(this);
  }
}

abstract class _MarketServerModel implements MarketServerModel {
  const factory _MarketServerModel({
    @JsonKey(name: 'mcpId') required final String mcpId,
    @JsonKey(name: 'githubUrl') required final String githubUrl,
    @JsonKey(name: 'logoUrl') final String? logoUrl,
    required final String name,
    required final String author,
    required final String description,
    required final String category,
    required final List<String> tags,
    @JsonKey(name: 'installCmd') required final String installCmd,
    @JsonKey(name: 'mcpConfig') final String? mcpConfig,
    @JsonKey(name: 'isRecommended') final bool isRecommended,
    @JsonKey(name: 'usedCount') final int usedCount,
    @JsonKey(name: 'downloadCount') final int downloadCount,
    @JsonKey(name: 'createdAt') required final String createdAt,
    @JsonKey(name: 'updatedAt') required final String updatedAt,
  }) = _$MarketServerModelImpl;

  factory _MarketServerModel.fromJson(Map<String, dynamic> json) =
      _$MarketServerModelImpl.fromJson;

  @override
  @JsonKey(name: 'mcpId')
  String get mcpId;
  @override
  @JsonKey(name: 'githubUrl')
  String get githubUrl;
  @override
  @JsonKey(name: 'logoUrl')
  String? get logoUrl;
  @override
  String get name;
  @override
  String get author;
  @override
  String get description;
  @override
  String get category;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'installCmd')
  String get installCmd;
  @override
  @JsonKey(name: 'mcpConfig')
  String? get mcpConfig;
  @override
  @JsonKey(name: 'isRecommended')
  bool get isRecommended;
  @override
  @JsonKey(name: 'usedCount')
  int get usedCount;
  @override
  @JsonKey(name: 'downloadCount')
  int get downloadCount;
  @override
  @JsonKey(name: 'createdAt')
  String get createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  String get updatedAt;

  /// Create a copy of MarketServerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketServerModelImplCopyWith<_$MarketServerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketCategoryModel _$MarketCategoryModelFromJson(Map<String, dynamic> json) {
  return _MarketCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$MarketCategoryModel {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MarketCategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketCategoryModelCopyWith<MarketCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketCategoryModelCopyWith<$Res> {
  factory $MarketCategoryModelCopyWith(
    MarketCategoryModel value,
    $Res Function(MarketCategoryModel) then,
  ) = _$MarketCategoryModelCopyWithImpl<$Res, MarketCategoryModel>;
  @useResult
  $Res call({
    int id,
    String code,
    String name,
    String description,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String updatedAt,
  });
}

/// @nodoc
class _$MarketCategoryModelCopyWithImpl<$Res, $Val extends MarketCategoryModel>
    implements $MarketCategoryModelCopyWith<$Res> {
  _$MarketCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarketCategoryModelImplCopyWith<$Res>
    implements $MarketCategoryModelCopyWith<$Res> {
  factory _$$MarketCategoryModelImplCopyWith(
    _$MarketCategoryModelImpl value,
    $Res Function(_$MarketCategoryModelImpl) then,
  ) = __$$MarketCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String code,
    String name,
    String description,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String updatedAt,
  });
}

/// @nodoc
class __$$MarketCategoryModelImplCopyWithImpl<$Res>
    extends _$MarketCategoryModelCopyWithImpl<$Res, _$MarketCategoryModelImpl>
    implements _$$MarketCategoryModelImplCopyWith<$Res> {
  __$$MarketCategoryModelImplCopyWithImpl(
    _$MarketCategoryModelImpl _value,
    $Res Function(_$MarketCategoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$MarketCategoryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketCategoryModelImpl implements _MarketCategoryModel {
  const _$MarketCategoryModelImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$MarketCategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketCategoryModelImplFromJson(json);

  @override
  final int id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'MarketCategoryModel(id: $id, code: $code, name: $name, description: $description, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    name,
    description,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of MarketCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketCategoryModelImplCopyWith<_$MarketCategoryModelImpl> get copyWith =>
      __$$MarketCategoryModelImplCopyWithImpl<_$MarketCategoryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketCategoryModelImplToJson(this);
  }
}

abstract class _MarketCategoryModel implements MarketCategoryModel {
  const factory _MarketCategoryModel({
    required final int id,
    required final String code,
    required final String name,
    required final String description,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at') required final String createdAt,
    @JsonKey(name: 'updated_at') required final String updatedAt,
  }) = _$MarketCategoryModelImpl;

  factory _MarketCategoryModel.fromJson(Map<String, dynamic> json) =
      _$MarketCategoryModelImpl.fromJson;

  @override
  int get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;

  /// Create a copy of MarketCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketCategoryModelImplCopyWith<_$MarketCategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketServerResponse _$MarketServerResponseFromJson(Map<String, dynamic> json) {
  return _MarketServerResponse.fromJson(json);
}

/// @nodoc
mixin _$MarketServerResponse {
  int get code => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  MarketServerData get data => throw _privateConstructorUsedError;

  /// Serializes this MarketServerResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketServerResponseCopyWith<MarketServerResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketServerResponseCopyWith<$Res> {
  factory $MarketServerResponseCopyWith(
    MarketServerResponse value,
    $Res Function(MarketServerResponse) then,
  ) = _$MarketServerResponseCopyWithImpl<$Res, MarketServerResponse>;
  @useResult
  $Res call({int code, String message, MarketServerData data});

  $MarketServerDataCopyWith<$Res> get data;
}

/// @nodoc
class _$MarketServerResponseCopyWithImpl<
  $Res,
  $Val extends MarketServerResponse
>
    implements $MarketServerResponseCopyWith<$Res> {
  _$MarketServerResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as int,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as MarketServerData,
          )
          as $Val,
    );
  }

  /// Create a copy of MarketServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MarketServerDataCopyWith<$Res> get data {
    return $MarketServerDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MarketServerResponseImplCopyWith<$Res>
    implements $MarketServerResponseCopyWith<$Res> {
  factory _$$MarketServerResponseImplCopyWith(
    _$MarketServerResponseImpl value,
    $Res Function(_$MarketServerResponseImpl) then,
  ) = __$$MarketServerResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int code, String message, MarketServerData data});

  @override
  $MarketServerDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$MarketServerResponseImplCopyWithImpl<$Res>
    extends _$MarketServerResponseCopyWithImpl<$Res, _$MarketServerResponseImpl>
    implements _$$MarketServerResponseImplCopyWith<$Res> {
  __$$MarketServerResponseImplCopyWithImpl(
    _$MarketServerResponseImpl _value,
    $Res Function(_$MarketServerResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(
      _$MarketServerResponseImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as int,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as MarketServerData,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketServerResponseImpl implements _MarketServerResponse {
  const _$MarketServerResponseImpl({
    required this.code,
    required this.message,
    required this.data,
  });

  factory _$MarketServerResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketServerResponseImplFromJson(json);

  @override
  final int code;
  @override
  final String message;
  @override
  final MarketServerData data;

  @override
  String toString() {
    return 'MarketServerResponse(code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketServerResponseImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, message, data);

  /// Create a copy of MarketServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketServerResponseImplCopyWith<_$MarketServerResponseImpl>
  get copyWith =>
      __$$MarketServerResponseImplCopyWithImpl<_$MarketServerResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketServerResponseImplToJson(this);
  }
}

abstract class _MarketServerResponse implements MarketServerResponse {
  const factory _MarketServerResponse({
    required final int code,
    required final String message,
    required final MarketServerData data,
  }) = _$MarketServerResponseImpl;

  factory _MarketServerResponse.fromJson(Map<String, dynamic> json) =
      _$MarketServerResponseImpl.fromJson;

  @override
  int get code;
  @override
  String get message;
  @override
  MarketServerData get data;

  /// Create a copy of MarketServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketServerResponseImplCopyWith<_$MarketServerResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MarketServerData _$MarketServerDataFromJson(Map<String, dynamic> json) {
  return _MarketServerData.fromJson(json);
}

/// @nodoc
mixin _$MarketServerData {
  List<MarketServerModel> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this MarketServerData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketServerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketServerDataCopyWith<MarketServerData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketServerDataCopyWith<$Res> {
  factory $MarketServerDataCopyWith(
    MarketServerData value,
    $Res Function(MarketServerData) then,
  ) = _$MarketServerDataCopyWithImpl<$Res, MarketServerData>;
  @useResult
  $Res call({List<MarketServerModel> items, int page, int size, int total});
}

/// @nodoc
class _$MarketServerDataCopyWithImpl<$Res, $Val extends MarketServerData>
    implements $MarketServerDataCopyWith<$Res> {
  _$MarketServerDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketServerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? size = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<MarketServerModel>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarketServerDataImplCopyWith<$Res>
    implements $MarketServerDataCopyWith<$Res> {
  factory _$$MarketServerDataImplCopyWith(
    _$MarketServerDataImpl value,
    $Res Function(_$MarketServerDataImpl) then,
  ) = __$$MarketServerDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MarketServerModel> items, int page, int size, int total});
}

/// @nodoc
class __$$MarketServerDataImplCopyWithImpl<$Res>
    extends _$MarketServerDataCopyWithImpl<$Res, _$MarketServerDataImpl>
    implements _$$MarketServerDataImplCopyWith<$Res> {
  __$$MarketServerDataImplCopyWithImpl(
    _$MarketServerDataImpl _value,
    $Res Function(_$MarketServerDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketServerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? size = null,
    Object? total = null,
  }) {
    return _then(
      _$MarketServerDataImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<MarketServerModel>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketServerDataImpl implements _MarketServerData {
  const _$MarketServerDataImpl({
    required final List<MarketServerModel> items,
    this.page = 1,
    this.size = 20,
    this.total = 0,
  }) : _items = items;

  factory _$MarketServerDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketServerDataImplFromJson(json);

  final List<MarketServerModel> _items;
  @override
  List<MarketServerModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int size;
  @override
  @JsonKey()
  final int total;

  @override
  String toString() {
    return 'MarketServerData(items: $items, page: $page, size: $size, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketServerDataImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    page,
    size,
    total,
  );

  /// Create a copy of MarketServerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketServerDataImplCopyWith<_$MarketServerDataImpl> get copyWith =>
      __$$MarketServerDataImplCopyWithImpl<_$MarketServerDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketServerDataImplToJson(this);
  }
}

abstract class _MarketServerData implements MarketServerData {
  const factory _MarketServerData({
    required final List<MarketServerModel> items,
    final int page,
    final int size,
    final int total,
  }) = _$MarketServerDataImpl;

  factory _MarketServerData.fromJson(Map<String, dynamic> json) =
      _$MarketServerDataImpl.fromJson;

  @override
  List<MarketServerModel> get items;
  @override
  int get page;
  @override
  int get size;
  @override
  int get total;

  /// Create a copy of MarketServerData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketServerDataImplCopyWith<_$MarketServerDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketCategoryResponse _$MarketCategoryResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MarketCategoryResponse.fromJson(json);
}

/// @nodoc
mixin _$MarketCategoryResponse {
  int get code => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<MarketCategoryModel> get data => throw _privateConstructorUsedError;

  /// Serializes this MarketCategoryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketCategoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketCategoryResponseCopyWith<MarketCategoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketCategoryResponseCopyWith<$Res> {
  factory $MarketCategoryResponseCopyWith(
    MarketCategoryResponse value,
    $Res Function(MarketCategoryResponse) then,
  ) = _$MarketCategoryResponseCopyWithImpl<$Res, MarketCategoryResponse>;
  @useResult
  $Res call({int code, String message, List<MarketCategoryModel> data});
}

/// @nodoc
class _$MarketCategoryResponseCopyWithImpl<
  $Res,
  $Val extends MarketCategoryResponse
>
    implements $MarketCategoryResponseCopyWith<$Res> {
  _$MarketCategoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketCategoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as int,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<MarketCategoryModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarketCategoryResponseImplCopyWith<$Res>
    implements $MarketCategoryResponseCopyWith<$Res> {
  factory _$$MarketCategoryResponseImplCopyWith(
    _$MarketCategoryResponseImpl value,
    $Res Function(_$MarketCategoryResponseImpl) then,
  ) = __$$MarketCategoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int code, String message, List<MarketCategoryModel> data});
}

/// @nodoc
class __$$MarketCategoryResponseImplCopyWithImpl<$Res>
    extends
        _$MarketCategoryResponseCopyWithImpl<$Res, _$MarketCategoryResponseImpl>
    implements _$$MarketCategoryResponseImplCopyWith<$Res> {
  __$$MarketCategoryResponseImplCopyWithImpl(
    _$MarketCategoryResponseImpl _value,
    $Res Function(_$MarketCategoryResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketCategoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(
      _$MarketCategoryResponseImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as int,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<MarketCategoryModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketCategoryResponseImpl implements _MarketCategoryResponse {
  const _$MarketCategoryResponseImpl({
    required this.code,
    required this.message,
    required final List<MarketCategoryModel> data,
  }) : _data = data;

  factory _$MarketCategoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketCategoryResponseImplFromJson(json);

  @override
  final int code;
  @override
  final String message;
  final List<MarketCategoryModel> _data;
  @override
  List<MarketCategoryModel> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'MarketCategoryResponse(code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketCategoryResponseImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    message,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of MarketCategoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketCategoryResponseImplCopyWith<_$MarketCategoryResponseImpl>
  get copyWith =>
      __$$MarketCategoryResponseImplCopyWithImpl<_$MarketCategoryResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketCategoryResponseImplToJson(this);
  }
}

abstract class _MarketCategoryResponse implements MarketCategoryResponse {
  const factory _MarketCategoryResponse({
    required final int code,
    required final String message,
    required final List<MarketCategoryModel> data,
  }) = _$MarketCategoryResponseImpl;

  factory _MarketCategoryResponse.fromJson(Map<String, dynamic> json) =
      _$MarketCategoryResponseImpl.fromJson;

  @override
  int get code;
  @override
  String get message;
  @override
  List<MarketCategoryModel> get data;

  /// Create a copy of MarketCategoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketCategoryResponseImplCopyWith<_$MarketCategoryResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
