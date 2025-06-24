// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mcp_server.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

McpServer _$McpServerFromJson(Map<String, dynamic> json) {
  return _McpServer.fromJson(json);
}

/// @nodoc
mixin _$McpServer {
  /// 服务器ID（唯一标识）
  String get id => throw _privateConstructorUsedError;

  /// 服务器名称
  String get name => throw _privateConstructorUsedError;

  /// 服务器描述
  String? get description => throw _privateConstructorUsedError;

  /// 服务器状态
  McpServerStatus get status => throw _privateConstructorUsedError;

  /// 连接类型
  McpConnectionType get connectionType => throw _privateConstructorUsedError;

  /// 安装类型
  McpInstallType get installType => throw _privateConstructorUsedError;

  /// 安装命令或路径
  String get command => throw _privateConstructorUsedError;

  /// 命令参数
  List<String> get args => throw _privateConstructorUsedError;

  /// 环境变量
  Map<String, String> get env => throw _privateConstructorUsedError;

  /// 工作目录
  String? get workingDirectory => throw _privateConstructorUsedError;

  /// 安装源（GitHub URL、npm包名等）
  String? get installSource => throw _privateConstructorUsedError;

  /// 版本信息
  String? get version => throw _privateConstructorUsedError;

  /// 配置参数
  Map<String, dynamic> get config => throw _privateConstructorUsedError;

  /// 进程ID（运行时）
  int? get processId => throw _privateConstructorUsedError;

  /// 端口号（SSE模式）
  int? get port => throw _privateConstructorUsedError;

  /// 创建时间
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 更新时间
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// 最后启动时间
  DateTime? get lastStartedAt => throw _privateConstructorUsedError;

  /// 最后停止时间
  DateTime? get lastStoppedAt => throw _privateConstructorUsedError;

  /// 是否自动启动
  bool get autoStart => throw _privateConstructorUsedError;

  /// 错误信息
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 日志级别
  String get logLevel => throw _privateConstructorUsedError;

  /// Serializes this McpServer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of McpServer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpServerCopyWith<McpServer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpServerCopyWith<$Res> {
  factory $McpServerCopyWith(McpServer value, $Res Function(McpServer) then) =
      _$McpServerCopyWithImpl<$Res, McpServer>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    McpServerStatus status,
    McpConnectionType connectionType,
    McpInstallType installType,
    String command,
    List<String> args,
    Map<String, String> env,
    String? workingDirectory,
    String? installSource,
    String? version,
    Map<String, dynamic> config,
    int? processId,
    int? port,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastStartedAt,
    DateTime? lastStoppedAt,
    bool autoStart,
    String? errorMessage,
    String logLevel,
  });
}

/// @nodoc
class _$McpServerCopyWithImpl<$Res, $Val extends McpServer>
    implements $McpServerCopyWith<$Res> {
  _$McpServerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpServer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? status = null,
    Object? connectionType = null,
    Object? installType = null,
    Object? command = null,
    Object? args = null,
    Object? env = null,
    Object? workingDirectory = freezed,
    Object? installSource = freezed,
    Object? version = freezed,
    Object? config = null,
    Object? processId = freezed,
    Object? port = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastStartedAt = freezed,
    Object? lastStoppedAt = freezed,
    Object? autoStart = null,
    Object? errorMessage = freezed,
    Object? logLevel = null,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as McpServerStatus,
            connectionType: null == connectionType
                ? _value.connectionType
                : connectionType // ignore: cast_nullable_to_non_nullable
                      as McpConnectionType,
            installType: null == installType
                ? _value.installType
                : installType // ignore: cast_nullable_to_non_nullable
                      as McpInstallType,
            command: null == command
                ? _value.command
                : command // ignore: cast_nullable_to_non_nullable
                      as String,
            args: null == args
                ? _value.args
                : args // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            env: null == env
                ? _value.env
                : env // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            workingDirectory: freezed == workingDirectory
                ? _value.workingDirectory
                : workingDirectory // ignore: cast_nullable_to_non_nullable
                      as String?,
            installSource: freezed == installSource
                ? _value.installSource
                : installSource // ignore: cast_nullable_to_non_nullable
                      as String?,
            version: freezed == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String?,
            config: null == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            processId: freezed == processId
                ? _value.processId
                : processId // ignore: cast_nullable_to_non_nullable
                      as int?,
            port: freezed == port
                ? _value.port
                : port // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastStartedAt: freezed == lastStartedAt
                ? _value.lastStartedAt
                : lastStartedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastStoppedAt: freezed == lastStoppedAt
                ? _value.lastStoppedAt
                : lastStoppedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            autoStart: null == autoStart
                ? _value.autoStart
                : autoStart // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            logLevel: null == logLevel
                ? _value.logLevel
                : logLevel // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$McpServerImplCopyWith<$Res>
    implements $McpServerCopyWith<$Res> {
  factory _$$McpServerImplCopyWith(
    _$McpServerImpl value,
    $Res Function(_$McpServerImpl) then,
  ) = __$$McpServerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    McpServerStatus status,
    McpConnectionType connectionType,
    McpInstallType installType,
    String command,
    List<String> args,
    Map<String, String> env,
    String? workingDirectory,
    String? installSource,
    String? version,
    Map<String, dynamic> config,
    int? processId,
    int? port,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastStartedAt,
    DateTime? lastStoppedAt,
    bool autoStart,
    String? errorMessage,
    String logLevel,
  });
}

/// @nodoc
class __$$McpServerImplCopyWithImpl<$Res>
    extends _$McpServerCopyWithImpl<$Res, _$McpServerImpl>
    implements _$$McpServerImplCopyWith<$Res> {
  __$$McpServerImplCopyWithImpl(
    _$McpServerImpl _value,
    $Res Function(_$McpServerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of McpServer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? status = null,
    Object? connectionType = null,
    Object? installType = null,
    Object? command = null,
    Object? args = null,
    Object? env = null,
    Object? workingDirectory = freezed,
    Object? installSource = freezed,
    Object? version = freezed,
    Object? config = null,
    Object? processId = freezed,
    Object? port = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastStartedAt = freezed,
    Object? lastStoppedAt = freezed,
    Object? autoStart = null,
    Object? errorMessage = freezed,
    Object? logLevel = null,
  }) {
    return _then(
      _$McpServerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as McpServerStatus,
        connectionType: null == connectionType
            ? _value.connectionType
            : connectionType // ignore: cast_nullable_to_non_nullable
                  as McpConnectionType,
        installType: null == installType
            ? _value.installType
            : installType // ignore: cast_nullable_to_non_nullable
                  as McpInstallType,
        command: null == command
            ? _value.command
            : command // ignore: cast_nullable_to_non_nullable
                  as String,
        args: null == args
            ? _value._args
            : args // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        env: null == env
            ? _value._env
            : env // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        workingDirectory: freezed == workingDirectory
            ? _value.workingDirectory
            : workingDirectory // ignore: cast_nullable_to_non_nullable
                  as String?,
        installSource: freezed == installSource
            ? _value.installSource
            : installSource // ignore: cast_nullable_to_non_nullable
                  as String?,
        version: freezed == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String?,
        config: null == config
            ? _value._config
            : config // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        processId: freezed == processId
            ? _value.processId
            : processId // ignore: cast_nullable_to_non_nullable
                  as int?,
        port: freezed == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastStartedAt: freezed == lastStartedAt
            ? _value.lastStartedAt
            : lastStartedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastStoppedAt: freezed == lastStoppedAt
            ? _value.lastStoppedAt
            : lastStoppedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        autoStart: null == autoStart
            ? _value.autoStart
            : autoStart // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        logLevel: null == logLevel
            ? _value.logLevel
            : logLevel // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$McpServerImpl implements _McpServer {
  const _$McpServerImpl({
    required this.id,
    required this.name,
    this.description,
    this.status = McpServerStatus.notInstalled,
    this.connectionType = McpConnectionType.stdio,
    required this.installType,
    required this.command,
    final List<String> args = const [],
    final Map<String, String> env = const {},
    this.workingDirectory,
    this.installSource,
    this.version,
    final Map<String, dynamic> config = const {},
    this.processId,
    this.port,
    required this.createdAt,
    required this.updatedAt,
    this.lastStartedAt,
    this.lastStoppedAt,
    this.autoStart = false,
    this.errorMessage,
    this.logLevel = 'info',
  }) : _args = args,
       _env = env,
       _config = config;

  factory _$McpServerImpl.fromJson(Map<String, dynamic> json) =>
      _$$McpServerImplFromJson(json);

  /// 服务器ID（唯一标识）
  @override
  final String id;

  /// 服务器名称
  @override
  final String name;

  /// 服务器描述
  @override
  final String? description;

  /// 服务器状态
  @override
  @JsonKey()
  final McpServerStatus status;

  /// 连接类型
  @override
  @JsonKey()
  final McpConnectionType connectionType;

  /// 安装类型
  @override
  final McpInstallType installType;

  /// 安装命令或路径
  @override
  final String command;

  /// 命令参数
  final List<String> _args;

  /// 命令参数
  @override
  @JsonKey()
  List<String> get args {
    if (_args is EqualUnmodifiableListView) return _args;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_args);
  }

  /// 环境变量
  final Map<String, String> _env;

  /// 环境变量
  @override
  @JsonKey()
  Map<String, String> get env {
    if (_env is EqualUnmodifiableMapView) return _env;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_env);
  }

  /// 工作目录
  @override
  final String? workingDirectory;

  /// 安装源（GitHub URL、npm包名等）
  @override
  final String? installSource;

  /// 版本信息
  @override
  final String? version;

  /// 配置参数
  final Map<String, dynamic> _config;

  /// 配置参数
  @override
  @JsonKey()
  Map<String, dynamic> get config {
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_config);
  }

  /// 进程ID（运行时）
  @override
  final int? processId;

  /// 端口号（SSE模式）
  @override
  final int? port;

  /// 创建时间
  @override
  final DateTime createdAt;

  /// 更新时间
  @override
  final DateTime updatedAt;

  /// 最后启动时间
  @override
  final DateTime? lastStartedAt;

  /// 最后停止时间
  @override
  final DateTime? lastStoppedAt;

  /// 是否自动启动
  @override
  @JsonKey()
  final bool autoStart;

  /// 错误信息
  @override
  final String? errorMessage;

  /// 日志级别
  @override
  @JsonKey()
  final String logLevel;

  @override
  String toString() {
    return 'McpServer(id: $id, name: $name, description: $description, status: $status, connectionType: $connectionType, installType: $installType, command: $command, args: $args, env: $env, workingDirectory: $workingDirectory, installSource: $installSource, version: $version, config: $config, processId: $processId, port: $port, createdAt: $createdAt, updatedAt: $updatedAt, lastStartedAt: $lastStartedAt, lastStoppedAt: $lastStoppedAt, autoStart: $autoStart, errorMessage: $errorMessage, logLevel: $logLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpServerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.connectionType, connectionType) ||
                other.connectionType == connectionType) &&
            (identical(other.installType, installType) ||
                other.installType == installType) &&
            (identical(other.command, command) || other.command == command) &&
            const DeepCollectionEquality().equals(other._args, _args) &&
            const DeepCollectionEquality().equals(other._env, _env) &&
            (identical(other.workingDirectory, workingDirectory) ||
                other.workingDirectory == workingDirectory) &&
            (identical(other.installSource, installSource) ||
                other.installSource == installSource) &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            (identical(other.processId, processId) ||
                other.processId == processId) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastStartedAt, lastStartedAt) ||
                other.lastStartedAt == lastStartedAt) &&
            (identical(other.lastStoppedAt, lastStoppedAt) ||
                other.lastStoppedAt == lastStoppedAt) &&
            (identical(other.autoStart, autoStart) ||
                other.autoStart == autoStart) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.logLevel, logLevel) ||
                other.logLevel == logLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    status,
    connectionType,
    installType,
    command,
    const DeepCollectionEquality().hash(_args),
    const DeepCollectionEquality().hash(_env),
    workingDirectory,
    installSource,
    version,
    const DeepCollectionEquality().hash(_config),
    processId,
    port,
    createdAt,
    updatedAt,
    lastStartedAt,
    lastStoppedAt,
    autoStart,
    errorMessage,
    logLevel,
  ]);

  /// Create a copy of McpServer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpServerImplCopyWith<_$McpServerImpl> get copyWith =>
      __$$McpServerImplCopyWithImpl<_$McpServerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$McpServerImplToJson(this);
  }
}

abstract class _McpServer implements McpServer {
  const factory _McpServer({
    required final String id,
    required final String name,
    final String? description,
    final McpServerStatus status,
    final McpConnectionType connectionType,
    required final McpInstallType installType,
    required final String command,
    final List<String> args,
    final Map<String, String> env,
    final String? workingDirectory,
    final String? installSource,
    final String? version,
    final Map<String, dynamic> config,
    final int? processId,
    final int? port,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? lastStartedAt,
    final DateTime? lastStoppedAt,
    final bool autoStart,
    final String? errorMessage,
    final String logLevel,
  }) = _$McpServerImpl;

  factory _McpServer.fromJson(Map<String, dynamic> json) =
      _$McpServerImpl.fromJson;

  /// 服务器ID（唯一标识）
  @override
  String get id;

  /// 服务器名称
  @override
  String get name;

  /// 服务器描述
  @override
  String? get description;

  /// 服务器状态
  @override
  McpServerStatus get status;

  /// 连接类型
  @override
  McpConnectionType get connectionType;

  /// 安装类型
  @override
  McpInstallType get installType;

  /// 安装命令或路径
  @override
  String get command;

  /// 命令参数
  @override
  List<String> get args;

  /// 环境变量
  @override
  Map<String, String> get env;

  /// 工作目录
  @override
  String? get workingDirectory;

  /// 安装源（GitHub URL、npm包名等）
  @override
  String? get installSource;

  /// 版本信息
  @override
  String? get version;

  /// 配置参数
  @override
  Map<String, dynamic> get config;

  /// 进程ID（运行时）
  @override
  int? get processId;

  /// 端口号（SSE模式）
  @override
  int? get port;

  /// 创建时间
  @override
  DateTime get createdAt;

  /// 更新时间
  @override
  DateTime get updatedAt;

  /// 最后启动时间
  @override
  DateTime? get lastStartedAt;

  /// 最后停止时间
  @override
  DateTime? get lastStoppedAt;

  /// 是否自动启动
  @override
  bool get autoStart;

  /// 错误信息
  @override
  String? get errorMessage;

  /// 日志级别
  @override
  String get logLevel;

  /// Create a copy of McpServer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpServerImplCopyWith<_$McpServerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

McpLifecycleEvent _$McpLifecycleEventFromJson(Map<String, dynamic> json) {
  return _McpLifecycleEvent.fromJson(json);
}

/// @nodoc
mixin _$McpLifecycleEvent {
  /// 事件ID
  String get id => throw _privateConstructorUsedError;

  /// 服务器ID
  String get serverId => throw _privateConstructorUsedError;

  /// 事件类型
  McpLifecycleEventType get type => throw _privateConstructorUsedError;

  /// 事件描述
  String get description => throw _privateConstructorUsedError;

  /// 事件详情
  Map<String, dynamic> get details => throw _privateConstructorUsedError;

  /// 事件时间
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// 是否成功
  bool get success => throw _privateConstructorUsedError;

  /// 错误信息
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 持续时间（毫秒）
  int? get duration => throw _privateConstructorUsedError;

  /// Serializes this McpLifecycleEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of McpLifecycleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpLifecycleEventCopyWith<McpLifecycleEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpLifecycleEventCopyWith<$Res> {
  factory $McpLifecycleEventCopyWith(
    McpLifecycleEvent value,
    $Res Function(McpLifecycleEvent) then,
  ) = _$McpLifecycleEventCopyWithImpl<$Res, McpLifecycleEvent>;
  @useResult
  $Res call({
    String id,
    String serverId,
    McpLifecycleEventType type,
    String description,
    Map<String, dynamic> details,
    DateTime timestamp,
    bool success,
    String? errorMessage,
    int? duration,
  });
}

/// @nodoc
class _$McpLifecycleEventCopyWithImpl<$Res, $Val extends McpLifecycleEvent>
    implements $McpLifecycleEventCopyWith<$Res> {
  _$McpLifecycleEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpLifecycleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? type = null,
    Object? description = null,
    Object? details = null,
    Object? timestamp = null,
    Object? success = null,
    Object? errorMessage = freezed,
    Object? duration = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as McpLifecycleEventType,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            details: null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            duration: freezed == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$McpLifecycleEventImplCopyWith<$Res>
    implements $McpLifecycleEventCopyWith<$Res> {
  factory _$$McpLifecycleEventImplCopyWith(
    _$McpLifecycleEventImpl value,
    $Res Function(_$McpLifecycleEventImpl) then,
  ) = __$$McpLifecycleEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String serverId,
    McpLifecycleEventType type,
    String description,
    Map<String, dynamic> details,
    DateTime timestamp,
    bool success,
    String? errorMessage,
    int? duration,
  });
}

/// @nodoc
class __$$McpLifecycleEventImplCopyWithImpl<$Res>
    extends _$McpLifecycleEventCopyWithImpl<$Res, _$McpLifecycleEventImpl>
    implements _$$McpLifecycleEventImplCopyWith<$Res> {
  __$$McpLifecycleEventImplCopyWithImpl(
    _$McpLifecycleEventImpl _value,
    $Res Function(_$McpLifecycleEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of McpLifecycleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? type = null,
    Object? description = null,
    Object? details = null,
    Object? timestamp = null,
    Object? success = null,
    Object? errorMessage = freezed,
    Object? duration = freezed,
  }) {
    return _then(
      _$McpLifecycleEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serverId: null == serverId
            ? _value.serverId
            : serverId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as McpLifecycleEventType,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        details: null == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$McpLifecycleEventImpl implements _McpLifecycleEvent {
  const _$McpLifecycleEventImpl({
    required this.id,
    required this.serverId,
    required this.type,
    required this.description,
    final Map<String, dynamic> details = const {},
    required this.timestamp,
    this.success = true,
    this.errorMessage,
    this.duration,
  }) : _details = details;

  factory _$McpLifecycleEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$McpLifecycleEventImplFromJson(json);

  /// 事件ID
  @override
  final String id;

  /// 服务器ID
  @override
  final String serverId;

  /// 事件类型
  @override
  final McpLifecycleEventType type;

  /// 事件描述
  @override
  final String description;

  /// 事件详情
  final Map<String, dynamic> _details;

  /// 事件详情
  @override
  @JsonKey()
  Map<String, dynamic> get details {
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_details);
  }

  /// 事件时间
  @override
  final DateTime timestamp;

  /// 是否成功
  @override
  @JsonKey()
  final bool success;

  /// 错误信息
  @override
  final String? errorMessage;

  /// 持续时间（毫秒）
  @override
  final int? duration;

  @override
  String toString() {
    return 'McpLifecycleEvent(id: $id, serverId: $serverId, type: $type, description: $description, details: $details, timestamp: $timestamp, success: $success, errorMessage: $errorMessage, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpLifecycleEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serverId,
    type,
    description,
    const DeepCollectionEquality().hash(_details),
    timestamp,
    success,
    errorMessage,
    duration,
  );

  /// Create a copy of McpLifecycleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpLifecycleEventImplCopyWith<_$McpLifecycleEventImpl> get copyWith =>
      __$$McpLifecycleEventImplCopyWithImpl<_$McpLifecycleEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$McpLifecycleEventImplToJson(this);
  }
}

abstract class _McpLifecycleEvent implements McpLifecycleEvent {
  const factory _McpLifecycleEvent({
    required final String id,
    required final String serverId,
    required final McpLifecycleEventType type,
    required final String description,
    final Map<String, dynamic> details,
    required final DateTime timestamp,
    final bool success,
    final String? errorMessage,
    final int? duration,
  }) = _$McpLifecycleEventImpl;

  factory _McpLifecycleEvent.fromJson(Map<String, dynamic> json) =
      _$McpLifecycleEventImpl.fromJson;

  /// 事件ID
  @override
  String get id;

  /// 服务器ID
  @override
  String get serverId;

  /// 事件类型
  @override
  McpLifecycleEventType get type;

  /// 事件描述
  @override
  String get description;

  /// 事件详情
  @override
  Map<String, dynamic> get details;

  /// 事件时间
  @override
  DateTime get timestamp;

  /// 是否成功
  @override
  bool get success;

  /// 错误信息
  @override
  String? get errorMessage;

  /// 持续时间（毫秒）
  @override
  int? get duration;

  /// Create a copy of McpLifecycleEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpLifecycleEventImplCopyWith<_$McpLifecycleEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

McpLogEntry _$McpLogEntryFromJson(Map<String, dynamic> json) {
  return _McpLogEntry.fromJson(json);
}

/// @nodoc
mixin _$McpLogEntry {
  /// 日志ID
  String get id => throw _privateConstructorUsedError;

  /// 服务器ID
  String get serverId => throw _privateConstructorUsedError;

  /// 日志级别
  String get level => throw _privateConstructorUsedError;

  /// 日志消息
  String get message => throw _privateConstructorUsedError;

  /// 日志时间
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// 日志来源（stdout/stderr）
  String get source => throw _privateConstructorUsedError;

  /// 额外数据
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this McpLogEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of McpLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpLogEntryCopyWith<McpLogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpLogEntryCopyWith<$Res> {
  factory $McpLogEntryCopyWith(
    McpLogEntry value,
    $Res Function(McpLogEntry) then,
  ) = _$McpLogEntryCopyWithImpl<$Res, McpLogEntry>;
  @useResult
  $Res call({
    String id,
    String serverId,
    String level,
    String message,
    DateTime timestamp,
    String source,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$McpLogEntryCopyWithImpl<$Res, $Val extends McpLogEntry>
    implements $McpLogEntryCopyWith<$Res> {
  _$McpLogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? level = null,
    Object? message = null,
    Object? timestamp = null,
    Object? source = null,
    Object? metadata = null,
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
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$McpLogEntryImplCopyWith<$Res>
    implements $McpLogEntryCopyWith<$Res> {
  factory _$$McpLogEntryImplCopyWith(
    _$McpLogEntryImpl value,
    $Res Function(_$McpLogEntryImpl) then,
  ) = __$$McpLogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String serverId,
    String level,
    String message,
    DateTime timestamp,
    String source,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$McpLogEntryImplCopyWithImpl<$Res>
    extends _$McpLogEntryCopyWithImpl<$Res, _$McpLogEntryImpl>
    implements _$$McpLogEntryImplCopyWith<$Res> {
  __$$McpLogEntryImplCopyWithImpl(
    _$McpLogEntryImpl _value,
    $Res Function(_$McpLogEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of McpLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? level = null,
    Object? message = null,
    Object? timestamp = null,
    Object? source = null,
    Object? metadata = null,
  }) {
    return _then(
      _$McpLogEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serverId: null == serverId
            ? _value.serverId
            : serverId // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$McpLogEntryImpl implements _McpLogEntry {
  const _$McpLogEntryImpl({
    required this.id,
    required this.serverId,
    required this.level,
    required this.message,
    required this.timestamp,
    this.source = 'stdout',
    final Map<String, dynamic> metadata = const {},
  }) : _metadata = metadata;

  factory _$McpLogEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$McpLogEntryImplFromJson(json);

  /// 日志ID
  @override
  final String id;

  /// 服务器ID
  @override
  final String serverId;

  /// 日志级别
  @override
  final String level;

  /// 日志消息
  @override
  final String message;

  /// 日志时间
  @override
  final DateTime timestamp;

  /// 日志来源（stdout/stderr）
  @override
  @JsonKey()
  final String source;

  /// 额外数据
  final Map<String, dynamic> _metadata;

  /// 额外数据
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'McpLogEntry(id: $id, serverId: $serverId, level: $level, message: $message, timestamp: $timestamp, source: $source, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpLogEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serverId,
    level,
    message,
    timestamp,
    source,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of McpLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpLogEntryImplCopyWith<_$McpLogEntryImpl> get copyWith =>
      __$$McpLogEntryImplCopyWithImpl<_$McpLogEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$McpLogEntryImplToJson(this);
  }
}

abstract class _McpLogEntry implements McpLogEntry {
  const factory _McpLogEntry({
    required final String id,
    required final String serverId,
    required final String level,
    required final String message,
    required final DateTime timestamp,
    final String source,
    final Map<String, dynamic> metadata,
  }) = _$McpLogEntryImpl;

  factory _McpLogEntry.fromJson(Map<String, dynamic> json) =
      _$McpLogEntryImpl.fromJson;

  /// 日志ID
  @override
  String get id;

  /// 服务器ID
  @override
  String get serverId;

  /// 日志级别
  @override
  String get level;

  /// 日志消息
  @override
  String get message;

  /// 日志时间
  @override
  DateTime get timestamp;

  /// 日志来源（stdout/stderr）
  @override
  String get source;

  /// 额外数据
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of McpLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpLogEntryImplCopyWith<_$McpLogEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

McpRequestRecord _$McpRequestRecordFromJson(Map<String, dynamic> json) {
  return _McpRequestRecord.fromJson(json);
}

/// @nodoc
mixin _$McpRequestRecord {
  /// 请求ID
  String get id => throw _privateConstructorUsedError;

  /// 服务器ID
  String get serverId => throw _privateConstructorUsedError;

  /// 请求方法
  String get method => throw _privateConstructorUsedError;

  /// 请求参数
  Map<String, dynamic> get params => throw _privateConstructorUsedError;

  /// 响应数据
  Map<String, dynamic>? get response => throw _privateConstructorUsedError;

  /// 请求时间
  DateTime get requestTime => throw _privateConstructorUsedError;

  /// 响应时间
  DateTime? get responseTime => throw _privateConstructorUsedError;

  /// 是否成功
  bool? get success => throw _privateConstructorUsedError;

  /// 错误信息
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 响应时间（毫秒）
  int? get duration => throw _privateConstructorUsedError;

  /// Serializes this McpRequestRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of McpRequestRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpRequestRecordCopyWith<McpRequestRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpRequestRecordCopyWith<$Res> {
  factory $McpRequestRecordCopyWith(
    McpRequestRecord value,
    $Res Function(McpRequestRecord) then,
  ) = _$McpRequestRecordCopyWithImpl<$Res, McpRequestRecord>;
  @useResult
  $Res call({
    String id,
    String serverId,
    String method,
    Map<String, dynamic> params,
    Map<String, dynamic>? response,
    DateTime requestTime,
    DateTime? responseTime,
    bool? success,
    String? errorMessage,
    int? duration,
  });
}

/// @nodoc
class _$McpRequestRecordCopyWithImpl<$Res, $Val extends McpRequestRecord>
    implements $McpRequestRecordCopyWith<$Res> {
  _$McpRequestRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpRequestRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? method = null,
    Object? params = null,
    Object? response = freezed,
    Object? requestTime = null,
    Object? responseTime = freezed,
    Object? success = freezed,
    Object? errorMessage = freezed,
    Object? duration = freezed,
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
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            params: null == params
                ? _value.params
                : params // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            response: freezed == response
                ? _value.response
                : response // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            requestTime: null == requestTime
                ? _value.requestTime
                : requestTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            responseTime: freezed == responseTime
                ? _value.responseTime
                : responseTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            success: freezed == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            duration: freezed == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$McpRequestRecordImplCopyWith<$Res>
    implements $McpRequestRecordCopyWith<$Res> {
  factory _$$McpRequestRecordImplCopyWith(
    _$McpRequestRecordImpl value,
    $Res Function(_$McpRequestRecordImpl) then,
  ) = __$$McpRequestRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String serverId,
    String method,
    Map<String, dynamic> params,
    Map<String, dynamic>? response,
    DateTime requestTime,
    DateTime? responseTime,
    bool? success,
    String? errorMessage,
    int? duration,
  });
}

/// @nodoc
class __$$McpRequestRecordImplCopyWithImpl<$Res>
    extends _$McpRequestRecordCopyWithImpl<$Res, _$McpRequestRecordImpl>
    implements _$$McpRequestRecordImplCopyWith<$Res> {
  __$$McpRequestRecordImplCopyWithImpl(
    _$McpRequestRecordImpl _value,
    $Res Function(_$McpRequestRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of McpRequestRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? method = null,
    Object? params = null,
    Object? response = freezed,
    Object? requestTime = null,
    Object? responseTime = freezed,
    Object? success = freezed,
    Object? errorMessage = freezed,
    Object? duration = freezed,
  }) {
    return _then(
      _$McpRequestRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serverId: null == serverId
            ? _value.serverId
            : serverId // ignore: cast_nullable_to_non_nullable
                  as String,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        params: null == params
            ? _value._params
            : params // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        response: freezed == response
            ? _value._response
            : response // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        requestTime: null == requestTime
            ? _value.requestTime
            : requestTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        responseTime: freezed == responseTime
            ? _value.responseTime
            : responseTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        success: freezed == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$McpRequestRecordImpl implements _McpRequestRecord {
  const _$McpRequestRecordImpl({
    required this.id,
    required this.serverId,
    required this.method,
    final Map<String, dynamic> params = const {},
    final Map<String, dynamic>? response,
    required this.requestTime,
    this.responseTime,
    this.success,
    this.errorMessage,
    this.duration,
  }) : _params = params,
       _response = response;

  factory _$McpRequestRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$McpRequestRecordImplFromJson(json);

  /// 请求ID
  @override
  final String id;

  /// 服务器ID
  @override
  final String serverId;

  /// 请求方法
  @override
  final String method;

  /// 请求参数
  final Map<String, dynamic> _params;

  /// 请求参数
  @override
  @JsonKey()
  Map<String, dynamic> get params {
    if (_params is EqualUnmodifiableMapView) return _params;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_params);
  }

  /// 响应数据
  final Map<String, dynamic>? _response;

  /// 响应数据
  @override
  Map<String, dynamic>? get response {
    final value = _response;
    if (value == null) return null;
    if (_response is EqualUnmodifiableMapView) return _response;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// 请求时间
  @override
  final DateTime requestTime;

  /// 响应时间
  @override
  final DateTime? responseTime;

  /// 是否成功
  @override
  final bool? success;

  /// 错误信息
  @override
  final String? errorMessage;

  /// 响应时间（毫秒）
  @override
  final int? duration;

  @override
  String toString() {
    return 'McpRequestRecord(id: $id, serverId: $serverId, method: $method, params: $params, response: $response, requestTime: $requestTime, responseTime: $responseTime, success: $success, errorMessage: $errorMessage, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpRequestRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other._params, _params) &&
            const DeepCollectionEquality().equals(other._response, _response) &&
            (identical(other.requestTime, requestTime) ||
                other.requestTime == requestTime) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serverId,
    method,
    const DeepCollectionEquality().hash(_params),
    const DeepCollectionEquality().hash(_response),
    requestTime,
    responseTime,
    success,
    errorMessage,
    duration,
  );

  /// Create a copy of McpRequestRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpRequestRecordImplCopyWith<_$McpRequestRecordImpl> get copyWith =>
      __$$McpRequestRecordImplCopyWithImpl<_$McpRequestRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$McpRequestRecordImplToJson(this);
  }
}

abstract class _McpRequestRecord implements McpRequestRecord {
  const factory _McpRequestRecord({
    required final String id,
    required final String serverId,
    required final String method,
    final Map<String, dynamic> params,
    final Map<String, dynamic>? response,
    required final DateTime requestTime,
    final DateTime? responseTime,
    final bool? success,
    final String? errorMessage,
    final int? duration,
  }) = _$McpRequestRecordImpl;

  factory _McpRequestRecord.fromJson(Map<String, dynamic> json) =
      _$McpRequestRecordImpl.fromJson;

  /// 请求ID
  @override
  String get id;

  /// 服务器ID
  @override
  String get serverId;

  /// 请求方法
  @override
  String get method;

  /// 请求参数
  @override
  Map<String, dynamic> get params;

  /// 响应数据
  @override
  Map<String, dynamic>? get response;

  /// 请求时间
  @override
  DateTime get requestTime;

  /// 响应时间
  @override
  DateTime? get responseTime;

  /// 是否成功
  @override
  bool? get success;

  /// 错误信息
  @override
  String? get errorMessage;

  /// 响应时间（毫秒）
  @override
  int? get duration;

  /// Create a copy of McpRequestRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpRequestRecordImplCopyWith<_$McpRequestRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
