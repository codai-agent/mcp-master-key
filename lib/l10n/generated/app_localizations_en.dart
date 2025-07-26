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
  String get common_retry => 'Retry';

  @override
  String get common_previous => 'Previous';

  @override
  String get common_next => 'Next';

  @override
  String get common_start_install => 'Start Install';

  @override
  String get common_installing => 'Installing...';

  @override
  String get tooltip_github => 'GitHub Repository';

  @override
  String get tooltip_mcp_client => 'MCP Host';

  @override
  String get tooltip_feedback => 'Community & Feedback';

  @override
  String get tooltip_refresh => 'Refresh Services';

  @override
  String get feedback_dialog_title => 'Communication & Feedback';

  @override
  String get feedback_report_bug => 'Report Bug';

  @override
  String get nav_servers => 'Server Management';

  @override
  String get nav_install => 'Install Server';

  @override
  String get nav_market => 'MCP Store';

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
  String get servers_install => 'Install MCP Server';

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
  String get servers_view_details => 'View Details';

  @override
  String get servers_delete_server => 'Delete Server';

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
  String get servers_sort_by_name => 'Name';

  @override
  String get servers_sort_by_status => 'Status';

  @override
  String get servers_sort_by_created => 'Time';

  @override
  String servers_starting_server(String serverName) {
    return 'Starting server: $serverName...';
  }

  @override
  String servers_stopping_server(String serverName) {
    return 'Stopping server: $serverName...';
  }

  @override
  String servers_restarting_server(String serverName) {
    return 'Restarting server: $serverName';
  }

  @override
  String servers_start_failed(String error) {
    return 'Start failed: $error';
  }

  @override
  String servers_stop_failed(String error) {
    return 'Stop failed: $error';
  }

  @override
  String servers_restart_failed(String error) {
    return 'Restart failed: $error';
  }

  @override
  String servers_restart_success(String serverName) {
    return 'Server restarted successfully: $serverName';
  }

  @override
  String get servers_not_exist => 'Server does not exist';

  @override
  String servers_load_failed(String error) {
    return 'Load failed: $error';
  }

  @override
  String servers_edit_dialog_title(String serverName) {
    return 'Edit Server Configuration - $serverName';
  }

  @override
  String get servers_edit_command_label => 'Command';

  @override
  String get servers_edit_command_hint =>
      'e.g.: node, python, /path/to/executable';

  @override
  String get servers_edit_command_helper => 'Path to executable or command';

  @override
  String get servers_edit_args_label => 'Arguments';

  @override
  String get servers_edit_args_hint =>
      'e.g.: --port 3000 --config \"path/to/config.json\"';

  @override
  String get servers_edit_args_helper =>
      'Command line arguments, space-separated, use quotes for arguments with spaces';

  @override
  String get servers_edit_preview_title => 'Preview Full Command';

  @override
  String get servers_edit_command_empty => 'Command cannot be empty';

  @override
  String get servers_edit_save_success => 'Server configuration updated';

  @override
  String servers_edit_save_failed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get servers_edit_load_failed => 'Failed to load server information';

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
  String get install_wizard_title => 'Installation Wizard';

  @override
  String get install_wizard_auto_install_note =>
      '• If using uvx/npx commands, packages will be installed automatically';

  @override
  String get install_wizard_manual_install_note =>
      '• If using other commands, additional installation steps may be required';

  @override
  String get install_wizard_env_support_note =>
      '• Supports environment variable configuration and command line arguments';

  @override
  String get install_wizard_uvx_example => 'UVX Example';

  @override
  String get install_wizard_npx_example => 'NPX Example';

  @override
  String get install_wizard_python_example => 'Python Example';

  @override
  String get install_wizard_manual_config_note =>
      'Since your configuration doesn\'t use uvx/npx, manual installation source configuration is required.';

  @override
  String get install_wizard_auto_config_note =>
      'The system will automatically download and install required packages, no additional configuration needed.';

  @override
  String get install_wizard_auto_install_supported =>
      'Your configuration supports automatic installation, you can proceed to the next step directly.';

  @override
  String get install_wizard_github_source => 'GitHub Source';

  @override
  String get install_wizard_github_source_desc =>
      'Clone and install from GitHub repository';

  @override
  String get install_wizard_local_path => 'Local Path';

  @override
  String get install_wizard_local_path_desc => 'Install from local path';

  @override
  String get install_wizard_auto_analyze_note =>
      'The system will automatically analyze repository structure and determine the best installation command.';

  @override
  String get install_wizard_step_configure => 'Configure Server';

  @override
  String get install_wizard_step_analyze => 'Analyze Installation';

  @override
  String get install_wizard_step_options => 'Installation Options';

  @override
  String get install_wizard_step_execute => 'Execute Installation';

  @override
  String get install_wizard_step_required => 'Required';

  @override
  String get install_wizard_step_auto => 'Auto';

  @override
  String get install_wizard_step_optional => 'Optional';

  @override
  String get install_wizard_step_complete => 'Complete';

  @override
  String get install_wizard_configure_title => 'Configure MCP Server';

  @override
  String get install_wizard_configure_subtitle =>
      'Please fill in the basic information and configuration for the MCP server. The mcpServers configuration is required to determine startup commands and installation methods.';

  @override
  String get install_wizard_server_name => 'Server Name';

  @override
  String get install_wizard_server_description =>
      'Server Description (Optional)';

  @override
  String get install_wizard_config_placeholder =>
      'Click here to enter MCP server configuration...';

  @override
  String get install_wizard_server_config_title => 'MCP Server Configuration *';

  @override
  String get install_wizard_server_name_example => 'e.g., Hot News Server';

  @override
  String get install_wizard_server_description_example =>
      'Briefly describe the functionality of this MCP server';

  @override
  String get install_wizard_analyze_config => 'Analyze Configuration';

  @override
  String get install_wizard_auto_install_ready => 'Auto-installation ready';

  @override
  String get install_wizard_auto_analysis => 'Auto Analysis';

  @override
  String get install_wizard_install_command =>
      'Installation Command (Optional)';

  @override
  String get install_wizard_install_complete =>
      'Installation complete! MCP server has been successfully added to your server list.';

  @override
  String get install_wizard_uvx_detected =>
      'UVX command detected, the system will automatically use uv tool to install Python packages.';

  @override
  String get install_wizard_npx_detected =>
      'NPX command detected, the system will automatically use npm to install Node.js packages.';

  @override
  String get install_wizard_finish => 'Finish';

  @override
  String get install_wizard_installation_complete =>
      'Installation complete, you can start this server in the server list';

  @override
  String get install_wizard_execution_title => 'Installation Execution';

  @override
  String get install_wizard_execution_installing =>
      'Installing MCP server, please wait...';

  @override
  String get install_wizard_execution_ready =>
      'Ready to start installation, click the \"Start Install\" button.';

  @override
  String get install_wizard_execution_summary => 'Installation Summary';

  @override
  String get install_wizard_execution_logs => 'Installation Logs';

  @override
  String get install_wizard_success_title => 'Installation Successful!';

  @override
  String get install_wizard_success_message =>
      'MCP server has been added to your server list and is ready to use.';

  @override
  String get install_wizard_analysis_title => 'Installation Strategy Analysis';

  @override
  String get install_wizard_analysis_subtitle =>
      'The system is analyzing your configuration to determine the best installation strategy.';

  @override
  String install_wizard_strategy_detected(String strategy) {
    return 'Detected installation strategy: $strategy';
  }

  @override
  String get install_wizard_config_source_title =>
      'Configure Installation Source';

  @override
  String get install_wizard_config_source_subtitle =>
      'Since your configuration doesn\'t use uvx/npx, please select the installation source type and provide relevant information.';

  @override
  String get install_wizard_source_type => 'Installation Source Type';

  @override
  String get install_wizard_summary_server_name => 'Server Name';

  @override
  String get install_wizard_summary_description => 'Description';

  @override
  String get install_wizard_summary_strategy => 'Installation Strategy';

  @override
  String get install_wizard_summary_source => 'Installation Source';

  @override
  String get install_wizard_summary_unnamed => 'Unnamed';

  @override
  String get install_wizard_source_github => 'GitHub Source';

  @override
  String get install_wizard_source_local => 'Local Path';

  @override
  String get install_wizard_python_manual =>
      'Python command detected, need to configure package installation source (GitHub or local path).';

  @override
  String get install_wizard_nodejs_manual =>
      'Node.js command detected, need to configure package installation source (GitHub or local path).';

  @override
  String get install_wizard_custom_manual =>
      'Custom command detected, need to manually configure installation source and method.';

  @override
  String get install_wizard_strategy_uvx => 'UVX (Python Package Manager)';

  @override
  String get install_wizard_strategy_npx => 'NPX (Node.js Package Manager)';

  @override
  String get install_wizard_strategy_pip => 'PIP (Python Installation)';

  @override
  String get install_wizard_strategy_npm => 'NPM (Node.js Installation)';

  @override
  String get install_wizard_strategy_git => 'Git Clone';

  @override
  String get install_wizard_strategy_local => 'Local Installation';

  @override
  String get install_wizard_no_additional_config =>
      'No additional configuration needed';

  @override
  String get install_wizard_additional_steps_required =>
      'Additional installation steps required';

  @override
  String get install_wizard_github_repo_url => 'GitHub Repository URL';

  @override
  String get install_wizard_local_path_label => 'Local Path';

  @override
  String get install_wizard_cancel_install_title => 'Cancel Installation';

  @override
  String get install_wizard_cancel_install_message =>
      'An installation process is currently in progress.\n\nIf cancelled, the current installation process will be terminated and downloaded content may need to be restarted.\n\nAre you sure you want to cancel the installation?';

  @override
  String get install_wizard_continue_install => 'Continue Installation';

  @override
  String get install_wizard_cancel_install => 'Cancel Installation';

  @override
  String get install_wizard_installation_cancelled =>
      '🛑 Installation cancelled by user';

  @override
  String get install_wizard_options_title => 'Installation Options';

  @override
  String get install_wizard_options_needed =>
      'Need to configure additional installation options';

  @override
  String get install_wizard_options_default =>
      'Use default installation options';

  @override
  String get install_wizard_source_type_title => 'Installation Source Type';

  @override
  String get install_wizard_github_repo => 'GitHub Repository';

  @override
  String get install_wizard_github_repo_desc =>
      'Install from GitHub repository';

  @override
  String get install_wizard_github_url_label => 'GitHub Repository URL';

  @override
  String get install_wizard_github_url_hint =>
      'https://github.com/user/repo.git';

  @override
  String get install_wizard_local_path_hint => '/path/to/mcp-server';

  @override
  String get install_wizard_auto_install_title => 'Auto Install';

  @override
  String get install_wizard_auto_install_desc =>
      'System will automatically handle the installation process, no additional configuration needed';

  @override
  String get install_wizard_step_1 => '1';

  @override
  String get install_wizard_step_2 => '2';

  @override
  String get install_wizard_step_3 => '3';

  @override
  String get install_wizard_step_4 => '4';

  @override
  String get install_wizard_step_configure_short => 'Configure';

  @override
  String get install_wizard_step_analyze_short => 'Analyze';

  @override
  String get install_wizard_step_options_short => 'Options';

  @override
  String get install_wizard_step_execute_short => 'Execute';

  @override
  String get config_step_title => 'Configure MCP Server';

  @override
  String get config_step_subtitle =>
      'Please enter the basic information and configuration for the MCP server';

  @override
  String get config_step_basic_info => 'Basic Information';

  @override
  String get config_step_server_name => 'Server Name (Optional)';

  @override
  String get config_step_server_name_hint => 'e.g., my-mcp-server';

  @override
  String get config_step_server_description => 'Server Description (Optional)';

  @override
  String get config_step_server_description_hint =>
      'e.g., MCP server for file operations';

  @override
  String get config_step_quick_config => 'Quick Configuration';

  @override
  String get config_step_command_parse => 'Command Parse';

  @override
  String get config_step_command_parse_desc =>
      'If you have an existing installation command, you can paste it here to automatically generate configuration';

  @override
  String get config_step_install_command => 'Installation Command';

  @override
  String get config_step_install_command_hint =>
      'e.g., npx -y @modelcontextprotocol/server-filesystem';

  @override
  String get config_step_parse_command => 'Parse Command';

  @override
  String get config_step_parse_command_tooltip => 'Parse Command';

  @override
  String get config_step_clear => 'Clear';

  @override
  String get config_step_mcp_config => 'MCP Configuration';

  @override
  String get config_step_config_parse_success =>
      'Configuration parsed successfully!';

  @override
  String get config_step_input_command_required =>
      'Please enter installation command';

  @override
  String get config_step_command_parse_success =>
      'Command parsed successfully! Configuration has been automatically filled in';

  @override
  String config_step_command_parse_failed(Object error) {
    return 'Command parsing failed: $error';
  }

  @override
  String get market_title => 'MCP Store';

  @override
  String get market_search_hint => 'Search MCP servers...';

  @override
  String get market_all_categories => 'All Categories';

  @override
  String get market_loading => 'Loading...';

  @override
  String get market_load_error => 'Failed to load';

  @override
  String get market_retry => 'Retry';

  @override
  String get market_no_results => 'No servers found';

  @override
  String get market_install => 'Install';

  @override
  String get market_installed => 'Installed';

  @override
  String get market_download_count => 'Downloads';

  @override
  String get market_used_count => 'Usage';

  @override
  String get market_view_github => 'View GitHub';

  @override
  String market_page_info(Object current, Object total) {
    return 'Page $current, $total results total';
  }

  @override
  String get market_previous_page => 'Previous';

  @override
  String get market_next_page => 'Next';

  @override
  String get market_install_success => 'Installation successful';

  @override
  String get market_install_failed => 'Installation failed';

  @override
  String get market_server_already_installed => 'Server already installed';

  @override
  String get market_installing_server => 'Installing server...';

  @override
  String get market_install_error => 'Installation failed';

  @override
  String get analysis_step_title => 'Analyze Installation Strategy';

  @override
  String get analysis_step_subtitle => 'Analyzing MCP server configuration...';

  @override
  String get analysis_step_result => 'Analysis Result';

  @override
  String get analysis_step_install_type => 'Installation Type';

  @override
  String get analysis_step_install_method => 'Installation Method';

  @override
  String get analysis_step_status => 'Status';

  @override
  String get analysis_step_manual_config => 'Manual configuration required';

  @override
  String get analysis_step_auto_install => 'Auto install';

  @override
  String get analysis_step_analyzing => 'Analyzing configuration...';

  @override
  String get analysis_step_auto_advancing =>
      'Automatically advancing to next step...';

  @override
  String get analysis_step_install_type_uvx => 'UVX (Python Package Manager)';

  @override
  String get analysis_step_install_type_npx => 'NPX (Node.js Package Manager)';

  @override
  String get analysis_step_install_type_smithery =>
      'Smithery (MCP Package Manager)';

  @override
  String get analysis_step_install_type_local_python => 'Local Python Package';

  @override
  String get analysis_step_install_type_local_jar => 'Local JAR Package';

  @override
  String get analysis_step_install_type_local_executable => 'Local Executable';

  @override
  String get analysis_step_install_type_unknown => 'Unknown Type';

  @override
  String get execution_step_title => 'Execute Installation';

  @override
  String get execution_step_subtitle_completed => 'Installation completed!';

  @override
  String get execution_step_subtitle_installing => 'Installing MCP server...';

  @override
  String get execution_step_subtitle_ready => 'Ready to install MCP server';

  @override
  String get execution_step_summary => 'Installation Summary';

  @override
  String get execution_step_server_name => 'Server Name';

  @override
  String get execution_step_unnamed => 'Unnamed';

  @override
  String get execution_step_description => 'Description';

  @override
  String get execution_step_install_type => 'Installation Type';

  @override
  String get execution_step_install_source => 'Installation Source';

  @override
  String get execution_step_github_repo => 'GitHub Repository';

  @override
  String get execution_step_local_path => 'Local Path';

  @override
  String get execution_step_install_logs => 'Installation Logs';

  @override
  String get execution_step_waiting_install =>
      'Waiting to start installation...';

  @override
  String get execution_step_cancel_install => 'Cancel Installation';

  @override
  String get execution_step_install_completed => 'Installation Completed!';

  @override
  String get execution_step_server_list_hint =>
      'You can start this server in the server list';

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
  String get monitor_server_statistics => 'Server Statistics';

  @override
  String get monitor_total_label => 'Total:';

  @override
  String get monitor_installed => 'Installed';

  @override
  String get monitor_connected_servers_title => 'Connected Servers';

  @override
  String get monitor_no_connected_servers => 'No connected servers';

  @override
  String get monitor_system_information => 'System Information';

  @override
  String monitor_total_servers(int count) {
    return 'Total: $count servers';
  }

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
  String server_monitor_log_load_failed(String error) {
    return 'Failed to load logs: $error';
  }

  @override
  String get server_monitor_log_filter => 'Level Filter: ';

  @override
  String server_monitor_operation_failed(String error) {
    return 'Operation failed: $error';
  }

  @override
  String get server_monitor_delete_confirm_title => 'Confirm Delete';

  @override
  String get server_monitor_delete_confirm_content =>
      'Are you sure you want to delete this server? This action cannot be undone.';

  @override
  String get server_monitor_logs_cleared => 'Logs cleared';

  @override
  String server_monitor_clear_logs_failed(String error) {
    return 'Failed to clear logs: $error';
  }

  @override
  String get server_monitor_export_logs_todo =>
      'Log export feature is under development';

  @override
  String server_monitor_export_logs_failed(String error) {
    return 'Failed to export logs: $error';
  }

  @override
  String get server_monitor_edit_todo => 'Edit feature is under development';

  @override
  String server_card_details_title(String serverName) {
    return 'Server Details - $serverName';
  }

  @override
  String server_card_delete_failed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get server_card_confirm_delete_title => 'Confirm Delete';

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
  String get settings_hub_mode => 'Running Mode';

  @override
  String get settings_hub_mode_sse => 'SSE Mode (Single Client)';

  @override
  String get settings_hub_mode_streamable => 'Streamable Mode (Multi Client)';

  @override
  String get settings_hub_port => 'Streamable Port';

  @override
  String settings_hub_port_desc(String port) {
    return 'Port used for multi-client mode: $port';
  }

  @override
  String get settings_hub_port_invalid => 'Port must be between 1024-65535';

  @override
  String get settings_startup => 'Startup Settings';

  @override
  String get settings_startup_auto => 'Auto Start on Boot';

  @override
  String get settings_startup_auto_desc =>
      'Automatically start application when system boots';

  @override
  String get settings_startup_minimize => 'Minimize to System Tray';

  @override
  String get settings_startup_minimize_desc =>
      'Minimize to system tray when closing window';

  @override
  String get settings_logs => 'Log Settings';

  @override
  String get settings_log_level => 'Log Level';

  @override
  String settings_log_level_desc(String level) {
    return 'Current level: $level';
  }

  @override
  String get settings_log_level_debug => 'Debug';

  @override
  String get settings_log_level_info => 'Info';

  @override
  String get settings_log_level_warn => 'Warning';

  @override
  String get settings_log_level_error => 'Error';

  @override
  String get settings_log_retention => 'Log Retention Days';

  @override
  String settings_log_retention_desc(String days) {
    return 'Automatically delete logs older than $days days';
  }

  @override
  String get settings_download => 'Download Settings';

  @override
  String get settings_download_mirror => 'Use China Mainland Mirrors';

  @override
  String get settings_download_mirror_desc =>
      'Use Tsinghua and other domestic mirrors to accelerate package downloads';

  @override
  String get settings_download_current_source => 'Current Mirror Source';

  @override
  String get settings_download_mirror_advantages => 'Mirror Advantages';

  @override
  String get settings_download_mirror_advantages_desc =>
      '• Download speed increased by 5-10 times\n• Solve network connection issues\n• Support Python and NPM packages';

  @override
  String get settings_download_official_pypi => 'Official PyPI';

  @override
  String get settings_download_tsinghua_pypi => 'Tsinghua PyPI Mirror';

  @override
  String get settings_download_official_npm => 'Official NPM';

  @override
  String get settings_download_taobao_npm => 'Taobao NPM Mirror';

  @override
  String get settings_maintenance => 'Maintenance';

  @override
  String get settings_clear_cache => 'Clear Cache';

  @override
  String get settings_clear_cache_desc =>
      'Clear temporary files and cache data';

  @override
  String get settings_clear_cache_button => 'Clear';

  @override
  String get settings_export_config => 'Export Configuration';

  @override
  String get settings_export_config_desc =>
      'Export server configuration and application settings';

  @override
  String get settings_export_config_button => 'Export';

  @override
  String get settings_about => 'About';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_version_desc => 'MCP Hub v1.0.0';

  @override
  String get settings_check_update => 'Check for Updates';

  @override
  String get settings_check_update_desc => 'Check if new version is available';

  @override
  String get settings_check_update_button => 'Check';

  @override
  String get settings_open_source => 'Open Source License';

  @override
  String get settings_open_source_desc =>
      'View open source license information';

  @override
  String settings_mode_changed(String mode) {
    return 'Server mode changed to: $mode';
  }

  @override
  String settings_mode_change_failed(String error) {
    return 'Failed to change server mode: $error';
  }

  @override
  String settings_port_changed(String port) {
    return 'Streamable port changed to: $port';
  }

  @override
  String settings_port_change_failed(String error) {
    return 'Failed to change port: $error';
  }

  @override
  String get settings_restart_required_title => 'Restart Required';

  @override
  String get settings_restart_required_content =>
      'Server mode change requires restarting MCP Hub service to take effect.';

  @override
  String get settings_restart_later => 'Restart Later';

  @override
  String get settings_restart_now => 'Restart Now';

  @override
  String get settings_hub_restarted => 'MCP Hub service restarted successfully';

  @override
  String settings_hub_restart_failed(String error) {
    return 'Failed to restart Hub service: $error';
  }

  @override
  String get settings_clear_cache_title => 'Clear Cache';

  @override
  String get settings_clear_cache_confirm =>
      'Are you sure you want to clear all cache data? This action cannot be undone.';

  @override
  String get settings_confirm => 'Confirm';

  @override
  String get settings_cache_cleared => 'Cache cleared successfully';

  @override
  String get settings_export_todo =>
      'Configuration export feature is under development';

  @override
  String get settings_already_latest => 'Already the latest version';

  @override
  String get settings_license_title => 'Open Source License';

  @override
  String get settings_runtime_mode => 'Runtime Mode';

  @override
  String get settings_multi_client_support =>
      'Support multiple concurrent client connections';

  @override
  String get settings_app_behavior => 'Application Behavior';

  @override
  String get settings_log_settings => 'Log Settings';

  @override
  String get settings_download_settings => 'Download Settings';

  @override
  String get settings_storage_management => 'Storage Management';

  @override
  String get settings_system_information => 'System Information';

  @override
  String get settings_about_section => 'About';

  @override
  String get settings_single_client_mode =>
      'Only allows single client connection';

  @override
  String get settings_single_client_help =>
      'Suitable for single application use, better performance, strong compatibility';

  @override
  String get settings_multi_client_help =>
      'Suitable for multiple applications connecting simultaneously, supports session isolation, resource sharing';

  @override
  String get splash_initializing => 'Initializing...';

  @override
  String get sidebar_collapse => 'Collapse Sidebar';

  @override
  String get sidebar_expand => 'Expand Sidebar';

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

  @override
  String get hub_monitor_title => 'MCP Hub Monitor';

  @override
  String get hub_monitor_status => 'MCP Hub Status';

  @override
  String get hub_monitor_running => 'Running';

  @override
  String get hub_monitor_stopped => 'Stopped';

  @override
  String get hub_monitor_port => 'Service Port';

  @override
  String get hub_monitor_mode => 'Running Mode';

  @override
  String get hub_monitor_connected_servers => 'Connected Servers';

  @override
  String get hub_monitor_available_tools => 'Available Tools';

  @override
  String get hub_monitor_service_address => 'Service Address';

  @override
  String get hub_monitor_not_running => 'Hub service is not running';

  @override
  String get hub_monitor_debug_info => 'Debug Info';

  @override
  String get hub_monitor_server_statistics => 'Server Statistics';

  @override
  String get hub_monitor_connected_servers_list => 'Connected Servers';

  @override
  String get hub_monitor_system_info => 'System Information';

  @override
  String get hub_monitor_unknown => 'Unknown';

  @override
  String get hub_monitor_count_unit => ' servers';

  @override
  String get hub_monitor_tools_unit => ' tools';

  @override
  String get servers_quick_actions => 'Quick Actions';

  @override
  String get servers_search_hint => 'Search servers...';

  @override
  String get servers_description_hint =>
      'MCP servers added through installation wizard';

  @override
  String get servers_status_running => 'Running';

  @override
  String get servers_status_stopped => 'Stopped';

  @override
  String get servers_status_starting => 'Starting';

  @override
  String get servers_status_stopping => 'Stopping';

  @override
  String get servers_status_error => 'Error';

  @override
  String get servers_status_installing => 'Installing';

  @override
  String get servers_status_uninstalling => 'Uninstalling';

  @override
  String get servers_status_installed => 'Installed';

  @override
  String get servers_status_not_installed => 'Not Installed';

  @override
  String get servers_status_unknown => 'Unknown';

  @override
  String get servers_more_options => 'More Options';

  @override
  String get servers_no_servers => 'No servers yet';

  @override
  String get servers_no_servers_found => 'No matching servers found';

  @override
  String get servers_add_server_hint =>
      'Click the floating button to start adding servers';

  @override
  String get servers_load_error => 'Load failed';

  @override
  String get servers_retry => 'Retry';

  @override
  String servers_starting_message(String serverName) {
    return 'Starting server: $serverName...';
  }

  @override
  String servers_stopping_message(String serverName) {
    return 'Stopping server: $serverName...';
  }

  @override
  String servers_restarting_message(String serverName) {
    return 'Restarting server: $serverName...';
  }
}
