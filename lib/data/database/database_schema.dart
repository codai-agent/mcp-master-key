/// 数据库模式定义
class DatabaseSchema {
  static const int currentVersion = 6;

  /// 创建MCP服务器表
  static const String createMcpServersTable = '''
    CREATE TABLE IF NOT EXISTS mcp_servers (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      command TEXT NOT NULL,
      args TEXT NOT NULL DEFAULT '[]',
      working_directory TEXT,
      env TEXT NOT NULL DEFAULT '{}',
      config TEXT NOT NULL DEFAULT '{}',
      install_type TEXT NOT NULL DEFAULT 'unknown',
      connection_type TEXT NOT NULL DEFAULT 'stdio',
      status TEXT NOT NULL DEFAULT 'stopped',
      auto_start INTEGER NOT NULL DEFAULT 0,
      install_source TEXT,
      install_source_type TEXT,
      version TEXT,
      process_id INTEGER,
      port INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      last_started_at INTEGER,
      last_stopped_at INTEGER,
      error_message TEXT,
      log_level TEXT NOT NULL DEFAULT 'info'
    )
  ''';

  /// 创建服务器生命周期事件表
  static const String createServerLifecycleEventsTable = '''
    CREATE TABLE IF NOT EXISTS server_lifecycle_events (
      id TEXT PRIMARY KEY,
      server_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      event_status TEXT NOT NULL DEFAULT 'pending',
      message TEXT,
      error_message TEXT,
      metadata TEXT NOT NULL DEFAULT '{}',
      timestamp INTEGER NOT NULL,
      duration_ms INTEGER,
      FOREIGN KEY (server_id) REFERENCES mcp_servers (id) ON DELETE CASCADE
    )
  ''';

  /// 创建服务器运行时统计表
  static const String createServerRuntimeStatsTable = '''
    CREATE TABLE IF NOT EXISTS server_runtime_stats (
      id TEXT PRIMARY KEY,
      server_id TEXT NOT NULL,
      session_id TEXT NOT NULL,
      cpu_usage_percent REAL,
      memory_usage_mb REAL,
      request_count INTEGER NOT NULL DEFAULT 0,
      error_count INTEGER NOT NULL DEFAULT 0,
      avg_response_time_ms REAL,
      last_heartbeat INTEGER,
      uptime_seconds INTEGER,
      timestamp INTEGER NOT NULL,
      FOREIGN KEY (server_id) REFERENCES mcp_servers (id) ON DELETE CASCADE
    )
  ''';

  /// 创建服务器日志表
  static const String createServerLogsTable = '''
    CREATE TABLE IF NOT EXISTS server_logs (
      id TEXT PRIMARY KEY,
      server_id TEXT NOT NULL,
      session_id TEXT,
      level TEXT NOT NULL,
      message TEXT NOT NULL,
      source TEXT NOT NULL DEFAULT 'stdout',
      metadata TEXT NOT NULL DEFAULT '{}',
      timestamp INTEGER NOT NULL,
      FOREIGN KEY (server_id) REFERENCES mcp_servers (id) ON DELETE CASCADE
    )
  ''';

  /// 创建MCP请求记录表
  static const String createMcpRequestsTable = '''
    CREATE TABLE IF NOT EXISTS mcp_requests (
      id TEXT PRIMARY KEY,
      server_id TEXT NOT NULL,
      session_id TEXT,
      client_id TEXT,
      request_id TEXT,
      method TEXT NOT NULL,
      params TEXT,
      response TEXT,
      error_code INTEGER,
      error_message TEXT,
      status TEXT NOT NULL DEFAULT 'pending',
      start_time INTEGER NOT NULL,
      end_time INTEGER,
      duration_ms INTEGER,
      FOREIGN KEY (server_id) REFERENCES mcp_servers (id) ON DELETE CASCADE
    )
  ''';

  /// 创建系统事件表
  static const String createSystemEventsTable = '''
    CREATE TABLE IF NOT EXISTS system_events (
      id TEXT PRIMARY KEY,
      event_type TEXT NOT NULL,
      event_level TEXT NOT NULL DEFAULT 'info',
      message TEXT NOT NULL,
      details TEXT,
      metadata TEXT NOT NULL DEFAULT '{}',
      timestamp INTEGER NOT NULL
    )
  ''';

  /// 创建应用配置表
  static const String createAppConfigTable = '''
    CREATE TABLE IF NOT EXISTS app_config (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      value_type TEXT NOT NULL DEFAULT 'string',
      description TEXT,
      category TEXT NOT NULL DEFAULT 'general',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  /// 所有表创建脚本
  static const List<String> createTableScripts = [
    createMcpServersTable,
    createServerLifecycleEventsTable,
    createServerRuntimeStatsTable,
    createServerLogsTable,
    createMcpRequestsTable,
    createSystemEventsTable,
    createAppConfigTable,
  ];
}

/// 数据库索引定义
class DatabaseIndexes {
  /// 创建索引的SQL语句
  static const List<String> createIndexScripts = [
    // MCP服务器索引
    'CREATE INDEX IF NOT EXISTS idx_mcp_servers_status ON mcp_servers (status)',
    'CREATE INDEX IF NOT EXISTS idx_mcp_servers_install_type ON mcp_servers (install_type)',
    'CREATE INDEX IF NOT EXISTS idx_mcp_servers_auto_start ON mcp_servers (auto_start)',
    
    // 生命周期事件索引
    'CREATE INDEX IF NOT EXISTS idx_lifecycle_events_server_id ON server_lifecycle_events (server_id)',
    'CREATE INDEX IF NOT EXISTS idx_lifecycle_events_type ON server_lifecycle_events (event_type)',
    'CREATE INDEX IF NOT EXISTS idx_lifecycle_events_timestamp ON server_lifecycle_events (timestamp)',
    'CREATE INDEX IF NOT EXISTS idx_lifecycle_events_status ON server_lifecycle_events (event_status)',
    
    // 运行时统计索引
    'CREATE INDEX IF NOT EXISTS idx_runtime_stats_server_id ON server_runtime_stats (server_id)',
    'CREATE INDEX IF NOT EXISTS idx_runtime_stats_session_id ON server_runtime_stats (session_id)',
    'CREATE INDEX IF NOT EXISTS idx_runtime_stats_timestamp ON server_runtime_stats (timestamp)',
    
    // 日志索引
    'CREATE INDEX IF NOT EXISTS idx_server_logs_server_id ON server_logs (server_id)',
    'CREATE INDEX IF NOT EXISTS idx_server_logs_level ON server_logs (level)',
    'CREATE INDEX IF NOT EXISTS idx_server_logs_timestamp ON server_logs (timestamp)',
    'CREATE INDEX IF NOT EXISTS idx_server_logs_session_id ON server_logs (session_id)',
    
    // MCP请求索引
    'CREATE INDEX IF NOT EXISTS idx_mcp_requests_server_id ON mcp_requests (server_id)',
    'CREATE INDEX IF NOT EXISTS idx_mcp_requests_method ON mcp_requests (method)',
    'CREATE INDEX IF NOT EXISTS idx_mcp_requests_status ON mcp_requests (status)',
    'CREATE INDEX IF NOT EXISTS idx_mcp_requests_start_time ON mcp_requests (start_time)',
    'CREATE INDEX IF NOT EXISTS idx_mcp_requests_session_id ON mcp_requests (session_id)',
    
    // 系统事件索引
    'CREATE INDEX IF NOT EXISTS idx_system_events_type ON system_events (event_type)',
    'CREATE INDEX IF NOT EXISTS idx_system_events_level ON system_events (event_level)',
    'CREATE INDEX IF NOT EXISTS idx_system_events_timestamp ON system_events (timestamp)',
    
    // 应用配置索引
    'CREATE INDEX IF NOT EXISTS idx_app_config_category ON app_config (category)',
    'CREATE INDEX IF NOT EXISTS idx_app_config_updated_at ON app_config (updated_at)',
  ];
}

/// 生命周期事件类型
class LifecycleEventType {
  static const String installation = 'installation';
  static const String configuration = 'configuration';
  static const String startup = 'startup';
  static const String shutdown = 'shutdown';
  static const String restart = 'restart';
  static const String crash = 'crash';
  static const String update = 'update';
  static const String uninstall = 'uninstall';
  static const String healthCheck = 'health_check';
  static const String configChange = 'config_change';
  static const String processStart = 'process_start';
  static const String processStop = 'process_stop';
  static const String connectionEstablished = 'connection_established';
  static const String connectionLost = 'connection_lost';
  static const String errorOccurred = 'error_occurred';
  static const String sessionStart = 'session_start';
  static const String sessionEnd = 'session_end';
}

/// 事件状态
class EventStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String cancelled = 'cancelled';
}

/// 系统事件类型
class SystemEventType {
  static const String appStart = 'app_start';
  static const String appStop = 'app_stop';
  static const String serverAdded = 'server_added';
  static const String serverRemoved = 'server_removed';
  static const String configUpdated = 'config_updated';
  static const String runtimeInitialized = 'runtime_initialized';
  static const String databaseMigration = 'database_migration';
  static const String errorOccurred = 'error_occurred';
  static const String maintenanceStart = 'maintenance_start';
  static const String maintenanceEnd = 'maintenance_end';
}

/// 事件级别
class EventLevel {
  static const String debug = 'debug';
  static const String info = 'info';
  static const String warning = 'warning';
  static const String error = 'error';
  static const String critical = 'critical';
} 