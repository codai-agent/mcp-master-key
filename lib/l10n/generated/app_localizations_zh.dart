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
  String get common_retry => '重试';

  @override
  String get common_previous => '上一步';

  @override
  String get common_next => '下一步';

  @override
  String get common_start_install => '开始安装';

  @override
  String get common_installing => '安装中...';

  @override
  String get tooltip_github => 'GitHub 地址';

  @override
  String get tooltip_mcp_client => 'MCP 客户端';

  @override
  String get tooltip_feedback => '交友与反馈';

  @override
  String get tooltip_refresh => '刷新服务';

  @override
  String get feedback_dialog_title => '交流反馈';

  @override
  String get feedback_report_bug => '报告Bug';

  @override
  String get nav_servers => '服务器管理';

  @override
  String get nav_install => '安装服务器';

  @override
  String get nav_market => 'MCP服务商店';

  @override
  String get nav_monitor => '监控';

  @override
  String get nav_settings => '设置';

  @override
  String get servers_title => 'MCP 服务器';

  @override
  String get servers_empty => '尚未配置任何服务器';

  @override
  String get servers_empty_subtitle => '点击 \'+\' 按钮添加您的第一个MCP服务器';

  @override
  String get servers_add => '添加服务器';

  @override
  String get servers_install => '安装MCP服务器';

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
  String get servers_view_details => '查看详情';

  @override
  String get servers_delete_server => '删除服务器';

  @override
  String get servers_delete_confirm => '确定要删除这个服务器吗？';

  @override
  String get servers_delete_success => '服务器删除成功';

  @override
  String get servers_start_success => '服务器启动请求发送成功';

  @override
  String get servers_stop_success => '服务器停止请求发送成功';

  @override
  String get servers_sort_by_name => '名称';

  @override
  String get servers_sort_by_status => '状态';

  @override
  String get servers_sort_by_created => '时间';

  @override
  String servers_starting_server(String serverName) {
    return '正在启动服务器: $serverName...';
  }

  @override
  String servers_stopping_server(String serverName) {
    return '正在停止服务器: $serverName...';
  }

  @override
  String servers_restarting_server(String serverName) {
    return '正在重启服务器: $serverName';
  }

  @override
  String servers_start_failed(String error) {
    return '启动失败: $error';
  }

  @override
  String servers_stop_failed(String error) {
    return '停止失败: $error';
  }

  @override
  String servers_restart_failed(String error) {
    return '重启失败: $error';
  }

  @override
  String servers_restart_success(String serverName) {
    return '服务器重启成功: $serverName';
  }

  @override
  String get servers_not_exist => '服务器不存在';

  @override
  String servers_load_failed(String error) {
    return '加载失败: $error';
  }

  @override
  String get install_title => '安装MCP服务器';

  @override
  String get install_subtitle => '将新的MCP服务器添加到您的集合中';

  @override
  String get install_config_label => '服务器配置';

  @override
  String get install_config_hint => '在此输入您的MCP服务器配置...';

  @override
  String get install_config_empty => '配置不能为空';

  @override
  String get install_config_invalid => '无效的JSON配置';

  @override
  String get install_install => '安装';

  @override
  String get install_installing => '安装中...';

  @override
  String get install_success => '服务器安装成功！';

  @override
  String get install_error => '安装失败';

  @override
  String get install_wizard_title => '安装向导';

  @override
  String get install_wizard_auto_install_note => '• 如果使用 uvx/npx 命令，系统会自动安装包';

  @override
  String get install_wizard_manual_install_note => '• 如果使用其他命令，可能需要额外的安装步骤';

  @override
  String get install_wizard_env_support_note => '• 支持环境变量配置和命令行参数';

  @override
  String get install_wizard_uvx_example => 'UVX示例';

  @override
  String get install_wizard_npx_example => 'NPX示例';

  @override
  String get install_wizard_python_example => 'Python示例';

  @override
  String get install_wizard_manual_config_note => '由于您的配置不使用uvx/npx，需要手动配置安装源。';

  @override
  String get install_wizard_auto_config_note => '系统将自动下载和安装所需的包，无需额外配置。';

  @override
  String get install_wizard_auto_install_supported => '您的配置支持自动安装，可以直接进行下一步。';

  @override
  String get install_wizard_github_source => 'GitHub源码';

  @override
  String get install_wizard_github_source_desc => '从GitHub仓库克隆并安装';

  @override
  String get install_wizard_local_path => '本地路径';

  @override
  String get install_wizard_local_path_desc => '从本地路径安装';

  @override
  String get install_wizard_auto_analyze_note => '系统将自动分析仓库结构并确定最佳安装命令。';

  @override
  String get install_wizard_step_configure => '配置服务器';

  @override
  String get install_wizard_step_analyze => '分析安装';

  @override
  String get install_wizard_step_options => '安装选项';

  @override
  String get install_wizard_step_execute => '执行安装';

  @override
  String get install_wizard_step_required => '必填';

  @override
  String get install_wizard_step_auto => '自动';

  @override
  String get install_wizard_step_optional => '可选';

  @override
  String get install_wizard_step_complete => '完成';

  @override
  String get install_wizard_configure_title => '配置MCP服务器';

  @override
  String get install_wizard_configure_subtitle =>
      '请填写MCP服务器的基本信息和配置。mcpServers配置是必填项，用于确定启动命令和安装方式。';

  @override
  String get install_wizard_server_name => '服务器名称';

  @override
  String get install_wizard_server_description => '服务器描述（可选）';

  @override
  String get install_wizard_config_placeholder => '点击此处输入MCP服务器配置...';

  @override
  String get install_wizard_server_config_title => 'MCP服务器配置 *';

  @override
  String get install_wizard_server_name_example => '例如：热点新闻服务器';

  @override
  String get install_wizard_server_description_example => '简单描述这个MCP服务器的功能';

  @override
  String get install_wizard_analyze_config => '分析配置';

  @override
  String get install_wizard_auto_install_ready => '自动安装就绪';

  @override
  String get install_wizard_auto_analysis => '自动分析';

  @override
  String get install_wizard_install_command => '安装命令（可选）';

  @override
  String get install_wizard_install_complete => '安装完成！MCP服务器已成功添加到您的服务器列表。';

  @override
  String get install_wizard_uvx_detected => '检测到UVX命令，系统将自动使用uv工具安装Python包。';

  @override
  String get install_wizard_npx_detected => '检测到NPX命令，系统将自动使用npm安装Node.js包。';

  @override
  String get install_wizard_finish => '完成';

  @override
  String get install_wizard_installation_complete => '安装完成，可以在服务器列表中启动该服务器';

  @override
  String get install_wizard_execution_title => '安装执行';

  @override
  String get install_wizard_execution_installing => '正在安装MCP服务器，请稍候...';

  @override
  String get install_wizard_execution_ready => '准备开始安装，点击\"开始安装\"按钮。';

  @override
  String get install_wizard_execution_summary => '安装摘要';

  @override
  String get install_wizard_execution_logs => '安装日志';

  @override
  String get install_wizard_success_title => '安装成功！';

  @override
  String get install_wizard_success_message => 'MCP服务器已添加到您的服务器列表，可以开始使用了。';

  @override
  String get install_wizard_analysis_title => '安装策略分析';

  @override
  String get install_wizard_analysis_subtitle => '系统正在分析您的配置，确定最佳的安装策略。';

  @override
  String install_wizard_strategy_detected(String strategy) {
    return '检测到安装策略: $strategy';
  }

  @override
  String get install_wizard_config_source_title => '配置安装源';

  @override
  String get install_wizard_config_source_subtitle =>
      '由于您的配置不使用uvx/npx，请选择安装源类型并提供相关信息。';

  @override
  String get install_wizard_source_type => '安装源类型';

  @override
  String get install_wizard_summary_server_name => '服务器名称';

  @override
  String get install_wizard_summary_description => '描述';

  @override
  String get install_wizard_summary_strategy => '安装策略';

  @override
  String get install_wizard_summary_source => '安装源';

  @override
  String get install_wizard_summary_unnamed => '未命名';

  @override
  String get install_wizard_source_github => 'GitHub源码';

  @override
  String get install_wizard_source_local => '本地路径';

  @override
  String get install_wizard_python_manual =>
      '检测到Python命令，需要配置包的安装源（GitHub或本地路径）。';

  @override
  String get install_wizard_nodejs_manual =>
      '检测到Node.js命令，需要配置包的安装源（GitHub或本地路径）。';

  @override
  String get install_wizard_custom_manual => '检测到自定义命令，需要手动配置安装源和方式。';

  @override
  String get install_wizard_strategy_uvx => 'UVX (Python包管理)';

  @override
  String get install_wizard_strategy_npx => 'NPX (Node.js包管理)';

  @override
  String get install_wizard_strategy_pip => 'PIP (Python安装)';

  @override
  String get install_wizard_strategy_npm => 'NPM (Node.js安装)';

  @override
  String get install_wizard_strategy_git => 'Git克隆';

  @override
  String get install_wizard_strategy_local => '本地安装';

  @override
  String get install_wizard_no_additional_config => '无需额外配置';

  @override
  String get install_wizard_additional_steps_required => '需要额外的安装步骤';

  @override
  String get install_wizard_github_repo_url => 'GitHub仓库地址';

  @override
  String get install_wizard_local_path_label => '本地路径';

  @override
  String get install_wizard_cancel_install_title => '取消安装';

  @override
  String get install_wizard_cancel_install_message =>
      '检测到正在进行安装过程。\n\n如果取消，当前安装的进程将被终止，已下载的内容可能需要重新开始。\n\n您确定要取消安装吗？';

  @override
  String get install_wizard_continue_install => '继续安装';

  @override
  String get install_wizard_cancel_install => '取消安装';

  @override
  String get install_wizard_installation_cancelled => '🛑 安装已被用户取消';

  @override
  String get install_wizard_options_title => '安装选项';

  @override
  String get install_wizard_options_needed => '需要配置额外的安装选项';

  @override
  String get install_wizard_options_default => '使用默认安装选项';

  @override
  String get install_wizard_source_type_title => '安装源类型';

  @override
  String get install_wizard_github_repo => 'GitHub仓库';

  @override
  String get install_wizard_github_repo_desc => '从GitHub仓库安装';

  @override
  String get install_wizard_github_url_label => 'GitHub仓库URL';

  @override
  String get install_wizard_github_url_hint =>
      'https://github.com/user/repo.git';

  @override
  String get install_wizard_local_path_hint => '/path/to/mcp-server';

  @override
  String get install_wizard_auto_install_title => '自动安装';

  @override
  String get install_wizard_auto_install_desc => '系统将自动处理安装过程，无需额外配置';

  @override
  String get install_wizard_step_1 => '1';

  @override
  String get install_wizard_step_2 => '2';

  @override
  String get install_wizard_step_3 => '3';

  @override
  String get install_wizard_step_4 => '4';

  @override
  String get install_wizard_step_configure_short => '配置';

  @override
  String get install_wizard_step_analyze_short => '分析';

  @override
  String get install_wizard_step_options_short => '选项';

  @override
  String get install_wizard_step_execute_short => '执行';

  @override
  String get config_step_title => '配置MCP服务器';

  @override
  String get config_step_subtitle => '请输入MCP服务器的基本信息和配置';

  @override
  String get config_step_basic_info => '基本信息';

  @override
  String get config_step_server_name => '服务器名称（自动）';

  @override
  String get config_step_server_name_hint => '例如：my-mcp-server';

  @override
  String get config_step_server_description => '服务器描述（可选）';

  @override
  String get config_step_server_description_hint => '例如：用于文件操作的MCP服务器';

  @override
  String get config_step_quick_config => '快速配置';

  @override
  String get config_step_command_parse => '命令解析';

  @override
  String get config_step_command_parse_desc => '如果您有现成的安装命令，可以直接粘贴到这里自动生成配置';

  @override
  String get config_step_install_command => '安装命令';

  @override
  String get config_step_install_command_hint =>
      '例如：npx -y @modelcontextprotocol/server-filesystem';

  @override
  String get config_step_parse_command => '解析命令';

  @override
  String get config_step_parse_command_tooltip => '解析命令';

  @override
  String get config_step_clear => '清空';

  @override
  String get config_step_mcp_config => 'MCP配置';

  @override
  String get config_step_config_parse_success => '配置解析成功！';

  @override
  String get config_step_input_command_required => '请输入安装命令';

  @override
  String get config_step_command_parse_success => '命令解析成功！配置已自动填入';

  @override
  String config_step_command_parse_failed(Object error) {
    return '命令解析失败：$error';
  }

  @override
  String get market_title => 'MCP服务商店';

  @override
  String get market_search_hint => '搜索MCP服务器...';

  @override
  String get market_all_categories => '所有类别';

  @override
  String get market_loading => '加载中...';

  @override
  String get market_load_error => '加载失败';

  @override
  String get market_retry => '重试';

  @override
  String get market_no_results => '未找到相关服务器';

  @override
  String get market_install => '安装';

  @override
  String get market_installed => '已安装';

  @override
  String get market_download_count => '下载量';

  @override
  String get market_used_count => '使用量';

  @override
  String get market_view_github => '查看GitHub';

  @override
  String market_page_info(Object current, Object total) {
    return '第 $current 页，共 $total 个结果';
  }

  @override
  String get market_previous_page => '上一页';

  @override
  String get market_next_page => '下一页';

  @override
  String get market_install_success => '安装成功';

  @override
  String get market_install_failed => '安装失败';

  @override
  String get market_server_already_installed => '服务器已安装';

  @override
  String get market_installing_server => '正在安装服务器...';

  @override
  String get market_install_error => '安装失败';

  @override
  String get analysis_step_title => '分析安装策略';

  @override
  String get analysis_step_subtitle => '正在分析MCP服务器配置...';

  @override
  String get analysis_step_result => '分析结果';

  @override
  String get analysis_step_install_type => '安装类型';

  @override
  String get analysis_step_install_method => '安装方式';

  @override
  String get analysis_step_status => '状态';

  @override
  String get analysis_step_manual_config => '需要手动配置';

  @override
  String get analysis_step_auto_install => '自动安装';

  @override
  String get analysis_step_analyzing => '正在分析配置...';

  @override
  String get analysis_step_auto_advancing => '正在自动切换到下一步...';

  @override
  String get analysis_step_install_type_uvx => 'UVX (Python包管理器)';

  @override
  String get analysis_step_install_type_npx => 'NPX (Node.js包管理器)';

  @override
  String get analysis_step_install_type_smithery => 'Smithery (MCP包管理器)';

  @override
  String get analysis_step_install_type_local_python => '本地Python包';

  @override
  String get analysis_step_install_type_local_jar => '本地JAR包';

  @override
  String get analysis_step_install_type_local_executable => '本地可执行文件';

  @override
  String get analysis_step_install_type_unknown => '未知类型';

  @override
  String get execution_step_title => '执行安装';

  @override
  String get execution_step_subtitle_completed => '安装已完成！';

  @override
  String get execution_step_subtitle_installing => '正在安装MCP服务器...';

  @override
  String get execution_step_subtitle_ready => '准备安装MCP服务器';

  @override
  String get execution_step_summary => '安装摘要';

  @override
  String get execution_step_server_name => '服务器名称';

  @override
  String get execution_step_unnamed => '未命名';

  @override
  String get execution_step_description => '描述';

  @override
  String get execution_step_install_type => '安装类型';

  @override
  String get execution_step_install_source => '安装源';

  @override
  String get execution_step_github_repo => 'GitHub仓库';

  @override
  String get execution_step_local_path => '本地路径';

  @override
  String get execution_step_install_logs => '安装日志';

  @override
  String get execution_step_waiting_install => '等待开始安装...';

  @override
  String get execution_step_cancel_install => '取消安装';

  @override
  String get execution_step_install_completed => '安装完成！';

  @override
  String get execution_step_server_list_hint => '您可以在服务器列表中启动该服务器';

  @override
  String get monitor_title => 'Hub 监控';

  @override
  String get monitor_hub_status => 'Hub状态';

  @override
  String get monitor_hub_running => 'Hub正在运行';

  @override
  String get monitor_hub_stopped => 'Hub未运行';

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
  String get monitor_connected_servers => '已连接服务器';

  @override
  String get monitor_system_info => '系统信息';

  @override
  String get monitor_protocol_version => '协议版本';

  @override
  String get monitor_app_version => '应用版本';

  @override
  String get monitor_runtime_mode => '运行模式';

  @override
  String get monitor_no_servers => '暂无已连接的服务器';

  @override
  String get monitor_refresh => '刷新';

  @override
  String get monitor_server_statistics => '服务器统计';

  @override
  String get monitor_total_label => '总计：';

  @override
  String get monitor_installed => '已安装';

  @override
  String get monitor_connected_servers_title => '已连接的服务器';

  @override
  String get monitor_no_connected_servers => '暂无已连接的服务器';

  @override
  String get monitor_system_information => '系统信息';

  @override
  String monitor_total_servers(int count) {
    return '总计: $count 个服务器';
  }

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
  String get server_monitor_mcp_config => 'MCP服务器配置';

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
  String get server_monitor_no_logs_level => '此级别暂无日志';

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
  String server_monitor_log_load_failed(String error) {
    return '加载日志失败: $error';
  }

  @override
  String get server_monitor_log_filter => '级别筛选: ';

  @override
  String server_monitor_operation_failed(String error) {
    return '操作失败: $error';
  }

  @override
  String get server_monitor_delete_confirm_title => '确认删除';

  @override
  String get server_monitor_delete_confirm_content => '确定要删除这个服务器吗？此操作不可撤销。';

  @override
  String get server_monitor_logs_cleared => '日志已清空';

  @override
  String server_monitor_clear_logs_failed(String error) {
    return '清空日志失败: $error';
  }

  @override
  String get server_monitor_export_logs_todo => '日志导出功能开发中';

  @override
  String server_monitor_export_logs_failed(String error) {
    return '导出日志失败: $error';
  }

  @override
  String get server_monitor_edit_todo => '编辑功能开发中';

  @override
  String server_card_details_title(String serverName) {
    return '服务器详情 - $serverName';
  }

  @override
  String server_card_delete_failed(String error) {
    return '删除失败: $error';
  }

  @override
  String get server_card_confirm_delete_title => '确认删除';

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
  String get settings_hub => 'Hub设置';

  @override
  String get settings_hub_mode => '运行模式';

  @override
  String get settings_hub_mode_sse => 'SSE模式 (单客户端)';

  @override
  String get settings_hub_mode_streamable => 'Streamable模式 (多客户端)';

  @override
  String get settings_hub_port => 'Streamable端口';

  @override
  String settings_hub_port_desc(String port) {
    return '多客户端模式使用的端口: $port';
  }

  @override
  String get settings_hub_port_invalid => '端口必须在1024-65535之间';

  @override
  String get settings_startup => '启动设置';

  @override
  String get settings_startup_auto => '开机自启动';

  @override
  String get settings_startup_auto_desc => '系统启动时自动启动应用';

  @override
  String get settings_startup_minimize => '最小化到系统托盘';

  @override
  String get settings_startup_minimize_desc => '关闭窗口时最小化到系统托盘';

  @override
  String get settings_logs => '日志设置';

  @override
  String get settings_log_level => '日志级别';

  @override
  String settings_log_level_desc(String level) {
    return '当前级别: $level';
  }

  @override
  String get settings_log_level_debug => '调试';

  @override
  String get settings_log_level_info => '信息';

  @override
  String get settings_log_level_warn => '警告';

  @override
  String get settings_log_level_error => '错误';

  @override
  String get settings_log_retention => '日志保留天数';

  @override
  String settings_log_retention_desc(String days) {
    return '自动删除 $days 天前的日志';
  }

  @override
  String get settings_download => '下载设置';

  @override
  String get settings_download_mirror => '使用中国大陆镜像源';

  @override
  String get settings_download_mirror_desc => '使用清华大学等国内镜像源加速包下载';

  @override
  String get settings_download_current_source => '当前镜像源';

  @override
  String get settings_download_mirror_advantages => '镜像源优势';

  @override
  String get settings_download_mirror_advantages_desc =>
      '• 下载速度提升 5-10 倍\n• 解决网络连接问题\n• 支持 Python 和 NPM 包';

  @override
  String get settings_download_official_pypi => '官方 PyPI';

  @override
  String get settings_download_tsinghua_pypi => '清华大学 PyPI 镜像';

  @override
  String get settings_download_official_npm => '官方 NPM';

  @override
  String get settings_download_taobao_npm => '淘宝 NPM 镜像';

  @override
  String get settings_maintenance => '维护';

  @override
  String get settings_clear_cache => '清理缓存';

  @override
  String get settings_clear_cache_desc => '清理临时文件和缓存数据';

  @override
  String get settings_clear_cache_button => '清理';

  @override
  String get settings_export_config => '导出配置';

  @override
  String get settings_export_config_desc => '导出服务器配置和应用设置';

  @override
  String get settings_export_config_button => '导出';

  @override
  String get settings_about => '关于';

  @override
  String get settings_version => '版本';

  @override
  String get settings_version_desc => 'MCP Hub v1.0.0';

  @override
  String get settings_check_update => '检查更新';

  @override
  String get settings_check_update_desc => '检查是否有新版本可用';

  @override
  String get settings_check_update_button => '检查';

  @override
  String get settings_open_source => '开源许可';

  @override
  String get settings_open_source_desc => '查看开源许可信息';

  @override
  String settings_mode_changed(String mode) {
    return '服务器模式已更改为: $mode';
  }

  @override
  String settings_mode_change_failed(String error) {
    return '更改服务器模式失败: $error';
  }

  @override
  String settings_port_changed(String port) {
    return 'Streamable端口已更改为: $port';
  }

  @override
  String settings_port_change_failed(String error) {
    return '更改端口失败: $error';
  }

  @override
  String get settings_restart_required_title => '需要重启';

  @override
  String get settings_restart_required_content => '服务器模式更改需要重启MCP Hub服务才能生效。';

  @override
  String get settings_restart_later => '稍后重启';

  @override
  String get settings_restart_now => '立即重启';

  @override
  String get settings_hub_restarted => 'MCP Hub服务重启成功';

  @override
  String settings_hub_restart_failed(String error) {
    return '重启Hub服务失败: $error';
  }

  @override
  String get settings_clear_cache_title => '清理缓存';

  @override
  String get settings_clear_cache_confirm => '确定要清理所有缓存数据吗？此操作不可撤销。';

  @override
  String get settings_confirm => '确定';

  @override
  String get settings_cache_cleared => '缓存清理完成';

  @override
  String get settings_export_todo => '配置导出功能开发中';

  @override
  String get settings_already_latest => '当前已是最新版本';

  @override
  String get settings_license_title => '开源许可';

  @override
  String get settings_runtime_mode => '运行模式';

  @override
  String get settings_multi_client_support => '支持多个客户端并发连接';

  @override
  String get settings_app_behavior => '应用行为';

  @override
  String get settings_log_settings => '日志设置';

  @override
  String get settings_download_settings => '下载设置';

  @override
  String get settings_storage_management => '存储管理';

  @override
  String get settings_system_information => '系统信息';

  @override
  String get settings_about_section => '关于';

  @override
  String get settings_single_client_mode => '只允许单个客户端连接';

  @override
  String get settings_single_client_help => '适合单一应用使用，性能更好，兼容性强';

  @override
  String get settings_multi_client_help => '适合多个应用同时连接，支持会话隔离，资源共享';

  @override
  String get splash_initializing => '正在初始化...';

  @override
  String get sidebar_collapse => '折叠侧边栏';

  @override
  String get sidebar_expand => '展开侧边栏';

  @override
  String get splash_init_runtime => '正在初始化运行时环境...';

  @override
  String get splash_init_process => '正在初始化进程管理器...';

  @override
  String get splash_init_database => '正在初始化数据库...';

  @override
  String get splash_init_hub => '正在启动MCP Hub服务器...';

  @override
  String get splash_init_complete => '初始化完成';

  @override
  String get splash_init_error => '初始化失败，继续...';

  @override
  String get config_show_title => '服务器配置';

  @override
  String get config_copy_success => '配置已复制到剪贴板';

  @override
  String get quick_actions_title => '快速操作';

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
  String get system_info_dart_version => 'Dart版本';

  @override
  String get system_info_flutter_version => 'Flutter版本';

  @override
  String get hub_monitor_title => 'MCP Hub 监控';

  @override
  String get hub_monitor_status => 'MCP Hub 状态';

  @override
  String get hub_monitor_running => '运行中';

  @override
  String get hub_monitor_stopped => '已停止';

  @override
  String get hub_monitor_port => '服务端口';

  @override
  String get hub_monitor_mode => '运行模式';

  @override
  String get hub_monitor_connected_servers => '连接的服务器';

  @override
  String get hub_monitor_available_tools => '可用工具数量';

  @override
  String get hub_monitor_service_address => '服务地址';

  @override
  String get hub_monitor_not_running => 'Hub 服务未运行';

  @override
  String get hub_monitor_debug_info => '调试信息';

  @override
  String get hub_monitor_server_statistics => '服务器统计';

  @override
  String get hub_monitor_connected_servers_list => '已连接服务器';

  @override
  String get hub_monitor_system_info => '系统信息';

  @override
  String get hub_monitor_unknown => '未知';

  @override
  String get hub_monitor_count_unit => ' 个';

  @override
  String get hub_monitor_tools_unit => ' 个';

  @override
  String get servers_quick_actions => '快速操作';

  @override
  String get servers_search_hint => '搜索服务器...';

  @override
  String get servers_description_hint => '通过安装向导添加的MCP服务器';

  @override
  String get servers_status_running => '运行中';

  @override
  String get servers_status_stopped => '已停止';

  @override
  String get servers_status_starting => '启动中';

  @override
  String get servers_status_stopping => '停止中';

  @override
  String get servers_status_error => '错误';

  @override
  String get servers_status_installing => '安装中';

  @override
  String get servers_status_uninstalling => '卸载中';

  @override
  String get servers_status_installed => '已安装';

  @override
  String get servers_status_not_installed => '未安装';

  @override
  String get servers_status_unknown => '未知';

  @override
  String get servers_more_options => '更多选项';

  @override
  String get servers_no_servers => '暂无服务器';

  @override
  String get servers_no_servers_found => '未找到匹配的服务器';

  @override
  String get servers_add_server_hint => '点击浮动按钮开始添加服务器';

  @override
  String get servers_load_error => '加载失败';

  @override
  String get servers_retry => '重试';

  @override
  String servers_starting_message(String serverName) {
    return '正在启动服务器: $serverName...';
  }

  @override
  String servers_stopping_message(String serverName) {
    return '正在停止服务器: $serverName...';
  }

  @override
  String servers_restarting_message(String serverName) {
    return '正在重启服务器: $serverName...';
  }
}
