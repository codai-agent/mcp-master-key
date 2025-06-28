import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'MCP Master Key'**
  String get appTitle;

  /// The subtitle of the application
  ///
  /// In en, this message translates to:
  /// **'Unified Management Center for MCP Servers'**
  String get appSubtitle;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get common_warning;

  /// No description provided for @common_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get common_info;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get common_copy;

  /// No description provided for @common_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get common_copied;

  /// No description provided for @nav_servers.
  ///
  /// In en, this message translates to:
  /// **'Server Management'**
  String get nav_servers;

  /// No description provided for @nav_install.
  ///
  /// In en, this message translates to:
  /// **'Install Server'**
  String get nav_install;

  /// No description provided for @nav_monitor.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get nav_monitor;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @servers_title.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get servers_title;

  /// No description provided for @servers_empty.
  ///
  /// In en, this message translates to:
  /// **'No servers configured yet'**
  String get servers_empty;

  /// No description provided for @servers_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Click the \'+\' button to add your first MCP server'**
  String get servers_empty_subtitle;

  /// No description provided for @servers_add.
  ///
  /// In en, this message translates to:
  /// **'Add Server'**
  String get servers_add;

  /// No description provided for @servers_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get servers_start;

  /// No description provided for @servers_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get servers_stop;

  /// No description provided for @servers_restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get servers_restart;

  /// No description provided for @servers_starting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get servers_starting;

  /// No description provided for @servers_stopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping'**
  String get servers_stopping;

  /// No description provided for @servers_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get servers_running;

  /// No description provided for @servers_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get servers_stopped;

  /// No description provided for @servers_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get servers_error;

  /// No description provided for @servers_show_config.
  ///
  /// In en, this message translates to:
  /// **'Show Config'**
  String get servers_show_config;

  /// No description provided for @servers_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this server?'**
  String get servers_delete_confirm;

  /// No description provided for @servers_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Server deleted successfully'**
  String get servers_delete_success;

  /// No description provided for @servers_start_success.
  ///
  /// In en, this message translates to:
  /// **'Server start request sent successfully'**
  String get servers_start_success;

  /// No description provided for @servers_stop_success.
  ///
  /// In en, this message translates to:
  /// **'Server stop request sent successfully'**
  String get servers_stop_success;

  /// No description provided for @install_title.
  ///
  /// In en, this message translates to:
  /// **'Install MCP Server'**
  String get install_title;

  /// No description provided for @install_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add new MCP servers to your collection'**
  String get install_subtitle;

  /// No description provided for @install_config_label.
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get install_config_label;

  /// No description provided for @install_config_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your MCP server configuration here...'**
  String get install_config_hint;

  /// No description provided for @install_config_empty.
  ///
  /// In en, this message translates to:
  /// **'Configuration cannot be empty'**
  String get install_config_empty;

  /// No description provided for @install_config_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON configuration'**
  String get install_config_invalid;

  /// No description provided for @install_install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install_install;

  /// No description provided for @install_installing.
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get install_installing;

  /// No description provided for @install_success.
  ///
  /// In en, this message translates to:
  /// **'Server installed successfully!'**
  String get install_success;

  /// No description provided for @install_error.
  ///
  /// In en, this message translates to:
  /// **'Installation failed'**
  String get install_error;

  /// No description provided for @monitor_title.
  ///
  /// In en, this message translates to:
  /// **'Hub Monitor'**
  String get monitor_title;

  /// No description provided for @monitor_hub_status.
  ///
  /// In en, this message translates to:
  /// **'Hub Status'**
  String get monitor_hub_status;

  /// No description provided for @monitor_hub_running.
  ///
  /// In en, this message translates to:
  /// **'Hub is running'**
  String get monitor_hub_running;

  /// No description provided for @monitor_hub_stopped.
  ///
  /// In en, this message translates to:
  /// **'Hub is not running'**
  String get monitor_hub_stopped;

  /// No description provided for @monitor_hub_port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get monitor_hub_port;

  /// No description provided for @monitor_hub_mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get monitor_hub_mode;

  /// No description provided for @monitor_hub_connected_servers.
  ///
  /// In en, this message translates to:
  /// **'Connected Servers'**
  String get monitor_hub_connected_servers;

  /// No description provided for @monitor_hub_available_tools.
  ///
  /// In en, this message translates to:
  /// **'Available Tools'**
  String get monitor_hub_available_tools;

  /// No description provided for @monitor_server_stats.
  ///
  /// In en, this message translates to:
  /// **'Server Statistics'**
  String get monitor_server_stats;

  /// No description provided for @monitor_servers_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get monitor_servers_running;

  /// No description provided for @monitor_servers_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get monitor_servers_stopped;

  /// No description provided for @monitor_servers_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get monitor_servers_error;

  /// No description provided for @monitor_servers_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get monitor_servers_total;

  /// No description provided for @monitor_connected_servers.
  ///
  /// In en, this message translates to:
  /// **'Connected Servers'**
  String get monitor_connected_servers;

  /// No description provided for @monitor_system_info.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get monitor_system_info;

  /// No description provided for @monitor_protocol_version.
  ///
  /// In en, this message translates to:
  /// **'Protocol Version'**
  String get monitor_protocol_version;

  /// No description provided for @monitor_app_version.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get monitor_app_version;

  /// No description provided for @monitor_runtime_mode.
  ///
  /// In en, this message translates to:
  /// **'Runtime Mode'**
  String get monitor_runtime_mode;

  /// No description provided for @monitor_no_servers.
  ///
  /// In en, this message translates to:
  /// **'No servers connected'**
  String get monitor_no_servers;

  /// No description provided for @monitor_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get monitor_refresh;

  /// No description provided for @server_monitor_title.
  ///
  /// In en, this message translates to:
  /// **'Server Monitor'**
  String get server_monitor_title;

  /// No description provided for @server_monitor_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get server_monitor_overview;

  /// No description provided for @server_monitor_config.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get server_monitor_config;

  /// No description provided for @server_monitor_logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get server_monitor_logs;

  /// No description provided for @server_monitor_stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get server_monitor_stats;

  /// No description provided for @server_monitor_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get server_monitor_status;

  /// No description provided for @server_monitor_uptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get server_monitor_uptime;

  /// No description provided for @server_monitor_pid.
  ///
  /// In en, this message translates to:
  /// **'Process ID'**
  String get server_monitor_pid;

  /// No description provided for @server_monitor_memory.
  ///
  /// In en, this message translates to:
  /// **'Memory Usage'**
  String get server_monitor_memory;

  /// No description provided for @server_monitor_env_vars.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get server_monitor_env_vars;

  /// No description provided for @server_monitor_mcp_config.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Configuration'**
  String get server_monitor_mcp_config;

  /// No description provided for @server_monitor_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get server_monitor_name;

  /// No description provided for @server_monitor_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get server_monitor_description;

  /// No description provided for @server_monitor_install_type.
  ///
  /// In en, this message translates to:
  /// **'Install Type'**
  String get server_monitor_install_type;

  /// No description provided for @server_monitor_connection_type.
  ///
  /// In en, this message translates to:
  /// **'Connection Type'**
  String get server_monitor_connection_type;

  /// No description provided for @server_monitor_command.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get server_monitor_command;

  /// No description provided for @server_monitor_args.
  ///
  /// In en, this message translates to:
  /// **'Arguments'**
  String get server_monitor_args;

  /// No description provided for @server_monitor_working_dir.
  ///
  /// In en, this message translates to:
  /// **'Working Directory'**
  String get server_monitor_working_dir;

  /// No description provided for @server_monitor_install_source.
  ///
  /// In en, this message translates to:
  /// **'Install Source'**
  String get server_monitor_install_source;

  /// No description provided for @server_monitor_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get server_monitor_version;

  /// No description provided for @server_monitor_auto_start.
  ///
  /// In en, this message translates to:
  /// **'Auto Start'**
  String get server_monitor_auto_start;

  /// No description provided for @server_monitor_log_level.
  ///
  /// In en, this message translates to:
  /// **'Log Level'**
  String get server_monitor_log_level;

  /// No description provided for @server_monitor_current_status.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get server_monitor_current_status;

  /// No description provided for @server_monitor_no_logs.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get server_monitor_no_logs;

  /// No description provided for @server_monitor_no_logs_level.
  ///
  /// In en, this message translates to:
  /// **'No logs available for this level'**
  String get server_monitor_no_logs_level;

  /// No description provided for @server_monitor_auto_scroll.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll'**
  String get server_monitor_auto_scroll;

  /// No description provided for @server_monitor_log_level_all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get server_monitor_log_level_all;

  /// No description provided for @server_monitor_log_level_error.
  ///
  /// In en, this message translates to:
  /// **'ERROR'**
  String get server_monitor_log_level_error;

  /// No description provided for @server_monitor_log_level_warn.
  ///
  /// In en, this message translates to:
  /// **'WARN'**
  String get server_monitor_log_level_warn;

  /// No description provided for @server_monitor_log_level_info.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get server_monitor_log_level_info;

  /// No description provided for @server_monitor_log_level_debug.
  ///
  /// In en, this message translates to:
  /// **'DEBUG'**
  String get server_monitor_log_level_debug;

  /// No description provided for @server_monitor_runtime_status.
  ///
  /// In en, this message translates to:
  /// **'Runtime Status'**
  String get server_monitor_runtime_status;

  /// No description provided for @server_monitor_time_tracking.
  ///
  /// In en, this message translates to:
  /// **'Time Tracking'**
  String get server_monitor_time_tracking;

  /// No description provided for @server_monitor_process_info.
  ///
  /// In en, this message translates to:
  /// **'Process Information'**
  String get server_monitor_process_info;

  /// No description provided for @server_monitor_tool_stats.
  ///
  /// In en, this message translates to:
  /// **'Tool Statistics'**
  String get server_monitor_tool_stats;

  /// No description provided for @server_monitor_connection_stats.
  ///
  /// In en, this message translates to:
  /// **'Connection Statistics'**
  String get server_monitor_connection_stats;

  /// No description provided for @server_monitor_performance_stats.
  ///
  /// In en, this message translates to:
  /// **'Performance Statistics'**
  String get server_monitor_performance_stats;

  /// No description provided for @server_monitor_config_stats.
  ///
  /// In en, this message translates to:
  /// **'Configuration Statistics'**
  String get server_monitor_config_stats;

  /// No description provided for @server_monitor_tools_count.
  ///
  /// In en, this message translates to:
  /// **'Tools Count'**
  String get server_monitor_tools_count;

  /// No description provided for @server_monitor_tools_list.
  ///
  /// In en, this message translates to:
  /// **'Tools List'**
  String get server_monitor_tools_list;

  /// No description provided for @server_monitor_connection_status.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get server_monitor_connection_status;

  /// No description provided for @server_monitor_error_info.
  ///
  /// In en, this message translates to:
  /// **'Error Information'**
  String get server_monitor_error_info;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settings_general;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_system.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settings_language_system;

  /// No description provided for @settings_language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @settings_language_zh.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get settings_language_zh;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_hub.
  ///
  /// In en, this message translates to:
  /// **'Hub Settings'**
  String get settings_hub;

  /// No description provided for @settings_hub_mode.
  ///
  /// In en, this message translates to:
  /// **'Hub Mode'**
  String get settings_hub_mode;

  /// No description provided for @settings_hub_mode_sse.
  ///
  /// In en, this message translates to:
  /// **'SSE Mode'**
  String get settings_hub_mode_sse;

  /// No description provided for @settings_hub_mode_streamable.
  ///
  /// In en, this message translates to:
  /// **'Streamable Mode'**
  String get settings_hub_mode_streamable;

  /// No description provided for @settings_hub_port.
  ///
  /// In en, this message translates to:
  /// **'Hub Port'**
  String get settings_hub_port;

  /// No description provided for @settings_download.
  ///
  /// In en, this message translates to:
  /// **'Download Settings'**
  String get settings_download;

  /// No description provided for @settings_download_mirror.
  ///
  /// In en, this message translates to:
  /// **'Use China Mainland Mirrors'**
  String get settings_download_mirror;

  /// No description provided for @settings_download_mirror_desc.
  ///
  /// In en, this message translates to:
  /// **'Enable to use Tsinghua PyPI and Taobao NPM mirrors for faster downloads in China'**
  String get settings_download_mirror_desc;

  /// No description provided for @settings_download_current_pypi.
  ///
  /// In en, this message translates to:
  /// **'Current PyPI Source'**
  String get settings_download_current_pypi;

  /// No description provided for @settings_download_current_npm.
  ///
  /// In en, this message translates to:
  /// **'Current NPM Source'**
  String get settings_download_current_npm;

  /// No description provided for @settings_download_official_pypi.
  ///
  /// In en, this message translates to:
  /// **'Official PyPI'**
  String get settings_download_official_pypi;

  /// No description provided for @settings_download_tsinghua_pypi.
  ///
  /// In en, this message translates to:
  /// **'Tsinghua PyPI Mirror'**
  String get settings_download_tsinghua_pypi;

  /// No description provided for @settings_download_official_npm.
  ///
  /// In en, this message translates to:
  /// **'Official NPM'**
  String get settings_download_official_npm;

  /// No description provided for @settings_download_taobao_npm.
  ///
  /// In en, this message translates to:
  /// **'Taobao NPM Mirror'**
  String get settings_download_taobao_npm;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get settings_build;

  /// No description provided for @settings_copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get settings_copyright;

  /// No description provided for @splash_initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get splash_initializing;

  /// No description provided for @splash_init_runtime.
  ///
  /// In en, this message translates to:
  /// **'Initializing runtime environment...'**
  String get splash_init_runtime;

  /// No description provided for @splash_init_process.
  ///
  /// In en, this message translates to:
  /// **'Initializing process manager...'**
  String get splash_init_process;

  /// No description provided for @splash_init_database.
  ///
  /// In en, this message translates to:
  /// **'Initializing database...'**
  String get splash_init_database;

  /// No description provided for @splash_init_hub.
  ///
  /// In en, this message translates to:
  /// **'Starting MCP Hub server...'**
  String get splash_init_hub;

  /// No description provided for @splash_init_complete.
  ///
  /// In en, this message translates to:
  /// **'Initialization complete'**
  String get splash_init_complete;

  /// No description provided for @splash_init_error.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed, continuing...'**
  String get splash_init_error;

  /// No description provided for @config_show_title.
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get config_show_title;

  /// No description provided for @config_copy_success.
  ///
  /// In en, this message translates to:
  /// **'Configuration copied to clipboard'**
  String get config_copy_success;

  /// No description provided for @quick_actions_title.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions_title;

  /// No description provided for @quick_actions_start_all.
  ///
  /// In en, this message translates to:
  /// **'Start All'**
  String get quick_actions_start_all;

  /// No description provided for @quick_actions_stop_all.
  ///
  /// In en, this message translates to:
  /// **'Stop All'**
  String get quick_actions_stop_all;

  /// No description provided for @quick_actions_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get quick_actions_refresh;

  /// No description provided for @system_info_platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get system_info_platform;

  /// No description provided for @system_info_architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get system_info_architecture;

  /// No description provided for @system_info_dart_version.
  ///
  /// In en, this message translates to:
  /// **'Dart Version'**
  String get system_info_dart_version;

  /// No description provided for @system_info_flutter_version.
  ///
  /// In en, this message translates to:
  /// **'Flutter Version'**
  String get system_info_flutter_version;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
