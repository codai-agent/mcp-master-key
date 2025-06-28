// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MCP管家';

  @override
  String get appSubtitle => 'MCP服务器统一管理中心';

  @override
  String get common_ok => '确定';

  @override
  String get common_cancel => '取消';

  @override
  String get common_save => '保存';

  @override
  String get common_delete => '删除';

  @override
  String get common_edit => '编辑';

  @override
  String get common_add => '添加';

  @override
  String get common_close => '关闭';

  @override
  String get common_refresh => '刷新';

  @override
  String get common_loading => '加载中...';

  @override
  String get common_error => '错误';

  @override
  String get common_success => '成功';

  @override
  String get common_warning => '警告';

  @override
  String get common_info => '信息';

  @override
  String get common_confirm => '确认';

  @override
  String get common_yes => '是';

  @override
  String get common_no => '否';

  @override
  String get common_copy => '复制';

  @override
  String get common_copied => '已复制到剪贴板';

  @override
  String get nav_servers => '服务器管理';

  @override
  String get nav_install => '安装服务器';

  @override
  String get nav_monitor => '监控';

  @override
  String get nav_settings => '设置';

  @override
  String get servers_title => 'MCP 服务器';

  @override
  String get servers_empty => '还没有配置任何服务器';

  @override
  String get servers_empty_subtitle => '点击 \'+\' 按钮添加您的第一个 MCP 服务器';

  @override
  String get servers_add => '添加服务器';

  @override
  String get servers_start => '启动';

  @override
  String get servers_stop => '停止';

  @override
  String get servers_restart => '重启';

  @override
  String get servers_starting => '启动中';

  @override
  String get servers_stopping => '停止中';

  @override
  String get servers_running => '运行中';

  @override
  String get servers_stopped => '已停止';

  @override
  String get servers_error => '错误';

  @override
  String get servers_show_config => '显示配置';

  @override
  String get servers_delete_confirm => '确定要删除这个服务器吗？';

  @override
  String get servers_delete_success => '服务器删除成功';

  @override
  String get servers_start_success => '服务器启动请求发送成功';

  @override
  String get servers_stop_success => '服务器停止请求发送成功';

  @override
  String get install_title => '安装 MCP 服务器';

  @override
  String get install_subtitle => '添加新的 MCP 服务器到您的集合中';

  @override
  String get install_config_label => '服务器配置';

  @override
  String get install_config_hint => '在此输入您的 MCP 服务器配置...';

  @override
  String get install_config_empty => '配置不能为空';

  @override
  String get install_config_invalid => '无效的 JSON 配置';

  @override
  String get install_install => '安装';

  @override
  String get install_installing => '安装中...';

  @override
  String get install_success => '服务器安装成功！';

  @override
  String get install_error => '安装失败';

  @override
  String get monitor_title => 'Hub 监控';

  @override
  String get monitor_hub_status => 'Hub 状态';

  @override
  String get monitor_hub_running => 'Hub 正在运行';

  @override
  String get monitor_hub_stopped => 'Hub 未运行';

  @override
  String get monitor_hub_port => '端口';

  @override
  String get monitor_hub_mode => '模式';

  @override
  String get monitor_hub_connected_servers => '已连接服务器';

  @override
  String get monitor_hub_available_tools => '可用工具';

  @override
  String get monitor_server_stats => '服务器统计';

  @override
  String get monitor_servers_running => '运行中';

  @override
  String get monitor_servers_stopped => '已停止';

  @override
  String get monitor_servers_error => '错误';

  @override
  String get monitor_servers_total => '总计';

  @override
  String get monitor_connected_servers => '已连接的服务器';

  @override
  String get monitor_system_info => '系统信息';

  @override
  String get monitor_protocol_version => '协议版本';

  @override
  String get monitor_app_version => '应用版本';

  @override
  String get monitor_runtime_mode => '运行模式';

  @override
  String get monitor_no_servers => '没有连接的服务器';

  @override
  String get monitor_refresh => '刷新';

  @override
  String get server_monitor_title => '服务器监控';

  @override
  String get server_monitor_overview => '概览';

  @override
  String get server_monitor_config => '配置';

  @override
  String get server_monitor_logs => '日志';

  @override
  String get server_monitor_stats => '统计';

  @override
  String get server_monitor_status => '状态';

  @override
  String get server_monitor_uptime => '运行时间';

  @override
  String get server_monitor_pid => '进程ID';

  @override
  String get server_monitor_memory => '内存使用';

  @override
  String get server_monitor_env_vars => '环境变量';

  @override
  String get server_monitor_mcp_config => 'MCP 服务器配置';

  @override
  String get server_monitor_name => '名称';

  @override
  String get server_monitor_description => '描述';

  @override
  String get server_monitor_install_type => '安装类型';

  @override
  String get server_monitor_connection_type => '连接类型';

  @override
  String get server_monitor_command => '命令';

  @override
  String get server_monitor_args => '参数';

  @override
  String get server_monitor_working_dir => '工作目录';

  @override
  String get server_monitor_install_source => '安装源';

  @override
  String get server_monitor_version => '版本';

  @override
  String get server_monitor_auto_start => '自动启动';

  @override
  String get server_monitor_log_level => '日志级别';

  @override
  String get server_monitor_current_status => '当前状态';

  @override
  String get server_monitor_no_logs => '暂无日志';

  @override
  String get server_monitor_no_logs_level => '该级别暂无日志';

  @override
  String get server_monitor_auto_scroll => '自动滚动';

  @override
  String get server_monitor_log_level_all => '全部';

  @override
  String get server_monitor_log_level_error => '错误';

  @override
  String get server_monitor_log_level_warn => '警告';

  @override
  String get server_monitor_log_level_info => '信息';

  @override
  String get server_monitor_log_level_debug => '调试';

  @override
  String get server_monitor_runtime_status => '运行状态';

  @override
  String get server_monitor_time_tracking => '时间跟踪';

  @override
  String get server_monitor_process_info => '进程信息';

  @override
  String get server_monitor_tool_stats => '工具统计';

  @override
  String get server_monitor_connection_stats => '连接统计';

  @override
  String get server_monitor_performance_stats => '性能统计';

  @override
  String get server_monitor_config_stats => '配置统计';

  @override
  String get server_monitor_tools_count => '工具数量';

  @override
  String get server_monitor_tools_list => '工具列表';

  @override
  String get server_monitor_connection_status => '连接状态';

  @override
  String get server_monitor_error_info => '错误信息';

  @override
  String get settings_title => '设置';

  @override
  String get settings_general => '通用设置';

  @override
  String get settings_language => '语言';

  @override
  String get settings_language_system => '跟随系统';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_language_zh => '中文';

  @override
  String get settings_theme => '主题';

  @override
  String get settings_theme_system => '跟随系统';

  @override
  String get settings_theme_light => '浅色';

  @override
  String get settings_theme_dark => '深色';

  @override
  String get settings_hub => 'Hub 设置';

  @override
  String get settings_hub_mode => 'Hub 模式';

  @override
  String get settings_hub_mode_sse => 'SSE 模式';

  @override
  String get settings_hub_mode_streamable => 'Streamable 模式';

  @override
  String get settings_hub_port => 'Hub 端口';

  @override
  String get settings_download => '下载设置';

  @override
  String get settings_download_mirror => '使用中国大陆镜像源';

  @override
  String get settings_download_mirror_desc =>
      '启用后将使用清华大学 PyPI 镜像和淘宝 NPM 镜像，在中国大陆地区下载更快';

  @override
  String get settings_download_current_pypi => '当前 PyPI 源';

  @override
  String get settings_download_current_npm => '当前 NPM 源';

  @override
  String get settings_download_official_pypi => '官方 PyPI';

  @override
  String get settings_download_tsinghua_pypi => '清华大学 PyPI 镜像';

  @override
  String get settings_download_official_npm => '官方 NPM';

  @override
  String get settings_download_taobao_npm => '淘宝 NPM 镜像';

  @override
  String get settings_about => '关于';

  @override
  String get settings_version => '版本';

  @override
  String get settings_build => '构建版本';

  @override
  String get settings_copyright => '版权';

  @override
  String get splash_initializing => '初始化中...';

  @override
  String get splash_init_runtime => '初始化运行时环境...';

  @override
  String get splash_init_process => '初始化进程管理器...';

  @override
  String get splash_init_database => '初始化数据库...';

  @override
  String get splash_init_hub => '启动 MCP Hub 服务器...';

  @override
  String get splash_init_complete => '初始化完成';

  @override
  String get splash_init_error => '初始化失败，继续启动...';

  @override
  String get config_show_title => '服务器配置';

  @override
  String get config_copy_success => '配置已复制到剪贴板';

  @override
  String get quick_actions_title => '快捷操作';

  @override
  String get quick_actions_start_all => '启动全部';

  @override
  String get quick_actions_stop_all => '停止全部';

  @override
  String get quick_actions_refresh => '刷新状态';

  @override
  String get system_info_platform => '平台';

  @override
  String get system_info_architecture => '架构';

  @override
  String get system_info_dart_version => 'Dart 版本';

  @override
  String get system_info_flutter_version => 'Flutter 版本';
}
