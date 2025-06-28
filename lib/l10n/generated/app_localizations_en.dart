// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MCP Master Key';

  @override
  String get appSubtitle => 'Unified Management Center for MCP Servers';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_add => 'Add';

  @override
  String get common_close => 'Close';

  @override
  String get common_refresh => 'Refresh';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_warning => 'Warning';

  @override
  String get common_info => 'Info';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_copy => 'Copy';

  @override
  String get common_copied => 'Copied to clipboard';

  @override
  String get nav_servers => 'Server Management';

  @override
  String get nav_install => 'Install Server';

  @override
  String get nav_monitor => 'Monitor';

  @override
  String get nav_settings => 'Settings';

  @override
  String get servers_title => 'MCP Servers';

  @override
  String get servers_empty => 'No servers configured yet';

  @override
  String get servers_empty_subtitle =>
      'Click the \'+\' button to add your first MCP server';

  @override
  String get servers_add => 'Add Server';

  @override
  String get servers_start => 'Start';

  @override
  String get servers_stop => 'Stop';

  @override
  String get servers_restart => 'Restart';

  @override
  String get servers_starting => 'Starting';

  @override
  String get servers_stopping => 'Stopping';

  @override
  String get servers_running => 'Running';

  @override
  String get servers_stopped => 'Stopped';

  @override
  String get servers_error => 'Error';

  @override
  String get servers_show_config => 'Show Config';

  @override
  String get servers_delete_confirm =>
      'Are you sure you want to delete this server?';

  @override
  String get servers_delete_success => 'Server deleted successfully';

  @override
  String get servers_start_success => 'Server start request sent successfully';

  @override
  String get servers_stop_success => 'Server stop request sent successfully';

  @override
  String get install_title => 'Install MCP Server';

  @override
  String get install_subtitle => 'Add new MCP servers to your collection';

  @override
  String get install_config_label => 'Server Configuration';

  @override
  String get install_config_hint =>
      'Enter your MCP server configuration here...';

  @override
  String get install_config_empty => 'Configuration cannot be empty';

  @override
  String get install_config_invalid => 'Invalid JSON configuration';

  @override
  String get install_install => 'Install';

  @override
  String get install_installing => 'Installing...';

  @override
  String get install_success => 'Server installed successfully!';

  @override
  String get install_error => 'Installation failed';

  @override
  String get monitor_title => 'Hub Monitor';

  @override
  String get monitor_hub_status => 'Hub Status';

  @override
  String get monitor_hub_running => 'Hub is running';

  @override
  String get monitor_hub_stopped => 'Hub is not running';

  @override
  String get monitor_hub_port => 'Port';

  @override
  String get monitor_hub_mode => 'Mode';

  @override
  String get monitor_hub_connected_servers => 'Connected Servers';

  @override
  String get monitor_hub_available_tools => 'Available Tools';

  @override
  String get monitor_server_stats => 'Server Statistics';

  @override
  String get monitor_servers_running => 'Running';

  @override
  String get monitor_servers_stopped => 'Stopped';

  @override
  String get monitor_servers_error => 'Error';

  @override
  String get monitor_servers_total => 'Total';

  @override
  String get monitor_connected_servers => 'Connected Servers';

  @override
  String get monitor_system_info => 'System Information';

  @override
  String get monitor_protocol_version => 'Protocol Version';

  @override
  String get monitor_app_version => 'App Version';

  @override
  String get monitor_runtime_mode => 'Runtime Mode';

  @override
  String get monitor_no_servers => 'No servers connected';

  @override
  String get monitor_refresh => 'Refresh';

  @override
  String get server_monitor_title => 'Server Monitor';

  @override
  String get server_monitor_overview => 'Overview';

  @override
  String get server_monitor_config => 'Configuration';

  @override
  String get server_monitor_logs => 'Logs';

  @override
  String get server_monitor_stats => 'Statistics';

  @override
  String get server_monitor_status => 'Status';

  @override
  String get server_monitor_uptime => 'Uptime';

  @override
  String get server_monitor_pid => 'Process ID';

  @override
  String get server_monitor_memory => 'Memory Usage';

  @override
  String get server_monitor_env_vars => 'Environment Variables';

  @override
  String get server_monitor_mcp_config => 'MCP Server Configuration';

  @override
  String get server_monitor_name => 'Name';

  @override
  String get server_monitor_description => 'Description';

  @override
  String get server_monitor_install_type => 'Install Type';

  @override
  String get server_monitor_connection_type => 'Connection Type';

  @override
  String get server_monitor_command => 'Command';

  @override
  String get server_monitor_args => 'Arguments';

  @override
  String get server_monitor_working_dir => 'Working Directory';

  @override
  String get server_monitor_install_source => 'Install Source';

  @override
  String get server_monitor_version => 'Version';

  @override
  String get server_monitor_auto_start => 'Auto Start';

  @override
  String get server_monitor_log_level => 'Log Level';

  @override
  String get server_monitor_current_status => 'Current Status';

  @override
  String get server_monitor_no_logs => 'No logs available';

  @override
  String get server_monitor_no_logs_level => 'No logs available for this level';

  @override
  String get server_monitor_auto_scroll => 'Auto Scroll';

  @override
  String get server_monitor_log_level_all => 'ALL';

  @override
  String get server_monitor_log_level_error => 'ERROR';

  @override
  String get server_monitor_log_level_warn => 'WARN';

  @override
  String get server_monitor_log_level_info => 'INFO';

  @override
  String get server_monitor_log_level_debug => 'DEBUG';

  @override
  String get server_monitor_runtime_status => 'Runtime Status';

  @override
  String get server_monitor_time_tracking => 'Time Tracking';

  @override
  String get server_monitor_process_info => 'Process Information';

  @override
  String get server_monitor_tool_stats => 'Tool Statistics';

  @override
  String get server_monitor_connection_stats => 'Connection Statistics';

  @override
  String get server_monitor_performance_stats => 'Performance Statistics';

  @override
  String get server_monitor_config_stats => 'Configuration Statistics';

  @override
  String get server_monitor_tools_count => 'Tools Count';

  @override
  String get server_monitor_tools_list => 'Tools List';

  @override
  String get server_monitor_connection_status => 'Connection Status';

  @override
  String get server_monitor_error_info => 'Error Information';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_general => 'General Settings';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_system => 'System Default';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_language_zh => '中文';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_theme_system => 'System Default';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_hub => 'Hub Settings';

  @override
  String get settings_hub_mode => 'Hub Mode';

  @override
  String get settings_hub_mode_sse => 'SSE Mode';

  @override
  String get settings_hub_mode_streamable => 'Streamable Mode';

  @override
  String get settings_hub_port => 'Hub Port';

  @override
  String get settings_download => 'Download Settings';

  @override
  String get settings_download_mirror => 'Use China Mainland Mirrors';

  @override
  String get settings_download_mirror_desc =>
      'Enable to use Tsinghua PyPI and Taobao NPM mirrors for faster downloads in China';

  @override
  String get settings_download_current_pypi => 'Current PyPI Source';

  @override
  String get settings_download_current_npm => 'Current NPM Source';

  @override
  String get settings_download_official_pypi => 'Official PyPI';

  @override
  String get settings_download_tsinghua_pypi => 'Tsinghua PyPI Mirror';

  @override
  String get settings_download_official_npm => 'Official NPM';

  @override
  String get settings_download_taobao_npm => 'Taobao NPM Mirror';

  @override
  String get settings_about => 'About';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_build => 'Build';

  @override
  String get settings_copyright => 'Copyright';

  @override
  String get splash_initializing => 'Initializing...';

  @override
  String get splash_init_runtime => 'Initializing runtime environment...';

  @override
  String get splash_init_process => 'Initializing process manager...';

  @override
  String get splash_init_database => 'Initializing database...';

  @override
  String get splash_init_hub => 'Starting MCP Hub server...';

  @override
  String get splash_init_complete => 'Initialization complete';

  @override
  String get splash_init_error => 'Initialization failed, continuing...';

  @override
  String get config_show_title => 'Server Configuration';

  @override
  String get config_copy_success => 'Configuration copied to clipboard';

  @override
  String get quick_actions_title => 'Quick Actions';

  @override
  String get quick_actions_start_all => 'Start All';

  @override
  String get quick_actions_stop_all => 'Stop All';

  @override
  String get quick_actions_refresh => 'Refresh Status';

  @override
  String get system_info_platform => 'Platform';

  @override
  String get system_info_architecture => 'Architecture';

  @override
  String get system_info_dart_version => 'Dart Version';

  @override
  String get system_info_flutter_version => 'Flutter Version';
}
