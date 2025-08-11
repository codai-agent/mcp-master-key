// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$McpServerImpl _$$McpServerImplFromJson(Map<String, dynamic> json) =>
    _$McpServerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status:
          $enumDecodeNullable(_$McpServerStatusEnumMap, json['status']) ??
          McpServerStatus.notInstalled,
      connectionType:
          $enumDecodeNullable(
            _$McpConnectionTypeEnumMap,
            json['connectionType'],
          ) ??
          McpConnectionType.stdio,
      installType: $enumDecode(_$McpInstallTypeEnumMap, json['installType']),
      command: json['command'] as String,
      args:
          (json['args'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      env:
          (json['env'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      workingDirectory: json['workingDirectory'] as String?,
      installSource: json['installSource'] as String?,
      installSourceType: json['installSourceType'] as String?,
      version: json['version'] as String?,
      config: json['config'] as Map<String, dynamic>? ?? const {},
      processId: (json['processId'] as num?)?.toInt(),
      port: (json['port'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastStartedAt: json['lastStartedAt'] == null
          ? null
          : DateTime.parse(json['lastStartedAt'] as String),
      lastStoppedAt: json['lastStoppedAt'] == null
          ? null
          : DateTime.parse(json['lastStoppedAt'] as String),
      autoStart: json['autoStart'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      logLevel: json['logLevel'] as String? ?? 'info',
    );

Map<String, dynamic> _$$McpServerImplToJson(_$McpServerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': _$McpServerStatusEnumMap[instance.status]!,
      'connectionType': _$McpConnectionTypeEnumMap[instance.connectionType]!,
      'installType': _$McpInstallTypeEnumMap[instance.installType]!,
      'command': instance.command,
      'args': instance.args,
      'env': instance.env,
      'workingDirectory': instance.workingDirectory,
      'installSource': instance.installSource,
      'installSourceType': instance.installSourceType,
      'version': instance.version,
      'config': instance.config,
      'processId': instance.processId,
      'port': instance.port,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastStartedAt': instance.lastStartedAt?.toIso8601String(),
      'lastStoppedAt': instance.lastStoppedAt?.toIso8601String(),
      'autoStart': instance.autoStart,
      'errorMessage': instance.errorMessage,
      'logLevel': instance.logLevel,
    };

const _$McpServerStatusEnumMap = {
  McpServerStatus.notInstalled: 'notInstalled',
  McpServerStatus.installed: 'installed',
  McpServerStatus.starting: 'starting',
  McpServerStatus.running: 'running',
  McpServerStatus.stopping: 'stopping',
  McpServerStatus.stopped: 'stopped',
  McpServerStatus.error: 'error',
  McpServerStatus.installing: 'installing',
  McpServerStatus.uninstalling: 'uninstalling',
};

const _$McpConnectionTypeEnumMap = {
  McpConnectionType.stdio: 'stdio',
  McpConnectionType.sse: 'sse',
};

const _$McpInstallTypeEnumMap = {
  McpInstallType.npx: 'npx',
  McpInstallType.uvx: 'uvx',
  McpInstallType.smithery: 'smithery',
  McpInstallType.localPython: 'localPython',
  McpInstallType.localJar: 'localJar',
  McpInstallType.localExecutable: 'localExecutable',
  McpInstallType.localNode: 'node',
  McpInstallType.preInstalled: 'preInstalled',
};

_$McpLifecycleEventImpl _$$McpLifecycleEventImplFromJson(
  Map<String, dynamic> json,
) => _$McpLifecycleEventImpl(
  id: json['id'] as String,
  serverId: json['serverId'] as String,
  type: $enumDecode(_$McpLifecycleEventTypeEnumMap, json['type']),
  description: json['description'] as String,
  details: json['details'] as Map<String, dynamic>? ?? const {},
  timestamp: DateTime.parse(json['timestamp'] as String),
  success: json['success'] as bool? ?? true,
  errorMessage: json['errorMessage'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$$McpLifecycleEventImplToJson(
  _$McpLifecycleEventImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'serverId': instance.serverId,
  'type': _$McpLifecycleEventTypeEnumMap[instance.type]!,
  'description': instance.description,
  'details': instance.details,
  'timestamp': instance.timestamp.toIso8601String(),
  'success': instance.success,
  'errorMessage': instance.errorMessage,
  'duration': instance.duration,
};

const _$McpLifecycleEventTypeEnumMap = {
  McpLifecycleEventType.installStarted: 'installStarted',
  McpLifecycleEventType.installCompleted: 'installCompleted',
  McpLifecycleEventType.installFailed: 'installFailed',
  McpLifecycleEventType.startStarted: 'startStarted',
  McpLifecycleEventType.startCompleted: 'startCompleted',
  McpLifecycleEventType.startFailed: 'startFailed',
  McpLifecycleEventType.stopStarted: 'stopStarted',
  McpLifecycleEventType.stopCompleted: 'stopCompleted',
  McpLifecycleEventType.stopFailed: 'stopFailed',
  McpLifecycleEventType.configUpdated: 'configUpdated',
  McpLifecycleEventType.statusChanged: 'statusChanged',
  McpLifecycleEventType.errorOccurred: 'errorOccurred',
  McpLifecycleEventType.restarted: 'restarted',
  McpLifecycleEventType.uninstallStarted: 'uninstallStarted',
  McpLifecycleEventType.uninstallCompleted: 'uninstallCompleted',
  McpLifecycleEventType.uninstallFailed: 'uninstallFailed',
  McpLifecycleEventType.healthCheck: 'healthCheck',
};

_$McpLogEntryImpl _$$McpLogEntryImplFromJson(Map<String, dynamic> json) =>
    _$McpLogEntryImpl(
      id: json['id'] as String,
      serverId: json['serverId'] as String,
      level: json['level'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String? ?? 'stdout',
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$McpLogEntryImplToJson(_$McpLogEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serverId': instance.serverId,
      'level': instance.level,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'source': instance.source,
      'metadata': instance.metadata,
    };

_$McpRequestRecordImpl _$$McpRequestRecordImplFromJson(
  Map<String, dynamic> json,
) => _$McpRequestRecordImpl(
  id: json['id'] as String,
  serverId: json['serverId'] as String,
  method: json['method'] as String,
  params: json['params'] as Map<String, dynamic>? ?? const {},
  response: json['response'] as Map<String, dynamic>?,
  requestTime: DateTime.parse(json['requestTime'] as String),
  responseTime: json['responseTime'] == null
      ? null
      : DateTime.parse(json['responseTime'] as String),
  success: json['success'] as bool?,
  errorMessage: json['errorMessage'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$$McpRequestRecordImplToJson(
  _$McpRequestRecordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'serverId': instance.serverId,
  'method': instance.method,
  'params': instance.params,
  'response': instance.response,
  'requestTime': instance.requestTime.toIso8601String(),
  'responseTime': instance.responseTime?.toIso8601String(),
  'success': instance.success,
  'errorMessage': instance.errorMessage,
  'duration': instance.duration,
};
