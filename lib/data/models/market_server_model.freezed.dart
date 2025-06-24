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

MCPMarketServer _$MCPMarketServerFromJson(Map<String, dynamic> json) {
  return _MCPMarketServer.fromJson(json);
}

/// @nodoc
mixin _$MCPMarketServer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get downloadCount => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  List<String> get screenshots => throw _privateConstructorUsedError;
  String get readme => throw _privateConstructorUsedError;
  MCPServerInstallConfig get installConfig =>
      throw _privateConstructorUsedError;
  List<String> get capabilities => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  DateTime get publishedAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get iconUrl => throw _privateConstructorUsedError;
  String get homepage => throw _privateConstructorUsedError;
  String get repository => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;
  String get license => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;

  /// Serializes this MCPMarketServer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MCPMarketServer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MCPMarketServerCopyWith<MCPMarketServer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MCPMarketServerCopyWith<$Res> {
  factory $MCPMarketServerCopyWith(
    MCPMarketServer value,
    $Res Function(MCPMarketServer) then,
  ) = _$MCPMarketServerCopyWithImpl<$Res, MCPMarketServer>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String author,
    String version,
    List<String> tags,
    String category,
    int downloadCount,
    double rating,
    List<String> screenshots,
    String readme,
    MCPServerInstallConfig installConfig,
    List<String> capabilities,
    Map<String, dynamic> metadata,
    DateTime publishedAt,
    DateTime updatedAt,
    String iconUrl,
    String homepage,
    String repository,
    List<String> keywords,
    String license,
    int reviewCount,
  });

  $MCPServerInstallConfigCopyWith<$Res> get installConfig;
}

/// @nodoc
class _$MCPMarketServerCopyWithImpl<$Res, $Val extends MCPMarketServer>
    implements $MCPMarketServerCopyWith<$Res> {
  _$MCPMarketServerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MCPMarketServer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? author = null,
    Object? version = null,
    Object? tags = null,
    Object? category = null,
    Object? downloadCount = null,
    Object? rating = null,
    Object? screenshots = null,
    Object? readme = null,
    Object? installConfig = null,
    Object? capabilities = null,
    Object? metadata = null,
    Object? publishedAt = null,
    Object? updatedAt = null,
    Object? iconUrl = null,
    Object? homepage = null,
    Object? repository = null,
    Object? keywords = null,
    Object? license = null,
    Object? reviewCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            downloadCount: null == downloadCount
                ? _value.downloadCount
                : downloadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            screenshots: null == screenshots
                ? _value.screenshots
                : screenshots // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            readme: null == readme
                ? _value.readme
                : readme // ignore: cast_nullable_to_non_nullable
                      as String,
            installConfig: null == installConfig
                ? _value.installConfig
                : installConfig // ignore: cast_nullable_to_non_nullable
                      as MCPServerInstallConfig,
            capabilities: null == capabilities
                ? _value.capabilities
                : capabilities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            publishedAt: null == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            iconUrl: null == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            homepage: null == homepage
                ? _value.homepage
                : homepage // ignore: cast_nullable_to_non_nullable
                      as String,
            repository: null == repository
                ? _value.repository
                : repository // ignore: cast_nullable_to_non_nullable
                      as String,
            keywords: null == keywords
                ? _value.keywords
                : keywords // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            license: null == license
                ? _value.license
                : license // ignore: cast_nullable_to_non_nullable
                      as String,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of MCPMarketServer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MCPServerInstallConfigCopyWith<$Res> get installConfig {
    return $MCPServerInstallConfigCopyWith<$Res>(_value.installConfig, (value) {
      return _then(_value.copyWith(installConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MCPMarketServerImplCopyWith<$Res>
    implements $MCPMarketServerCopyWith<$Res> {
  factory _$$MCPMarketServerImplCopyWith(
    _$MCPMarketServerImpl value,
    $Res Function(_$MCPMarketServerImpl) then,
  ) = __$$MCPMarketServerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String author,
    String version,
    List<String> tags,
    String category,
    int downloadCount,
    double rating,
    List<String> screenshots,
    String readme,
    MCPServerInstallConfig installConfig,
    List<String> capabilities,
    Map<String, dynamic> metadata,
    DateTime publishedAt,
    DateTime updatedAt,
    String iconUrl,
    String homepage,
    String repository,
    List<String> keywords,
    String license,
    int reviewCount,
  });

  @override
  $MCPServerInstallConfigCopyWith<$Res> get installConfig;
}

/// @nodoc
class __$$MCPMarketServerImplCopyWithImpl<$Res>
    extends _$MCPMarketServerCopyWithImpl<$Res, _$MCPMarketServerImpl>
    implements _$$MCPMarketServerImplCopyWith<$Res> {
  __$$MCPMarketServerImplCopyWithImpl(
    _$MCPMarketServerImpl _value,
    $Res Function(_$MCPMarketServerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MCPMarketServer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? author = null,
    Object? version = null,
    Object? tags = null,
    Object? category = null,
    Object? downloadCount = null,
    Object? rating = null,
    Object? screenshots = null,
    Object? readme = null,
    Object? installConfig = null,
    Object? capabilities = null,
    Object? metadata = null,
    Object? publishedAt = null,
    Object? updatedAt = null,
    Object? iconUrl = null,
    Object? homepage = null,
    Object? repository = null,
    Object? keywords = null,
    Object? license = null,
    Object? reviewCount = null,
  }) {
    return _then(
      _$MCPMarketServerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        downloadCount: null == downloadCount
            ? _value.downloadCount
            : downloadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        screenshots: null == screenshots
            ? _value._screenshots
            : screenshots // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        readme: null == readme
            ? _value.readme
            : readme // ignore: cast_nullable_to_non_nullable
                  as String,
        installConfig: null == installConfig
            ? _value.installConfig
            : installConfig // ignore: cast_nullable_to_non_nullable
                  as MCPServerInstallConfig,
        capabilities: null == capabilities
            ? _value._capabilities
            : capabilities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        publishedAt: null == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        iconUrl: null == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        homepage: null == homepage
            ? _value.homepage
            : homepage // ignore: cast_nullable_to_non_nullable
                  as String,
        repository: null == repository
            ? _value.repository
            : repository // ignore: cast_nullable_to_non_nullable
                  as String,
        keywords: null == keywords
            ? _value._keywords
            : keywords // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        license: null == license
            ? _value.license
            : license // ignore: cast_nullable_to_non_nullable
                  as String,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MCPMarketServerImpl implements _MCPMarketServer {
  const _$MCPMarketServerImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.version,
    required final List<String> tags,
    required this.category,
    this.downloadCount = 0,
    this.rating = 0.0,
    final List<String> screenshots = const [],
    this.readme = '',
    required this.installConfig,
    final List<String> capabilities = const [],
    final Map<String, dynamic> metadata = const {},
    required this.publishedAt,
    required this.updatedAt,
    this.iconUrl = '',
    this.homepage = '',
    this.repository = '',
    final List<String> keywords = const [],
    this.license = '',
    this.reviewCount = 0,
  }) : _tags = tags,
       _screenshots = screenshots,
       _capabilities = capabilities,
       _metadata = metadata,
       _keywords = keywords;

  factory _$MCPMarketServerImpl.fromJson(Map<String, dynamic> json) =>
      _$$MCPMarketServerImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String author;
  @override
  final String version;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String category;
  @override
  @JsonKey()
  final int downloadCount;
  @override
  @JsonKey()
  final double rating;
  final List<String> _screenshots;
  @override
  @JsonKey()
  List<String> get screenshots {
    if (_screenshots is EqualUnmodifiableListView) return _screenshots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_screenshots);
  }

  @override
  @JsonKey()
  final String readme;
  @override
  final MCPServerInstallConfig installConfig;
  final List<String> _capabilities;
  @override
  @JsonKey()
  List<String> get capabilities {
    if (_capabilities is EqualUnmodifiableListView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_capabilities);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final DateTime publishedAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String iconUrl;
  @override
  @JsonKey()
  final String homepage;
  @override
  @JsonKey()
  final String repository;
  final List<String> _keywords;
  @override
  @JsonKey()
  List<String> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  @override
  @JsonKey()
  final String license;
  @override
  @JsonKey()
  final int reviewCount;

  @override
  String toString() {
    return 'MCPMarketServer(id: $id, name: $name, description: $description, author: $author, version: $version, tags: $tags, category: $category, downloadCount: $downloadCount, rating: $rating, screenshots: $screenshots, readme: $readme, installConfig: $installConfig, capabilities: $capabilities, metadata: $metadata, publishedAt: $publishedAt, updatedAt: $updatedAt, iconUrl: $iconUrl, homepage: $homepage, repository: $repository, keywords: $keywords, license: $license, reviewCount: $reviewCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MCPMarketServerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            const DeepCollectionEquality().equals(
              other._screenshots,
              _screenshots,
            ) &&
            (identical(other.readme, readme) || other.readme == readme) &&
            (identical(other.installConfig, installConfig) ||
                other.installConfig == installConfig) &&
            const DeepCollectionEquality().equals(
              other._capabilities,
              _capabilities,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.homepage, homepage) ||
                other.homepage == homepage) &&
            (identical(other.repository, repository) ||
                other.repository == repository) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.license, license) || other.license == license) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    author,
    version,
    const DeepCollectionEquality().hash(_tags),
    category,
    downloadCount,
    rating,
    const DeepCollectionEquality().hash(_screenshots),
    readme,
    installConfig,
    const DeepCollectionEquality().hash(_capabilities),
    const DeepCollectionEquality().hash(_metadata),
    publishedAt,
    updatedAt,
    iconUrl,
    homepage,
    repository,
    const DeepCollectionEquality().hash(_keywords),
    license,
    reviewCount,
  ]);

  /// Create a copy of MCPMarketServer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MCPMarketServerImplCopyWith<_$MCPMarketServerImpl> get copyWith =>
      __$$MCPMarketServerImplCopyWithImpl<_$MCPMarketServerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MCPMarketServerImplToJson(this);
  }
}

abstract class _MCPMarketServer implements MCPMarketServer {
  const factory _MCPMarketServer({
    required final String id,
    required final String name,
    required final String description,
    required final String author,
    required final String version,
    required final List<String> tags,
    required final String category,
    final int downloadCount,
    final double rating,
    final List<String> screenshots,
    final String readme,
    required final MCPServerInstallConfig installConfig,
    final List<String> capabilities,
    final Map<String, dynamic> metadata,
    required final DateTime publishedAt,
    required final DateTime updatedAt,
    final String iconUrl,
    final String homepage,
    final String repository,
    final List<String> keywords,
    final String license,
    final int reviewCount,
  }) = _$MCPMarketServerImpl;

  factory _MCPMarketServer.fromJson(Map<String, dynamic> json) =
      _$MCPMarketServerImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get author;
  @override
  String get version;
  @override
  List<String> get tags;
  @override
  String get category;
  @override
  int get downloadCount;
  @override
  double get rating;
  @override
  List<String> get screenshots;
  @override
  String get readme;
  @override
  MCPServerInstallConfig get installConfig;
  @override
  List<String> get capabilities;
  @override
  Map<String, dynamic> get metadata;
  @override
  DateTime get publishedAt;
  @override
  DateTime get updatedAt;
  @override
  String get iconUrl;
  @override
  String get homepage;
  @override
  String get repository;
  @override
  List<String> get keywords;
  @override
  String get license;
  @override
  int get reviewCount;

  /// Create a copy of MCPMarketServer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MCPMarketServerImplCopyWith<_$MCPMarketServerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MCPServerInstallConfig _$MCPServerInstallConfigFromJson(
  Map<String, dynamic> json,
) {
  return _MCPServerInstallConfig.fromJson(json);
}

/// @nodoc
mixin _$MCPServerInstallConfig {
  String get installMethod =>
      throw _privateConstructorUsedError; // 'uvx' | 'npx' | 'git' | 'manual'
  String get packageName => throw _privateConstructorUsedError;
  List<String> get installArgs => throw _privateConstructorUsedError;
  Map<String, String> get envVars => throw _privateConstructorUsedError;
  List<String> get dependencies => throw _privateConstructorUsedError;
  Map<String, dynamic> get mcpConfig => throw _privateConstructorUsedError;
  String get repositoryUrl => throw _privateConstructorUsedError;
  String get branch => throw _privateConstructorUsedError;
  String get subPath => throw _privateConstructorUsedError;
  List<String> get buildCommands => throw _privateConstructorUsedError;

  /// Serializes this MCPServerInstallConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MCPServerInstallConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MCPServerInstallConfigCopyWith<MCPServerInstallConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MCPServerInstallConfigCopyWith<$Res> {
  factory $MCPServerInstallConfigCopyWith(
    MCPServerInstallConfig value,
    $Res Function(MCPServerInstallConfig) then,
  ) = _$MCPServerInstallConfigCopyWithImpl<$Res, MCPServerInstallConfig>;
  @useResult
  $Res call({
    String installMethod,
    String packageName,
    List<String> installArgs,
    Map<String, String> envVars,
    List<String> dependencies,
    Map<String, dynamic> mcpConfig,
    String repositoryUrl,
    String branch,
    String subPath,
    List<String> buildCommands,
  });
}

/// @nodoc
class _$MCPServerInstallConfigCopyWithImpl<
  $Res,
  $Val extends MCPServerInstallConfig
>
    implements $MCPServerInstallConfigCopyWith<$Res> {
  _$MCPServerInstallConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MCPServerInstallConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installMethod = null,
    Object? packageName = null,
    Object? installArgs = null,
    Object? envVars = null,
    Object? dependencies = null,
    Object? mcpConfig = null,
    Object? repositoryUrl = null,
    Object? branch = null,
    Object? subPath = null,
    Object? buildCommands = null,
  }) {
    return _then(
      _value.copyWith(
            installMethod: null == installMethod
                ? _value.installMethod
                : installMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            packageName: null == packageName
                ? _value.packageName
                : packageName // ignore: cast_nullable_to_non_nullable
                      as String,
            installArgs: null == installArgs
                ? _value.installArgs
                : installArgs // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            envVars: null == envVars
                ? _value.envVars
                : envVars // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            dependencies: null == dependencies
                ? _value.dependencies
                : dependencies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            mcpConfig: null == mcpConfig
                ? _value.mcpConfig
                : mcpConfig // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            repositoryUrl: null == repositoryUrl
                ? _value.repositoryUrl
                : repositoryUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            branch: null == branch
                ? _value.branch
                : branch // ignore: cast_nullable_to_non_nullable
                      as String,
            subPath: null == subPath
                ? _value.subPath
                : subPath // ignore: cast_nullable_to_non_nullable
                      as String,
            buildCommands: null == buildCommands
                ? _value.buildCommands
                : buildCommands // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MCPServerInstallConfigImplCopyWith<$Res>
    implements $MCPServerInstallConfigCopyWith<$Res> {
  factory _$$MCPServerInstallConfigImplCopyWith(
    _$MCPServerInstallConfigImpl value,
    $Res Function(_$MCPServerInstallConfigImpl) then,
  ) = __$$MCPServerInstallConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String installMethod,
    String packageName,
    List<String> installArgs,
    Map<String, String> envVars,
    List<String> dependencies,
    Map<String, dynamic> mcpConfig,
    String repositoryUrl,
    String branch,
    String subPath,
    List<String> buildCommands,
  });
}

/// @nodoc
class __$$MCPServerInstallConfigImplCopyWithImpl<$Res>
    extends
        _$MCPServerInstallConfigCopyWithImpl<$Res, _$MCPServerInstallConfigImpl>
    implements _$$MCPServerInstallConfigImplCopyWith<$Res> {
  __$$MCPServerInstallConfigImplCopyWithImpl(
    _$MCPServerInstallConfigImpl _value,
    $Res Function(_$MCPServerInstallConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MCPServerInstallConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installMethod = null,
    Object? packageName = null,
    Object? installArgs = null,
    Object? envVars = null,
    Object? dependencies = null,
    Object? mcpConfig = null,
    Object? repositoryUrl = null,
    Object? branch = null,
    Object? subPath = null,
    Object? buildCommands = null,
  }) {
    return _then(
      _$MCPServerInstallConfigImpl(
        installMethod: null == installMethod
            ? _value.installMethod
            : installMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        packageName: null == packageName
            ? _value.packageName
            : packageName // ignore: cast_nullable_to_non_nullable
                  as String,
        installArgs: null == installArgs
            ? _value._installArgs
            : installArgs // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        envVars: null == envVars
            ? _value._envVars
            : envVars // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        dependencies: null == dependencies
            ? _value._dependencies
            : dependencies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        mcpConfig: null == mcpConfig
            ? _value._mcpConfig
            : mcpConfig // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        repositoryUrl: null == repositoryUrl
            ? _value.repositoryUrl
            : repositoryUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        branch: null == branch
            ? _value.branch
            : branch // ignore: cast_nullable_to_non_nullable
                  as String,
        subPath: null == subPath
            ? _value.subPath
            : subPath // ignore: cast_nullable_to_non_nullable
                  as String,
        buildCommands: null == buildCommands
            ? _value._buildCommands
            : buildCommands // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MCPServerInstallConfigImpl implements _MCPServerInstallConfig {
  const _$MCPServerInstallConfigImpl({
    required this.installMethod,
    required this.packageName,
    final List<String> installArgs = const [],
    final Map<String, String> envVars = const {},
    final List<String> dependencies = const [],
    final Map<String, dynamic> mcpConfig = const {},
    this.repositoryUrl = '',
    this.branch = '',
    this.subPath = '',
    final List<String> buildCommands = const [],
  }) : _installArgs = installArgs,
       _envVars = envVars,
       _dependencies = dependencies,
       _mcpConfig = mcpConfig,
       _buildCommands = buildCommands;

  factory _$MCPServerInstallConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$MCPServerInstallConfigImplFromJson(json);

  @override
  final String installMethod;
  // 'uvx' | 'npx' | 'git' | 'manual'
  @override
  final String packageName;
  final List<String> _installArgs;
  @override
  @JsonKey()
  List<String> get installArgs {
    if (_installArgs is EqualUnmodifiableListView) return _installArgs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_installArgs);
  }

  final Map<String, String> _envVars;
  @override
  @JsonKey()
  Map<String, String> get envVars {
    if (_envVars is EqualUnmodifiableMapView) return _envVars;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_envVars);
  }

  final List<String> _dependencies;
  @override
  @JsonKey()
  List<String> get dependencies {
    if (_dependencies is EqualUnmodifiableListView) return _dependencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dependencies);
  }

  final Map<String, dynamic> _mcpConfig;
  @override
  @JsonKey()
  Map<String, dynamic> get mcpConfig {
    if (_mcpConfig is EqualUnmodifiableMapView) return _mcpConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_mcpConfig);
  }

  @override
  @JsonKey()
  final String repositoryUrl;
  @override
  @JsonKey()
  final String branch;
  @override
  @JsonKey()
  final String subPath;
  final List<String> _buildCommands;
  @override
  @JsonKey()
  List<String> get buildCommands {
    if (_buildCommands is EqualUnmodifiableListView) return _buildCommands;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_buildCommands);
  }

  @override
  String toString() {
    return 'MCPServerInstallConfig(installMethod: $installMethod, packageName: $packageName, installArgs: $installArgs, envVars: $envVars, dependencies: $dependencies, mcpConfig: $mcpConfig, repositoryUrl: $repositoryUrl, branch: $branch, subPath: $subPath, buildCommands: $buildCommands)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MCPServerInstallConfigImpl &&
            (identical(other.installMethod, installMethod) ||
                other.installMethod == installMethod) &&
            (identical(other.packageName, packageName) ||
                other.packageName == packageName) &&
            const DeepCollectionEquality().equals(
              other._installArgs,
              _installArgs,
            ) &&
            const DeepCollectionEquality().equals(other._envVars, _envVars) &&
            const DeepCollectionEquality().equals(
              other._dependencies,
              _dependencies,
            ) &&
            const DeepCollectionEquality().equals(
              other._mcpConfig,
              _mcpConfig,
            ) &&
            (identical(other.repositoryUrl, repositoryUrl) ||
                other.repositoryUrl == repositoryUrl) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.subPath, subPath) || other.subPath == subPath) &&
            const DeepCollectionEquality().equals(
              other._buildCommands,
              _buildCommands,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    installMethod,
    packageName,
    const DeepCollectionEquality().hash(_installArgs),
    const DeepCollectionEquality().hash(_envVars),
    const DeepCollectionEquality().hash(_dependencies),
    const DeepCollectionEquality().hash(_mcpConfig),
    repositoryUrl,
    branch,
    subPath,
    const DeepCollectionEquality().hash(_buildCommands),
  );

  /// Create a copy of MCPServerInstallConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MCPServerInstallConfigImplCopyWith<_$MCPServerInstallConfigImpl>
  get copyWith =>
      __$$MCPServerInstallConfigImplCopyWithImpl<_$MCPServerInstallConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MCPServerInstallConfigImplToJson(this);
  }
}

abstract class _MCPServerInstallConfig implements MCPServerInstallConfig {
  const factory _MCPServerInstallConfig({
    required final String installMethod,
    required final String packageName,
    final List<String> installArgs,
    final Map<String, String> envVars,
    final List<String> dependencies,
    final Map<String, dynamic> mcpConfig,
    final String repositoryUrl,
    final String branch,
    final String subPath,
    final List<String> buildCommands,
  }) = _$MCPServerInstallConfigImpl;

  factory _MCPServerInstallConfig.fromJson(Map<String, dynamic> json) =
      _$MCPServerInstallConfigImpl.fromJson;

  @override
  String get installMethod; // 'uvx' | 'npx' | 'git' | 'manual'
  @override
  String get packageName;
  @override
  List<String> get installArgs;
  @override
  Map<String, String> get envVars;
  @override
  List<String> get dependencies;
  @override
  Map<String, dynamic> get mcpConfig;
  @override
  String get repositoryUrl;
  @override
  String get branch;
  @override
  String get subPath;
  @override
  List<String> get buildCommands;

  /// Create a copy of MCPServerInstallConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MCPServerInstallConfigImplCopyWith<_$MCPServerInstallConfigImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ServerReview _$ServerReviewFromJson(Map<String, dynamic> json) {
  return _ServerReview.fromJson(json);
}

/// @nodoc
mixin _$ServerReview {
  String get id => throw _privateConstructorUsedError;
  String get serverId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get helpfulCount => throw _privateConstructorUsedError;

  /// Serializes this ServerReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServerReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServerReviewCopyWith<ServerReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerReviewCopyWith<$Res> {
  factory $ServerReviewCopyWith(
    ServerReview value,
    $Res Function(ServerReview) then,
  ) = _$ServerReviewCopyWithImpl<$Res, ServerReview>;
  @useResult
  $Res call({
    String id,
    String serverId,
    String userId,
    String userName,
    double rating,
    String comment,
    DateTime createdAt,
    int helpfulCount,
  });
}

/// @nodoc
class _$ServerReviewCopyWithImpl<$Res, $Val extends ServerReview>
    implements $ServerReviewCopyWith<$Res> {
  _$ServerReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServerReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? userId = null,
    Object? userName = null,
    Object? rating = null,
    Object? comment = null,
    Object? createdAt = null,
    Object? helpfulCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            serverId: null == serverId
                ? _value.serverId
                : serverId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            comment: null == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            helpfulCount: null == helpfulCount
                ? _value.helpfulCount
                : helpfulCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServerReviewImplCopyWith<$Res>
    implements $ServerReviewCopyWith<$Res> {
  factory _$$ServerReviewImplCopyWith(
    _$ServerReviewImpl value,
    $Res Function(_$ServerReviewImpl) then,
  ) = __$$ServerReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String serverId,
    String userId,
    String userName,
    double rating,
    String comment,
    DateTime createdAt,
    int helpfulCount,
  });
}

/// @nodoc
class __$$ServerReviewImplCopyWithImpl<$Res>
    extends _$ServerReviewCopyWithImpl<$Res, _$ServerReviewImpl>
    implements _$$ServerReviewImplCopyWith<$Res> {
  __$$ServerReviewImplCopyWithImpl(
    _$ServerReviewImpl _value,
    $Res Function(_$ServerReviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServerReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? userId = null,
    Object? userName = null,
    Object? rating = null,
    Object? comment = null,
    Object? createdAt = null,
    Object? helpfulCount = null,
  }) {
    return _then(
      _$ServerReviewImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serverId: null == serverId
            ? _value.serverId
            : serverId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        comment: null == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        helpfulCount: null == helpfulCount
            ? _value.helpfulCount
            : helpfulCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServerReviewImpl implements _ServerReview {
  const _$ServerReviewImpl({
    required this.id,
    required this.serverId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.helpfulCount = 0,
  });

  factory _$ServerReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServerReviewImplFromJson(json);

  @override
  final String id;
  @override
  final String serverId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final double rating;
  @override
  final String comment;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int helpfulCount;

  @override
  String toString() {
    return 'ServerReview(id: $id, serverId: $serverId, userId: $userId, userName: $userName, rating: $rating, comment: $comment, createdAt: $createdAt, helpfulCount: $helpfulCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.helpfulCount, helpfulCount) ||
                other.helpfulCount == helpfulCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serverId,
    userId,
    userName,
    rating,
    comment,
    createdAt,
    helpfulCount,
  );

  /// Create a copy of ServerReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerReviewImplCopyWith<_$ServerReviewImpl> get copyWith =>
      __$$ServerReviewImplCopyWithImpl<_$ServerReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServerReviewImplToJson(this);
  }
}

abstract class _ServerReview implements ServerReview {
  const factory _ServerReview({
    required final String id,
    required final String serverId,
    required final String userId,
    required final String userName,
    required final double rating,
    required final String comment,
    required final DateTime createdAt,
    final int helpfulCount,
  }) = _$ServerReviewImpl;

  factory _ServerReview.fromJson(Map<String, dynamic> json) =
      _$ServerReviewImpl.fromJson;

  @override
  String get id;
  @override
  String get serverId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  double get rating;
  @override
  String get comment;
  @override
  DateTime get createdAt;
  @override
  int get helpfulCount;

  /// Create a copy of ServerReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerReviewImplCopyWith<_$ServerReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketSearchResult _$MarketSearchResultFromJson(Map<String, dynamic> json) {
  return _MarketSearchResult.fromJson(json);
}

/// @nodoc
mixin _$MarketSearchResult {
  List<MCPMarketServer> get servers => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  List<String> get suggestions => throw _privateConstructorUsedError;

  /// Serializes this MarketSearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketSearchResultCopyWith<MarketSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketSearchResultCopyWith<$Res> {
  factory $MarketSearchResultCopyWith(
    MarketSearchResult value,
    $Res Function(MarketSearchResult) then,
  ) = _$MarketSearchResultCopyWithImpl<$Res, MarketSearchResult>;
  @useResult
  $Res call({
    List<MCPMarketServer> servers,
    int totalCount,
    int currentPage,
    int totalPages,
    List<String> suggestions,
  });
}

/// @nodoc
class _$MarketSearchResultCopyWithImpl<$Res, $Val extends MarketSearchResult>
    implements $MarketSearchResultCopyWith<$Res> {
  _$MarketSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? servers = null,
    Object? totalCount = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? suggestions = null,
  }) {
    return _then(
      _value.copyWith(
            servers: null == servers
                ? _value.servers
                : servers // ignore: cast_nullable_to_non_nullable
                      as List<MCPMarketServer>,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            suggestions: null == suggestions
                ? _value.suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarketSearchResultImplCopyWith<$Res>
    implements $MarketSearchResultCopyWith<$Res> {
  factory _$$MarketSearchResultImplCopyWith(
    _$MarketSearchResultImpl value,
    $Res Function(_$MarketSearchResultImpl) then,
  ) = __$$MarketSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MCPMarketServer> servers,
    int totalCount,
    int currentPage,
    int totalPages,
    List<String> suggestions,
  });
}

/// @nodoc
class __$$MarketSearchResultImplCopyWithImpl<$Res>
    extends _$MarketSearchResultCopyWithImpl<$Res, _$MarketSearchResultImpl>
    implements _$$MarketSearchResultImplCopyWith<$Res> {
  __$$MarketSearchResultImplCopyWithImpl(
    _$MarketSearchResultImpl _value,
    $Res Function(_$MarketSearchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? servers = null,
    Object? totalCount = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? suggestions = null,
  }) {
    return _then(
      _$MarketSearchResultImpl(
        servers: null == servers
            ? _value._servers
            : servers // ignore: cast_nullable_to_non_nullable
                  as List<MCPMarketServer>,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        suggestions: null == suggestions
            ? _value._suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketSearchResultImpl implements _MarketSearchResult {
  const _$MarketSearchResultImpl({
    required final List<MCPMarketServer> servers,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    final List<String> suggestions = const [],
  }) : _servers = servers,
       _suggestions = suggestions;

  factory _$MarketSearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketSearchResultImplFromJson(json);

  final List<MCPMarketServer> _servers;
  @override
  List<MCPMarketServer> get servers {
    if (_servers is EqualUnmodifiableListView) return _servers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_servers);
  }

  @override
  final int totalCount;
  @override
  final int currentPage;
  @override
  final int totalPages;
  final List<String> _suggestions;
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  String toString() {
    return 'MarketSearchResult(servers: $servers, totalCount: $totalCount, currentPage: $currentPage, totalPages: $totalPages, suggestions: $suggestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketSearchResultImpl &&
            const DeepCollectionEquality().equals(other._servers, _servers) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_servers),
    totalCount,
    currentPage,
    totalPages,
    const DeepCollectionEquality().hash(_suggestions),
  );

  /// Create a copy of MarketSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketSearchResultImplCopyWith<_$MarketSearchResultImpl> get copyWith =>
      __$$MarketSearchResultImplCopyWithImpl<_$MarketSearchResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketSearchResultImplToJson(this);
  }
}

abstract class _MarketSearchResult implements MarketSearchResult {
  const factory _MarketSearchResult({
    required final List<MCPMarketServer> servers,
    required final int totalCount,
    required final int currentPage,
    required final int totalPages,
    final List<String> suggestions,
  }) = _$MarketSearchResultImpl;

  factory _MarketSearchResult.fromJson(Map<String, dynamic> json) =
      _$MarketSearchResultImpl.fromJson;

  @override
  List<MCPMarketServer> get servers;
  @override
  int get totalCount;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  List<String> get suggestions;

  /// Create a copy of MarketSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketSearchResultImplCopyWith<_$MarketSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketFilter _$MarketFilterFromJson(Map<String, dynamic> json) {
  return _MarketFilter.fromJson(json);
}

/// @nodoc
mixin _$MarketFilter {
  String get query => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  SortBy get sortBy => throw _privateConstructorUsedError;
  SortOrder get sortOrder => throw _privateConstructorUsedError;
  double get minRating => throw _privateConstructorUsedError;
  List<String> get installMethods => throw _privateConstructorUsedError;

  /// Serializes this MarketFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketFilterCopyWith<MarketFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketFilterCopyWith<$Res> {
  factory $MarketFilterCopyWith(
    MarketFilter value,
    $Res Function(MarketFilter) then,
  ) = _$MarketFilterCopyWithImpl<$Res, MarketFilter>;
  @useResult
  $Res call({
    String query,
    List<String> categories,
    List<String> tags,
    String author,
    SortBy sortBy,
    SortOrder sortOrder,
    double minRating,
    List<String> installMethods,
  });
}

/// @nodoc
class _$MarketFilterCopyWithImpl<$Res, $Val extends MarketFilter>
    implements $MarketFilterCopyWith<$Res> {
  _$MarketFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? categories = null,
    Object? tags = null,
    Object? author = null,
    Object? sortBy = null,
    Object? sortOrder = null,
    Object? minRating = null,
    Object? installMethods = null,
  }) {
    return _then(
      _value.copyWith(
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            sortBy: null == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                      as SortBy,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as SortOrder,
            minRating: null == minRating
                ? _value.minRating
                : minRating // ignore: cast_nullable_to_non_nullable
                      as double,
            installMethods: null == installMethods
                ? _value.installMethods
                : installMethods // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarketFilterImplCopyWith<$Res>
    implements $MarketFilterCopyWith<$Res> {
  factory _$$MarketFilterImplCopyWith(
    _$MarketFilterImpl value,
    $Res Function(_$MarketFilterImpl) then,
  ) = __$$MarketFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String query,
    List<String> categories,
    List<String> tags,
    String author,
    SortBy sortBy,
    SortOrder sortOrder,
    double minRating,
    List<String> installMethods,
  });
}

/// @nodoc
class __$$MarketFilterImplCopyWithImpl<$Res>
    extends _$MarketFilterCopyWithImpl<$Res, _$MarketFilterImpl>
    implements _$$MarketFilterImplCopyWith<$Res> {
  __$$MarketFilterImplCopyWithImpl(
    _$MarketFilterImpl _value,
    $Res Function(_$MarketFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? categories = null,
    Object? tags = null,
    Object? author = null,
    Object? sortBy = null,
    Object? sortOrder = null,
    Object? minRating = null,
    Object? installMethods = null,
  }) {
    return _then(
      _$MarketFilterImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        sortBy: null == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as SortBy,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as SortOrder,
        minRating: null == minRating
            ? _value.minRating
            : minRating // ignore: cast_nullable_to_non_nullable
                  as double,
        installMethods: null == installMethods
            ? _value._installMethods
            : installMethods // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketFilterImpl implements _MarketFilter {
  const _$MarketFilterImpl({
    this.query = '',
    final List<String> categories = const [],
    final List<String> tags = const [],
    this.author = '',
    this.sortBy = SortBy.popularity,
    this.sortOrder = SortOrder.descending,
    this.minRating = 0.0,
    final List<String> installMethods = const [],
  }) : _categories = categories,
       _tags = tags,
       _installMethods = installMethods;

  factory _$MarketFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketFilterImplFromJson(json);

  @override
  @JsonKey()
  final String query;
  final List<String> _categories;
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String author;
  @override
  @JsonKey()
  final SortBy sortBy;
  @override
  @JsonKey()
  final SortOrder sortOrder;
  @override
  @JsonKey()
  final double minRating;
  final List<String> _installMethods;
  @override
  @JsonKey()
  List<String> get installMethods {
    if (_installMethods is EqualUnmodifiableListView) return _installMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_installMethods);
  }

  @override
  String toString() {
    return 'MarketFilter(query: $query, categories: $categories, tags: $tags, author: $author, sortBy: $sortBy, sortOrder: $sortOrder, minRating: $minRating, installMethods: $installMethods)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketFilterImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            const DeepCollectionEquality().equals(
              other._installMethods,
              _installMethods,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_tags),
    author,
    sortBy,
    sortOrder,
    minRating,
    const DeepCollectionEquality().hash(_installMethods),
  );

  /// Create a copy of MarketFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketFilterImplCopyWith<_$MarketFilterImpl> get copyWith =>
      __$$MarketFilterImplCopyWithImpl<_$MarketFilterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketFilterImplToJson(this);
  }
}

abstract class _MarketFilter implements MarketFilter {
  const factory _MarketFilter({
    final String query,
    final List<String> categories,
    final List<String> tags,
    final String author,
    final SortBy sortBy,
    final SortOrder sortOrder,
    final double minRating,
    final List<String> installMethods,
  }) = _$MarketFilterImpl;

  factory _MarketFilter.fromJson(Map<String, dynamic> json) =
      _$MarketFilterImpl.fromJson;

  @override
  String get query;
  @override
  List<String> get categories;
  @override
  List<String> get tags;
  @override
  String get author;
  @override
  SortBy get sortBy;
  @override
  SortOrder get sortOrder;
  @override
  double get minRating;
  @override
  List<String> get installMethods;

  /// Create a copy of MarketFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketFilterImplCopyWith<_$MarketFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
